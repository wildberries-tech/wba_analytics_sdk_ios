//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import CoreData

protocol Storage {
    func addBatch(_ batch: Batch) throws
    func nextBatch() throws -> BatchModel?
    func removeBatch(with id: String) throws
}

final class StorageImpl: Storage {

    private enum Constants {
        static let logLabel = "StorageImpl"
    }

    private let logger: Logger
    private let jsonSerializer: JSONSerialization.Type
    private var coreDataStack: CoreDataStackProtocol

    init(
        logger: Logger,
        coreDataStack: CoreDataStackProtocol,
        jsonSerializer: JSONSerialization.Type = JSONSerialization.self
    ) {
        self.logger = logger
        self.jsonSerializer = jsonSerializer
        self.coreDataStack = coreDataStack
    }

    func addBatch(_ batch: Batch) throws {
        try transaction {
            let entity = BatchEntity(context: coreDataStack.context)
            entity.id = UUID().uuidString
            entity.createdAt = Date()

            guard JSONSerialization.isValidJSONObject(batch) else {
                throw StorageErrors.invalidJSON
            }

            let jsonData = try JSONSerialization.data(
                withJSONObject: batch,
                options: []
            )

            entity.data = String(decoding: jsonData, as: UTF8.self)
        }
    }

    func nextBatch() throws -> BatchModel? {
        try transaction {
            let context = coreDataStack.context

            let fetchRequest: NSFetchRequest<BatchEntity> = BatchEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BatchEntity.createdAt), ascending: true)]
            fetchRequest.fetchLimit = 1

            do {
                if let batchEntity = try context.fetch(fetchRequest).first {
                    // Проверяем валидность объекта
                    if batchEntity.isDeleted || batchEntity.managedObjectContext == nil {
                        logger.error(
                            Constants.logLabel,
                            "Fetched BatchEntity is invalid (fault/deleted/context nil)"
                        )
                        throw StorageErrors.entityNotFound
                    }
                    guard let id = batchEntity.id, let data = batchEntity.data else {
                        logger.error(
                            Constants.logLabel,
                            "BatchEntity has missing id or data"
                        )
                        throw StorageErrors.entityNotFound
                    }
                    let batch = try toBatch(data)
                    return BatchModel(id: id, batch: batch)
                } else {
                    return nil
                }
            } catch {
                logger.error(Constants.logLabel, "Error retrieving batch: \(error)")
                throw error
            }
        }
    }

    func removeBatch(with id: String) throws {
        try transaction {
            let context = coreDataStack.context
            let fetchRequest: NSFetchRequest<BatchEntity> = BatchEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(BatchEntity.id)) == %@", id)
            fetchRequest.fetchLimit = 1

            do {
                let batches = try context.fetch(fetchRequest)
                if let batchToDelete = batches.first {
                    // Проверяем валидность объекта
                    if batchToDelete.isDeleted || batchToDelete.managedObjectContext == nil {
                        logger.error(
                            Constants.logLabel,
                            "Batch to delete is already deleted or context is nil"
                        )
                        throw StorageErrors.entityNotFound
                    }
                    context.delete(batchToDelete)
                } else {
                    logger.error(
                        Constants.logLabel,
                        "Batch to delete not found for id: \(id)"
                    )
                    throw StorageErrors.entityNotFound
                }
            } catch {
                logger.error(Constants.logLabel, "Error deleting batch: \(error)")
                throw StorageErrors.deleteError(error)
            }
        }
    }

    private func toBatch(_ jsonString: String?) throws -> Batch {
        guard let jsonString = jsonString else {
            throw StorageErrors.invalidJSON
        }
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw StorageErrors.invalidJSON
        }
        if let batch = try JSONSerialization.jsonObject(with: jsonData, options: []) as? Batch {
            return batch
        } else {
            throw StorageErrors.castingToDictionaryFailed
        }
    }

    @discardableResult
    private func transaction<T>(block: () throws -> T) throws -> T {
        var result: Result<T, Error> = .failure(StorageErrors.emptyValue)
        coreDataStack.context.performAndWait {
            do {
                result = .success(try block())
                if coreDataStack.context.hasChanges {
                    try coreDataStack.context.save()
                }
            } catch {
                logger.error(Constants.logLabel, "transaction error: \(error)")
                coreDataStack.context.rollback()
                result = .failure(error)
            }
        }
        return try result.get()
    }
}

private enum StorageErrors: Error {
    case entityNotFound
    case emptyValue
    case castingToDictionaryFailed
    case invalidJSON
    case saveError(Error)
    case deleteError(Error)
}

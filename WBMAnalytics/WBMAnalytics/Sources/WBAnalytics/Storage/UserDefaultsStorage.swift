// Copyright © 2021 Wildberries. All rights reserved.

import Foundation

protocol UserDefaultsStorage {
    func loadBatches() -> [BatchModel]
    func save(batches: [BatchModel]) throws
}

final class UserDefaultsStorageImpl: UserDefaultsStorage {

    private enum Constants {
        static let logLabel = "Storage"
        static let analyticsFilename = "wbanalytics_pending_batches.json"
        static let successfullySentInBackground = "successfullySentInBackground"
    }

    private let defaults: UserDefaults?
    private let apiKey: String
    private let logger: Logger
    private let jsonSerializer: JSONSerialization.Type
    private let fileManager: FileManagerProtocol

    private lazy var pendingBatchesFileURL: URL = {
        let baseURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
        return baseURL.appendingPathComponent(pendingBatchesFilename)
    }()

    private var pendingBatchesFilename: String {
        "\(apiKey)_\(Constants.analyticsFilename)"
    }

    private var successfullySentInBackgroundBatchesIds: [String] {
        get {
            return (defaults?.value(forKey: Constants.successfullySentInBackground) as? [String]) ?? []
        }
        set {
            defaults?.set(newValue, forKey: Constants.successfullySentInBackground)
        }
    }

    init(
        apiKey: String,
        logger: Logger,
        defaults: UserDefaults?,
        fileManager: FileManagerProtocol = FileManager.default,
        jsonSerializer: JSONSerialization.Type = JSONSerialization.self
    ) {
        self.apiKey = apiKey
        self.logger = logger
        self.defaults = defaults
        self.fileManager = fileManager
        self.jsonSerializer = jsonSerializer

        migrateOldPendingBatchesIfNeeded()
    }

    func addSuccessfullySentInBackgroundBatch(id: String) {
        successfullySentInBackgroundBatchesIds.append(id)
    }

    func loadBatches() -> [BatchModel] {

        guard let data = try? Data(contentsOf: pendingBatchesFileURL) else {
            logger.debug(Constants.logLabel, "cannot get file url: \(pendingBatchesFileURL)")
            return []
        }
        guard let savedBatches = (try? jsonSerializer.jsonObject(with: data)) as? [String: Batch] else {
            logger.debug(Constants.logLabel, "no batches in storage")
            return []
        }

        let successfullySentIds = successfullySentInBackgroundBatchesIds
        let batches = savedBatches.filter { !successfullySentIds.contains($0.key) }
        successfullySentInBackgroundBatchesIds = []
        logger.debug(Constants.logLabel, "loaded batches: \(batches)")
        return batches.map {
            BatchModel(id: $0.key, batch: $0.value)
        }
    }

    func save(batches: [BatchModel]) throws {
         logger.debug(Constants.logLabel, "save batches: \(batches), count: \(batches.count)")
         let batchesJson = batches.reduce(into: [String: Batch]()) { $0[$1.id] = $1.batch }
         guard let data = try? jsonSerializer.data(withJSONObject: batchesJson) else {
             logger.error(
                 Constants.logLabel,
                 "failed to serialize batches: \(batchesJson), count: \(batchesJson.count)"
             )
             throw StorageErrors.serializationError
         }

         do {
             try data.write(to: pendingBatchesFileURL)
         } catch {
             logger.error(
                 Constants.logLabel,
                 "failed to write batches: \(batchesJson), count: \(batchesJson.count)"
             )
             throw StorageErrors.saveError
         }
     }

    enum StorageErrors: Error, CustomStringConvertible {
        case serializationError
        case saveError

        var description: String {
            switch self {
            case .serializationError:
                return "An error occurred while serializing data."
            case .saveError:
                return "An error occurred while saving data."
            }
        }
    }
}

private extension UserDefaultsStorageImpl {
    // Additional migration function
        private func migrateOldPendingBatchesIfNeeded() {
            let baseURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
            let oldFileURL = baseURL.appendingPathComponent(Constants.analyticsFilename)

            guard fileManager.fileExists(atPath: oldFileURL.path) else { return }

            logger.debug(Constants.logLabel, "Found old pending batches file, starting migration.")

            do {
                try fileManager.copyItem(at: oldFileURL, to: pendingBatchesFileURL)
                try fileManager.removeItem(at: oldFileURL)
                logger.debug(Constants.logLabel, "Successfully migrated old pending batches file.")
            } catch {
                logger.error(Constants.logLabel, "Failed to migrate old pending batches file: \(error)")
            }
        }

}

private enum StorageErrors: Error {
    case serializationError
    case saveError
}

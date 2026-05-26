//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol {
    var context: NSManagedObjectContext { get }
    var container: NSPersistentContainer { get }
}

final class CoreDataStack: CoreDataStackProtocol {

    enum Constants {
        static let logLabel = "CoreDataStack"
    }

    // MARK: Static

    static let managedObjectModel = {
        let model = NSManagedObjectModel()
        model.entities = [BatchEntity.schema]
        model.localizationDictionary = [:]
        return model
    }()

    // MARK: Properties

    private let apiKey: String
    private let logger: Logger

    // Инициализация с конкретным apiKey
    init(apiKey: String, logger: Logger) {
        self.apiKey = apiKey
        self.logger = logger
    }

    // Получаем контекст для работы с данными
    private(set) lazy var context: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        return context
    }()

    private(set) lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BatchEntityModel", managedObjectModel: CoreDataStack.managedObjectModel)

        let description = NSPersistentStoreDescription(url: storeURL())
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { [logger] storeDescription, error in
            if let error = error {
                logger.error(Constants.logLabel, "Failed to load persistent store: $\(error)")
                DeviceMemoryState.setState(.noMemory)
            } else {
                logger.info(Constants.logLabel, "Persistent store loaded: \(storeDescription)")
            }
        }

        return container
    }()

    // Генерируем уникальный путь для базы данных для каждого apiKey
    private func storeURL() -> URL {
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
        ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return directoryURL.appendingPathComponent("\(apiKey)_wbanalytics_batches.sqlite")
    }
}

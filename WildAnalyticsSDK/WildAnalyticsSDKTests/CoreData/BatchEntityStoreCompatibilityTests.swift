//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import CoreData

@testable import WildAnalyticsSDK

/// Проверяет, что хранилище, созданное предыдущей версией SDK, читается текущей версией
/// без model migration после отказа от `@objc(BatchEntity)`.
final class BatchEntityStoreCompatibilityTests: XCTestCase {

    private var storeURL: URL!

    override func setUp() {
        super.setUp()
        storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("compat_\(UUID().uuidString).sqlite")
    }

    override func tearDown() {
        for suffix in ["", "-wal", "-shm"] {
            let url = URL(fileURLWithPath: storeURL.path + suffix)
            try? FileManager.default.removeItem(at: url)
        }
        storeURL = nil
        super.tearDown()
    }

    /// Модель в том виде, в котором её строила предыдущая версия SDK: имя класса —
    /// захардкоженная строка без префикса модуля.
    private func legacyModel() -> NSManagedObjectModel {
        makeModel(entityName: "BatchEntity", managedObjectClassName: "BatchEntity")
    }

    private func makeModel(entityName: String, managedObjectClassName: String) -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = managedObjectClassName

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .stringAttributeType
        idAttribute.isOptional = true

        let dataAttribute = NSAttributeDescription()
        dataAttribute.name = "data"
        dataAttribute.attributeType = .stringAttributeType
        dataAttribute.isOptional = true

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = true

        entity.properties = [idAttribute, dataAttribute, createdAtAttribute]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        model.localizationDictionary = [:]
        return model
    }

    /// Префикс в *имени сущности* делает хранилище предыдущей версии нечитаемым: имя
    /// сущности участвует в метаданных хранилища и в version hash.
    /// Поэтому изоляцию копий SDK нельзя строить на `entity.name`.
    func testPrefixInEntityNameBreaksExistingStore() throws {
        // given: хранилище, записанное текущей схемой (сущность называется "BatchEntity")
        let writer = NSPersistentStoreCoordinator(managedObjectModel: legacyModel())
        let store = try writer.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )
        try writer.remove(store)

        // when: модель, где к имени сущности добавлен префикс
        let prefixed = makeModel(
            entityName: "HostApp_BatchEntity",
            managedObjectClassName: NSStringFromClass(BatchEntity.self)
        )
        let reader = NSPersistentStoreCoordinator(managedObjectModel: prefixed)

        // then: Core Data отказывается открыть хранилище
        XCTAssertThrowsError(
            try reader.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: nil
            ),
            "переименование сущности должно ломать совместимость хранилища"
        ) { error in
            XCTAssertEqual(
                (error as NSError).code,
                NSPersistentStoreIncompatibleVersionHashError
            )
        }
    }

    /// Имя сущности живёт внутри своей модели, а не в глобальном пространстве процесса:
    /// две копии SDK могут одновременно держать сущность "BatchEntity" без конфликта.
    func testTwoModelsCanShareEntityNameSimultaneously() throws {
        let first = NSPersistentStoreCoordinator(managedObjectModel: legacyModel())
        let second = NSPersistentStoreCoordinator(managedObjectModel: makeModel(
            entityName: "BatchEntity",
            managedObjectClassName: NSStringFromClass(BatchEntity.self)
        ))

        try first.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        try second.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        XCTAssertNotNil(first.managedObjectModel.entitiesByName["BatchEntity"])
        XCTAssertNotNil(second.managedObjectModel.entitiesByName["BatchEntity"])
    }

    /// Version hash считается по имени сущности и её атрибутам, но не по имени класса.
    /// Совпадение хэшей означает, что Core Data считает хранилище совместимым и migration
    /// не потребуется.
    func testVersionHashesAreUnchanged() {
        XCTAssertEqual(
            legacyModel().entityVersionHashesByName,
            CoreDataStack.managedObjectModel.entityVersionHashesByName
        )
    }

    /// Сквозная проверка апгрейда: пишем хранилище старой моделью, читаем новой.
    func testStoreWrittenByPreviousVersionIsReadable() throws {
        // given: хранилище на диске, созданное предыдущей версией SDK
        let legacyCoordinator = NSPersistentStoreCoordinator(managedObjectModel: legacyModel())
        let legacyStore = try legacyCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )

        let legacyContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        legacyContext.persistentStoreCoordinator = legacyCoordinator

        let createdAt = Date()
        var saveError: Error?
        legacyContext.performAndWait {
            let object = NSEntityDescription.insertNewObject(
                forEntityName: "BatchEntity",
                into: legacyContext
            )
            object.setValue("legacy-id", forKey: "id")
            object.setValue("{\"events\":[]}", forKey: "data")
            object.setValue(createdAt, forKey: "createdAt")
            do {
                try legacyContext.save()
            } catch {
                saveError = error
            }
        }
        if let saveError = saveError {
            throw saveError
        }

        // Полностью отпускаем файл, чтобы новая версия открыла его с нуля
        try legacyCoordinator.remove(legacyStore)

        // when: то же хранилище открывает текущая версия
        let container = NSPersistentContainer(
            name: "BatchEntityModel",
            managedObjectModel: CoreDataStack.managedObjectModel
        )
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        XCTAssertNil(loadError, "хранилище предыдущей версии должно открываться без ошибок")

        // then: строка читается и приводится к BatchEntity текущего модуля
        // (именно этот мост NSArray -> [BatchEntity] падал при конфликте имён классов)
        let request: NSFetchRequest<BatchEntity> = BatchEntity.fetchRequest()
        let batches = try container.viewContext.fetch(request)

        XCTAssertEqual(batches.count, 1)
        XCTAssertEqual(batches.first?.id, "legacy-id")
        XCTAssertEqual(batches.first?.data, "{\"events\":[]}")
        XCTAssertEqual(
            batches.first?.createdAt?.timeIntervalSince1970 ?? 0,
            createdAt.timeIntervalSince1970,
            accuracy: 0.001
        )
    }
}

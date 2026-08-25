//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import CoreData

@testable import WildAnalyticsSDK

/// Verifies that a store created by a previous version of the SDK can be read by the
/// current version without a model migration after dropping `@objc(BatchEntity)`.
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

    /// The model exactly as the previous version of the SDK built it: the class name is
    /// a hardcoded string with no module prefix.
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

    /// A prefix in the *entity name* makes the previous version's store unreadable: the
    /// entity name is part of the store metadata and the version hash.
    /// That's why isolation between SDK copies can't be built on `entity.name`.
    func testPrefixInEntityNameBreaksExistingStore() throws {
        // given: a store written with the current schema (entity named "BatchEntity")
        let writer = NSPersistentStoreCoordinator(managedObjectModel: legacyModel())
        let store = try writer.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )
        try writer.remove(store)

        // when: a model with a prefix added to the entity name
        let prefixed = makeModel(
            entityName: "HostApp_BatchEntity",
            managedObjectClassName: NSStringFromClass(BatchEntity.self)
        )
        let reader = NSPersistentStoreCoordinator(managedObjectModel: prefixed)

        // then: Core Data refuses to open the store
        XCTAssertThrowsError(
            try reader.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: nil
            ),
            "renaming the entity should break store compatibility"
        ) { error in
            XCTAssertEqual(
                (error as NSError).code,
                NSPersistentStoreIncompatibleVersionHashError
            )
        }
    }

    /// The entity name lives inside its own model rather than in a global process-wide
    /// namespace: two copies of the SDK can simultaneously hold a "BatchEntity" entity
    /// without conflict.
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

    /// The version hash is computed from the entity name and its attributes, but not from
    /// the class name. Matching hashes mean Core Data considers the store compatible and
    /// no migration will be required.
    func testVersionHashesAreUnchanged() {
        XCTAssertEqual(
            legacyModel().entityVersionHashesByName,
            CoreDataStack.managedObjectModel.entityVersionHashesByName
        )
    }

    /// End-to-end upgrade check: write the store with the old model, read it with the new one.
    func testStoreWrittenByPreviousVersionIsReadable() throws {
        // given: a store on disk, created by a previous version of the SDK
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

        // Fully release the file so the new version opens it from scratch
        try legacyCoordinator.remove(legacyStore)

        // when: the current version opens the same store
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
        XCTAssertNil(loadError, "a store from a previous version should open without errors")

        // then: the row is read back and cast to this module's BatchEntity
        // (this exact NSArray -> [BatchEntity] bridge is what crashed on class name conflicts)
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

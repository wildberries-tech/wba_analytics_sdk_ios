//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import CoreData

@testable import WildAnalyticsSDK

final class StorageImplTests: XCTestCase {

    private var storage: StorageImpl!
    private var loggerMock: LoggerMock!
    private var coreDataStackMock: CoreDataStackMock!
    private var jsonSerializerMock: JSONSerializationMock.Type!

    override func setUp() {
        super.setUp()
        jsonSerializerMock = JSONSerializationMock.self
        coreDataStackMock = .init()
        loggerMock = .init()

        // Set the context on the mock
        let container = NSPersistentContainer(name: "BatchEntityModel", managedObjectModel: CoreDataStack.managedObjectModel)
        // Configure the in-memory store
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        // Load the persistent stores
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load the store: \(error)")
            }
        }
        // Set the mock
        coreDataStackMock.containerGetStub = container

        storage = StorageImpl(
            logger: loggerMock,
            coreDataStack: coreDataStackMock,
            jsonSerializer: jsonSerializerMock
        )
    }

    override func tearDown() {
        jsonSerializerMock.reset()
        super.tearDown()
    }

    func testAddBatch() throws {
        // given
        jsonSerializerMock.dataStub = TestData.batchData

        // when
        do {
            try storage.addBatch(TestData.batch)
        } catch {
            XCTFail("Error adding record: \(error)")
        }

        // then
        XCTAssertEqual(coreDataStackMock.contextGetWasCalled, 4, "Context was not obtained")

        // Check that a record exists in the context
        let fetchRequest: NSFetchRequest<BatchEntity> = BatchEntity.fetchRequest()
        let fetchedEntities = try coreDataStackMock.context.fetch(fetchRequest)

        // Check that exactly one record was added
        XCTAssertEqual(fetchedEntities.count, 1, "Record was not added.")
        // Check the content of the added record
        let fetchedEntity = try XCTUnwrap(fetchedEntities.first)
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity.data, TestData.batchString)
        XCTAssertEqual(fetchedEntity.id?.isEmpty, false)
        XCTAssertNotNil(fetchedEntity.createdAt)
        XCTAssertLessThan(abs(fetchedEntity.createdAt!.timeIntervalSince1970 - Date().timeIntervalSince1970), 1)
    }

    func testAddBatchInvalidJson() throws {
        // given
        jsonSerializerMock.dataStub = TestData.batchData

        // when
        do {
            try storage.addBatch(TestData.batchInvalidJson)
        } catch {
            switch String(describing: error) {
               case let str where str.contains("invalidJSON"):
                   // Error of the expected type
                   break
               default:
                   XCTFail("Expected an invalidJSON error, got \(error)")
               }
        }

    }

    func testsNextBatch() throws {
        // given
        jsonSerializerMock.dataStub = TestData.batchData
        do {
            try storage.addBatch(TestData.batch)
        } catch {
            XCTFail("Error adding record: \(error)")
        }

        // when
        let model = try storage.nextBatch()
        // then
        XCTAssertEqual(model?.batch as? [String: Int], TestData.batch)
    }

    func testsRemoveBatch() throws {
        // given
        jsonSerializerMock.dataStub = TestData.batchData
        do {
            try storage.addBatch(TestData.batch)
        } catch {
            XCTFail("Error adding record: \(error)")
        }
        let model = try storage.nextBatch()
        // when
        do {
            try storage.removeBatch(with: model!.id)
        } catch {
            XCTFail("Error remove batch: \(error)")
        }
        // then
        // Check that a record exists in the context
        let fetchRequest: NSFetchRequest<BatchEntity> = BatchEntity.fetchRequest()
        let fetchedEntities = try coreDataStackMock.context.fetch(fetchRequest)
        XCTAssertEqual(fetchedEntities.count, 0, "Record was not added.")
    }
}

private extension StorageImplTests {
    enum TestData {
        static let batch: [String: Int] = ["123": 321]
        static let batchInvalidJson: [String: Any] = ["123": RandomStruct()]
        static let batchString = "{\"123\":321}"
        static let batchData = Data(batchString.utf8)
    }

    private struct RandomStruct {
    }

    enum CustomError: Error {
        case random
    }
}

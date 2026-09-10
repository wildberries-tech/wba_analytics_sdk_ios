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

    func testsNextBatchKeepsDecimalFormOfFractionalNumbers() throws {
        // given: 2.65 is not representable in binary floating point. Parsing JSON yields a Double,
        // and without normalization it serializes back as 2.6499999999999999
        let batch: Batch = ["cpu": 2.65]
        try storage.addBatch(batch)
        // when
        let model = try storage.nextBatch()
        let reserialized = try JSONSerialization.data(withJSONObject: XCTUnwrap(model?.batch))
        // then
        let json = try XCTUnwrap(String(data: reserialized, encoding: .utf8))
        XCTAssertEqual(json, #"{"cpu":2.65}"#)
    }

    func testsNextBatchKeepsIntegersAndBoolsIntact() throws {
        // given
        let batch: Batch = ["ram": 32, "flag": true, "name": "foreground"]
        try storage.addBatch(batch)
        // when
        let model = try storage.nextBatch()
        // then: normalization must not turn integers into fractions, nor booleans into numbers
        XCTAssertEqual(model?.batch["ram"] as? Int, 32)
        XCTAssertEqual(model?.batch["flag"] as? Bool, true)
        XCTAssertEqual(model?.batch["name"] as? String, "foreground")
    }

    func testsNextBatchNormalizesNestedAndArrayValues() throws {
        // given: events live in an array inside the batch, so normalization has to be recursive
        let batch: Batch = ["events": [["cpu": 0.533], ["cpu": 4.26]]]
        try storage.addBatch(batch)
        // when
        let model = try storage.nextBatch()
        let reserialized = try JSONSerialization.data(withJSONObject: XCTUnwrap(model?.batch))
        // then
        let json = try XCTUnwrap(String(data: reserialized, encoding: .utf8))
        XCTAssertEqual(json, #"{"events":[{"cpu":0.533},{"cpu":4.26}]}"#)
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

//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class BatchTests: XCTestCase {

    private var batch: Batch!

    override func setUp() {
        super.setUp()

        batch = Batch(
            meta: [TestData.metaKey: 1],
            batchNum: TestData.batchNum,
            events: [TestData.events]
        )
    }

    // MARK: init

    func testInit() {
        // then
        XCTAssertEqual(
            (batch[TestData.metaKey] as? [String: Any])?[TestData.batchNumKey] as? Int,
            TestData.batchNum
        )
        XCTAssertEqual(
            (batch[TestData.eventsKey] as? [[String: Int]]),
            [TestData.events]
        )
    }

    // MARK: isSplittable

    func testNotSplittable() {
        // then
        XCTAssertFalse(batch.isSplittable)
    }

    func testSplittable() {
        // when
        let batch = Batch(
            meta: [TestData.metaKey: 1],
            batchNum: TestData.batchNum,
            events: [TestData.events, TestData.events]
        )
        // then
        XCTAssertTrue(batch.isSplittable)
    }

    // MARK: splittedEvents

    func testIsNotSplittedEvents() {
        let batch = Batch(
            meta: [TestData.metaKey: 1],
            batchNum: TestData.batchNum,
            events: [TestData.events]
        )
        // then
        XCTAssertEqual(batch.splittedEvents as? [[[String: Int]]], [[TestData.events]])
    }

    func testIsSplittedEvents() {
        let batch = Batch(
            meta: [TestData.metaKey: 1],
            batchNum: TestData.batchNum,
            events: [TestData.events, TestData.events, TestData.events]
        )
        // then
        XCTAssertEqual(
            batch.splittedEvents as? [[[String: Int]]],
            [[TestData.events], [TestData.events, TestData.events]]
        )
    }
}

private extension BatchTests {
    enum TestData {
        static let batchNumKey: String = "batch_num"
        static let eventsKey: String = "events"
        static let metaKey: String = "meta"
        static let events: [String: Int] = ["event": 3]
        static let batchNum = 2
    }
}

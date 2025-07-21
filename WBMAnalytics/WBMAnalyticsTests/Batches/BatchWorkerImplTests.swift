//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class BatchWorkerImplTests: XCTestCase {

    private var worker: BatchWorkerImpl!
    private var queueMock: DispatcherMock!
    private var batchConfig: BatchConfig!

    override func setUp() {
        queueMock = .init()
        batchConfig = BatchConfig()
        worker = .init(queue: queueMock, batchConfig: batchConfig)
    }

    // MARK: - sendBatchDelayed

    func testSetStateSendBatchDelayed() {
        // given
        // then
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        XCTAssertEqual(queueMock.asyncAfterReceivedFlags, [])
        XCTAssertEqual(queueMock.asyncAfterWasCalled, 1)
        XCTAssertEqual(queueMock.asyncAfterReceivedQoS, .unspecified)
    }

    func testChangeStateSendBatchDelayed() {
        // given
        var eventWasCalled = 0
        let event = { eventWasCalled += 1 }
        worker.sendBatchDelayed(id: TestData.id, event: event)
        // then
        queueMock.asyncAfterReceivedWork?()
        // then
        XCTAssertEqual(eventWasCalled, 1)
    }

    func testDeadlineFirstSendBatchDelayed() {
        // given
        let time = (.now() + batchConfig.sendingDelay).uptimeNanoseconds
        let tolerance: UInt64 = 1_000_000 // 1 миллисекунда
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        XCTAssert(
            abs(Int64((queueMock.asyncAfterReceivedDeadline?.uptimeNanoseconds ?? 0) - time)) <= UInt64(tolerance)
        )
    }

    func testDeadlineCount2SendBatchDelayed() {
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        let deltaSecond = (
            queueMock.asyncAfterReceivedDeadline?.seconds ?? 0
        ) - DispatchTime.now().seconds
        XCTAssertEqual(
            String(format: "%.1f", deltaSecond),
            TestData.count2
        )
    }

    func testDeadlineCount3SendBatchDelayed() {
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        let deltaSecond = (
            queueMock.asyncAfterReceivedDeadline?.seconds ?? 0
        ) - DispatchTime.now().seconds
        XCTAssertEqual(
            String(format: "%.1f", deltaSecond),
            TestData.count3
        )
    }

    func testDeadlineCount4SendBatchDelayed() {
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        let deltaSecond = (
            queueMock.asyncAfterReceivedDeadline?.seconds ?? 0
        ) - DispatchTime.now().seconds
        XCTAssertEqual(
            String(format: "%.1f", deltaSecond),
            TestData.count4
        )
    }

    func testDeadlineCount5SendBatchDelayed() {
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        let deltaSecond = (
            queueMock.asyncAfterReceivedDeadline?.seconds ?? 0
        ) - DispatchTime.now().seconds
        XCTAssertEqual(
            String(format: "%.1f", deltaSecond),
            TestData.count5
        )
    }

    func testDeadlineCount10SendBatchDelayed() {
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        let deltaSecond = (
            queueMock.asyncAfterReceivedDeadline?.seconds ?? 0
        ) - DispatchTime.now().seconds
        XCTAssertEqual(
            String(format: "%.1f", deltaSecond),
            TestData.count10
        )
    }

    func testDeadlineCount11SendBatchDelayed() {
        // given
        let time = (.now() + batchConfig.sendingDelay).uptimeNanoseconds
        let tolerance: UInt64 = 3_000_000 // 3 миллисекунды
        // when
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        worker.sendBatchDelayed(id: TestData.id, event: {})
        // then
        XCTAssert(
            abs(Int64((queueMock.asyncAfterReceivedDeadline?.uptimeNanoseconds ?? 0) - time)) <= UInt64(tolerance)
        )
    }
}

private extension BatchWorkerImplTests {
    enum TestData {
        static let id = "123"
        static let count2 = "4.7"
        static let count3 = "5.9"
        static let count4 = "7.6"
        static let count5 = "10.1"
        static let count10 = "60.2"
    }
}

private extension BatchWorkerImplTests {

    final class Mirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: BatchWorkerImpl) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var batch: BatchWorkerImpl.SendBatch? { extract() }
    }
}

private extension DispatchTime {
    var seconds: Double {
        return Double(self.uptimeNanoseconds) / 1_000_000_000.0
    }
}

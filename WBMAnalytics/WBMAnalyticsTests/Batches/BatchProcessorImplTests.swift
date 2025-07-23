//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import SQLite3

@testable import WBMAnalytics

// swiftlint:disable type_body_length
// swiftlint:disable file_length
final class BatchProcessorImplTests: XCTestCase {

    private var batchProcessor: BatchProcessorImpl!
    private var storageMock: StorageMock!
    private var userStorageMock: UserDefaultsStorageMock!
    private var batchWorkerMock: BatchWorkerMock!
    private var loggerMock: LoggerMock!
    private var counterMock: EnumerationCounterMock!
    private var batchSenderMock: BatchSenderMock!
    private var networkProviderMock: NetworkTypeProviderMock!
    private var dispatchMock: DispatcherMock!
    private var jsonSerializerMock: JSONSerializationMock.Type!

    override func setUp() {
        super.setUp()

        storageMock = StorageMock()
        loggerMock = LoggerMock()
        jsonSerializerMock = JSONSerializationMock.self
        counterMock = .init()
        batchWorkerMock = .init()
        batchSenderMock = .init()
        dispatchMock = .init()
        networkProviderMock = .init()
        userStorageMock = .init()
        batchProcessor = BatchProcessorImpl(
            logger: loggerMock,
            storage: storageMock,
            userDefaultsStorage: userStorageMock,
            batchSender: batchSenderMock,
            jsonSerializer: jsonSerializerMock
        )
        networkProviderMock.getCurrentNetworkTypeStub = .cellular2G
        jsonSerializerMock.dataStub = TestData.data
    }

    override func tearDown() {
        DeviceMemoryState.setState(.normal)
        jsonSerializerMock.reset()
        super.tearDown()
    }

    // MARK: Init

    func testDefaultInit() {
        // given
        let batchProcessor = BatchProcessorImpl(
            logger: loggerMock,
            storage: storageMock,
            userDefaultsStorage: userStorageMock
        )
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        // then
        XCTAssertNil(mirror.batchSender)
    }

    func testDefaultInitProperty() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        // then
        XCTAssertFalse(mirror.isNewLaunch)
        XCTAssertTrue(mirror.batches.isEmpty)
        if case .normal = mirror.state {
            XCTAssert(true)
        } else {
            XCTFail("Default value state equal needRetrain")
        }
    }

    // MARK: Setup

    func testSetPropertySetup() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        // when
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        // then
        XCTAssertIdentical(
            mirror.networkTypeProvider as? NetworkTypeProviderMock,
            networkProviderMock
        )
        XCTAssertIdentical(
            mirror.counter as? EnumerationCounterMock,
            counterMock
        )
        XCTAssertIdentical(mirror.queue, dispatchMock)
        XCTAssertIdentical(mirror.batchSender, batchSenderMock)
        XCTAssertIdentical(mirror.storage as? StorageMock, storageMock)
        XCTAssertIdentical(mirror.batchWorker as? BatchWorkerMock, batchWorkerMock)
    }

    func testSetDeviceStateSetup() {
        // given
        DeviceMemoryState.setState(.noMemory)
        // when
        batchProcessor.setup(
            batchSender: BatchSenderMock(),
            queue: dispatchMock,
            networkTypeProvider: NetworkTypeProviderMock(),
            counter: EnumerationCounterMock(),
            batchWorker: batchWorkerMock
        )
        // then
        XCTAssertEqual(DeviceMemoryState.state, .normal)
    }

    func testSetBatchesSetup() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.addBatch(withEvents: [TestData.event])
        // when
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        // then
        XCTAssertTrue(mirror.batches.isEmpty)
    }

    // MARK: - launch

    func testLaunch() {
        // given
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        // when
        batchProcessor.launch()
        // then
        XCTAssertEqual(loggerMock.debugReceivedMessage, "batches storage is empty")
    }

    func testIsSendingLaunch() {
        // given
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        storageMock.nextBatchStub = TestData.nextBatch
        // when
        batchProcessor.launch()
        batchProcessor.launch()
        // then
        XCTAssertEqual(loggerMock.debugReceivedMessage, "batch sending proccess in progress...")
    }

    // MARK: SendEventSync

    func testSendEventSync() {
        // given
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        // mocks
        var completionWasCalled = 0
        var completionReceivedArgument: Bool?
        let completion: (_ successfully: Bool) -> Void  = { result in
            completionReceivedArgument = result
            completionWasCalled += 1
            print("Все")
        }
        // when
        batchProcessor.sendEventSync(event: TestData.event, completion: completion)
        dispatchMock.asyncReceivedWork?()
        batchSenderMock.sendBatchReceivedCompletion?(true)
        // then
        XCTAssertEqual(dispatchMock.asyncWasCalled, 2)
        XCTAssertNotNil(dispatchMock.asyncReceivedWork)
        XCTAssertEqual(completionWasCalled, 1)
        XCTAssertEqual(completionReceivedArgument, true)
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 1)
    }

    func testSendEventSyncJsonSerializerError() {
        // given
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        jsonSerializerMock.dataErrorStub = CustomError.random
        counterMock.incrementedCountStub = 0
        // mocks
        var completionWasCalled = 0
        var completionReceivedArgument: Bool?
        let completion: (_ successfully: Bool) -> Void  = { result in
            completionReceivedArgument = result
            completionWasCalled += 1
        }
        // when
        batchProcessor.sendEventSync(event: TestData.event, completion: completion)
        dispatchMock.asyncReceivedWork?()
        // then
        XCTAssertEqual(dispatchMock.asyncWasCalled, 2)
        XCTAssertNotNil(dispatchMock.asyncReceivedWork)
        XCTAssertEqual(completionWasCalled, 1)
        XCTAssertEqual(completionReceivedArgument, false)
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 0)
    }

    // MARK: SendBatch

    func testJsonSerializeErrorSendBatchLaunch() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        jsonSerializerMock.dataErrorStub = CustomError.random
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        counterMock.incrementedCountStub = 0
        storageMock.nextBatchStub = TestData.nextBatch
        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        // then
        dispatchMock.asyncReceivedWork?()
        XCTAssertTrue(mirror.sendingBatch == nil)
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 0)
        XCTAssertEqual(dispatchMock.asyncWasCalled, 1)
        if case .normal = mirror.state {
            XCTAssert(true)
        } else {
            XCTFail("Default value state equal needRetrain")
        }
        XCTAssertEqual(batchWorkerMock.sendBatchDelayedWasCalled, 1)
    }

    func testDataMaxSizeSendBatchLaunch() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        counterMock.incrementedCountStub = 0
        storageMock.nextBatchStub = TestData.nextBatchTwoEvent
        jsonSerializerMock.dataStub = TestData.dataMax
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )

        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        // then
        XCTAssertEqual(storageMock.removeBatchWasCalled, 1)
        XCTAssertEqual(storageMock.addBatchWasCalled, 3)
        XCTAssertNil(mirror.sendingBatch)
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 0)
    }

    func testDataMaxSizeWithErrorRemoveBatchSendBatchLaunch() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        counterMock.incrementedCountStub = 0
        storageMock.nextBatchStub = TestData.nextBatchTwoEvent
        jsonSerializerMock.dataStub = TestData.dataMax
        storageMock.removeBatchReceivedError = CustomError.random
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )

        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        // then
        XCTAssertEqual(storageMock.removeBatchWasCalled, 1)
        XCTAssertEqual(storageMock.addBatchWasCalled, 1)
        XCTAssertEqual(
            loggerMock.errorReceivedMessage?.contains("failed to split batch with error"),
            true
        )
        XCTAssertNil(mirror.sendingBatch)
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 0)
    }

    // MARK: didSendBatch

    func testSendBatchAddBatch() {
        // given
        storageMock.nextBatchStub = TestData.nextBatch
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        // then
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 1)
        XCTAssertEqual(batchSenderMock.sendBatchReceivedData, TestData.data)
    }

    // completion successfully

    func testDidSendBatchSuccessfullyAddBatch() {
        // given
        storageMock.nextBatchStub = TestData.nextBatch
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        batchProcessor.addBatch(withEvents: [TestData.event])
        // when
        batchSenderMock.sendBatchReceivedCompletion?(true)
        dispatchMock.asyncReceivedWork?()
        // then
        XCTAssertEqual(loggerMock.debugReceivedMessage?.contains("did send batch:"), true)
        XCTAssertEqual(dispatchMock.asyncWasCalled, 1)
        XCTAssertEqual(storageMock.removeBatchWasCalled, 1)
        XCTAssertNil(mirror.sendingBatch)
        if case .normal = mirror.state {
            XCTAssert(true)
        } else {
            XCTFail("Default value state equal needRetrain")
        }
    }

    func testDidSendBatchSuccessfullyWithRemoveErrorAddBatch() {
        // given
        storageMock.nextBatchStub = TestData.nextBatch
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        batchProcessor.addBatch(withEvents: [TestData.event])
        storageMock.removeBatchReceivedError = CustomError.random
        batchSenderMock.sendBatchReceivedCompletion?(true)
        // when
        dispatchMock.asyncReceivedWork?()
        // then
        XCTAssertEqual(loggerMock.debugReceivedMessage?.contains("did send batch:"), true)
        XCTAssertEqual(loggerMock.errorReceivedMessage?.contains("attempt to remove batch failed  with error"), true)
        XCTAssertEqual(dispatchMock.asyncWasCalled, 1)
        XCTAssertEqual(storageMock.removeBatchWasCalled, 1)
        XCTAssertNil(mirror.sendingBatch)
        if case .normal = mirror.state {
            XCTAssert(true)
        } else {
            XCTFail("Default value state equal needRetrain")
        }
    }

    func testDidSendBatchSuccessfullyWithNoMemoryAddBatch() {
        // given
        storageMock.nextBatchStub = TestData.nextBatch
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        DeviceMemoryState.setState(.noMemory)
        batchProcessor.addBatch(withEvents: [TestData.event])
        batchProcessor.addBatch(withEvents: [TestData.eventTwo])
        // when
        batchSenderMock.sendBatchReceivedCompletion?(true)
        // then
        XCTAssertEqual(dispatchMock.asyncWasCalled, 1)
        XCTAssertEqual(mirror.batches.count, 1)
        XCTAssertNil(mirror.sendingBatch)
    }

    // completion failure

    func testDidSendBatchFailureAddBatch() {
        // given
        storageMock.nextBatchStub = TestData.nextBatch
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        batchProcessor.addBatch(withEvents: [TestData.event])
        // when
        batchSenderMock.sendBatchReceivedCompletion?(false)
        // then
        XCTAssertEqual(dispatchMock.asyncWasCalled, 0)
        XCTAssertEqual(storageMock.removeBatchWasCalled, 0)
        XCTAssertNil(mirror.sendingBatch)
        if case .needRetain = mirror.state {
            XCTAssert(true)
        } else {
            XCTFail("Default value state equal normal")
        }
    }

    // sendBatchDelayed

    func testDidSendBatchNeedRetainAddBatch() {
        // given
        storageMock.nextBatchStub = TestData.nextBatch
        jsonSerializerMock.dataStub = TestData.data
        counterMock.incrementedCountStub = 0
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        batchProcessor.addBatch(withEvents: [TestData.event])
        batchSenderMock.sendBatchReceivedCompletion?(false)
        // when
        batchWorkerMock.sendBatchDelayedReceivedEvent?()
        // then
        XCTAssertEqual(batchSenderMock.sendBatchWasCalled, 2)
        XCTAssertEqual(batchWorkerMock.sendBatchDelayedWasCalled, 1)
        XCTAssertNotNil(batchWorkerMock.sendBatchDelayedReceivedId)
        XCTAssertNotNil(batchWorkerMock.sendBatchDelayedReceivedEvent)
        if case .needRetain = mirror.state {
            XCTAssert(true)
        } else {
            XCTFail("Default value state equal normal")
        }
    }

    // MARK: addBatch

    func testAddBatch() {
        // given
        userStorageMock.loadBatchesStub = []
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        let timeZoneOffsetSeconds = TimeZone.current.secondsFromGMT()
        let hours = timeZoneOffsetSeconds / 3600
        let minutes = abs(timeZoneOffsetSeconds / 60) % 60
        let timeZoneOffset = String(format: "%+.2d%02d", hours, minutes)
        counterMock.incrementedCountStub = 0
        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        let batches = storageMock.addBatchReceivedBatch
        let meta = batches?["meta"] as? [String: Any]
        let events = batches?["events"] as? [[String: Any]]
        // then
        XCTAssertEqual(counterMock.incrementedCountWasCalled, 1)
        XCTAssertEqual(counterMock.incrementedCountReceivedKey, "batch_num")
        XCTAssertNotNil(meta)
        XCTAssertEqual(meta?["batch_num"] as? Int, 0)
        XCTAssertEqual(meta?["product"] as? String, TestData.product)
        XCTAssertEqual(meta?["app_id"] as? String, TestData.appId)
        XCTAssertEqual(meta?["os-build"] as? String, UIDevice.current.systemVersion)
        XCTAssertEqual(meta?["model"] as? String, TestData.model)
        XCTAssertEqual(meta?["tz_offset"] as? String, timeZoneOffset)
        XCTAssertEqual(meta?["is_new_user"] as? Int, 0)
        XCTAssertEqual(meta?["app_version"] as? String, TestData.appVersion)
        if #available(iOS 16, *) {
            XCTAssertEqual(meta?["locale"] as? String, Locale.current.language.languageCode?.identifier)
        } else {
            XCTAssertEqual(meta?["locale"] as? String, Locale.current.languageCode)
        }
        XCTAssertEqual(meta?["mobile_device_type"] as? String, "computer")
        XCTAssertEqual(meta?["timezone"] as? String, TimeZone.current.identifier)
        XCTAssertEqual(meta?["analytics_sdk_version"] as? String, TestData.analyticsSdkVersion)
        XCTAssertEqual(meta?["device_id"] as? String, WBAnalytics.deviceId)
        XCTAssertEqual(meta?["manufacturer"] as? String, TestData.manufacturer)
        XCTAssertEqual(meta?["net_type"] as? String, "2G")
        XCTAssertEqual(events?.count, 1)
        XCTAssertEqual(events?.first?["event"] as? Int, 321)
        XCTAssertEqual(storageMock.addBatchWasCalled, 1)
    }

    func testNoMemoryAddBatch() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        DeviceMemoryState.setState(.noMemory)
        counterMock.incrementedCountStub = 0
        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        // then
        XCTAssertEqual(mirror.batches.first?.batch["events"] as? [[String: Int]], [TestData.event])
    }

    func testStorageErrorNoMemoryAddBatch() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        DeviceMemoryState.setState(.normal)
        counterMock.incrementedCountStub = 0
        storageMock.addBatchReceivedError = NSError(domain: "NO", code: Int(SQLITE_NOMEM))
        batchProcessor.setup(
            batchSender: batchSenderMock,
            queue: dispatchMock,
            networkTypeProvider: networkProviderMock,
            counter: counterMock,
            batchWorker: batchWorkerMock
        )
        // when
        batchProcessor.addBatch(withEvents: [TestData.event])
        // then
        XCTAssertEqual(mirror.batches.count, 1)
        XCTAssertEqual(storageMock.addBatchWasCalled, 1)
        XCTAssertEqual(DeviceMemoryState.state, .noMemory)
        XCTAssertEqual(loggerMock.errorReceivedMessage?.contains("Can't add batch error:"), true)
    }

    // MARK: update

    func testUpdate() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        // when
        batchProcessor.update(isNewLaunch: true)
        // then
        XCTAssertTrue(mirror.isNewLaunch)
    }

    func testUpdateFalse() {
        // given
        let mirror = BatchProcessorImplMirror(reflecting: batchProcessor)
        // when
        batchProcessor.update(isNewLaunch: false)
        // then
        XCTAssertFalse(mirror.isNewLaunch)
    }
}

// MARK: - TestData

private extension BatchProcessorImplTests {
    enum TestData {
        static let nextBatch = BatchModel(id: "123", batch: event)
        static let nextBatchTwoEvent = BatchModel(id: "123", batch: batchTwoEvents)
        static let queue = "queue"
        static let data = Data()
        static let dataMax = Data(repeating: 0, count: 513 * 1024)
        static let event: [String: Int] = ["event": 321]
        static let eventTwo: Event = ["event2": 321]
        static let batch = ["request2": 12]
        static let batchTwoEvents = [
            "events": [event, eventTwo]
        ]
        static let batches: [String: Batch] = ["request1": batch]
        static let product = "iOS"
        static let appId = "com.apple.dt.xctest.tool"
        static let appVersion = "16.0"
        static let model = "arm64"
        static let manufacturer = "Apple"
        static let analyticsSdkVersion = "3.4.4"
    }

    enum CustomError: Error {
        case random
    }
}

// MARK: - Mirror

private extension BatchProcessorImplTests {

    final class BatchProcessorImplMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: BatchProcessorImpl) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var batchSender: BatchSender? { extract() }
        var queue: Dispatcher? { extract() }
        var networkTypeProvider: NetworkTypeProviderProtocol? { extract() }
        var counter: EnumerationCounter? { extract() }
        var batchWorker: BatchWorker? { extract() }
        var storage: Storage? { extract() }
        var batches: [BatchModel] { extract() }
        var sendingBatch: BatchModel? { extract() }
        var state: BatchProcessorImpl.BatchProcessingState { extract() }

        var isNewLaunch: Bool { extract() }
        var isSending: Bool { extract() }
        var isExecutingInBackground: Bool { extract() }
        var batchesBeingSentIds: Set<String> { extract() }

    }
}

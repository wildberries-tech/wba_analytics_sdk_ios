//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

// swiftlint:disable type_body_length
// swiftlint:disable file_length

final class EventsProcessorImplTests: XCTestCase {

    private var batchProcessorMock: BatchProcessorMock!
    private var loggerMock: LoggerMock!
    private var timerMakerMock: TimerMock.Type!
    private var timerMock: TimerMock!
    private var queueMock: DispatchQueue!
    private var batchConfig: BatchConfig!
    private var networkMock: NetworkTypeProviderMock!
    private var notificationCenterMock: NotificationCenterMock!
    private var enumerationCounterMock: EnumerationCounterMock!
    private var userEngagementTrackerMock: UserEngagementTrackerMock!
    private var processor: EventsProcessorImpl!
    private var requestInterceptorMock: RequestInterceptorMock!

    override func setUp() {
        super.setUp()
        batchProcessorMock = .init()
        loggerMock = .init()
        timerMakerMock = TimerMock.self
        timerMock = .init()
        enumerationCounterMock = .init()
        notificationCenterMock = .init()
        batchConfig = .init()
        requestInterceptorMock = .init()
        networkMock = .init()
        userEngagementTrackerMock = .init()
        queueMock = .init(label: TestData.queueLabel)
        timerMakerMock.timerStub = timerMock
        processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: notificationCenterMock,
            timerMaker: timerMakerMock
        )
    }

    override func tearDown() {
        timerMakerMock.reset()
        super.tearDown()
    }

    // MARK: Init

    func testDefaultInit() {
        // when
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock
        )
        let mirror = Mirror(reflecting: processor)
        // then
        XCTAssertEqual(mirror.notificationCenter, NotificationCenter.default)
        XCTAssertIdentical(mirror.timerMaker, Timer.self)
        XCTAssertEqual(mirror.queue.label, TestData.analyticsQueueName)
        XCTAssertEqual(mirror.queue.qos, .default)
    }

    // MARK: setup

    func testDefaultInitSetup() {
        // given
        let mirror = Mirror(reflecting: processor)
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(loggerMock.debugWasCalled, 2)
        XCTAssertEqual(batchProcessorMock.launchWasCalled, 1)
        XCTAssertEqual(loggerMock.debugReceivedLabel, TestData.logLabel)
        XCTAssertEqual(mirror.queue.label, TestData.analyticsQueueName)
        XCTAssertEqual(mirror.queue.qos, .default)
        XCTAssertEqual(mirror.batchConfig, batchConfig)
        XCTAssertNotNil(mirror.counter as? UserDefaultsEnumerationCounter)
        XCTAssertIdentical(mirror.interceptor as? RequestInterceptorMock, requestInterceptorMock)
    }

    func testSubscribeNotificationsInitSetup() {
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: nil,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(notificationCenterMock.addObserverSelectorNameObjectWasCalled, 3)
        XCTAssertEqual(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[0].aSelector,
            Selector("willEnterForeground")
        )
        XCTAssertEqual(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[1].aSelector,
            Selector("didEnterBackground")
        )
        XCTAssertEqual(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[2].aSelector,
            Selector("willTerminate")
        )
        XCTAssertEqual(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[0].aName,
            UIApplication.willEnterForegroundNotification
        )
        XCTAssertEqual(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[1].aName,
            UIApplication.didEnterBackgroundNotification
        )
        XCTAssertEqual(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[2].aName,
            UIApplication.willTerminateNotification
        )
        XCTAssertIdentical(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[0].observer as? EventsProcessorImpl,
            processor
        )
        XCTAssertIdentical(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[1].observer as? EventsProcessorImpl,
            processor
        )
        XCTAssertIdentical(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[2].observer as? EventsProcessorImpl,
            processor
        )
        XCTAssertNil(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[0].anObject
        )
        XCTAssertNil(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[1].anObject
        )
        XCTAssertNil(
            notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[2].anObject
        )
    }

    func testBatchSenderInitCallInitSetup() {
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 100)
        let batchSender = batchProcessorMock.setupReceivedArguments?.batchSender as? BatchSenderImpl
        let batchSenderMirror = BatchSenderImplMirror(reflecting: batchSender!)
        // then
        XCTAssertEqual(batchSenderMirror.apiKey, TestData.apiKey)
        XCTAssertEqual(batchSenderMirror.queue, queueMock)
        XCTAssertEqual(batchSenderMirror.batchConfig, batchConfig)
        XCTAssertIdentical(batchSenderMirror.logger as? LoggerMock, loggerMock)
    }

    func testBatchProcessorSetupCallSetup() {
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 100)
        let batchSender = batchProcessorMock.setupReceivedArguments?.batchSender as? BatchSenderImpl
        // then
        XCTAssertEqual(batchProcessorMock.setupReceivedArguments?.batchSender, batchSender)
        XCTAssertEqual(batchProcessorMock.setupReceivedArguments?.queue as? DispatchQueue, queueMock)
        XCTAssertIdentical(
            batchProcessorMock.setupReceivedArguments?.networkTypeProvider as? NetworkTypeProviderMock,
            networkMock
        )
        XCTAssertIdentical(
            batchProcessorMock.setupReceivedArguments?.counter as? EnumerationCounterMock,
            enumerationCounterMock
        )
    }

    func testIsNewLaunchTrueCheckOnNewLaunchSetup() {
        // given
        UserDefaults.standard.set(true, forKey: TestData.newLaunchKey)
        enumerationCounterMock.incrementedCountStub = 1
        let mirror = Mirror(reflecting: processor)
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(batchProcessorMock.updateWasCalled, 0)
        XCTAssertTrue(mirror.events.isEmpty)
        XCTAssertFalse(UserDefaults.standard.object(forKey: TestData.newLaunchKey) as! Bool)
    }

    func testIsNewLaunchFalseCheckOnNewLaunchSetup() {
        // given
        UserDefaults.standard.set(false, forKey: TestData.newLaunchKey)
        enumerationCounterMock.incrementedCountStub = 1
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(batchProcessorMock.updateWasCalled, 1)
        XCTAssertFalse(batchProcessorMock.updateReceivedIsNewValue!)
    }

    func testIsNewLaunchNilCheckOnNewLaunchSetup() {
        // given
        UserDefaults.standard.set(nil, forKey: TestData.newLaunchKey)
        enumerationCounterMock.incrementedCountStub = 1
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(batchProcessorMock.updateWasCalled, 1)
        XCTAssertTrue(batchProcessorMock.updateReceivedIsNewValue!)
        XCTAssertEqual(
            UserDefaults.standard.object(
                forKey: TestData.newLaunchKey
            ) as? Bool,
            true
        )
    }

    func testIsFirstLaunchSetup() {
        // given
        let mirror = Mirror(reflecting: processor)
        let timeString = Date().asString
        enumerationCounterMock.incrementedCountStub = 0
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(mirror.events.first?["event_num"] as? Int, 0)
        XCTAssertEqual(mirror.events.first?["event_time"] as? String, timeString)
        XCTAssertEqual(mirror.events.first?["name"] as? String, "first_open")
        XCTAssertEqual((mirror.events.first?["data"] as? [String: Any])?.isEmpty, true)
    }

    func testUserEngagementTrackerSetup() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(userEngagementTrackerMock.startWasCalled, 1)
    }

    func testTimerSetup() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(timerMakerMock.timerWasCalled, 1)
        XCTAssertEqual(timerMakerMock.timerReceivedArguments?.timeInterval, batchConfig.sendingTimerTimeout)
        XCTAssertEqual(timerMakerMock.timerReceivedArguments?.repeats, true)
        XCTAssertEqual(timerMock.scheduleWasCalled, 1)
    }

    // MARK: setCommonParameters

    func testSetCommonParameters() {
        // given
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        // when
        processor.setCommonParameters(TestData.parameters)
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(mirror.commonParameters as? [String: Int], TestData.parameters)
    }

    // MARK: logEvent

    func testLogEvent() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        // when
        processor.logEvent(TestData.eventString, parameters: TestData.parameters, completion: {_ in})
        let timeString = Date().asString
        // then
        XCTAssertEqual(batchProcessorMock.sendEventSyncWasCalled, 1)
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["event_num"] as? Int, 0)
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["event_time"] as? String, timeString)
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["name"] as? String, "event")
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["data"] as? [String: Int], TestData.parameters)
    }

    // MARK: addEvent

    func testAddEvent() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        processor.setCommonParameters(TestData.parameters2)
        let mirror = Mirror(reflecting: processor)
        // when
        processor.addEvent(TestData.eventString, parameters: TestData.parameters)
        let timeString = Date().asString
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(mirror.events[1]["event_num"] as? Int, 0)
        XCTAssertEqual(mirror.events[1]["event_time"] as? String, timeString)
        XCTAssertEqual(mirror.events[1]["name"] as? String, "event")
        XCTAssertEqual((mirror.events[1]["data"] as? [String: Int]), TestData.parametersFull)
    }

    // MARK: - MakeBatch

    func testMakeBatchMaxEvents() {
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        for identifier in 0..<200 {
            processor.addEvent("event_\(identifier)", parameters: ["data": String(repeating: "x", count: 3000)])
        }
        // then
        sleep(milliseconds: 600)
        XCTAssertEqual(batchProcessorMock.addBatchWasCalled, 2)
    }

    func testMakeBatchMinEvents() {
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        for identifier in 0..<200 {
            processor.addEvent("event_\(identifier)", parameters: ["data": String(repeating: "x", count: 1)])
        }
        // then
        sleep(milliseconds: 300)
        XCTAssertEqual(batchProcessorMock.addBatchWasCalled, 1)
    }

    // MARK: logUserEngagement

    func testLogUserEngagement() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )

        // when
        processor.logUserEngagement(TestData.userEngagement)
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(userEngagementTrackerMock.setUserEngagementReceivedArguments, TestData.userEngagement)
        XCTAssertEqual(userEngagementTrackerMock.setUserEngagementWasCalled, 1)
    }

    // MARK: logLaunchURL

    func testLogLaunchURL() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        let mirror = Mirror(reflecting: processor)
        // when
        sleep(milliseconds: 500)
        processor.logLaunchURL(TestData.url)
        sleep(milliseconds: 500)
            // then
        XCTAssertEqual(mirror.events[1]["name"] as? String, "dynamic_link_app_open")
        XCTAssertEqual(
            (mirror.events[1]["data"] as? [String: String]),
            ["link": TestData.url.absoluteString]
        )
    }

    // MARK: willEnterForeground

    func testWillEnterForeground() {
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: NotificationCenter.default,
            timerMaker: timerMakerMock
        )
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: nil,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 1000)
        // when
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        sleep(milliseconds: 1000)
        // then
        XCTAssertEqual(userEngagementTrackerMock.startWasCalled, 2)
    }

    // MARK: willEnterBackground

    func testWillEnterBackground() {
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: NotificationCenter.default,
            timerMaker: timerMakerMock
        )
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: nil,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 300)
        processor.addEvent(TestData.eventString)
        // when
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(userEngagementTrackerMock.invalidateWasCalled, 1)
        XCTAssertEqual(loggerMock.debugReceivedMessage, "didEnterBackground")
        XCTAssertEqual(batchProcessorMock.addBatchWasCalled, 1)
        XCTAssertEqual(
            batchProcessorMock.addBatchReceivedEvents?.first?["name"] as? String,
            TestData.eventString
        )
        XCTAssertTrue(mirror.events.isEmpty)
        XCTAssertNil(mirror.sendEventsTimer)
        XCTAssertEqual(timerMock.invalidateWasCalled, 1)
    }

    // MARK: willEnterBackground

    func testWillTerminate() {
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: NotificationCenter.default,
            timerMaker: timerMakerMock
        )
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            dropCache: false,
            queue: nil,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 300)
        processor.addEvent(TestData.eventString)
        // when
        NotificationCenter.default.post(name: UIApplication.willTerminateNotification, object: nil)
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(userEngagementTrackerMock.invalidateWasCalled, 1)
        XCTAssertEqual(loggerMock.debugReceivedMessage, "willTerminate")
        XCTAssertEqual(batchProcessorMock.addBatchWasCalled, 1)
        XCTAssertEqual(
            batchProcessorMock.addBatchReceivedEvents?.first?["name"] as? String,
            TestData.eventString
        )
        XCTAssertTrue(mirror.events.isEmpty)
        XCTAssertNil(mirror.sendEventsTimer)
        XCTAssertEqual(timerMock.invalidateWasCalled, 1)
    }

    // MARK: didUserEngagementTrackerFire

    func testDidUserEngagementTrackerFire() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 500)
        let mirror = Mirror(reflecting: processor)
        // when
        processor.didUserEngagementTrackerFire(TestData.userEngagement)
        let time = Date(timeIntervalSince1970:Date().timeIntervalSince1970).asString
        sleep(milliseconds: 500)
        // then
        XCTAssertEqual(mirror.events[1]["event_num"] as? Int, 0)
        XCTAssertEqual(mirror.events[1]["event_time"] as? String, time)
        XCTAssertEqual(mirror.events[1]["name"] as? String, "user_engagement")
        XCTAssertEqual((mirror.events[1]["data"] as? [String: Any])?["screen_name"] as? String, TestData.eventString)
        XCTAssertEqual((mirror.events[1]["data"] as? [String: Any])?["text_size"] as? Int, 2)
    }

}

// MARK: TestData

private extension EventsProcessorImplTests {
    enum TestData {
        static let userEngagement: UserEngagement = .init(screenName: "event", textSize: .small)
        static let url = URL(string: "https://example.com")!
        static let event: Event = .init(meta: ["Meta": 123], batchNum: 0, events: [["name":321]])
        static let parameters: [String: Int] = [event2String: 123]
        static let parameters2: [String: Int] = [eventString: 321]
        static let parametersFull: [String: Int] = [event2String: 123, eventString: 321]
        static let eventString = "event"
        static let event2String = "event2"
        static let apiKey = "ApiKey"
        static let queueLabel = "queueLabel"
        static let logLabel = "EventsProcessor"
        static let analyticsQueueName = "WBAnalytics"
        static let newLaunchKey = "WBMAnalytics-isNewLaunch"
    }
}

// MARK: - Mirror

private extension EventsProcessorImplTests {

    final class Mirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: EventsProcessorImpl) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var notificationCenter: NotificationCenter! { extract() }
        var timerMaker: TimerProtocol.Type! { extract() }
        var queue: DispatchQueue! { extract() }
        var batchConfig: BatchConfig! { extract() }
        var counter: EnumerationCounter! { extract() }
        var interceptor: RequestInterceptor! { extract() }
        var sendEventsTimer: TimerProtocol? { extract() }
        var events: [Event]! { extract() }
        var commonParameters: [String: Any]! { extract() }
    }

    final class BatchSenderImplMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: BatchSenderImpl) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var queue: DispatchQueue! { extract() }
        var batchConfig: BatchConfig! { extract() }
        var apiKey: String! { extract() }
        var logger: Logger! { extract() }
    }
}

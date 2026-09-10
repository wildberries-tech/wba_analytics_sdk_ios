//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

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
    private var sessionValueManagerMock: SessionValueManagerMock!
    private var appStartTrackerMock: AppStartTrackerMock!
    private var heartbeatTrackerMock: PeriodicTrackerMock!
    private var firstOpenTrackerMock: FirstOpenTrackerMock!

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
        sessionValueManagerMock = .init()
        sessionValueManagerMock.sessionValue = TestData.sessionValue
        appStartTrackerMock = .init()
        heartbeatTrackerMock = .init()
        firstOpenTrackerMock = .init()
        processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: notificationCenterMock,
            timerMaker: timerMakerMock,
            sessionValueManager: sessionValueManagerMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
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
            interceptor: requestInterceptorMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
        )
        let mirror = Mirror(reflecting: processor)
        // then
        XCTAssertEqual(mirror.notificationCenter, NotificationCenter.default)
        XCTAssertIdentical(mirror.timerMaker, Timer.self)
        XCTAssertIdentical(mirror.sessionValueManager as? SessionValueManager, SessionValueManager.shared)
        XCTAssertEqual(mirror.queue.label, TestData.analyticsQueueName)
        XCTAssertEqual(mirror.queue.qos, .default)
    }

    // MARK: setup

    func testDefaultInitSetup() {
        // given
        let mirror = Mirror(reflecting: processor)
        firstOpenTrackerMock.shouldTrack = false
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
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
        XCTAssertEqual(appStartTrackerMock.setupWithWasCalled, 1)
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
        // first_open is processed asynchronously on the queue (addEvent), so it would land in
        // events AFTER the makeBatch call from checkOnNewLaunch — disable it so this test checks
        // exactly that state, without mixing in the independent first_open flow
        firstOpenTrackerMock.shouldTrack = false
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

    func testFirstOpenIsSentWithoutClientFlag() {
        // given
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(firstOpenTrackerMock.trackIfNeededWasCalled, 1)
        XCTAssertEqual(firstOpenTrackerMock.trackIfNeededReceivedApiKey, TestData.apiKey)
        XCTAssertEqual(mirror.events.first?["event_num"] as? Int, 0)
        XCTAssertEqual(mirror.events.first?["name"] as? String, "first_open")
        XCTAssertEqual(mirror.events.first?["session_value"] as? String, TestData.sessionValue)
        XCTAssertEqual((mirror.events.first?["data"] as? [String: Any])?.isEmpty, true)
    }

    func testFirstOpenIsNotSentWhenTrackerSaysAlreadySent() {
        // given
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        firstOpenTrackerMock.shouldTrack = false
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(firstOpenTrackerMock.trackIfNeededWasCalled, 1)
        XCTAssertNil(mirror.events.first { $0["name"] as? String == "first_open" })
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
        // The IDFA read delay must not hold back event sending: the timer starts immediately.
        XCTAssertEqual(timerMakerMock.timerWasCalled, 1)
        XCTAssertEqual(timerMakerMock.timerReceivedArguments?.timeInterval, batchConfig.sendingTimerTimeout)
        XCTAssertEqual(timerMakerMock.timerReceivedArguments?.repeats, true)
        XCTAssertEqual(timerMock.scheduleWasCalled, 1)
    }

    func testAppStartTrackerSetup() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(appStartTrackerMock.setupWithWasCalled, 1)
    }

    func testAppStartTrackerSetupClosureAddsEventToCommonBatch() {
        // given: application_start no longer goes out through a synchronous path with its own
        // retry logic — it now flows through the regular event pipeline (addEvent), gets persisted,
        // and is retried by the same batch mechanism as every other event.
        enumerationCounterMock.incrementedCountStub = 0
        let mirror = Mirror(reflecting: processor)
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 100)
        // when
        let input = AppStartTracker.Input(
            name: TestData.appStartEventName,
            parameters: TestData.appStartEventParameters
        )
        appStartTrackerMock.setupWithReceivedClosure?(input)
        sleep(milliseconds: 100)
        // then: the event went out through the regular path and sits in the shared events array,
        // rather than having been sent synchronously, bypassing batches
        XCTAssertEqual(batchProcessorMock.sendEventSyncWasCalled, 0)
        let appStartEvent = mirror.events.first { $0["name"] as? String == TestData.appStartEventName }
        XCTAssertNotNil(appStartEvent)
        XCTAssertEqual(appStartEvent?["data"] as? [String: Double], TestData.appStartEventParameters)
    }

    // MARK: heartbeat

    func testHeartbeatTrackerStartsOnSetup() {
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(heartbeatTrackerMock.setupWithWasCalled, 1)
        XCTAssertEqual(heartbeatTrackerMock.startWasCalled, 1)
    }

    func testHeartbeatTrackerClosureAddsEvent() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        let mirror = Mirror(reflecting: processor)
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // when
        heartbeatTrackerMock.setupWithReceivedClosure?()
        sleep(milliseconds: 300)
        // then
        let heartbeatEvent = mirror.events.first { $0["name"] as? String == "heartbeat" }
        XCTAssertNotNil(heartbeatEvent)
        XCTAssertEqual((heartbeatEvent?["data"] as? [String: Any])?.isEmpty, true)
    }

    func testHeartbeatTrackerStopsOnDidEnterBackground() {
        // given
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: NotificationCenter.default,
            timerMaker: timerMakerMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
        )
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: nil,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 500)
        // when
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(milliseconds: 500)
        // then
        XCTAssertEqual(heartbeatTrackerMock.invalidateWasCalled, 1)
        // and when
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        sleep(milliseconds: 500)
        // then
        XCTAssertEqual(heartbeatTrackerMock.startWasCalled, 2)
    }

    // MARK: automatic events

    func testAutomaticEventsFlagIsForwardedToBatchProcessorForMeta() {
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then: the value ends up in the meta of every batch under the enable_automatic_events key
        XCTAssertEqual(batchProcessorMock.setupReceivedEnableAutomaticEvents, true)
    }

    func testAutomaticEventsDisabledFlagIsForwardedToBatchProcessorForMeta() {
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
        // then: the default is disabled, and that must reach the meta as well
        XCTAssertEqual(batchProcessorMock.setupReceivedEnableAutomaticEvents, false)
    }

    func testAutomaticEventsDisabledDoesNotStartHeartbeat() {
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(heartbeatTrackerMock.setupWithWasCalled, 0)
        XCTAssertEqual(heartbeatTrackerMock.startWasCalled, 0)
    }

    func testAutomaticEventsDisabledDoesNotSendFirstOpen() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        let mirror = Mirror(reflecting: processor)
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then: the tracker is not called at all — otherwise it would mark first_open as sent
        // and the event would be lost forever once automatic events are enabled again
        XCTAssertEqual(firstOpenTrackerMock.trackIfNeededWasCalled, 0)
        XCTAssertNil(mirror.events.first { $0["name"] as? String == "first_open" })
    }

    func testAutomaticEventsDisabledDoesNotSetupAppStartTracker() {
        // given
        enumerationCounterMock.incrementedCountStub = 0
        let mirror = Mirror(reflecting: processor)
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            enableAutomaticEvents: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(appStartTrackerMock.setupWithWasCalled, 0)
        XCTAssertNil(mirror.events.first { $0["name"] as? String == TestData.appStartEventName })
    }

    func testAutomaticEventsDisabledDoesNotStartHeartbeatOnWillEnterForeground() {
        // given
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: NotificationCenter.default,
            timerMaker: timerMakerMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
        )
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: false,
            dropCache: false,
            queue: nil,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 500)
        // when
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(milliseconds: 500)
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        sleep(milliseconds: 500)
        // then
        XCTAssertEqual(heartbeatTrackerMock.startWasCalled, 0)
    }

    func testAutomaticEventsDisabledKeepsUserEngagementTracking() {
        // given: user_engagement is not covered by the flag — the timer still starts
        // and the collected event reaches the batch as usual
        enumerationCounterMock.incrementedCountStub = 0
        let mirror = Mirror(reflecting: processor)
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: true,
            enableAutomaticEvents: false,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock,
            userEngagementTracker: userEngagementTrackerMock
        )
        sleep(milliseconds: 300)
        // when
        processor.didUserEngagementTrackerFire(TestData.userEngagement)
        sleep(milliseconds: 300)
        // then
        XCTAssertEqual(userEngagementTrackerMock.startWasCalled, 1)
        let engagementEvent = mirror.events.first { $0["name"] as? String == "user_engagement" }
        XCTAssertNotNil(engagementEvent)
        XCTAssertEqual(
            (engagementEvent?["data"] as? [String: Any])?["screen_name"] as? String,
            TestData.eventString
        )
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
//        let timeString = Date().asString
        // then
        XCTAssertEqual(batchProcessorMock.sendEventSyncWasCalled, 1)
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["event_num"] as? Int, 0)
//        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["event_time"] as? String, timeString)
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["name"] as? String, "event")
        XCTAssertEqual(batchProcessorMock.sendEventSyncReceivedValue?.event["session_value"] as? String, TestData.sessionValue)
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
        sleep(milliseconds: 100)
        // then
        // Look the event up by name, not by index: which automatic events are present
        // depends on enableAutomaticEvents and must not affect this test
        let event = mirror.events.first { $0["name"] as? String == TestData.eventString }
        XCTAssertNotNil(event)
        XCTAssertEqual(event?["event_num"] as? Int, 0)
        XCTAssertEqual(event?["name"] as? String, "event")
        XCTAssertEqual(event?["session_value"] as? String, TestData.sessionValue)
        XCTAssertEqual((event?["data"] as? [String: Int]), TestData.parametersFull)
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
        sleep(milliseconds: 1000)
        // when
        processor.logLaunchURL(TestData.url, referrerURL: nil)
        sleep(milliseconds: 1000)
        // then
        let event = mirror.events.first { $0["name"] as? String == "dynamic_link_app_open" }
        XCTAssertEqual(
            event?["data"] as? [String: String],
            ["link": TestData.url.absoluteString]
        )
    }

    func testLogLaunchURLWithReferrer() {
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
        sleep(milliseconds: 1000)
        // when
        processor.logLaunchURL(TestData.url, referrerURL: TestData.referrerURL)
        sleep(milliseconds: 1000)
        // then
        let event = mirror.events.first { $0["name"] as? String == "dynamic_link_app_open" }
        XCTAssertEqual(
            event?["data"] as? [String: String],
            [
                "link": TestData.url.absoluteString,
                "referrerURL": TestData.referrerURL.absoluteString
            ]
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
            timerMaker: timerMakerMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
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
            timerMaker: timerMakerMock,
            appStartTracker: appStartTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
        )
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        firstOpenTrackerMock.shouldTrack = false
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
            timerMaker: timerMakerMock,
            appStartTracker: appStartTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
        )
        let mirror = Mirror(reflecting: processor)
        enumerationCounterMock.incrementedCountStub = 0
        firstOpenTrackerMock.shouldTrack = false
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
        // Look the event up by name, not by index: which automatic events are present
        // depends on enableAutomaticEvents and must not affect this test
        let event = mirror.events.first { $0["name"] as? String == "user_engagement" }
        XCTAssertNotNil(event)
        XCTAssertEqual(event?["event_num"] as? Int, 0)
        XCTAssertEqual(event?["name"] as? String, "user_engagement")
        XCTAssertEqual((event?["data"] as? [String: Any])?["screen_name"] as? String, TestData.eventString)
        XCTAssertEqual((event?["data"] as? [String: Any])?["text_size"] as? Int, 2)
        XCTAssertEqual((event?["data"] as? [String: Any])?["auth_type"] as? String, "noAuth")
        XCTAssertEqual((event?["data"] as? [String: Any])?["scale_factor"] as? String, "scaleFactor")
    }

    func testDidUserEngagementTrackerFireWithoutScaleFactor() {
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
        processor.didUserEngagementTrackerFire(TestData.userEngagementWithoutScaleFactor)
        sleep(milliseconds: 500)
        // then the key is omitted rather than sent as null
        // Look the event up by name, not by index: which automatic events are present
        // depends on enableAutomaticEvents and must not affect this test
        let event = mirror.events.first { $0["name"] as? String == "user_engagement" }
        XCTAssertNotNil(event)
        XCTAssertEqual(event?["name"] as? String, "user_engagement")
        XCTAssertEqual((event?["data"] as? [String: Any])?["screen_name"] as? String, TestData.eventString)
        XCTAssertNil((event?["data"] as? [String: Any])?["scale_factor"])
    }

    // MARK: setDeviceId

    func testSetDeviceId() {
        // when
        processor.setDeviceId(TestData.deviceId)
        // then
        XCTAssertEqual(batchProcessorMock.setDeviceIdWasCalled, 1)
        XCTAssertEqual(batchProcessorMock.setDeviceReceivedArguments, TestData.deviceId)
    }

    // MARK: setSessionValue

    func testSetSessionValue() {
        // given
        let newValue = "12345"
        // when
        sessionValueManagerMock.setSessionValue(newValue)
        // then
        XCTAssertEqual(sessionValueManagerMock.setSessionValueWasCalled, 1)
        XCTAssertEqual(sessionValueManagerMock.setSessionValueReceivedValue, newValue)
    }

    // MARK: setOnSessionValueUpdated

    func testSetOnSessionValueUpdated() {
        // given
        let handler: (String?) -> Void = { _ in }
        // when
        sessionValueManagerMock.setOnSessionValueUpdated(handler)
        // then
        XCTAssertNotNil(sessionValueManagerMock.setOnSessionValueUpdatedReceivedValue)
        XCTAssertEqual(sessionValueManagerMock.setOnSessionValueUpdatedWasCalled, 1)
    }

    // MARK: setCustomHeader

    func testSetCustomHeader() {
        // when
        processor.setCustomHeader(key: TestData.customHeaderKey, value: TestData.customHeaderValue)
        // then
        XCTAssertEqual(batchProcessorMock.setCustomHeadersWasCalled, 1)
        XCTAssertEqual(
            batchProcessorMock.setCustomHeadersReceivedValue,
            [TestData.customHeaderKey: TestData.customHeaderValue]
        )
    }

    func testSetCustomHeaders() {
        // when
        processor.setCustomHeaders(TestData.customHeaders)
        // then
        XCTAssertEqual(batchProcessorMock.setCustomHeadersWasCalled, 1)
        XCTAssertEqual(batchProcessorMock.setCustomHeadersReceivedValue, TestData.customHeaders)
    }

    func testSetCustomHeaderMergesWithExistingHeaders() {
        // when
        processor.setCustomHeader(key: TestData.customHeaderKey, value: TestData.customHeaderValue)
        processor.setCustomHeaders(TestData.customHeaders)
        // then the second call is merged with the first, not replacing it
        XCTAssertEqual(batchProcessorMock.setCustomHeadersWasCalled, 2)
        var expected = TestData.customHeaders
        expected[TestData.customHeaderKey] = TestData.customHeaderValue
        XCTAssertEqual(batchProcessorMock.setCustomHeadersReceivedValue, expected)
    }

    func testSetCustomHeaderOverridesExistingKey() {
        // when
        processor.setCustomHeader(key: TestData.customHeaderKey, value: TestData.customHeaderValue)
        processor.setCustomHeader(key: TestData.customHeaderKey, value: "newValue")
        // then
        XCTAssertEqual(
            batchProcessorMock.setCustomHeadersReceivedValue,
            [TestData.customHeaderKey: "newValue"]
        )
    }

    func testCustomHeadersAppliedToBatchSenderOnSetup() {
        // given headers set before setup creates the batch sender
        processor.setCustomHeader(key: TestData.customHeaderKey, value: TestData.customHeaderValue)
        batchProcessorMock = .init()
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: notificationCenterMock,
            timerMaker: timerMakerMock,
            sessionValueManager: sessionValueManagerMock,
            appStartTracker: appStartTrackerMock,
            firstOpenTracker: firstOpenTrackerMock
        )
        processor.setCustomHeaders(TestData.customHeaders)
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
        // then the stored headers are re-applied to the freshly created batch sender
        XCTAssertEqual(batchProcessorMock.setCustomHeadersReceivedValue, TestData.customHeaders)
    }

    // MARK: - first_open ordering integration
    //
    // FirstOpenTrackerMock doesn't touch UserDefaults, so it wouldn't catch a regression where
    // firstOpenTracker.trackIfNeeded and checkOnNewLaunch() get reordered inside setup(). These
    // tests exercise a real FirstOpenTracker over isolated UserDefaults suites (not .standard) to
    // verify EventsProcessorImpl.setup()'s end-to-end behavior without a mock in the way.

    func testFirstOpenIntegrationSendsEventForFreshInstall() {
        // given: a real FirstOpenTracker, no legacy key present — a fresh install
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        let suiteName = "EventsProcessorImplTests-firstOpen-\(UUID().uuidString)"
        let legacySuiteName = "EventsProcessorImplTests-legacy-\(UUID().uuidString)"
        let defaultsSuite = UserDefaults(suiteName: suiteName)!
        let legacySuite = UserDefaults(suiteName: legacySuiteName)!
        defer {
            defaultsSuite.removePersistentDomain(forName: suiteName)
            legacySuite.removePersistentDomain(forName: legacySuiteName)
            FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        }
        let realFirstOpenTracker = FirstOpenTracker(defaults: defaultsSuite, legacyDefaults: legacySuite)
        enumerationCounterMock.incrementedCountStub = 0
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: notificationCenterMock,
            timerMaker: timerMakerMock,
            sessionValueManager: sessionValueManagerMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: realFirstOpenTracker
        )
        let mirror = Mirror(reflecting: processor)
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertNotNil(mirror.events.first { $0["name"] as? String == "first_open" })
    }

    func testFirstOpenIntegrationIsSuppressedWhenLegacyKeyIsPreset() {
        // given: the legacy key already exists — the SDK has run on this device before this version
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        let suiteName = "EventsProcessorImplTests-firstOpen-\(UUID().uuidString)"
        let legacySuiteName = "EventsProcessorImplTests-legacy-\(UUID().uuidString)"
        let defaultsSuite = UserDefaults(suiteName: suiteName)!
        let legacySuite = UserDefaults(suiteName: legacySuiteName)!
        legacySuite.set(false, forKey: "WildAnalyticsSDK-isNewLaunch")
        defer {
            defaultsSuite.removePersistentDomain(forName: suiteName)
            legacySuite.removePersistentDomain(forName: legacySuiteName)
            FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        }
        let realFirstOpenTracker = FirstOpenTracker(defaults: defaultsSuite, legacyDefaults: legacySuite)
        enumerationCounterMock.incrementedCountStub = 0
        let processor = EventsProcessorImpl(
            batchProcessor: batchProcessorMock,
            logger: loggerMock,
            analyticsURL: TestData.url,
            interceptor: requestInterceptorMock,
            notificationCenter: notificationCenterMock,
            timerMaker: timerMakerMock,
            sessionValueManager: sessionValueManagerMock,
            appStartTracker: appStartTrackerMock,
            heartbeatTracker: heartbeatTrackerMock,
            firstOpenTracker: realFirstOpenTracker
        )
        let mirror = Mirror(reflecting: processor)
        // when
        processor.setup(
            apiKey: TestData.apiKey,
            isFirstLaunch: false,
            enableAutomaticEvents: true,
            dropCache: false,
            queue: queueMock,
            batchConfig: batchConfig,
            networkTypeProvider: networkMock,
            enumerationCounter: enumerationCounterMock
        )
        sleep(milliseconds: 300)
        // then
        XCTAssertNil(mirror.events.first { $0["name"] as? String == "first_open" })
    }
}

// MARK: TestData

private extension EventsProcessorImplTests {
    enum TestData {
        static let deviceId = "deviceId"
        static let userEngagement = UserEngagement(
            screenName: "event",
            textSize: .small,
            authType: "noAuth",
            scaleFactor: "scaleFactor"
        )
        static let userEngagementWithoutScaleFactor = UserEngagement(
            screenName: "event",
            textSize: .small,
            authType: "noAuth",
            scaleFactor: nil
        )
        static let url = URL(string: "https://example.com")!
        static let referrerURL = URL(string: "https://referrer.example.com")!
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
        static let newLaunchKey = "WildAnalyticsSDK-isNewLaunch"
        static let sessionValue = "1587023248356386046"
        static let appStartEventName = "application_start"
        static let appStartEventParameters: [String: Double] = ["ram": 64, "cpu": 4.61]
        static let idfa = "01234567-1234-1234-1234-123456789012"
        static let customHeaderKey = "X-Custom-Header"
        static let customHeaderValue = "customValue"
        static let customHeaders = ["X-Header-One": "one", "X-Header-Two": "two"]
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
        var appStartTracker: AppStartTrackerProtocol! { extract() }
        var sendEventsTimer: TimerProtocol? { extract() }
        var events: [Event]! { extract() }
        var commonParameters: [String: Any]! { extract() }
        var sessionValueManager: SessionValueManagerProtocol! { extract() }
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

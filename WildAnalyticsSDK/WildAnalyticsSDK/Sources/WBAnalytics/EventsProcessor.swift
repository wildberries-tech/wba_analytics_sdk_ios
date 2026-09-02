// Copyright © 2021 Wildberries. All rights reserved.

import UIKit

protocol EventsProcessor {
    /// Configuration for WBAnalytics.
    /// - Parameters:
    ///   - apiKey: Auth key for endpoint.
    ///   - isFirstLaunch: Deprecated. No longer affects the first_open event — the SDK determines
    ///     the first launch on its own. The value is only used to delay reading the IDFA on first launch.
    ///   - enableAutomaticEvents: Enables the automatic events of the SDK (`first_open`,
    ///     `application_start`, `heartbeat`). Disabled by default. `user_engagement` is not affected.
    ///     The value is sent in the `meta` of every batch under the `enable_automatic_events` key.
    ///   - dropCache: Delete cached events
    ///   - queue: Queue for processing batches
    ///   - batchConfig: Configuration of batch sending parameters.
    ///   - networkTypeProvider: Object that returns the current network status.
    ///   - enumerationCounter: Counts sent events and batches.
    ///   - userEngagementTracker: Tracker for shown screens.
    ///   - sessionDelegate: Custom URLSessionDelegate for handling authentication challenges of the batch sending session.
    func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        enableAutomaticEvents: Bool,
        dropCache: Bool,
        queue: DispatchQueue?,
        batchConfig: BatchConfig,
        idfaConfig: IDFAConfig,
        networkTypeProvider: NetworkTypeProviderProtocol,
        enumerationCounter: EnumerationCounter,
        userEngagementTracker:  UserEngagementTrackerProtocol?,
        sessionDelegate: URLSessionDelegate?
    )
    /// Sets common parameters for the analytics that will be added to all events
    func setCommonParameters(_ parameters: [String: Any])
    /// Adds an event to batch
    ///   - event: Event name.
    ///   - 'parameters': Event parameters
    func addEvent(_ event: String, parameters: [String: Any]?)
    /// Creates an event for user engagement
    func logUserEngagement(_ userEngagement: UserEngagement?)
    /// Creates an event for launch url
    /// - Parameters:
    ///   - url: URL the app was opened with
    ///   - referrerURL: Referrer of the link the app was opened with
    func logLaunchURL(_ url: URL, referrerURL: URL?)
    /// Log an event to batch
    ///   - event: Event name.
    ///   - 'parameters': Event parameters
    ///   - completion with result
    func logEvent(_ event: String, parameters: [String: Any]?, completion: @escaping (_ successfully: Bool) -> Void)

    /// Set authenticated user token
    /// - Parameter token: Token
    func setUserToken(_ token: String?)
    /// Set a single custom header that will be added to all batch requests
    /// - Parameters:
    ///   - key: Header field name
    ///   - value: Header field value
    func setCustomHeader(key: String, value: String)
    /// Set custom headers that will be added to all batch requests
    /// - Parameter headers: Dictionary of header field names and values
    func setCustomHeaders(_ headers: [String: String])
    /// Set device id
    func setDeviceId(_ deviceId: String?)
    /// Set a unique session value
    func setSessionValue(_ value: String?)
    /// Set a handler called when session value updates
    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void)
}

final class EventsProcessorImpl: EventsProcessor {

    private enum Constants {
        static let logLabel = "EventsProcessor"
        static let analyticsQueueName = "WBAnalytics"
        static let newLaunchKey = "WildAnalyticsSDK-isNewLaunch"
        static let maxBatchSizeInBytes: Int = 512 * 1024
        static let heartbeatInterval = 30.0
    }

    private let logger: Logger
    private let analyticsURL: URL
    private let interceptor: RequestInterceptor
    private let batchProcessor: BatchProcessor
    private var userEngagementTracker: UserEngagementTrackerProtocol!
    private let notificationCenter: NotificationCenter
    private var queue: DispatchQueue
    private var batchConfig: BatchConfig!
    private var counter: EnumerationCounter!
    private var sendEventsTimer: TimerProtocol?
    private let timerMaker: TimerProtocol.Type
    private let sessionValueManager: SessionValueManagerProtocol
    private let appStartTracker: AppStartTrackerProtocol
    private let heartbeatTracker: PeriodicTrackerProtocol
    private let firstOpenTracker: FirstOpenTrackerProtocol
    private var enableAutomaticEvents = false

    private var events = [Event]()
    private var commonParameters = [String: Any]()

    private let customHeadersQueue = DispatchQueue(
        label: "\(Constants.analyticsQueueName).customHeaders",
        attributes: .concurrent
    )
    private var _customHeaders = [String: String]()

    init(
        batchProcessor: BatchProcessor,
        logger: Logger,
        analyticsURL: URL,
        interceptor: RequestInterceptor,
        notificationCenter: NotificationCenter = .default,
        timerMaker: TimerProtocol.Type = Timer.self,
        sessionValueManager: SessionValueManagerProtocol = SessionValueManager.shared,
        appStartTracker: AppStartTrackerProtocol,
        heartbeatTracker: PeriodicTrackerProtocol = PeriodicTracker(interval: Constants.heartbeatInterval),
        firstOpenTracker: FirstOpenTrackerProtocol = FirstOpenTracker(),
        queue: DispatchQueue = DispatchQueue(
            label: Constants.analyticsQueueName,
            qos: .default
        )
    ) {
        self.batchProcessor = batchProcessor
        self.logger = logger
        self.analyticsURL = analyticsURL
        self.interceptor = interceptor
        self.notificationCenter = notificationCenter
        self.timerMaker = timerMaker
        self.sessionValueManager = sessionValueManager
        self.appStartTracker = appStartTracker
        self.heartbeatTracker = heartbeatTracker
        self.firstOpenTracker = firstOpenTracker
        self.queue = queue
    }

    func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        enableAutomaticEvents: Bool = false,
        dropCache: Bool,
        queue: DispatchQueue? = nil,
        batchConfig: BatchConfig,
        idfaConfig: IDFAConfig = IDFAConfig(),
        networkTypeProvider: NetworkTypeProviderProtocol,
        enumerationCounter: EnumerationCounter = UserDefaultsEnumerationCounter(),
        userEngagementTracker:  UserEngagementTrackerProtocol? = nil,
        sessionDelegate: URLSessionDelegate? = nil
    ) {
        logger.debug(Constants.logLabel, "---------------------")

        self.batchConfig = batchConfig
        self.enableAutomaticEvents = enableAutomaticEvents
        self.counter = enumerationCounter
        self.userEngagementTracker = userEngagementTracker ?? UserEngagementTracker(delegate: self)
        if let queue {
            self.queue = queue
        }
        let batchSender: BatchSender = BatchSenderImpl(
            apiKey: apiKey,
            analyticsURL: analyticsURL,
            queue: self.queue,
            batchConfig: batchConfig,
            logger: logger,
            interceptor: interceptor,
            sessionDelegate: sessionDelegate
        )
        subscribeForNotifications()

        logger.info(
            Constants.logLabel,
            "Setup is finished, isFirstLaunch = \(isFirstLaunch) dropCache: \(dropCache), queue: \(String(describing: queue))"
        )

        async { [weak self] in
            guard let self else { return }
            // On the first launch, postpone reading the IDFA for the configured interval so the app
            // can request ATT authorization and the user can answer. Events still flow during this
            // window — they just carry an empty device_ad_id until the IDFA reader is activated.
            let idfaDelay = isFirstLaunch ? idfaConfig.firstLaunchIDFADelay : 0
            let idfaProvider = DelayedIDFAProvider(
                wrapped: SystemIDFAProvider(isDisabled: idfaConfig.isDisabled),
                isActive: idfaDelay <= 0
            )
            self.batchProcessor.setup(
                batchSender: batchSender,
                queue: self.queue,
                networkTypeProvider: networkTypeProvider,
                counter: self.counter,
                batchWorker: BatchWorkerImpl(
                    queue: self.queue,
                    batchConfig: batchConfig
                ),
                idfaProvider: idfaProvider,
                enableAutomaticEvents: enableAutomaticEvents
            )
            let storedHeaders = self.customHeadersQueue.sync { self._customHeaders }
            if !storedHeaders.isEmpty {
                self.batchProcessor.setCustomHeaders(storedHeaders)
            }
            self.batchProcessor.launch()
            // FirstOpenTracker captures the migration flag (the legacy isNewLaunch key) once, when
            // it's created in EventsProcessorImpl.init, rather than reading UserDefaults here — so
            // the call order relative to checkOnNewLaunch() below (which creates that key) no longer
            // affects the result of trackIfNeeded
            if enableAutomaticEvents {
                self.firstOpenTracker.trackIfNeeded(apiKey: apiKey) { [weak self] in
                    self?.addEvent(Event.Name.firstOpen)
                }
            }
            self.checkOnNewLaunch()

            self.userEngagementTracker.start()
            if enableAutomaticEvents {
                self.heartbeatTracker.setup { [weak self] in
                    self?.addEvent(Event.Name.heartbeat)
                }
                self.heartbeatTracker.start()
            }
            self.startSendEventsTimer()
            if idfaDelay > 0 {
                self.queue.asyncAfter(deadline: .now() + idfaDelay) { [weak idfaProvider] in
                    idfaProvider?.activate()
                }
            }
            // application_start now goes through the regular addEvent path: it's batched, persisted
            // in CoreData, and retried by the shared batch pipeline — the tracker no longer has its
            // own retry logic, which avoids duplicate events on a flaky network (see BatchProcessor's
            // retry state machine).
            if enableAutomaticEvents {
                self.appStartTracker.setup { [weak self] input in
                    self?.addEvent(input.name, parameters: input.parameters)
                }
            }
        }
    }

    deinit {
        notificationCenter.removeObserver(self)
        stopSendEventsTimer()
        heartbeatTracker.invalidate()
    }

    func setCommonParameters(_ parameters: [String: Any]) {
        async { [weak self] in
            guard let self else { return }
            self.commonParameters = parameters
            self.logger.info(Constants.logLabel, "setCommonParameters: \(parameters)")
        }
    }

    func setUserToken(_ token: String?) {
        batchProcessor.setUserToken(token)
    }

    func setCustomHeader(key: String, value: String) {
        let headers: [String: String] = customHeadersQueue.sync(flags: .barrier) {
            _customHeaders[key] = value
            return _customHeaders
        }
        logger.info(Constants.logLabel, "setCustomHeader: \(key)")
        batchProcessor.setCustomHeaders(headers)
    }

    func setCustomHeaders(_ headers: [String: String]) {
        let merged: [String: String] = customHeadersQueue.sync(flags: .barrier) {
            _customHeaders.merge(headers) { _, new in new }
            return _customHeaders
        }
        logger.info(Constants.logLabel, "setCustomHeaders: \(headers.keys)")
        batchProcessor.setCustomHeaders(merged)
    }

    func setDeviceId(_ deviceId: String?) {
        batchProcessor.setDeviceId(deviceId)
    }

    func setSessionValue(_ value: String?) {
        sessionValueManager.setSessionValue(value)
    }

    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void) {
        sessionValueManager.setOnSessionValueUpdated(handler)
    }

    func addEvent(_ event: String, parameters: [String: Any]? = nil) {
        async { [weak self] in
            guard let self else { return }
            self.processEvent(event, parameters: parameters)
        }
    }

    func logEvent(_ event: String, parameters: [String: Any]?, completion: @escaping (_ successfully: Bool) -> Void) {
        processEventSync(event, parameters: parameters, completion: completion)
    }

    func logUserEngagement(_ userEngagement: UserEngagement?) {
        async { [weak self] in
            guard let self else { return }
            let message = "logUserEngagement screenName: \(userEngagement?.screenName ?? "")"
            self.logger.debug(Constants.logLabel, message)
            self.userEngagementTracker.set(userEngagement: userEngagement)
        }
    }

    func logLaunchURL(_ url: URL, referrerURL: URL?) {
        async { [weak self] in
            guard let self else { return }
            var parameters = ["link": url.absoluteString]
            if let referrerURL {
                parameters["referrerURL"] = referrerURL.absoluteString
            }
            self.logger.debug(Constants.logLabel, "logLaunchURL parameters: \(parameters)")
            self.processEvent(Event.Name.openAppWithLink, parameters: parameters)
        }
    }

    // MARK: - Private

    /// Starts the heartbeat timer only if automatic events are enabled in the configuration.
    /// The paired `invalidate()` stays unconditional: it is a no-op on a timer that was never started.
    private func startHeartbeatIfNeeded() {
        guard enableAutomaticEvents else { return }
        heartbeatTracker.start()
    }

    @objc private func willEnterForeground() {
        async { [weak self] in
            guard let self else { return }
            self.userEngagementTracker.start()
            self.startHeartbeatIfNeeded()
            self.startSendEventsTimer()
            self.logger.debug(Constants.logLabel, "willEnterForeground")
        }
    }

    @objc private func didEnterBackground() {
        async { [weak self] in
            guard let self else { return }
            self.stopSendEventsTimer()
            self.userEngagementTracker.invalidate()
            self.heartbeatTracker.invalidate()
            self.makeBatch()
            self.logger.debug(Constants.logLabel, "didEnterBackground")
        }
    }

    @objc private func willTerminate() {
        async { [weak self] in
            guard let self else { return }
            self.stopSendEventsTimer()
            self.userEngagementTracker.invalidate()
            self.heartbeatTracker.invalidate()
            self.makeBatch()
            self.logger.debug(Constants.logLabel, "willTerminate")
        }
    }

    private func checkOnNewLaunch() {
        guard let isNewLaunch = UserDefaults.standard.object(forKey: Constants.newLaunchKey) as? Bool else {
            UserDefaults.standard.set(true, forKey: Constants.newLaunchKey)
            batchProcessor.update(isNewLaunch: true)
            return
        }

        if isNewLaunch {
            makeBatch()
            UserDefaults.standard.set(false, forKey: Constants.newLaunchKey)
        } else {
            batchProcessor.update(isNewLaunch: false)
        }
    }

    private func subscribeForNotifications() {
        notificationCenter.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(willTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    private func trackUserEngagementEvents(userEngagement: UserEngagement?) {
        guard let userEngagement,
              let parametersDictionary = userEngagement.dictionary
        else { return }
        let currentTime = Date().timeIntervalSince1970
        let eventParameters: [String: Any] = parametersDictionary

        processEvent(
            Event.Name.userEngagement,
            parameters: eventParameters,
            date: Date(timeIntervalSince1970: currentTime)
        )
    }

    private func processEvent(_ event: String, parameters: [String: Any]? = nil, date: Date? = nil) {
        let timeString = (date ?? Date()).asString
        var parameters = parameters ?? [:]
        parameters.merge(commonParameters) { (current, _) in current }

        let eventNum = counter.incrementedCount(for: CounterParams.eventNum)
        let sessionValue = sessionValueManager.sessionValue
        let event = Event(name: event, data: parameters, time: timeString, eventNum: eventNum, sessionValue: sessionValue)
        events.append(event)

        logger.debug(Constants.logLabel, "processEvent: \(event)")

        if events.count >= batchConfig.size || DeviceMemoryState.state == .noMemory {
            makeBatch()
        }
    }

    private func processEventSync(
        _ event: String,
        parameters: [String: Any]? = nil,
        date: Date? = nil,
        completion: @escaping (
            _ successfully: Bool
        ) -> Void
    ) {
        let timeString = (date ?? Date()).asString
        var parameters = parameters ?? [:]
        parameters.merge(commonParameters) { (current, _) in current }

        let eventNum = counter.incrementedCount(for: CounterParams.eventNum)
        let sessionValue = sessionValueManager.sessionValue
        let event = Event(name: event, data: parameters, time: timeString, eventNum: eventNum, sessionValue: sessionValue)

        logger.debug(Constants.logLabel, "processEvent: \(event)")

        batchProcessor.sendEventSync(event: event, completion: completion)
    }

    private func makeBatch() {
        guard !events.isEmpty else {
            logger.debug(Constants.logLabel, "no events to make a batch, skipping")
            return
        }
        let maxBytes = Constants.maxBatchSizeInBytes // 512 KB
        let batches = splitEventsByMaxBytes(events: events, maxBytes: maxBytes)
        for batch in batches {
            batchProcessor.addBatch(withEvents: batch)
        }
        events = []
    }
}

// MARK: - Private functions
private extension EventsProcessorImpl {
    func splitEventsByMaxBytes(events: [Event], maxBytes: Int) -> [[Event]] {
        var result = [[Event]]()
        var chunk = [Event]()
        var chunkSize = 0

        for event in events {
            let size = eventSize(event)
            switch (size >= maxBytes, chunkSize + size >= maxBytes) {
            // Event exceeds the limit on its own — goes into its own chunk
            case (true, _):
                if !chunk.isEmpty {
                    result.append(chunk)
                    chunk.removeAll()
                    chunkSize = 0
                }
                result.append([event])
            // Doesn't fit in the current chunk — flush it and start a new one
            case (false, true):
                if !chunk.isEmpty { result.append(chunk) }
                chunk = [event]
                chunkSize = size
            // Fits — add it to the current chunk
            case (false, false):
                chunk.append(event)
                chunkSize += size
            }
        }
        if !chunk.isEmpty { result.append(chunk) }
        return result
    }

    func eventSize(_ event: Event) -> Int {
        guard JSONSerialization.isValidJSONObject(event),
              let data = try? JSONSerialization.data(withJSONObject: event, options: []) else {
            // If the object can't be serialized — return the maximum allowed size
            return Constants.maxBatchSizeInBytes
        }
        return data.count
    }
}

// MARK: - Processor queue calls

private extension EventsProcessorImpl {

    func async(_ block: @escaping () -> Void) {
        queue.async { block() }
    }
}

// MARK: - Sending timer

private extension EventsProcessorImpl {

    private func startSendEventsTimer() {
        stopSendEventsTimer()
        async { [weak self] in
            guard let self else { return }
            logger.debug(Constants.logLabel, "start events sending timer...")
            sendEventsTimer = timerMaker.timer(with: batchConfig.sendingTimerTimeout, repeats: true, block: { [weak self] _ in
                guard let self else { return }
                self.async { [weak self] in
                    guard let self = self else { return }
                    self.logger.debug(Constants.logLabel, "scheduled next event batch sending...")
                    self.makeBatch()
                }
            })
        }
        queue.async { [weak self] in
            self?.sendEventsTimer?.schedule(on: .main)
        }
    }

    private func stopSendEventsTimer() {
        guard let timer = sendEventsTimer, timer.isValid else { return }
        logger.debug(Constants.logLabel, "reset events sending timer")
        timer.invalidate()
        sendEventsTimer = nil
    }

}

// MARK: - UserEngagementTrackerDelegate

extension EventsProcessorImpl: UserEngagementTrackerDelegate {

    func didUserEngagementTrackerFire(_ userEngagement: UserEngagement?) {
        async({ [weak self] in
            guard let self else { return }
            self.trackUserEngagementEvents(userEngagement: userEngagement)
        })
    }
}

// Copyright © 2021 Wildberries. All rights reserved.

import UIKit

protocol EventsProcessor {
    /// Configuration for WBAnalytics.
    /// - Parameters:
    ///   - apiKey: Auth key for endpoint.
    ///   - isFirstLaunch: First launch option, affects sending first run event
    ///   - dropCache: Delete cached events
    ///   - queue: Queue for processing batches
    ///   - batchConfig: Сonfiguration of batch sending parameters.
    ///   - networkTypeProvider: Object that returns the current network status.
    ///   - enumerationCounter: Counts sent events and batches.
    ///   - userEngagementTracker: Tracker for shown screens.
    func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        dropCache: Bool,
        queue: DispatchQueue?,
        batchConfig: BatchConfig,
        networkTypeProvider: NetworkTypeProviderProtocol,
        enumerationCounter: EnumerationCounter,
        userEngagementTracker:  UserEngagementTrackerProtocol?
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
    func logLaunchURL(_ url: URL)
    /// Log an event to batch
    ///   - event: Event name.
    ///   - 'parameters': Event parameters
    ///   - completion with result
    func logEvent(_ event: String, parameters: [String: Any]?, completion: @escaping (_ successfully: Bool) -> Void)

    /// Set authenticated user token
    /// - Parameter token: Token
    func setUserToken(_ token: String?)
}

final class EventsProcessorImpl: EventsProcessor {

    private enum Constants {
        static let logLabel = "EventsProcessor"
        static let analyticsQueueName = "WBAnalytics"
        static let newLaunchKey = "WBMAnalytics-isNewLaunch"
        static let maxBatchSizeInBytes: Int = 512 * 1024
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

    private var events = [Event]()
    private var commonParameters = [String: Any]()

    init(
        batchProcessor: BatchProcessor,
        logger: Logger,
        analyticsURL: URL,
        interceptor: RequestInterceptor,
        notificationCenter: NotificationCenter = NotificationCenter.default,
        timerMaker: TimerProtocol.Type = Timer.self,
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
        self.queue = queue
    }

    func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        dropCache: Bool,
        queue: DispatchQueue? = nil,
        batchConfig: BatchConfig,
        networkTypeProvider: NetworkTypeProviderProtocol,
        enumerationCounter: EnumerationCounter = UserDefaultsEnumerationCounter(),
        userEngagementTracker:  UserEngagementTrackerProtocol? = nil
    ) {
        logger.debug(Constants.logLabel, "---------------------")

        self.batchConfig = batchConfig
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
            interceptor: interceptor
        )
        subscribeForNotifications()

        logger.info(
            Constants.logLabel,
            "Setup is finished, isFirstLaunch = \(isFirstLaunch) dropCache: \(dropCache), queue: \(String(describing: queue))"
        )

        async { [weak self] in
            guard let self else { return }
            self.batchProcessor.setup(
                batchSender: batchSender,
                queue: self.queue,
                networkTypeProvider: networkTypeProvider,
                counter: self.counter,
                batchWorker: BatchWorkerImpl(
                    queue: self.queue,
                    batchConfig: batchConfig
                )
            )
            self.batchProcessor.launch()
            self.checkOnNewLaunch()
            if isFirstLaunch {
                self.addEvent(Event.Name.firstOpen)
            }

            self.userEngagementTracker.start()
            self.startSendEventsTimer()
        }
    }

    deinit {
        notificationCenter.removeObserver(self)
        stopSendEventsTimer()
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

    func logLaunchURL(_ url: URL) {
        async { [weak self] in
            guard let self else { return }
            let parameters = ["link": url.absoluteString]
            self.logger.debug(Constants.logLabel, "logLaunchURL parameters: \(parameters)")
            self.processEvent(Event.Name.openAppWithLink, parameters: parameters)
        }
    }

    // MARK: - Private

    @objc private func willEnterForeground() {
        async { [weak self] in
            guard let self else { return }
            self.userEngagementTracker.start()
            self.startSendEventsTimer()
            self.logger.debug(Constants.logLabel, "willEnterForeground")
        }
    }

    @objc private func didEnterBackground() {
        async { [weak self] in
            guard let self else { return }
            self.stopSendEventsTimer()
            self.userEngagementTracker.invalidate()
            self.makeBatch()
            self.logger.debug(Constants.logLabel, "didEnterBackground")
        }
    }

    @objc private func willTerminate() {
        async { [weak self] in
            guard let self else { return }
            self.stopSendEventsTimer()
            self.userEngagementTracker.invalidate()
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
        let event = Event(name: event, data: parameters, time: timeString, eventNum: eventNum)
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
        let event = Event(name: event, data: parameters, time: timeString, eventNum: eventNum)

        logger.debug(Constants.logLabel, "processEvent: \(event)")

        batchProcessor.sendEventSync(event: event, completion: completion)
    }

    private func makeBatch() {
        guard !events.isEmpty else {
            logger.debug(Constants.logLabel, "no events to make a batch, skipping")
            return
        }
        let maxBytes = Constants.maxBatchSizeInBytes // 512 кб 
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
            // Событие больше лимита — отдельная пачка
            case (true, _):
                if !chunk.isEmpty {
                    result.append(chunk)
                    chunk.removeAll()
                    chunkSize = 0
                }
                result.append([event])
            // Не влезает в текущую пачку — сохраняем пачку, начинаем новую
            case (false, true):
                if !chunk.isEmpty { result.append(chunk) }
                chunk = [event]
                chunkSize = size
            // Влезает — добавляем в текущую пачку
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
            // Если объект нельзя сериализовать — возвращаем максимальный допустимый размер
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

// Copyright © 2021 Wildberries. All rights reserved.

import Foundation

/// Public delegate of WBAnalytics
public protocol WBAnalyticsDelegateProtocol: AnyObject {

    /// Called when WB Tracker found an attributed deeplink that can be handled by the client
    /// - Parameter link: URL
    func didResolveAttributedLink(_ link: URL)
}

/// WBAnalytics provides functionalities for setting up analytics,
/// logging events, viewing screens, logging launch URLs and accessing device ID.
public class WBAnalytics {

    private enum Constants {
        static let deviceId = "deviceId"
        static let defaultsSuiteName = "WBAnalyticsDefaults"
    }

    private static let defaults = UserDefaults(suiteName: Constants.defaultsSuiteName)

    private lazy var processor: EventsProcessor = EventsProcessorImpl(
        batchProcessor: BatchProcessorImpl(
            logger: logger,
            storage: StorageImpl(logger: logger, coreDataStack: CoreDataStack(apiKey: apiKey, logger: logger)),
            userDefaultsStorage: UserDefaultsStorageImpl(
                apiKey: apiKey,
                logger: logger,
                defaults: Self.defaults
            )
        ),
        logger: logger,
        analyticsURL: analyticsURL,
        interceptor: interceptor
    )

    lazy var logger = {
        let consoleLogger = ConsoleLogger(apiKey: apiKey)
        return CompositeLogger(loggers: [
            consoleLogger,
            FileLogger(apiKey: apiKey, logger: consoleLogger),
        ])
    }()

    lazy var configProvider: ConfigProvider = ConfigProvider(logger: logger)

    private lazy var attributionTracker: WBTracker = {
        WBTracker(logger: logger)
    }()

    private let apiKey: String
    private let analyticsURL: URL
    private let interceptor: RequestInterceptor
    private weak var delegate: WBAnalyticsDelegateProtocol?

    static var loggingOptions: LoggingOptions = .default

    private init(
        apiKey: String,
        analyticsURL: URL,
        interceptor: RequestInterceptor
    ) {
        self.apiKey = apiKey
        self.analyticsURL = analyticsURL
        self.interceptor = interceptor
    }

    /// This function is used to setup the analytics with the provided parameters.
    /// It should be called in your app's application:didFinishLaunchingWithOptions: method.
    public static func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        enableAttributionTracking: Bool,
        dropCache: Bool,
        networkTypeProvider: NetworkTypeProviderProtocol,
        queue: DispatchQueue? = nil,
        batchConfig: BatchConfig,
        analyticsURL: URL,
        interceptor: RequestInterceptor,
        loggingOptions: LoggingOptions = .default,
        delegate: WBAnalyticsDelegateProtocol? = nil
    ) -> WBAnalytics {
        let analytics = WBAnalytics(
            apiKey: apiKey,
            analyticsURL: analyticsURL,
            interceptor: interceptor
        )
        Self.loggingOptions = loggingOptions
        analytics.processor.setup(
            apiKey: apiKey,
            isFirstLaunch: isFirstLaunch,
            dropCache: dropCache,
            queue: queue,
            batchConfig: batchConfig,
            networkTypeProvider: networkTypeProvider,
            enumerationCounter: UserDefaultsEnumerationCounter(),
            userEngagementTracker: nil
        )

        analytics.delegate = delegate
        analytics.checkAttribution()
        return analytics
    }

    /// Set authenticated user token
    /// - Parameter token: Token
    public func setUserToken(_ token: String?) {
        processor.setUserToken(token)
    }

    /// This function is used to set common parameters for the analytics.
    public func setCommonParameters(_ parameters: [String: Any]) {
        processor.setCommonParameters(parameters)
    }

    /// This function is used to log an event with the provided parameters.
    public func log(_ event: String, parameters: [String: Any]? = nil) {
        processor.addEvent(event, parameters: parameters)
    }

    /// This function is used to log a screen view with the provided name.
    public func logUserEngagement(_ userEngagement: UserEngagement?) {
        processor.logUserEngagement(userEngagement)
    }

    /// This function is used to log a launch URL.
    public func logLaunchURL(_ url: URL) {
        processor.logLaunchURL(url)
    }

    /// This function is used to log an event with the provided parameters sync
    func logEvent(_ event: String, parameters: [String: Any]?, completion: @escaping (_ successfully: Bool) -> Void) {
        processor.logEvent(event, parameters: parameters, completion: completion)
    }

    /// Access the device ID.
    public static var deviceId: String {
        if let id = defaults?.string(forKey: Constants.deviceId) {
            return id
        } else {
            let id = String(UInt64.random(in: UInt64.min...UInt64.max))
            defaults?.set(id, forKey: Constants.deviceId)
            return id
        }
    }

    /// Send app_install
    public func reportInstall(parameters: [String: Any]? = nil) {
        processor.addEvent("app_install", parameters: parameters)
    }

    /// Check possible attribution
    private func checkAttribution() {
        attributionTracker.checkAttribution { [weak self] result in
            switch result {
            case .success(let data):
                guard data != nil else { return }

                // report install
                let parameters = data?.parametersAsAny() ?? [:]
                self?.reportInstall(parameters: parameters)

                // resolve a link
                if let link = data?.link, let url = URL(string: link) {
                    self?.delegate?.didResolveAttributedLink(url)
                }
            case .failure:
                // do nothing with that
                break
            }
        }
    }
}

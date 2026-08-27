// Copyright © 2021 Wildberries. All rights reserved.

import Foundation
import UIKit

/// Public delegate of WBAnalytics
public protocol WildAnalyticsDelegateProtocol: AnyObject {

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
        interceptor: interceptor,
        appStartTracker: AppStartTracker()
    )

    lazy var logger = {
        let consoleLogger = ConsoleLogger(apiKey: apiKey)
        return CompositeLogger(loggers: [
            consoleLogger,
            FileLogger(apiKey: apiKey, logger: consoleLogger),
        ])
    }()

    lazy var configProvider: ConfigProvider = ConfigProvider(logger: logger)

    private lazy var attributionTracker: WildTracker = {
        WildTracker(apiKey: apiKey, logger: logger, sessionDelegate: sessionDelegate)
    }()

    private let apiKey: String
    private let analyticsURL: URL
    private let interceptor: RequestInterceptor
    private let sessionDelegate: URLSessionDelegate?
    private weak var delegate: WildAnalyticsDelegateProtocol?

    static var loggingOptions: LoggingOptions = .default

    private init(
        apiKey: String,
        analyticsURL: URL,
        interceptor: RequestInterceptor,
        sessionDelegate: URLSessionDelegate?
    ) {
        self.apiKey = apiKey
        self.analyticsURL = analyticsURL
        self.interceptor = interceptor
        self.sessionDelegate = sessionDelegate
    }

    /// This function is used to setup the analytics with the provided parameters.
    /// It should be called in your app's application:didFinishLaunchingWithOptions: method.
    /// - Note: The `isFirstLaunch` parameter no longer affects the `first_open` event — the SDK determines the first launch on its own.
    public static func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        enableAttributionTracking: Bool,
        enableAutomaticEvents: Bool = true,
        dropCache: Bool,
        networkTypeProvider: NetworkTypeProviderProtocol,
        queue: DispatchQueue? = nil,
        batchConfig: BatchConfig,
        idfaConfig: IDFAConfig = IDFAConfig(),
        analyticsURL: URL,
        interceptor: RequestInterceptor,
        loggingOptions: LoggingOptions = .default,
        sessionDelegate: URLSessionDelegate? = nil,
        delegate: WildAnalyticsDelegateProtocol? = nil
    ) -> WBAnalytics {
        let analytics = WBAnalytics(
            apiKey: apiKey,
            analyticsURL: analyticsURL,
            interceptor: interceptor,
            sessionDelegate: sessionDelegate
        )
        Self.loggingOptions = loggingOptions
        analytics.processor.setup(
            apiKey: apiKey,
            isFirstLaunch: isFirstLaunch,
            enableAutomaticEvents: enableAutomaticEvents,
            dropCache: dropCache,
            queue: queue,
            batchConfig: batchConfig,
            idfaConfig: idfaConfig,
            networkTypeProvider: networkTypeProvider,
            enumerationCounter: UserDefaultsEnumerationCounter(),
            userEngagementTracker: nil,
            sessionDelegate: sessionDelegate
        )

        analytics.delegate = delegate

        if enableAttributionTracking {
            analytics.checkAttribution()
        }
        return analytics
    }

    /// Set authenticated user token
    /// - Parameter token: Token
    public func setUserToken(_ token: String?) {
        processor.setUserToken(token)
    }

    public func setDeviceId(_ deviceId: String?) {
        processor.setDeviceId(deviceId)
    }

    /// Set a single custom header that will be added to all analytics requests.
    /// - Parameters:
    ///   - key: Header field name
    ///   - value: Header field value
    public func setCustomHeader(key: String, value: String) {
        processor.setCustomHeader(key: key, value: value)
    }

    /// Set custom headers that will be added to all analytics requests.
    /// - Parameter headers: Dictionary of header field names and values
    public func setCustomHeaders(_ headers: [String: String]) {
        processor.setCustomHeaders(headers)
    }

    /// Sets a unique session value
    public func setSessionValue(_ value: String?) {
        processor.setSessionValue(value)
    }

    /// Set a handler called when session value updates
    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void) {
        processor.setOnSessionValueUpdated(handler)
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
    /// - Parameters:
    ///   - url: URL the app was opened with
    ///   - referrerURL: Referrer of the link the app was opened with
    public func logLaunchURL(_ url: URL, referrerURL: URL? = nil) {
        processor.logLaunchURL(url, referrerURL: referrerURL)
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

    /// Show logs
    public static func logsViewController(apiKeys: [String]) -> UIViewController {
        ReceiversListViewController(apiKeys: apiKeys)
    }

    /// Check possible attribution
    private func checkAttribution() {
        attributionTracker.checkAttribution { [weak self] result in
            switch result {
            case .success(let attributionResult):
                guard let attributionResult else { return }

                // Prepare parameters with fingerprint data as user_attributes and attribution response as fingerprint_gathered
                var parameters: [String: Any] = [:]

                // Add attribution response as fingerprint_gathered
                if let attributionData = attributionResult.attributionData {
                    if let attributionParameters = attributionData.parametersAsAny() {
                        parameters.merge(attributionParameters) { _, new in new }
                    }

                    if let deeplink = attributionData.deeplink {
                        parameters["deeplink"] = deeplink
                    }

                    // resolve a link
                    if let deeplink = attributionData.deeplink, let url = URL(string: deeplink) {
                        self?.delegate?.didResolveAttributedLink(url)
                    }
                }
                // report install
                self?.reportInstall(parameters: parameters)
            case .failure:
                // do nothing with that
                break
            }
        }
    }
}

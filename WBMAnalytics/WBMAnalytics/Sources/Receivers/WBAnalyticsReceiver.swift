//  Copyright © 2021 Wildberries LLC. All rights reserved.

import Foundation

/// Configuration for WBAnalytics.
public final class WBAnalyticsReceiver {

    // MARK: - Properties
    private let apiKey: String
    private let analyticsURL: URL
    private let interceptor: RequestInterceptor
    private let isFirstLaunch: Bool
    private let enableAttributionTracking: Bool
    private let loggingOptions: LoggingOptions
    private let networkTypeProvider: NetworkTypeProviderProtocol
    private let batchConfig: BatchConfig
    private var analyticsInstance: WBAnalytics?
    private weak var delegate: WBAnalyticsDelegateProtocol?

    // MARK: - Initialization
    /// Configuration for WBAnalytics.
    /// - Parameters:
    ///   - environment: Applicaton environment: production or debug.
    ///   - analyticsURL: URL for sending analytics.
    ///   - isFirstLaunch: First launch option affects sending first run event
    ///   - enableAttributionTracking - Enable WB Tracker
    ///   - loggingOptions: Structure that holds the logging configurations.
    ///   - networkTypeProvider: Object that returns the current network status.
    ///   - batchConfig: Сonfiguration of batch sending parameters.
    public init(
        apiKey: String,
        analyticsURL: URL = WBAnalyticsReceiver.defaultAnalyticsURL,
        inteceptor: RequestInterceptor = NoOpInterceptor(),
        isFirstLaunch: Bool,
        enableAttributionTracking: Bool = false,
        loggingOptions: LoggingOptions,
        networkTypeProvider: NetworkTypeProviderProtocol,
        batchConfig: BatchConfig,
        delegate: WBAnalyticsDelegateProtocol? = nil
    ) {
        self.apiKey = apiKey
        self.analyticsURL = analyticsURL
        self.interceptor = inteceptor
        self.isFirstLaunch = isFirstLaunch
        self.enableAttributionTracking = enableAttributionTracking
        self.loggingOptions = loggingOptions
        self.networkTypeProvider = networkTypeProvider
        self.batchConfig = batchConfig
        self.delegate = delegate
    }
}

// MARK: - AnalyticsReceiver
extension WBAnalyticsReceiver: AnalyticsReceiver {

    /// Unique identifier for receiver
    public static var identifier: String {
        "ru.wildberries.receiver_" + String(describing: WBAnalyticsReceiver.self).lowercased()
    }

    /// Unique identifier for receiver
    public var identifier: String {
        return Self.identifier
    }

    /// Setup the analytics SDK with the provided parameters.
    /// It should be called in your app's application:didFinishLaunchingWithOptions: method.
    public func setup() {
        analyticsInstance = WBAnalytics.setup(
            apiKey: apiKey,
            isFirstLaunch: isFirstLaunch,
            enableAttributionTracking: enableAttributionTracking,
            dropCache: false,
            networkTypeProvider: networkTypeProvider,
            batchConfig: batchConfig,
            analyticsURL: analyticsURL,
            interceptor: interceptor,
            loggingOptions: loggingOptions,
            delegate: delegate
        )
    }

    public func setUserToken(_ token: String?) {
        analyticsInstance?.setUserToken(token)
    }

    /// Sets common parameters for the analytics.
    public func setCommonParameters(_ parameters: [String: Any]) {
        analyticsInstance?.setCommonParameters(parameters)
    }

    /// Logs an event with the provided parameters.
    public func trackEvent(name: String, parameters: [String: Any]?) {
        analyticsInstance?.log(name, parameters: parameters ?? [:])
    }

    /// Logs a screen viewed with the provided name.
    public func trackUserEngagement(_ userEngagement: UserEngagement) {
        analyticsInstance?.logUserEngagement(userEngagement)
    }
}

extension WBAnalyticsReceiver: AnalyticsCompletionReceiver {

    /// Tracks an event with a completion handler to indicate success or failure.
    public func trackEventWithCompletion(name: String, parameters: [String : Any]?, completion: @escaping (Bool) -> Void) {
        analyticsInstance?.logEvent(name, parameters: parameters, completion: completion)
    }
}

extension WBAnalyticsReceiver {

    public static var defaultAnalyticsURL: URL {
        URL(string: "https://a.wb.ru/m/batch")!
    }
}

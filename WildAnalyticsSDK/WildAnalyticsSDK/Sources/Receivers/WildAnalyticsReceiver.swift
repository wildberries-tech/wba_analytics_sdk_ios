//  Copyright © 2021 Wildberries LLC. All rights reserved.

import Foundation
import UIKit

/// Configuration for WBAnalytics.
public final class WildAnalyticsReceiver {

    // MARK: - Properties
    private let apiKey: String
    private let analyticsURL: URL
    private let interceptor: RequestInterceptor
    private let isFirstLaunch: Bool
    private let enableAttributionTracking: Bool
    private let loggingOptions: LoggingOptions
    private let networkTypeProvider: NetworkTypeProviderProtocol
    private let batchConfig: BatchConfig
    private let sessionDelegate: URLSessionDelegate?
    private let idfaConfig: IDFAConfig
    private var analyticsInstance: WBAnalytics?
    private weak var delegate: WildAnalyticsDelegateProtocol?

    // MARK: - Initialization
    /// Configuration for WBAnalytics.
    /// - Parameters:
    ///   - environment: Applicaton environment: production or debug.
    ///   - analyticsURL: URL for sending analytics.
    ///   - isFirstLaunch: Deprecated. No longer affects the first_open event — the SDK determines
    ///     the first launch on its own. The value is only used to delay reading the IDFA on first launch.
    ///   - enableAttributionTracking - Enable WB Tracker
    ///   - loggingOptions: Structure that holds the logging configurations.
    ///   - networkTypeProvider: Object that returns the current network status.
    ///   - batchConfig: Configuration of batch sending parameters.
    ///   - idfaConfig: Configuration of the advertising identifier (IDFA) collection.
    ///   - sessionDelegate: Custom URLSessionDelegate for handling authentication challenges (e.g. SSL pinning) of the batch sending session.
    public init(
        apiKey: String,
        analyticsURL: URL = WildAnalyticsReceiver.defaultAnalyticsURL,
        inteceptor: RequestInterceptor = NoOpInterceptor(),
        isFirstLaunch: Bool,
        enableAttributionTracking: Bool = true,
        loggingOptions: LoggingOptions,
        networkTypeProvider: NetworkTypeProviderProtocol,
        batchConfig: BatchConfig,
        idfaConfig: IDFAConfig = IDFAConfig(),
        sessionDelegate: URLSessionDelegate? = nil,
        delegate: WildAnalyticsDelegateProtocol? = nil
    ) {
        self.apiKey = apiKey
        self.analyticsURL = analyticsURL
        self.interceptor = inteceptor
        self.isFirstLaunch = isFirstLaunch
        self.enableAttributionTracking = enableAttributionTracking
        self.loggingOptions = loggingOptions
        self.networkTypeProvider = networkTypeProvider
        self.batchConfig = batchConfig
        self.idfaConfig = idfaConfig
        self.sessionDelegate = sessionDelegate
        self.delegate = delegate
    }
}

// MARK: - AnalyticsReceiver
extension WildAnalyticsReceiver: AnalyticsReceiver {

    /// Unique identifier for receiver
    public static var identifier: String {
        "ru.wildanalytics.receiver_" + String(describing: WildAnalyticsReceiver.self).lowercased()
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
            idfaConfig: idfaConfig,
            analyticsURL: analyticsURL,
            interceptor: interceptor,
            loggingOptions: loggingOptions,
            sessionDelegate: sessionDelegate,
            delegate: delegate
        )
    }

    public func setUserToken(_ token: String?) {
        analyticsInstance?.setUserToken(token)
    }

    /// Set a single custom header that will be added to all analytics requests.
    public func setCustomHeader(key: String, value: String) {
        analyticsInstance?.setCustomHeader(key: key, value: value)
    }

    /// Set custom headers that will be added to all analytics requests.
    public func setCustomHeaders(_ headers: [String: String]) {
        analyticsInstance?.setCustomHeaders(headers)
    }

    public func setDeviceId(_ deviceId: String?) {
        analyticsInstance?.setDeviceId(deviceId)
    }

    /// Sets a unique session value
    public func setSessionValue(_ value: String?) {
        analyticsInstance?.setSessionValue(value)
    }

    /// Set a handler called when session value updates
    public func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void) {
        analyticsInstance?.setOnSessionValueUpdated(handler)
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

    /// Logs the URL the app was opened with.
    public func trackLaunchURL(_ url: URL, referrerURL: URL?) {
        analyticsInstance?.logLaunchURL(url, referrerURL: referrerURL)
    }
}

extension WildAnalyticsReceiver: AnalyticsCompletionReceiver {

    /// Tracks an event with a completion handler to indicate success or failure.
    public func trackEventWithCompletion(name: String, parameters: [String : Any]?, completion: @escaping (Bool) -> Void) {
        analyticsInstance?.logEvent(name, parameters: parameters, completion: completion)
    }
}

public extension WildAnalyticsReceiver {
    func showLogScreen() -> UIViewController? {
        analyticsInstance?.logViewController()
    }
}

extension WildAnalyticsReceiver {

    public static var defaultAnalyticsURL: URL {
        URL(string: "https://wba.wb.ru/m/batch")!
    }
}

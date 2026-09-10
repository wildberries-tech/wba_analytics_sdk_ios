//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class EventsProcessorMock: EventsProcessor {

    // MARK: - setDeviceId

    private(set) var setDeviceIdWasCalled: Int = 0
    private(set) var setDeviceReceivedArguments: String?

    func setDeviceId(_ deviceId: String?) {
        setDeviceIdWasCalled += 1
        setDeviceReceivedArguments = deviceId
    }

    // MARK: - Properties to track method calls and parameters

    private(set) var setupWasCalled: Int = 0
    private(set) var setupReceivedApiKey: String?
    private(set) var setupReceivedIsFirstLaunch: Bool?
    private(set) var setupReceivedEnableAutomaticEvents: Bool?
    private(set) var setupReceivedDropCache: Bool?
    private(set) var setupReceivedQueue: DispatchQueue?
    private(set) var setupReceivedBatchConfig: BatchConfig?
    private(set) var setupReceivedIDFAConfig: IDFAConfig?
    private(set) var setupReceivedNetworkTypeProvider: NetworkTypeProviderProtocol?
    private(set) var setupReceivedEnumerationCounter: EnumerationCounter?
    private(set) var setupReceivedUserEngagementTracker:  UserEngagementTrackerProtocol?
    private(set) var setupReceivedSessionDelegate: URLSessionDelegate?

    // MARK: - Methods

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
    ) {
        setupWasCalled += 1
        setupReceivedApiKey = apiKey
        setupReceivedIsFirstLaunch = isFirstLaunch
        setupReceivedEnableAutomaticEvents = enableAutomaticEvents
        setupReceivedDropCache = dropCache
        setupReceivedQueue = queue
        setupReceivedBatchConfig = batchConfig
        setupReceivedIDFAConfig = idfaConfig
        setupReceivedNetworkTypeProvider = networkTypeProvider
        setupReceivedEnumerationCounter = enumerationCounter
        setupReceivedUserEngagementTracker = userEngagementTracker
        setupReceivedSessionDelegate = sessionDelegate

    }

    private(set) var setCommonParametersWasCalled: Int = 0
    private(set) var setCommonParametersReceived: [String: Any]?

    func setCommonParameters(_ parameters: [String: Any]) {
        setCommonParametersReceived = parameters
        setCommonParametersWasCalled += 1
    }

    private(set) var addEventReceivedName: String?
    private(set) var addEventReceivedWasCalled: Int = 0
    private(set) var addEventReceivedParameters: [String: Any]?

    func addEvent(_ event: String, parameters: [String: Any]?) {
        addEventReceivedName = event
        addEventReceivedParameters = parameters
        addEventReceivedWasCalled += 1
    }

    private(set) var logUserEngagementWasCalled: Int = 0
    private(set) var logUserEngagementReceivedUserEngagement: UserEngagement?

    func logUserEngagement(_ userEngagement: UserEngagement?) {
        logUserEngagementWasCalled += 1
        logUserEngagementReceivedUserEngagement = userEngagement
    }

    private(set) var logLaunchURLWasCalled: Int = 0
    private(set) var logLaunchURLReceivedURL: URL?
    private(set) var logLaunchURLReceivedReferrerURL: URL?

    func logLaunchURL(_ url: URL, referrerURL: URL?) {
        logLaunchURLWasCalled += 1
        logLaunchURLReceivedURL = url
        logLaunchURLReceivedReferrerURL = referrerURL
    }

    private(set) var logEventWasCalled: Int = 0
    private(set) var logEventReceivedValue: (event: String, parameters: [String : Any]?, completion: (Bool) -> Void)?

    func logEvent(_ event: String, parameters: [String : Any]?, completion: @escaping (Bool) -> Void) {
        logEventWasCalled += 1
        logEventReceivedValue = (event, parameters, completion)
    }

    private(set) var setUserTokenWasCalled: Int = 0
    private(set) var setUserTokenReceivedValue: String?

    func setUserToken(_ token: String?) {
        setUserTokenWasCalled += 1
        self.setUserTokenReceivedValue = token
    }

    private(set) var setCustomHeaderWasCalled: Int = 0
    private(set) var setCustomHeaderReceivedValue: (key: String, value: String)?

    func setCustomHeader(key: String, value: String) {
        setCustomHeaderWasCalled += 1
        setCustomHeaderReceivedValue = (key, value)
    }

    private(set) var setCustomHeadersWasCalled: Int = 0
    private(set) var setCustomHeadersReceivedValue: [String: String]?

    func setCustomHeaders(_ headers: [String: String]) {
        setCustomHeadersWasCalled += 1
        setCustomHeadersReceivedValue = headers
    }

    private(set) var setSessionValueReceivedValue: String?
    private(set) var setSessionValueWasCalled: Int = 0

    func setSessionValue(_ value: String?) {
        setSessionValueReceivedValue = value
        setSessionValueWasCalled += 1
    }

    private(set) var setOnSessionValueUpdatedReceivedValue: ((String?) -> Void)?
    private(set) var setOnSessionValueUpdatedWasCalled: Int = 0

    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void) {
        setOnSessionValueUpdatedReceivedValue = handler
        setOnSessionValueUpdatedWasCalled += 1
    }
}

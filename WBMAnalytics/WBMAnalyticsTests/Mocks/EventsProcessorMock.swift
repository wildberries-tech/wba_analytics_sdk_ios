//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class EventsProcessorMock: EventsProcessor {

    // MARK: - Properties to track method calls and parameters

    private(set) var setupWasCalled: Int = 0
    private(set) var setupReceivedApiKey: String?
    private(set) var setupReceivedIsFirstLaunch: Bool?
    private(set) var setupReceivedDropCache: Bool?
    private(set) var setupReceivedQueue: DispatchQueue?
    private(set) var setupReceivedBatchConfig: BatchConfig?
    private(set) var setupReceivedNetworkTypeProvider: NetworkTypeProviderProtocol?
    private(set) var setupReceivedEnumerationCounter: EnumerationCounter?
    private(set) var setupReceivedUserEngagementTracker:  UserEngagementTrackerProtocol?

    // MARK: - Methods

    func setup(
        apiKey: String,
        isFirstLaunch: Bool,
        dropCache: Bool,
        queue: DispatchQueue?,
        batchConfig: BatchConfig,
        networkTypeProvider: NetworkTypeProviderProtocol,
        enumerationCounter: EnumerationCounter,
        userEngagementTracker:  UserEngagementTrackerProtocol?
    ) {
        setupWasCalled += 1
        setupReceivedApiKey = apiKey
        setupReceivedIsFirstLaunch = isFirstLaunch
        setupReceivedDropCache = dropCache
        setupReceivedQueue = queue
        setupReceivedBatchConfig = batchConfig
        setupReceivedNetworkTypeProvider = networkTypeProvider
        setupReceivedEnumerationCounter = enumerationCounter
        setupReceivedUserEngagementTracker = userEngagementTracker

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

    func logLaunchURL(_ url: URL) {
        logLaunchURLWasCalled += 1
        logLaunchURLReceivedURL = url
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

}

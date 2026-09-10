//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
import UIKit
@testable import WildAnalyticsSDK

final class AnalyticsReceiverMock: AnalyticsReceiver {

    private(set) var showLogScreenWasCalled: Int = 0
    var showLogScreenStub: UIViewController = UIViewController()

    func showLogScreen() -> UIViewController? {
        showLogScreenWasCalled += 1
        return showLogScreenStub
    }

    private(set) var identifierWasCalled: Int = 0
    var identifierStub: String!

    var identifier: String {
        identifierWasCalled += 1
        return identifierStub
    }

    private(set) var setupWasCalled: Int = 0

    func setup() {
        setupWasCalled += 1
    }

    private(set) var setCommonParametersReceivedParameters: [String: Any]?
    private(set) var setCommonParametersWasCalled: Int = 0

    func setCommonParameters(_ parameters: [String: Any]) {
        setCommonParametersWasCalled += 1
        setCommonParametersReceivedParameters = parameters
    }

    private(set) var trackEventWasCalled: Int = 0
    private(set) var trackEventReceivedName: String?
    private(set) var trackEventReceivedParameters: [String: Any]?

    func trackEvent(name: String, parameters: [String: Any]?) {
        trackEventWasCalled += 1
        trackEventReceivedName = name
        trackEventReceivedParameters = parameters
    }

    private(set) var trackEventPWasCalled: Int = 0
    private(set) var trackEventPReceivedName: String?
    private(set) var trackEventPReceivedParameters: [Encodable]?

    func trackEvent<P>(name: String, parameters: [P]?) where P: Encodable {
        trackEventPWasCalled += 1
        trackEventPReceivedName = name
        trackEventPReceivedParameters = parameters
    }

    private(set) var trackUserEngagementWasCalled: Int = 0
    private(set) var trackUserEngagementReceivedValue: UserEngagement?

    func trackUserEngagement(_ userEngagement: UserEngagement) {
        trackUserEngagementWasCalled += 1
        trackUserEngagementReceivedValue = userEngagement
    }

    private(set) var trackEventSyncWasCalled: Int = 0
    private(set) var trackEventSyncReceivedValue: (name: String, parameters: [String : Any]?, completion: (Bool) -> Void)?

    func trackEventSync(name: String, parameters: [String : Any]?, completion: @escaping (Bool) -> Void) {
        trackEventSyncReceivedValue = (name, parameters, completion)
        trackEventSyncWasCalled += 1
    }

    private(set) var setUserTokenReceivedValue: String?
    private(set) var setUserTokenWasCalled: Int = 0

    func setUserToken(_ token: String?) {
        setUserTokenWasCalled += 1
        setUserTokenReceivedValue = token
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

    private(set) var checkAttributionCompletionReceivedValue: ((Result<AttributionResult?, any Error>) -> Void)?
    private(set) var checkAttributionWasCalled: Int = 0

    func checkAttribution(completion: ((Result<AttributionResult?, any Error>) -> Void)?) {
        checkAttributionWasCalled += 1
        checkAttributionCompletionReceivedValue = completion
    }

    private(set) var trackLaunchURLWasCalled: Int = 0
    private(set) var trackLaunchURLReceivedURL: URL?
    private(set) var trackLaunchURLReceivedReferrerURL: URL?

    func trackLaunchURL(_ url: URL, referrerURL: URL?) {
        trackLaunchURLWasCalled += 1
        trackLaunchURLReceivedURL = url
        trackLaunchURLReceivedReferrerURL = referrerURL
    }
}

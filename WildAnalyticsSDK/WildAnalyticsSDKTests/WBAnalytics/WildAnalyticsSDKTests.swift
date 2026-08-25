//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class WildAnalyticsSDKTests: XCTestCase {

    // MARK: Init

    func testInit() {
        // when
        let analytics = WildAnalyticsSDK()
        let mirror = WildAnalyticsSDKMirror(reflecting: analytics)
        // then
        XCTAssertTrue(mirror.receiversSetupStatuses.isEmpty)
        XCTAssertTrue(mirror.receivers.isEmpty)
    }

    // MARK: registerReceiver

    func testRegisterReceiver() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = "identifierStub"
        let analytics = WildAnalyticsSDK()
        let mirror = WildAnalyticsSDKMirror(reflecting: analytics)
        // when
        analytics.registerReceiver(receiver)
        // then
        XCTAssertEqual(receiver.identifierWasCalled, 2)
        XCTAssertEqual(mirror.receiversSetupStatuses[receiver.identifier], false)
        XCTAssertIdentical(
            mirror.receivers[receiver.identifier] as? AnalyticsReceiverMock,
            receiver
        )
    }

    // MARK: setupReceiversIfPossible

    func testSetupReceiversIfPossible() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = "identifierStub"
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        analytics.setupReceiversIfPossible()
        // then
        XCTAssertEqual(receiver.identifierWasCalled, 2)
        XCTAssertEqual(receiver.setupWasCalled, 1)
    }

    // MARK: setCommonParameters

    func testSetCommonParameters() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        analytics.setCommonParameters(
            TestData.parameters,
            receiverIdentifier: TestData.receiverIdentifier
        )
        // then
        XCTAssertEqual(receiver.identifierWasCalled, 2)
        XCTAssertEqual(receiver.setCommonParametersWasCalled, 1)
        XCTAssertEqual(
            receiver.setCommonParametersReceivedParameters as? [String: Int],
            TestData.parameters
        )
    }

    // MARK: setUserToken

    func testSetUserToken() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        analytics.setUserToken("Test token")
        // then
        XCTAssertEqual(receiver.setUserTokenReceivedValue, "Test token")
        XCTAssertEqual(receiver.setUserTokenWasCalled, 1)
    }

    // MARK: trackEvent

    func testTrackEvent() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        analytics.trackEvent(
            name: TestData.name,
            parameters: TestData.parameters,
            receiverIdentifier: TestData.receiverIdentifier
        )
        // then
        XCTAssertEqual(receiver.trackEventWasCalled, 1)
        XCTAssertEqual(receiver.trackEventReceivedName, TestData.name)
        XCTAssertEqual(
            receiver.trackEventReceivedParameters as? [String: Int],
            TestData.parameters
        )
    }

    // MARK: trackEvent

    func testTrackEventTwoParameters() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        analytics.trackEvent(name: TestData.name, parameters: TestData.parameters)
        // then
        XCTAssertEqual(receiver.trackEventWasCalled, 1)
        XCTAssertEqual(receiver.trackEventReceivedName, TestData.name)
        XCTAssertEqual(
            receiver.trackEventReceivedParameters as? [String: Int],
            TestData.parameters
        )
    }

    // MARK: trackLaunchURL

    func testTrackLaunchURLBroadcastsToAllReceivers() {
        // given
        let receiverMock = AnalyticsReceiverMock()
        receiverMock.identifierStub = "receiver"
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiverMock)
        let url = URL(string: "https://example.com")!
        let referrerURL = URL(string: "https://referrer.example.com")!
        // when
        analytics.trackLaunchURL(url, referrerURL: referrerURL)
        // then
        XCTAssertEqual(receiverMock.trackLaunchURLWasCalled, 1)
        XCTAssertEqual(receiverMock.trackLaunchURLReceivedURL, url)
        XCTAssertEqual(receiverMock.trackLaunchURLReceivedReferrerURL, referrerURL)
    }

    func testTrackLaunchURLSendsToSpecificReceiver() {
        // given
        let receiverMock = AnalyticsReceiverMock()
        receiverMock.identifierStub = TestData.receiverIdentifier
        let otherReceiverMock = AnalyticsReceiverMock()
        otherReceiverMock.identifierStub = "otherReceiverIdentifier"
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiverMock)
        analytics.registerReceiver(otherReceiverMock)
        let url = URL(string: "https://example.com")!
        let referrerURL = URL(string: "https://referrer.example.com")!
        // when
        analytics.trackLaunchURL(
            url,
            referrerURL: referrerURL,
            receiverIdentifier: TestData.receiverIdentifier
        )
        // then
        XCTAssertEqual(receiverMock.trackLaunchURLWasCalled, 1)
        XCTAssertEqual(receiverMock.trackLaunchURLReceivedURL, url)
        XCTAssertEqual(receiverMock.trackLaunchURLReceivedReferrerURL, referrerURL)
        XCTAssertEqual(otherReceiverMock.trackLaunchURLWasCalled, 0)
    }

    /// Regression test for protocol dispatch: `AnalyticsReceiver.trackLaunchURL(_:)` — the
    /// convenience single-parameter method from the extension — must call the protocol requirement
    /// `trackLaunchURL(_:referrerURL:)`, which the concrete receiver overrides, rather than the empty
    /// default implementation from that same extension. If someone ever "simplifies" the two extension
    /// methods back into one with `referrerURL: URL? = nil`, a call through the protocol
    /// (existential) type would statically resolve to that empty default — silently dropping the
    /// attribution event — and without this test the regression would go unnoticed
    /// (testTrackLaunchURLBroadcastsToAllReceivers doesn't catch it, since it always calls the
    /// two-argument form directly).
    func testTrackLaunchURLConvenienceOverloadDispatchesToReceiverOverride() {
        // given
        let receiverMock = AnalyticsReceiverMock()
        receiverMock.identifierStub = TestData.receiverIdentifier
        let receiver: AnalyticsReceiver = receiverMock
        let url = URL(string: "https://example.com")!
        // when: the single-parameter convenience method, called through the protocol type
        receiver.trackLaunchURL(url)
        // then: this must reach the concrete receiver's override, not the empty extension default
        XCTAssertEqual(receiverMock.trackLaunchURLWasCalled, 1)
        XCTAssertEqual(receiverMock.trackLaunchURLReceivedURL, url)
        XCTAssertNil(receiverMock.trackLaunchURLReceivedReferrerURL)
    }

    // MARK: trackUserEngagement

    func testTrackUserEngagement() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        analytics.trackUserEngagement(
            TestData.userEngagement,
            receiverIdentifier: TestData.receiverIdentifier
        )
        // then
        XCTAssertEqual(receiver.trackUserEngagementWasCalled, 1)
        XCTAssertEqual(receiver.trackUserEngagementReceivedValue, TestData.userEngagement)
    }

    // MARK: setSessionValue

    func testSetSessionValue() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        // when
        receiver.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertEqual(receiver.setSessionValueReceivedValue, TestData.sessionValue)
        XCTAssertEqual(receiver.setSessionValueWasCalled, 1)
    }

    // MARK: setOnSessionValueUpdated

    func testSetOnSessionValueUpdated() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WildAnalyticsSDK()
        analytics.registerReceiver(receiver)
        let handler: (String?) -> Void = { _ in }
        // when
        receiver.setOnSessionValueUpdated(handler)
        // then
        XCTAssertNotNil(receiver.setOnSessionValueUpdatedReceivedValue)
        XCTAssertEqual(receiver.setOnSessionValueUpdatedWasCalled, 1)
    }

    // MARK: WildAnalyticsDelegateProtocol Tests

    func testWBAnalyticsSetupWithDelegate() {
        // given
        let delegateMock = WildAnalyticsDelegateMock()
        let networkProvider = NetworkTypeProviderMock()
        let batchConfig = BatchConfig()

        // when
        let analytics = WBAnalytics.setup(
            apiKey: "test-api-key",
            isFirstLaunch: false,
            enableAttributionTracking: true,
            dropCache: false,
            networkTypeProvider: networkProvider,
            batchConfig: batchConfig,
            analyticsURL: URL(string: "https://test.example.com")!,
            interceptor: NoOpInterceptor(),
            delegate: delegateMock
        )

        let mirror = WBAnalyticsMirror(reflecting: analytics)

        // then
        XCTAssertNotNil(mirror.delegate)
        XCTAssertIdentical(mirror.delegate as? WildAnalyticsDelegateMock, delegateMock)
    }

    func testWBAnalyticsSetupWithoutDelegate() {
        // given
        let networkProvider = NetworkTypeProviderMock()
        let batchConfig = BatchConfig()

        // when
        let analytics = WBAnalytics.setup(
            apiKey: "test-api-key",
            isFirstLaunch: false,
            enableAttributionTracking: true,
            dropCache: false,
            networkTypeProvider: networkProvider,
            batchConfig: batchConfig,
            analyticsURL: URL(string: "https://test.example.com")!,
            interceptor: NoOpInterceptor(),
            delegate: nil
        )

        let mirror = WBAnalyticsMirror(reflecting: analytics)

        // then
        XCTAssertNil(mirror.delegate)
    }

    func testDelegateWeakReference() {
        // given
        var delegateMock: WildAnalyticsDelegateMock? = WildAnalyticsDelegateMock()
        let networkProvider = NetworkTypeProviderMock()
        let batchConfig = BatchConfig()

        let analytics = WBAnalytics.setup(
            apiKey: "test-api-key",
            isFirstLaunch: false,
            enableAttributionTracking: true,
            dropCache: false,
            networkTypeProvider: networkProvider,
            batchConfig: batchConfig,
            analyticsURL: URL(string: "https://test.example.com")!,
            interceptor: NoOpInterceptor(),
            delegate: delegateMock
        )

        let mirror = WBAnalyticsMirror(reflecting: analytics)
        XCTAssertNotNil(mirror.delegate)

        // when
        delegateMock = nil

        // then
        XCTAssertNil(mirror.delegate)
    }

    func testDidResolveAttributedLinkCalled() {
        // given
        let delegateMock = WildAnalyticsDelegateMock()
        let networkProvider = NetworkTypeProviderMock()
        let batchConfig = BatchConfig()

        let analytics = WBAnalytics.setup(
            apiKey: "test-api-key",
            isFirstLaunch: false,
            enableAttributionTracking: true,
            dropCache: false,
            networkTypeProvider: networkProvider,
            batchConfig: batchConfig,
            analyticsURL: URL(string: "https://test.example.com")!,
            interceptor: NoOpInterceptor(),
            delegate: delegateMock
        )

        let mirror = WBAnalyticsMirror(reflecting: analytics)
        let testURL = URL(string: "https://www.wildberries.ru/catalog/123456/detail.aspx")!

        // when
        // Simulate successful attribution with a link
        mirror.delegate?.didResolveAttributedLink(testURL)

        // then
        XCTAssertEqual(delegateMock.didResolveAttributedLinkWasCalled, 1)
        XCTAssertEqual(delegateMock.didResolveAttributedLinkReceivedURL, testURL)
    }

    func testDidResolveAttributedLinkNotCalledWhenNilDelegate() {
        // given
        let networkProvider = NetworkTypeProviderMock()
        let batchConfig = BatchConfig()

        let analytics = WBAnalytics.setup(
            apiKey: "test-api-key",
            isFirstLaunch: false,
            enableAttributionTracking: true,
            dropCache: false,
            networkTypeProvider: networkProvider,
            batchConfig: batchConfig,
            analyticsURL: URL(string: "https://test.example.com")!,
            interceptor: NoOpInterceptor(),
            delegate: nil
        )

        let mirror = WBAnalyticsMirror(reflecting: analytics)

        // when/then - Should not crash when delegate is nil
        XCTAssertNil(mirror.delegate)
        // This would be called internally by checkAttribution but with nil delegate should not crash
        mirror.delegate?.didResolveAttributedLink(URL(string: "https://example.com")!)
    }

    func testReportInstallParameterStructure() {
        // Given
        let mockFingerprint = DeviceFingerprint(
            screen_resolution: "1440x900",
            pixel_ratio: "2",
            platform: "iPhone",
            language: "en-US",
            timezone: "America/New_York",
            user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
            device: "iPhone",
            version_os: "17.0"
        )
        let mockAttributionData = AttributionData.create(
            isEmpty: false,
            deeplink: "https://example.com/deeplink",
            parametersAny: [
                "utm_source": "google",
                "utm_medium": "cpc",
                "campaign_id": "123456"
            ]
        )
        let attributionResult = AttributionResult(
            fingerprintData: mockFingerprint,
            attributionData: mockAttributionData
        )
        // When - simulate what checkAttribution does
        var capturedParameters: [String: Any] = [:]
        // Add fingerprint data as user_attributes using direct conversion
        if let fingerprintData = try? JSONEncoder().encode(attributionResult.fingerprintData),
           let fingerprintDict = (try? JSONSerialization.jsonObject(with: fingerprintData) as? [String: Any]) {
            capturedParameters["user_attributes"] = fingerprintDict
        }
        // Add attribution response as fingerprint_gathered
        if let attributionData = attributionResult.attributionData {
            var fingerprintGathered: [String: Any] = [:]
            if let deeplink = attributionData.deeplink {
                fingerprintGathered["deeplink"] = deeplink
            }
            if let attributionParameters = attributionData.parametersAsAny() {
                // Merge attribution parameters at the same level as link
                fingerprintGathered.merge(attributionParameters) { _, new in new }
            }
            capturedParameters["fingerprint_gathered"] = fingerprintGathered
            // Also include attribution parameters at the root level for backward compatibility
            if let attributionParameters = attributionData.parametersAsAny() {
                capturedParameters.merge(attributionParameters) { _, new in new }
            }
        }
        // Then - verify the structure
        XCTAssertNotNil(capturedParameters["user_attributes"])
        XCTAssertNotNil(capturedParameters["fingerprint_gathered"])
        // Check user_attributes contains fingerprint data
        if let userAttributes = capturedParameters["user_attributes"] as? [String: Any] {
            XCTAssertEqual(userAttributes["screen_resolution"] as? String, "1440x900")
            XCTAssertEqual(userAttributes["platform"] as? String, "iPhone")
            XCTAssertEqual(userAttributes["device"] as? String, "iPhone")
            XCTAssertEqual(userAttributes["language"] as? String, "en-US")
            XCTAssertEqual(userAttributes["timezone"] as? String, "America/New_York")
            XCTAssertEqual(userAttributes["version_os"] as? String, "17.0")
            XCTAssertNotNil(userAttributes["user_agent"])
        } else {
            XCTFail("user_attributes should be a dictionary")
        }
        // Check fingerprint_gathered contains flattened attribution data
        if let fingerprintGathered = capturedParameters["fingerprint_gathered"] as? [String: Any] {
            XCTAssertEqual(fingerprintGathered["deeplink"] as? String, "https://example.com/deeplink")
            XCTAssertEqual(fingerprintGathered["utm_source"] as? String, "google")
            XCTAssertEqual(fingerprintGathered["utm_medium"] as? String, "cpc")
            XCTAssertEqual(fingerprintGathered["campaign_id"] as? String, "123456")
        } else {
            XCTFail("fingerprint_gathered should be a dictionary")
        }
        // Check backward compatibility - attribution parameters at root level
        XCTAssertEqual(capturedParameters["utm_source"] as? String, "google")
        XCTAssertEqual(capturedParameters["utm_medium"] as? String, "cpc")
        XCTAssertEqual(capturedParameters["campaign_id"] as? String, "123456")
    }

}

// MARK: TestData

private extension WildAnalyticsSDKTests {
    enum TestData {
        static let usetToken: String = "Test token"
        static let parameters: [String: Int] = ["123": 2]
        static let receiverIdentifier: String = "receiverIdentifier"
        static let name: String = "name"
        static let sessionValue = "1587023248356386046"
        static let userEngagement = UserEngagement(
                    screenName: "name",
                    textSize: .large,
                    authType: "noAuth",
                    scaleFactor: "1.5"
                )
        static let idfa = "01234567-1234-1234-1234-123456789012"
    }
}

// MARK: - Mirror

private extension WildAnalyticsSDKTests {

    final class WildAnalyticsSDKMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: WildAnalyticsSDK) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var receivers: [String: AnalyticsReceiver]! { extract() }
        var receiversSetupStatuses: [String: Bool]! { extract() }
        var delegate: WildAnalyticsDelegateProtocol? { extract() }
    }

    final class WBAnalyticsMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: WBAnalytics) {
            super.init(reflecting: counter)
        }

        var delegate: WildAnalyticsDelegateProtocol? { extract() }
    }
}

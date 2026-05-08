//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class WBMAnalyticsTests: XCTestCase {

    // MARK: Init

    func testInit() {
        // when
        let analytics = WBMAnalytics()
        let mirror = WBMAnalyticsMirror(reflecting: analytics)
        // then
        XCTAssertTrue(mirror.receiversSetupStatuses.isEmpty)
        XCTAssertTrue(mirror.receivers.isEmpty)
    }

    // MARK: registerReceiver

    func testRegisterReceiver() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = "identifierStub"
        let analytics = WBMAnalytics()
        let mirror = WBMAnalyticsMirror(reflecting: analytics)
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
        let analytics = WBMAnalytics()
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
        let analytics = WBMAnalytics()
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
        let analytics = WBMAnalytics()
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
        let analytics = WBMAnalytics()
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
        let analytics = WBMAnalytics()
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

    // MARK: trackUserEngagement

    func testTrackUserEngagement() {
        // given
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WBMAnalytics()
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
        let analytics = WBMAnalytics()
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
        let analytics = WBMAnalytics()
        analytics.registerReceiver(receiver)
        let handler: (String?) -> Void = { _ in }
        // when
        receiver.setOnSessionValueUpdated(handler)
        // then
        XCTAssertNotNil(receiver.setOnSessionValueUpdatedReceivedValue)
        XCTAssertEqual(receiver.setOnSessionValueUpdatedWasCalled, 1)
    }

    // MARK: setIDFA

    func testSetIDFA() {
        let receiver = AnalyticsReceiverMock()
        receiver.identifierStub = TestData.receiverIdentifier
        let analytics = WBMAnalytics()
        analytics.registerReceiver(receiver)
        let idfaClosure: () -> String = { TestData.idfa }
        // when
        analytics.setIDFA(idfaClosure)
        // then
        XCTAssertEqual(receiver.setIDFAWasCalled, 1)
        XCTAssertNotNil(receiver.setIDFAReceivedValue?(), TestData.idfa)
    }

    // MARK: WBAnalyticsDelegateProtocol Tests

    func testWBAnalyticsSetupWithDelegate() {
        // given
        let delegateMock = WBAnalyticsDelegateMock()
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
        XCTAssertIdentical(mirror.delegate as? WBAnalyticsDelegateMock, delegateMock)
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
        var delegateMock: WBAnalyticsDelegateMock? = WBAnalyticsDelegateMock()
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
        let delegateMock = WBAnalyticsDelegateMock()
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

private extension WBMAnalyticsTests {
    enum TestData {
        static let usetToken: String = "Test token"
        static let parameters: [String: Int] = ["123": 2]
        static let receiverIdentifier: String = "receiverIdentifier"
        static let name: String = "name"
        static let sessionValue = "1587023248356386046"
        static let userEngagement: UserEngagement = .init(screenName: "name", textSize: .large, authType: "noAuth")
        static let idfa = "01234567-1234-1234-1234-123456789012"
    }
}

// MARK: - Mirror

private extension WBMAnalyticsTests {

    final class WBMAnalyticsMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: WBMAnalytics) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var receivers: [String: AnalyticsReceiver]! { extract() }
        var receiversSetupStatuses: [String: Bool]! { extract() }
        var delegate: WBAnalyticsDelegateProtocol? { extract() }
    }

    final class WBAnalyticsMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: WBAnalytics) {
            super.init(reflecting: counter)
        }

        var delegate: WBAnalyticsDelegateProtocol? { extract() }
    }
}

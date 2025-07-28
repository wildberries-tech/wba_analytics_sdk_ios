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

}

// MARK: TestData

private extension WBMAnalyticsTests {
    enum TestData {
        static let usetToken: String = "Test token"
        static let parameters: [String: Int] = ["123": 2]
        static let receiverIdentifier: String = "receiverIdentifier"
        static let name: String = "name"
        static let userEngagement: UserEngagement = .init(screenName: "name", textSize: .large)
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

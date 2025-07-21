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
    }
}

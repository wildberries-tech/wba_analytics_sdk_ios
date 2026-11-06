//
//  Copyright © 2026 WildAnalytics. All rights reserved.
//

import UIKit
import XCTest

@testable import WildAnalyticsSDK

final class SessionValueManagerTests: XCTestCase {
    /// A notification center shared by several managers plays the role of `NotificationCenter.default`
    /// in the app: SDK copies linked into different modules coordinate through it.
    private var notificationCenter: NotificationCenter!
    private var subject: SessionValueManager!
    /// Plays the SDK instance setting the handler: the manager keeps one handler per owner
    private var owner: NSObject!
    private var otherOwner: NSObject!

    override func setUp() {
        super.setUp()
        notificationCenter = NotificationCenter()
        subject = SessionValueManager(notificationCenter: notificationCenter)
        owner = NSObject()
        otherOwner = NSObject()
    }

    override func tearDown() {
        otherOwner = nil
        owner = nil
        subject = nil
        notificationCenter = nil
        super.tearDown()
    }

    // MARK: sessionValue

    func testSessionValueIsGeneratedOnInit() {
        // when
        let sessionValue = subject.sessionValue
        // then
        XCTAssertNotEqual(sessionValue, 0)
        // The value is built from milliseconds shifted left by 20 bits plus a random tail
        let timestamp = Double(sessionValue >> TestData.timestampShift) / 1000
        XCTAssertEqual(timestamp, Date().timeIntervalSince1970, accuracy: TestData.timestampAccuracy)
    }

    func testSessionValueFitsIntoSignedRange() {
        // The value is sent in JSON as a number and parsed as Int64 after being read from storage,
        // so going beyond its bounds would mean a loss of precision
        XCTAssertLessThanOrEqual(subject.sessionValue, UInt64(Int64.max))
    }

    // MARK: setSessionValue

    func testSetSessionValue() {
        // when
        subject.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertEqual(subject.sessionValue, TestData.sessionValue)
    }

    func testSetSessionValueWithNilGeneratesNewValue() {
        // given
        subject.setSessionValue(TestData.sessionValue)
        // when
        subject.setSessionValue(nil)
        // then
        XCTAssertNotEqual(subject.sessionValue, TestData.sessionValue)
        XCTAssertNotEqual(subject.sessionValue, 0)
    }

    // MARK: setOnSessionValueUpdated

    func testSetOnSessionValueUpdatedCallsHandlerWithCurrentValue() {
        // given
        let currentValue = subject.sessionValue
        var receivedValues = [UInt64?]()
        // when
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: owner)
        // then
        XCTAssertEqual(receivedValues, [currentValue])
    }

    /// Handlers of different SDK instances must not overwrite each other
    func testSetOnSessionValueUpdatedKeepsHandlerOfEveryOwner() {
        // given
        let currentValue = subject.sessionValue
        var firstReceivedValues = [UInt64?]()
        var secondReceivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ firstReceivedValues.append($0) }, for: owner)
        subject.setOnSessionValueUpdated({ secondReceivedValues.append($0) }, for: otherOwner)
        // when
        subject.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertEqual(firstReceivedValues, [currentValue, TestData.sessionValue])
        XCTAssertEqual(secondReceivedValues, [currentValue, TestData.sessionValue])
    }

    func testSetOnSessionValueUpdatedReplacesHandlerOfSameOwner() {
        // given
        var firstReceivedValues = [UInt64?]()
        var secondReceivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ firstReceivedValues.append($0) }, for: owner)
        subject.setOnSessionValueUpdated({ secondReceivedValues.append($0) }, for: owner)
        firstReceivedValues.removeAll()
        secondReceivedValues.removeAll()
        // when
        subject.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertEqual(firstReceivedValues, [])
        XCTAssertEqual(secondReceivedValues, [TestData.sessionValue])
    }

    /// A handler must not outlive the SDK instance that set it
    func testHandlerIsDroppedWithReleasedOwner() {
        // given
        var receivedValues = [UInt64?]()
        var releasedOwner: NSObject? = NSObject()
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: releasedOwner!)
        receivedValues.removeAll()
        // when
        releasedOwner = nil
        subject.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertEqual(receivedValues, [])
    }

    // MARK: Lifecycle

    func testWillEnterForegroundGeneratesNewValue() {
        // given
        let oldValue = subject.sessionValue
        var receivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: owner)
        // when
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        // then
        XCTAssertNotEqual(subject.sessionValue, oldValue)
        XCTAssertEqual(receivedValues, [oldValue, subject.sessionValue])
    }

    func testDidEnterBackgroundNotifiesHandlersWithNil() {
        // given
        let oldValue = subject.sessionValue
        var receivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: owner)
        // when
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        // then
        XCTAssertEqual(receivedValues, [oldValue, nil])
        XCTAssertEqual(subject.sessionValue, oldValue)
    }

    func testWillTerminateNotifiesHandlersWithNil() {
        // given
        let oldValue = subject.sessionValue
        var receivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: owner)
        // when
        notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)
        // then
        XCTAssertEqual(receivedValues, [oldValue, nil])
    }

    func testDidFinishLaunchingKeepsValueGeneratedInInit() {
        // given
        let oldValue = subject.sessionValue
        var receivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: owner)
        // when
        notificationCenter.post(name: UIApplication.didFinishLaunchingNotification, object: nil)
        // then
        XCTAssertEqual(subject.sessionValue, oldValue)
        XCTAssertEqual(receivedValues, [oldValue, oldValue])
    }

    // MARK: Several SDK copies in the app

    func testNewInstanceAdoptsValueOfExistingOne() {
        // when
        let otherSubject = SessionValueManager(notificationCenter: notificationCenter)
        // then
        XCTAssertEqual(otherSubject.sessionValue, subject.sessionValue)
    }

    func testSetSessionValueIsSharedBetweenInstances() {
        // given
        let otherSubject = SessionValueManager(notificationCenter: notificationCenter)
        let oldValue = subject.sessionValue
        var receivedValues = [UInt64?]()
        otherSubject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: otherOwner)
        // when
        subject.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertEqual(otherSubject.sessionValue, TestData.sessionValue)
        XCTAssertEqual(receivedValues, [oldValue, TestData.sessionValue])
    }

    /// Key requirement: on a foreground transition only one SDK copy generates a new value,
    /// the others pick it up instead of computing their own
    func testWillEnterForegroundGeneratesSingleValueForAllInstances() {
        // given
        let otherSubject = SessionValueManager(notificationCenter: notificationCenter)
        let oldValue = subject.sessionValue

        var receivedValues = [UInt64?]()
        var otherReceivedValues = [UInt64?]()
        subject.setOnSessionValueUpdated({ receivedValues.append($0) }, for: owner)
        otherSubject.setOnSessionValueUpdated({ otherReceivedValues.append($0) }, for: otherOwner)
        // when
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        // then
        let newValue = subject.sessionValue
        XCTAssertNotEqual(newValue, oldValue)
        XCTAssertEqual(otherSubject.sessionValue, newValue)
        // Each copy's handler is notified exactly once: with the value before the transition and with the new shared value
        XCTAssertEqual(receivedValues, [oldValue, newValue])
        XCTAssertEqual(otherReceivedValues, [oldValue, newValue])
    }

    func testInstancesStayIndependentAcrossNotificationCenters() {
        // given
        let otherSubject = SessionValueManager(notificationCenter: NotificationCenter())
        // when
        subject.setSessionValue(TestData.sessionValue)
        // then
        XCTAssertNotEqual(otherSubject.sessionValue, TestData.sessionValue)
    }

    // MARK: shared

    func testSharedInstanceHasGeneratedValue() {
        XCTAssertNotEqual(SessionValueManager.shared.sessionValue, 0)
    }
}

// MARK: TestData

private extension SessionValueManagerTests {
    enum TestData {
        static let sessionValue: UInt64 = 1_587_023_248_356_386_046
        static let timestampShift: UInt64 = 20
        static let timestampAccuracy: TimeInterval = 60
    }
}

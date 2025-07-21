//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class UserEngagementTrackerTests: XCTestCase {

    private var delegateMock: UserEngagementTrackerDelegateMock!
    private var userEngagementTracker: UserEngagementTracker!
    private var timerMock: TimerMock!
    private var timerMaker: TimerMock.Type!

    override func setUp() {
        delegateMock = .init()
        timerMock = .init()
        timerMaker = TimerMock.self
        userEngagementTracker = UserEngagementTracker(
            delegate: delegateMock,
            timerMaker: timerMaker
        )
    }

    override func tearDown() {
        timerMaker.reset()
        super.tearDown()
    }

    // MARK: init

    func testInit() {
        // when
        let userTracker = UserEngagementTracker()
        let mirror = Mirror(reflecting: userTracker)
        // then
        XCTAssertNil(mirror.delegate)
        XCTAssertIdentical(mirror.timerMaker, Timer.self)
    }

    // MARK: set

    func testSet() {
        // when
        userEngagementTracker.set(userEngagement: TestData.userEngagement)
        let mirror = Mirror(reflecting: userEngagementTracker)
        // then
        XCTAssertEqual(mirror.lastUserEngagement, TestData.userEngagement)
    }

    // MARK: start

    func testStart() {
        // given
        timerMaker.timerStub = timerMock
        userEngagementTracker.set(userEngagement: TestData.userEngagement)
        // when
        userEngagementTracker.start()
        // then
        let mirror = Mirror(reflecting: userEngagementTracker)
        XCTAssertIdentical(mirror.timer, timerMock)
        XCTAssertEqual(timerMaker.timerWasCalled, 1)
        XCTAssertEqual(timerMaker.timerReceivedArguments?.timeInterval, TestData.timerInterval)
        XCTAssertEqual(timerMaker.timerReceivedArguments?.repeats, true)
        XCTAssertNotNil(timerMaker.timerReceivedArguments?.block)
        timerMaker.timerReceivedArguments?.block(Timer())

        XCTAssertEqual(delegateMock.didUserEngagementTrackerFireWasCalled, 1)
        XCTAssertEqual(
            delegateMock.didUserEngagementTrackerFireReceivedUserEngagement,
            TestData.userEngagement
        )
        XCTAssertEqual(timerMock.scheduleWasCalled, 1)
        XCTAssertEqual(timerMock.scheduleReceivedArguments, .main)
        XCTAssertEqual(timerMock.invalidateWasCalled, 0)
    }

    func testInvalidateStart() {
        // given
        timerMaker.timerStub = timerMock
        userEngagementTracker.set(userEngagement: TestData.userEngagement)
        // when
        userEngagementTracker.start()
        userEngagementTracker.start()
        // then
        XCTAssertEqual(timerMock.invalidateWasCalled, 1)
    }
}

// MARK: - TestData

private extension UserEngagementTrackerTests {
    enum TestData {
        static let userEngagement = UserEngagement(screenName: "screenName", textSize: .large)
        static let timerInterval = 30.0
    }
}

// MARK: - Mirror

private extension UserEngagementTrackerTests {

    final class Mirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: UserEngagementTracker) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var timerMaker: TimerProtocol.Type? { extract() }
        var timer: TimerProtocol? { extract() }
        var lastUserEngagement: UserEngagement? { extract() }
        var delegate: UserEngagementTrackerDelegate? { extract() }
    }
}

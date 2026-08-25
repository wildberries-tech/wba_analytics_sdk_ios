//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class HeartbeatTrackerTests: XCTestCase {

    private var timerMock: TimerMock!
    private var timerMaker: TimerMock.Type!
    private var subject: HeartbeatTracker!

    override func setUp() {
        super.setUp()
        timerMock = .init()
        timerMaker = TimerMock.self
        timerMaker.timerStub = timerMock
        subject = HeartbeatTracker(timerMaker: timerMaker)
    }

    override func tearDown() {
        timerMaker.reset()
        super.tearDown()
    }

    func testStartCreatesRepeatingTimerWithThirtySecondsInterval() {
        // when
        subject.start()
        // then
        XCTAssertEqual(timerMaker.timerWasCalled, 1)
        XCTAssertEqual(timerMaker.timerReceivedArguments?.timeInterval, 30.0)
        XCTAssertEqual(timerMaker.timerReceivedArguments?.repeats, true)
        XCTAssertEqual(timerMock.scheduleWasCalled, 1)
        XCTAssertEqual(timerMock.scheduleReceivedArguments, .main)
    }

    func testTimerFireCallsSetupClosure() {
        // given
        var firedCount = 0
        subject.setup { firedCount += 1 }
        // when
        subject.start()
        timerMaker.timerReceivedArguments?.block(Timer())
        // then
        XCTAssertEqual(firedCount, 1)
    }

    func testTimerFireWithoutSetupDoesNotCrash() {
        // when
        subject.start()
        timerMaker.timerReceivedArguments?.block(Timer())
        // then
        XCTAssertEqual(timerMaker.timerWasCalled, 1)
    }

    func testStartInvalidatesPreviousTimer() {
        // given
        subject.start()
        // when
        subject.start()
        // then
        XCTAssertEqual(timerMock.invalidateWasCalled, 1)
        XCTAssertEqual(timerMaker.timerWasCalled, 2)
    }

    func testInvalidateStopsTimer() {
        // given
        subject.start()
        // when
        subject.invalidate()
        // then
        XCTAssertEqual(timerMock.invalidateWasCalled, 1)
        XCTAssertNil(subject.timer)
    }

    func testInvalidateWithoutStartDoesNothing() {
        // when
        subject.invalidate()
        // then
        XCTAssertEqual(timerMock.invalidateWasCalled, 0)
    }

    func testInvalidateClearsTimerEvenWhenAlreadyInvalid() {
        // given: the timer already became invalid on its own (e.g. cancelled externally)
        subject.start()
        timerMock.isValid = false
        // when
        subject.invalidate()
        // then: state no longer keeps a dangling reference to an invalid timer
        XCTAssertNil(subject.timer)
        XCTAssertEqual(timerMock.invalidateWasCalled, 0)
    }
}

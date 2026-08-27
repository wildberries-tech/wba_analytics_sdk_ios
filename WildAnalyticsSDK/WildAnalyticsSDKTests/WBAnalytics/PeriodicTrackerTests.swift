//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class PeriodicTrackerTests: XCTestCase {

    private var timerMock: TimerMock!
    private var timerMaker: TimerMock.Type!
    private var subject: PeriodicTracker!

    override func setUp() {
        super.setUp()
        timerMock = .init()
        timerMaker = TimerMock.self
        timerMaker.timerStub = timerMock
        subject = PeriodicTracker(interval: TestData.interval, timerMaker: timerMaker)
    }

    override func tearDown() {
        timerMaker.reset()
        super.tearDown()
    }

    // MARK: init

    func testDefaultInitUsesSystemTimer() {
        // when
        let subject = PeriodicTracker(interval: TestData.interval)
        let mirror = Mirror(reflecting: subject)
        // then
        XCTAssertIdentical(mirror.timerMaker, Timer.self)
        XCTAssertEqual(mirror.interval, TestData.interval)
    }

    // MARK: start

    func testStartCreatesRepeatingTimerWithGivenInterval() {
        // when
        subject.start()
        // then
        XCTAssertEqual(timerMaker.timerWasCalled, 1)
        XCTAssertEqual(timerMaker.timerReceivedArguments?.timeInterval, TestData.interval)
        XCTAssertEqual(timerMaker.timerReceivedArguments?.repeats, true)
        XCTAssertEqual(timerMock.scheduleWasCalled, 1)
        XCTAssertEqual(timerMock.scheduleReceivedArguments, .main)
    }

    func testStartUsesIntervalItWasCreatedWith() {
        // given
        let subject = PeriodicTracker(interval: TestData.otherInterval, timerMaker: timerMaker)
        // when
        subject.start()
        // then
        XCTAssertEqual(timerMaker.timerReceivedArguments?.timeInterval, TestData.otherInterval)
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

    // MARK: invalidate

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
        // given: the timer already became invalid on its own (e.g. cancelled from the outside)
        subject.start()
        timerMock.isValid = false
        // when
        subject.invalidate()
        // then: the state no longer keeps a dangling reference to an invalid timer
        XCTAssertNil(subject.timer)
        XCTAssertEqual(timerMock.invalidateWasCalled, 0)
    }
}

// MARK: - TestData

private extension PeriodicTrackerTests {
    enum TestData {
        static let interval = 30.0
        static let otherInterval = 5.0
    }
}

// MARK: - Mirror

private extension PeriodicTrackerTests {

    final class Mirror: MirrorObject {
        init(reflecting tracker: PeriodicTracker) {
            super.init(reflecting: tracker)
        }

        var timerMaker: TimerProtocol.Type? { extract() }
        var interval: TimeInterval? { extract() }
    }
}

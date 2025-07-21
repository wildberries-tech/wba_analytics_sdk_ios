//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

public final class TimerMock: TimerProtocol {
    public var isValid = true

    public static func reset() {
        scheduledTimerWithRepeatsBlockReceivedArguments = nil
        scheduledTimerWithRepeatsBlockWasCalled = 0
        timerReceivedArguments = nil
        timerStub = nil
        timerWasCalled = 0
    }

    public init() { }

    // MARK: - timer

    public static var timerWasCalled = 0
    public static var timerReceivedArguments: (timeInterval: TimeInterval, repeats: Bool, block: (Timer) -> Void)?
    public static var timerStub: TimerProtocol!

    public static func timer(with timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> TimerProtocol {
        timerWasCalled += 1
        timerReceivedArguments = (timeInterval, repeats, block)
        return timerStub
    }

    // MARK: - schedule

    public var scheduleWasCalled = 0
    public var scheduleReceivedArguments: RunLoop?

    public func schedule(on runLoop: RunLoop) {
        scheduleWasCalled += 1
        scheduleReceivedArguments = runLoop
    }

    // MARK: - scheduledTimer

    public private(set) static var scheduledTimerWithRepeatsBlockWasCalled: Int = 0
    // swiftlint:disable identifier_name
    public private(set) static var scheduledTimerWithRepeatsBlockReceivedArguments: (
        timeInterval: TimeInterval,
        repeats: Bool,
        block: (Timer) -> Void
    )?
    public static var scheduledTimerWithRepeatsBlockStub: TimerProtocol!

    public static func scheduledTimer(
        with timeInterval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> TimerProtocol {
        scheduledTimerWithRepeatsBlockWasCalled += 1
        scheduledTimerWithRepeatsBlockReceivedArguments = (timeInterval: timeInterval, repeats: repeats, block: block)
        return scheduledTimerWithRepeatsBlockStub
    }

    // MARK: - invalidate

    public var invalidateWasCalled = 0

    public func invalidate() {
        invalidateWasCalled += 1
        isValid = false
    }
}

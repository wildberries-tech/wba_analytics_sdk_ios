//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

// MARK: - TimerProtocol

public protocol TimerProtocol: AnyObject {
    // MARK: Factories

    /// Creates a timer but doesn't start it.
    ///
    /// After creation, the timer must be started on the needed `RunLoop` via `schedule(on:)`.
    static func timer(
        with timeInterval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> TimerProtocol

    /// Creates a timer and starts it on the current `RunLoop`.
    static func scheduledTimer(
        with timeInterval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> TimerProtocol

    // MARK: Instance properties and methods

    var isValid: Bool { get }
    func schedule(on runLoop: RunLoop)
    func invalidate()
}

// MARK: - Timer + TimerProtocol

extension Timer: TimerProtocol {
    public static func timer(
        with timeInterval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> TimerProtocol {
        Timer(timeInterval: timeInterval, repeats: repeats, block: block)
    }

    public static func scheduledTimer(
        with timeInterval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> TimerProtocol {
        scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
    }

    public func schedule(on runLoop: RunLoop) {
        runLoop.add(self, forMode: .common)
    }
}

// MARK: - RunLoopProtocol

public protocol RunLoopProtocol {
    func add(_ timer: Timer, forMode: RunLoop.Mode)
    func perform(modes: [RunLoop.Mode], block: @escaping () -> Void)
}

// MARK: - RunLoop + RunLoopProtocol

extension RunLoop: RunLoopProtocol {
    public func perform(modes: [RunLoop.Mode], block: @escaping () -> Void) {
        perform(inModes: modes) {
            block()
        }
    }
}

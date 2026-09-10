//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import Foundation

protocol PeriodicTrackerProtocol {
    /// Sets the closure called on every timer tick
    func setup(with closure: @escaping () -> Void)
    /// Restarts the countdown: the first tick happens after the interval
    func start()
    /// Stops the countdown
    func invalidate()
}

/// Repeating timer with a fixed interval.
/// Shared foundation for the periodic trackers of the SDK: heartbeat drives it directly,
/// UserEngagementTracker keeps one inside and adds its own payload and delegate on top.
/// The owner drives the lifecycle: start on setup and on returning to the foreground,
/// stop when going to background and on app termination.
final class PeriodicTracker {

    private let interval: TimeInterval
    private let timerMaker: TimerProtocol.Type
    private(set) var timer: TimerProtocol?
    private var onTick: (() -> Void)?

    init(interval: TimeInterval, timerMaker: TimerProtocol.Type = Timer.self) {
        self.interval = interval
        self.timerMaker = timerMaker
    }

    deinit {
        invalidate()
    }
}

// MARK: - PeriodicTrackerProtocol

extension PeriodicTracker: PeriodicTrackerProtocol {

    func setup(with closure: @escaping () -> Void) {
        onTick = closure
    }

    func start() {
        invalidate()
        timer = timerMaker.timer(with: interval, repeats: true) { [weak self] _ in
            self?.onTick?()
        }
        timer?.schedule(on: .main)
    }

    func invalidate() {
        guard let timer else { return }
        if timer.isValid {
            timer.invalidate()
        }
        self.timer = nil
    }
}

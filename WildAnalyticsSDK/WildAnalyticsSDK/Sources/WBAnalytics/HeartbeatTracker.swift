//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import Foundation

protocol HeartbeatTrackerProtocol {
    /// Sets the closure called on every timer tick
    func setup(with closure: @escaping () -> Void)
    /// Restarts the countdown: the first firing happens after one interval
    func start()
    /// Stops the countdown
    func invalidate()
}

/// Sends a heartbeat event every 30 seconds while the app is in the foreground.
/// EventsProcessorImpl drives its lifecycle: started on setup and on returning from background,
/// stopped when the app goes to background or terminates.
final class HeartbeatTracker {

    private enum Constants {
        static let timerInterval = 30.0
    }

    private let timerMaker: TimerProtocol.Type
    private(set) var timer: TimerProtocol?
    private var trackEventClosure: (() -> Void)?

    init(timerMaker: TimerProtocol.Type = Timer.self) {
        self.timerMaker = timerMaker
    }

    deinit {
        invalidate()
    }
}

// MARK: - HeartbeatTrackerProtocol

extension HeartbeatTracker: HeartbeatTrackerProtocol {

    func setup(with closure: @escaping () -> Void) {
        trackEventClosure = closure
    }

    func start() {
        invalidate()
        timer = timerMaker.timer(with: Constants.timerInterval, repeats: true) { [weak self] _ in
            self?.trackEventClosure?()
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

// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

/// Protocol for User Engagement Tracker Delegate
protocol UserEngagementTrackerDelegate: AnyObject {
    /// Method to be called when User Engagement Tracker is fired
    /// - Parameter userEngagement: Parameters that were collected where the user is engaged
    func didUserEngagementTrackerFire(_ userEngagement: UserEngagement?)
}

protocol UserEngagementTrackerProtocol {
    func start()
    func invalidate()
    func set(userEngagement: UserEngagement?)
}

/// User Engagement Tracker
final class UserEngagementTracker: UserEngagementTrackerProtocol {

    private enum Constants {
        /// Timer interval for tracking user engagement
        static let timerInterval = 30.0
    }

    private let timerMaker: TimerProtocol.Type
    private(set) var timer: TimerProtocol?
    private var lastUserEngagement: UserEngagement?
    private weak var delegate: UserEngagementTrackerDelegate?

    /// Initializer for User Engagement Tracker
    /// - Parameter queue: DispatchQueue where DispatchSourceTimer will be working on
    /// - Parameter delegate: The delegate to be notified when user engagement should be tracked
    init(
        delegate: UserEngagementTrackerDelegate? = nil,
        timerMaker: TimerProtocol.Type = Timer.self
    ) {
        self.delegate = delegate
        self.timerMaker = timerMaker
    }

    /// Set the actual user engagements
    /// - Parameter userEngagement: Parameters that were collected
    func set(userEngagement: UserEngagement?) {
        self.lastUserEngagement = userEngagement
    }

    /// Start tracking user engagement
    func start() {
        invalidate()
        timer = timerMaker.timer(with: Constants.timerInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.delegate?.didUserEngagementTrackerFire(self.lastUserEngagement)
        }
        timer?.schedule(on: .main)
    }

    /// Invalidate tracking
    func invalidate() {
        guard let timer = timer, timer.isValid else { return }
        timer.invalidate()
        self.timer = nil
    }
}

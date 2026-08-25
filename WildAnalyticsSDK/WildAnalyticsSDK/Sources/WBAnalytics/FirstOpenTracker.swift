//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import Foundation

protocol FirstOpenTrackerProtocol {
    /// Tracks exactly once per app lifetime on the device — per apiKey
    func trackIfNeeded(apiKey: String, _ track: () -> Void)
}

/// Responsible for the first_open event being sent only once.
/// The sent flag is stored separately per apiKey, so each receiver sends its own event.
final class FirstOpenTracker {

    private enum Constants {
        static let sentKeyPrefix = "first-open-sent."
        /// Key from previous SDK versions: its presence means the SDK has already run on this device
        static let legacyLaunchKey = "WildAnalyticsSDK-isNewLaunch"
        static let defaultsSuiteName = "WBAnalyticsDefaults"
    }

    // Process-wide snapshot of the legacy key: each receiver has its own EventsProcessorImpl with
    // its own queue, and their setup blocks run in parallel. If the legacy key were read lazily
    // inside trackIfNeeded, receiver A could create the key (via checkOnNewLaunch) before receiver B
    // reaches its own check, and B would mistake that for a migration, permanently losing first_open.
    // Instead the key is read once — when the very first FirstOpenTracker in the process is created
    // (it's created in EventsProcessorImpl.init, i.e. strictly before the first setup) — and that
    // snapshot is reused by every other instance by default.
    private static var cachedLegacyLaunchKeyExists: Bool?

    /// Resets the legacy key snapshot. Only needed by tests: otherwise the static state leaks
    /// between test methods running in the same process.
    static func resetLegacyLaunchKeyCacheForTesting() {
        cachedLegacyLaunchKeyExists = nil
    }

    private let defaults: UserDefaults
    private let legacyDefaults: UserDefaults
    private let legacyLaunchKeyExists: Bool

    /// - Parameter legacyLaunchKeyExists: Injectable value for tests — lets tests exercise
    ///   `trackIfNeeded`'s behavior without touching the process-wide static snapshot. `nil` (the
    ///   default) enables production behavior: the value comes from the process cache, or, if the
    ///   cache is still empty, is read from `legacyDefaults` and stored in the cache.
    init(
        defaults: UserDefaults = UserDefaults(suiteName: Constants.defaultsSuiteName) ?? .standard,
        legacyDefaults: UserDefaults = .standard,
        legacyLaunchKeyExists: Bool? = nil
    ) {
        self.defaults = defaults
        self.legacyDefaults = legacyDefaults

        if let legacyLaunchKeyExists {
            self.legacyLaunchKeyExists = legacyLaunchKeyExists
        } else if let cached = Self.cachedLegacyLaunchKeyExists {
            self.legacyLaunchKeyExists = cached
        } else {
            let exists = legacyDefaults.object(forKey: Constants.legacyLaunchKey) != nil
            Self.cachedLegacyLaunchKeyExists = exists
            self.legacyLaunchKeyExists = exists
        }
    }
}

// MARK: - FirstOpenTrackerProtocol

extension FirstOpenTracker: FirstOpenTrackerProtocol {

    func trackIfNeeded(apiKey: String, _ track: () -> Void) {
        let key = Constants.sentKeyPrefix + apiKey
        guard !defaults.bool(forKey: key) else { return }
        defaults.set(true, forKey: key)

        // Migration: the SDK was already running on this device before this flag existed,
        // and first_open was already sent earlier based on the client's isFirstLaunch flag
        guard !legacyLaunchKeyExists else { return }

        track()
    }
}

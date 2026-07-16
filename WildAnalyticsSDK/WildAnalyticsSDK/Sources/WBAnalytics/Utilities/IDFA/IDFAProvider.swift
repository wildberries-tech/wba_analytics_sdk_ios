//  Copyright © 2026 Wildberries LLC. All rights reserved.

import Foundation
#if canImport(AdSupport)
import AdSupport
#endif
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// Provides the device advertising identifier (IDFA) read directly from the OS.
protocol IDFAProvider {
    /// Current IDFA, or an empty string when tracking isn't authorized,
    /// collection is disabled, or the value is otherwise unavailable.
    func currentIDFA() -> String
}

/// Reads the IDFA straight from the OS using `AdSupport`.
///
/// We only ever read the identifier — we never present the ATT prompt. The prompt is the
/// integrating app's responsibility. We consult `AppTrackingTransparency` solely to learn the
/// user's response: if the user hasn't authorized tracking (explicitly denied or not yet asked),
/// we treat it as no permission and return an empty string.
final class SystemIDFAProvider: IDFAProvider {

    private let isDisabled: Bool

    /// - Parameter isDisabled: When `true`, the provider always returns an empty string.
    init(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }

    func currentIDFA() -> String {
        guard !isDisabled else { return "" }
        return readIDFAFromSystem()
    }

    private func readIDFAFromSystem() -> String {
#if canImport(AdSupport) && canImport(AppTrackingTransparency)
        guard isTrackingAuthorized else { return "" }
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return idfa.isValidIDFA ? idfa : ""
#else
        return ""
#endif
    }

#if canImport(AppTrackingTransparency)
    private var isTrackingAuthorized: Bool {
        // ATT exists only on iOS/tvOS 14+. On earlier systems there is no authorization
        // concept to consult, so we conservatively treat tracking as not authorized.
        guard #available(iOS 14, tvOS 14, *) else { return false }
        return ATTrackingManager.trackingAuthorizationStatus == .authorized
    }
#endif
}

/// Gates IDFA reads until the provider is activated.
///
/// On the first launch we postpone *reading* the identifier for a configurable interval so the
/// app has time to request ATT authorization and the user to answer. Until `activate()` is called
/// the wrapped provider is not consulted and `currentIDFA()` returns an empty string; afterwards
/// reads pass straight through. Event delivery is unaffected — only the IDFA value is withheld.
///
/// Not thread-safe by itself: it is only ever touched on the analytics serial queue, where both
/// `currentIDFA()` (batch building) and `activate()` (the scheduled activation) run.
final class DelayedIDFAProvider: IDFAProvider {

    private let wrapped: IDFAProvider
    private var isActive: Bool

    /// - Parameters:
    ///   - wrapped: The provider consulted once active.
    ///   - isActive: Whether reads are allowed immediately. Pass `false` to start gated.
    init(wrapped: IDFAProvider, isActive: Bool) {
        self.wrapped = wrapped
        self.isActive = isActive
    }

    /// Opens the gate so subsequent `currentIDFA()` calls read from the wrapped provider.
    func activate() {
        isActive = true
    }

    func currentIDFA() -> String {
        guard isActive else { return "" }
        return wrapped.currentIDFA()
    }
}

extension String {
    /// `true` when the string is a usable IDFA, i.e. not the all-zero placeholder the
    /// system returns when the advertising identifier is unavailable.
    var isValidIDFA: Bool {
        self != Constants.zeroIDFA
    }

    private enum Constants {
        // The advertising identifier UUID format is fixed.
        static let zeroIDFA = "00000000-0000-0000-0000-000000000000"
    }
}

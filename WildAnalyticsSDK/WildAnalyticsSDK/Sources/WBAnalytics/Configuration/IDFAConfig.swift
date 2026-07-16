//  Copyright © 2026 Wildberries LLC. All rights reserved.

import Foundation

/// Configuration of the advertising identifier (IDFA) collection.
///
/// The SDK reads the IDFA directly from the OS via `AdSupport`, gated by the user's
/// App Tracking Transparency response. The integrating app controls whether collection
/// happens at all and how long the first launch waits for the ATT answer.
public struct IDFAConfig: Equatable {

    /// When `true`, the SDK never reads or sends the advertising identifier:
    /// `device_ad_id` is always an empty string. Use this for apps that don't want
    /// to collect the IDFA even though `AdSupport` is linked.
    public let isDisabled: Bool

    /// On the very first launch, the SDK postpones *reading* the IDFA for this interval to give
    /// the app time to request ATT authorization and the user time to respond. Events keep
    /// flowing during this window — they simply carry an empty `device_ad_id` until the delay
    /// elapses, after which subsequent batches carry the real value. Applies only to the first
    /// launch. Set `0` to start reading immediately.
    public let firstLaunchIDFADelay: TimeInterval

    /// - Parameters:
    ///   - isDisabled: Disable IDFA collection entirely. Defaults to `false`.
    ///   - firstLaunchIDFADelay: First launch IDFA read delay in seconds. Defaults to `60`.
    public init(
        isDisabled: Bool = false,
        firstLaunchIDFADelay: TimeInterval = 60
    ) {
        self.isDisabled = isDisabled
        self.firstLaunchIDFADelay = firstLaunchIDFADelay
    }
}

//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

/// AnalyticsCompletionReceiver is a protocol that defines methods for analytics tracking
/// with a completion handler to indicate success or failure of the tracking operation.
///
/// **Note:** The usage of this protocol is independent of events from the `AnalyticsReceiver` protocol.
/// It is recommended to use this protocol only when it is essential to know that the event was tracked successfully.
/// In other cases, prefer using `func trackEvent(name: String, parameters: [String: Any]?)` from `AnalyticsReceiver`.
public protocol AnalyticsCompletionReceiver {

    /// Tracks an event synchronously with a name and optional parameters.
    /// - Parameters:
    ///   - name: The name of the event to be tracked. This should be a descriptive string
    ///            that identifies the action or occurrence being logged.
    ///   - parameters: A dictionary of parameters for the event. This can include any
    ///                 additional data relevant to the event, or it can be nil if no extra data is needed.
    ///   - completion: A closure that is called when the tracking operation is complete.
    ///                 It takes a Boolean parameter indicating whether the event was tracked successfully.
    func trackEventWithCompletion(name: String, parameters: [String: Any]?, completion: @escaping (_ successfully: Bool) -> Void)
}

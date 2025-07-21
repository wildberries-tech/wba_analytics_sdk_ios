//  Copyright © 2021 Wildberries LLC. All rights reserved.

import Foundation

/// AnalyticsReceiver is a protocol that defines the basic methods for analytics tracking.
public protocol AnalyticsReceiver {

    /// A unique identifier for the analytics receiver.
    var identifier: String { get }

    /// Sets up the analytics receiver.
    func setup()

    /// Sets common parameters for all tracking events.
    /// - Parameter parameters: A dictionary of parameters to be set.
    func setCommonParameters(_ parameters: [String: Any])

    /// Tracks an event with a name and optional parameters.
    /// - Parameters:
    ///   - name: The name of the event.
    ///   - parameters: A dictionary of parameters for the event.
    func trackEvent(name: String, parameters: [String: Any]?)

    /// Tracks an event with a name and optional parameters.
    /// - Parameters:
    ///   - name: The name of the event.
    ///   - parameters: An array of parameters for the event.
    func trackEvent<P>(name: String, parameters: [P]?) where P: Encodable

    /// Track user engagement last seen screen
    /// - Parameter screenName: screen name
    func trackUserEngagement(_ userEngagement: UserEngagement)

    /// Set authenticated user token
    /// - Parameter token: Token
    func setUserToken(_ token: String?)

    /// Check attribution
    /// - Parameter completion: Completion block with result
    func checkAttribution(completion: ((Result<AttributionData?, Error>) -> Void)?)
}

public extension AnalyticsReceiver {
    /// Setup the analytics SDK with the provided parameters.
    /// It should be called in your app's application:didFinishLaunchingWithOptions: method.
    func setup() {}
    /// Sets common parameters for the analytics.
    func setCommonParameters(_ parameters: [String: Any]) {}
    /// Logs an event with the provided parameters.
    func trackEvent(name: String, parameters: [String: Any]?) {}
    /// Logging generic for sending an event with the provided parameters.
    func trackEvent<P>(name: String, parameters: [P]?) where P: Encodable {}
}

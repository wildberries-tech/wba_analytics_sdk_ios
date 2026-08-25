// Copyright © 2021 Wildberries. All rights reserved.

import Foundation

/// Event is a typealias for a dictionary with String keys and Any values.
typealias Event = [String: Any]

/// Extension to add functionality to Event.
extension Event {

    /// Initializer for Event.
    /// - Parameters:
    ///   - name: The name of the event.
    ///   - data: The data associated with the event.
    ///   - time: The time the event occurred.
    ///   - eventNum: Event number
    ///   - sessionValue: Unique session value
    init(name: String, data: [String: Any], time: String, eventNum: Int, sessionValue: String) {
        self = [
            Self.nameKey: name,
            Self.dataKey: data,
            Self.eventTimeKey: time,
            Self.eventNumKey: eventNum,
            Self.sessionValueKey: sessionValue
        ]
    }

    /// Enum to hold constant event names.
    enum Name {
        static let userEngagement = "user_engagement"
        static let firstOpen = "first_open"
        static let openAppWithLink = "dynamic_link_app_open"
        static let heartbeat = "heartbeat"
    }
}

private extension Event {
    static let dataKey: String = "data"
    static let nameKey: String = "name"
    static let eventTimeKey: String = "event_time"
    static let eventNumKey: String = "event_num"
    static let sessionValueKey: String = "session_value"

    /// Enum to hold constant parameter names.
    enum Parameter {
        static let screenName = "screen_name"
    }
}

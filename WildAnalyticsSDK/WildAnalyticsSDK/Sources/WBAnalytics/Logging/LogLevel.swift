// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

/// Log level for any messages to be logged.
/// Please check [this Apple Logging Article](https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code) to understand different logging levels.
public enum LogLevel: Int, CustomStringConvertible {
    /// Use this log level if you want to see everything that is logged.
    case debug = 0
    /// Use this log level if you want to see what is happening during the app execution.
    case info
    /// Use this log level if you want to see if something is not 100% right.
    case warning
    /// Use this log level if you want to see only errors.
    case error

    public var description: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .error:
            return "ERROR"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        }
    }
}

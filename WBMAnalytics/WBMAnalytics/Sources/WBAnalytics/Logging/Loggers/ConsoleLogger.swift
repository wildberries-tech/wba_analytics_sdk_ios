// Copyright © 2024 Wildberries. All rights reserved.

import Foundation
import os.log

final class ConsoleLogger: Logger {

    private static let subsystem = "WBAnalytics"

    private let oslog: OSLog
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
        self.oslog = OSLog(subsystem: Self.subsystem, category: Self.subsystem)
    }

    /// Logs a message with a specific log level
    /// - Parameters:
    ///   - level: The log level
    ///   - label: Tag label
    ///   - message: The message to log
    func log(level: LogLevel, label: String, message: String) {
        guard WBAnalytics.loggingOptions.loggingEnabled, level.rawValue >= WBAnalytics.loggingOptions.level.rawValue  else { return }

        let logMessage = "[\(apiKey)][\(label)]: \(message)"
        os_log("%{public}@", log: oslog, type: osLogType(for: level), logMessage)
    }

    /// Returns the OSLogType for a specific log level
    /// - Parameter level: The log level
    /// - Returns: The corresponding OSLogType
    private func osLogType(for level: LogLevel) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        }
    }
}

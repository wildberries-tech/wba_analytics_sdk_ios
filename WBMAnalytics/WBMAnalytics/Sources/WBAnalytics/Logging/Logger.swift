// Copyright © 2024 Wildberries. All rights reserved.

import Foundation
import os.log

protocol Logger {
    func log(level: LogLevel, label: String, message: String)
    func debug(_ label: String, _ message: String)
    func info(_ label: String, _ message: String)
    func warning(_ label: String, _ message: String)
    func error(_ label: String, _ message: String)
}

extension Logger {
    /// Logs a debug message
    /// - Parameter message: The message to log
    func debug(_ label: String, _ message: String) {
        log(level: .debug, label: label, message: message)
    }

    /// Logs an info message
    /// - Parameter message: The message to log
    func info(_ label: String, _ message: String) {
        log(level: .info, label: label, message: message)
    }

    /// Logs a warning message
    /// - Parameter message: The message to log
    func warning(_ label: String, _ message: String) {
        log(level: .warning, label: label, message: message)
    }

    /// Logs an error message
    /// - Parameter message: The message to log
    func error(_ label: String, _ message: String) {
        log(level: .error, label: label, message: message)
    }
}

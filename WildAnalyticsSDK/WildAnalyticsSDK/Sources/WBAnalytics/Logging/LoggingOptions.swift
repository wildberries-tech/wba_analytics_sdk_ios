// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

/// LoggingOptions is a structure that holds the logging configurations.
public struct LoggingOptions {

    /// A Boolean value that determines whether logging is enabled.
    public let loggingEnabled: Bool
    /// A Boolean value that determines whether requests should be logged.
    public let logRequests: Bool
    /// A Boolean value that determines whether logs should be logged into file.
    public let logToFile: Bool
    /// The level of logging.
    public let level: LogLevel
    /// The default logging options.
    public static let `default`: LoggingOptions = .init(loggingEnabled: false, logRequests: false, logToFile: false, level: .info)

    /// Initializes a new instance of LoggingOptions.
    /// - Parameters:
    ///   - loggingEnabled: A Boolean value that determines whether logging is enabled.
    ///   - logRequests: A Boolean value that determines whether requests should be logged.
    ///   - logToFile: A Boolean value that determines whether logs should be saved to file.
    ///   - level: The level of logging.
    public init(loggingEnabled: Bool, logRequests: Bool, logToFile: Bool, level: LogLevel) {
        self.loggingEnabled = loggingEnabled
        self.logRequests = logRequests
        self.logToFile = logToFile
        self.level = level
    }
}

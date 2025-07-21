// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

final class CompositeLogger: Logger {

    private let loggers: [Logger]

    init(loggers: [Logger]) {
        self.loggers = loggers
    }

    func log(level: LogLevel, label: String, message: String) {
        for logger in loggers {
            logger.log(level: level, label: label, message: message)
        }
    }
}

// MARK: - LogFileHandling

extension CompositeLogger: LogFileHandling {

    func logFileURL() -> URL? {
        loggers.compactMap({ $0 as? LogFileHandling }).first?.logFileURL()
    }

    func clearLogFile() {
        loggers.compactMap({ $0 as? LogFileHandling }).forEach({ $0.clearLogFile() })
    }
}

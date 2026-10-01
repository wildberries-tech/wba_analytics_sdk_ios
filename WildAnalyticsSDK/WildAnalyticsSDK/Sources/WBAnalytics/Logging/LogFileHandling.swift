// Copyright © 2024 WildAnalytics. All rights reserved.

import Foundation

protocol LogFileHandling {
    func logFileURL() -> URL?
    func clearLogFile()
}

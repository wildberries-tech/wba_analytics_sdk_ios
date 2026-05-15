// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

protocol LogFileHandling {
    func logFileURL() -> URL?
    func clearLogFile()
}

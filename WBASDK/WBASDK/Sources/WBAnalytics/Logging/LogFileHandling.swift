// Copyright © 2024 WBA. All rights reserved.

import Foundation

protocol LogFileHandling {
    func logFileURL() -> URL?
    func clearLogFile()
}

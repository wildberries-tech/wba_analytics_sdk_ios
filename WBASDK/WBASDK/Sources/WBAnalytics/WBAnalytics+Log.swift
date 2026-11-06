// Copyright © 2024 WBA. All rights reserved.

import Foundation

public extension WBAnalytics {
    func logViewController() -> AnalyticsLogViewController {
        return AnalyticsLogViewController(logFileHandling: logger)
    }
}

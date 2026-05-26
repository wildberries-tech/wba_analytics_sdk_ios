// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

public extension WBAnalytics {
    func logViewController() -> AnalyticsLogViewController {
        return AnalyticsLogViewController(logFileHandling: logger)
    }
}

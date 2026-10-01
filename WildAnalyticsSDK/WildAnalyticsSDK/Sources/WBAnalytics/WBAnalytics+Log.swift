// Copyright © 2024 WildAnalytics. All rights reserved.

import Foundation

public extension WBAnalytics {
    func logViewController() -> AnalyticsLogViewController {
        return AnalyticsLogViewController(logFileHandling: logger)
    }
}

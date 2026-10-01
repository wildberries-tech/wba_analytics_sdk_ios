//
//  Copyright © 2024 WildAnalytics. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class LoggingOptionsTests: XCTestCase {

    func testDefault() {
        // given
        let value: LoggingOptions = .default
        // then
        XCTAssertEqual(value.level, .info)
        XCTAssertFalse(value.loggingEnabled)
        XCTAssertFalse(value.logRequests)
        XCTAssertFalse(value.logToFile)
    }

}

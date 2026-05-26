//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
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

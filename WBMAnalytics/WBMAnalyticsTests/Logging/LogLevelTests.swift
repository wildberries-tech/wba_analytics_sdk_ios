//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class LogLevelTests: XCTestCase {

    func testDebug() {
        // given
        let log: LogLevel = .debug
        // when
        let result = log.description
        // then
        XCTAssertEqual(result, "DEBUG")
    }

    func testError() {
        // given
        let log: LogLevel = .error
        // when
        let result = log.description
        // then
        XCTAssertEqual(result, "ERROR")
    }

    func testInfo() {
        // given
        let log: LogLevel = .info
        // when
        let result = log.description
        // then
        XCTAssertEqual(result, "INFO")
    }

    func testWarning() {
        // given
        let log: LogLevel = .warning
        // when
        let result = log.description
        // then
        XCTAssertEqual(result, "WARNING")
    }

}

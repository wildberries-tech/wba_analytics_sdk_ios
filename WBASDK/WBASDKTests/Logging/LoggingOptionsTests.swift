//
//  Copyright © 2024 WBA. All rights reserved.
//

import XCTest

@testable import WBASDK

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

//
//  Copyright © 2026 WBA. All rights reserved.
//

import XCTest

@testable import WBASDK

final class IDFAConfigTests: XCTestCase {

    func testDefaultValues() {
        // when
        let config = IDFAConfig()
        // then
        XCTAssertFalse(config.isDisabled)
        XCTAssertEqual(config.firstLaunchIDFADelay, 60)
    }

    func testCustomValues() {
        // when
        let config = IDFAConfig(isDisabled: true, firstLaunchIDFADelay: 0)
        // then
        XCTAssertTrue(config.isDisabled)
        XCTAssertEqual(config.firstLaunchIDFADelay, 0)
    }
}

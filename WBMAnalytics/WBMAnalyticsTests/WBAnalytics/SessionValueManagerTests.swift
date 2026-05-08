//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class SessionValueManagerTests: XCTestCase {
    var subject: SessionValueManagerProtocol!

    override func setUp() {
        super.setUp()
        subject = SessionValueManager.shared
    }

    func testSessionValue() {
        // when
        let sessionValue = subject.sessionValue
        // then
        XCTAssertNotEqual(sessionValue, "")
        XCTAssertNotEqual(sessionValue, TestData.sessionValue)
    }

    func testSetSessionValue() {
        // given
        let newValue = "12345"
        // when
        subject.setSessionValue(newValue)
        // then
        XCTAssertEqual(subject.sessionValue, newValue)
    }
}

// MARK: TestData

private extension SessionValueManagerTests {
    enum TestData {
        static let sessionValue = "1587023248356386046"
    }
}

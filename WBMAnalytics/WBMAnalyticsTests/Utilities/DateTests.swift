//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class DateTests: XCTestCase {

    func testAsString() {
        // given
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        // when
        let dateString = date.asString
        // then
        XCTAssertEqual(dateString, dateFormatter.string(from: date))
    }

}

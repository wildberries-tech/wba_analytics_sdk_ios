//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class DateTests: XCTestCase {

    func testAsString() {
        // given
        let date = Date()
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        // when
        let dateString = date.asString
        // then
        XCTAssertEqual(dateString, dateFormate.string(from: date))
    }

}

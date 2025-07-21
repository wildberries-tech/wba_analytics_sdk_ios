//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class EventTests: XCTestCase {

    // MARK: Init

    func testInit() {
        // when
        let event = Event(
            name: TestData.name,
            data: TestData.data,
            time: TestData.time,
            eventNum: TestData.num
        )
        // then
        XCTAssertEqual(event[TestData.nameKey] as? String, TestData.name)
        XCTAssertEqual(event[TestData.dataKey] as? [String: Int], TestData.data)
        XCTAssertEqual(event[TestData.eventTimeKey] as? String, TestData.time)
        XCTAssertEqual(event[TestData.eventNumKey] as? Int, TestData.num)
    }

    // MARK: Name

    func testName() {
        typealias Name = Event.Name
        XCTAssertEqual(Name.userEngagement, "user_engagement")
        XCTAssertEqual(Name.firstOpen, "first_open")
        XCTAssertEqual(Name.openAppWithLink, "dynamic_link_app_open")
    }
}

private extension EventTests {
    enum TestData {
        static let name: String = "Name123"
        static let time: String = "Name321"
        static let num: Int = 1
        static let data: [String: Int] = ["Data": 2]
        static let dataKey: String = "data"
        static let nameKey: String = "name"
        static let eventTimeKey: String = "event_time"
        static let eventNumKey: String = "event_num"
    }
}

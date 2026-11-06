//
//  Copyright © 2024 WBA. All rights reserved.
//

import XCTest

@testable import WBASDK

final class EventTests: XCTestCase {

    // MARK: Init

    func testInit() {
        // when
        let event = Event(
            name: TestData.name,
            data: TestData.data,
            time: TestData.time,
            eventNum: TestData.num,
            sessionValue: TestData.sessionValue
        )
        // then
        XCTAssertEqual(event[TestData.nameKey] as? String, TestData.name)
        XCTAssertEqual(event[TestData.dataKey] as? [String: Int], TestData.data)
        XCTAssertEqual(event[TestData.eventTimeKey] as? String, TestData.time)
        XCTAssertEqual(event[TestData.eventNumKey] as? Int, TestData.num)
        XCTAssertEqual(event[TestData.sessionValueKey] as? UInt64, TestData.sessionValue)
    }

    // MARK: Name

    func testName() {
        typealias Name = Event.Name
        XCTAssertEqual(Name.userEngagement, "user_engagement")
        XCTAssertEqual(Name.firstOpen, "first_open")
        XCTAssertEqual(Name.openAppWithLink, "dynamic_link_app_open")
        XCTAssertEqual(Name.heartbeat, "heartbeat")
    }
}

private extension EventTests {
    enum TestData {
        static let name: String = "Name123"
        static let time: String = "Name321"
        static let num: Int = 1
        static let sessionValue: UInt64 = 1_587_023_248_356_386_046
        static let data: [String: Int] = ["Data": 2]
        static let dataKey: String = "data"
        static let nameKey: String = "name"
        static let eventTimeKey: String = "event_time"
        static let eventNumKey: String = "event_num"
        static let sessionValueKey: String = "session_value"
    }
}

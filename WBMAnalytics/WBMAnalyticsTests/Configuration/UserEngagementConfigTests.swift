//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class UserEngagementConfigTests: XCTestCase {

    func testDecodeBatchSizeConfigDecodable() {
        // given
        let data = TestData.jsonString.data(using: .utf8)!

        do {
            // when
            let userEngagementConfig = try JSONDecoder().decode(UserEngagementConfig.self, from: data)

            // then
            XCTAssertEqual(
                userEngagementConfig.timerInterval,
                TestData.timerInterval,
                "Decoded timerInterval is not correct"
            )
        } catch {
            XCTFail("Failed to decode BatchSizeConfig: \(error)")
        }
    }
}

private extension UserEngagementConfigTests {
    enum TestData {
        static let timerInterval = 1024.0
        static let jsonString = """
           {
               "timerInterval": 1024.0
           }
           """
    }
}

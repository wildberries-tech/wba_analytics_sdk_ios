//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class UserEngagementTests: XCTestCase {

    // MARK: init

    func testInit() {
        // when
        let userEngagement = UserEngagement(
            screenName: TestData.screenName,
            textSize: .large,
            authType: TestData.authType,
            scaleFactor: TestData.scaleFactor
        )
        // then
        XCTAssertEqual(userEngagement.screenName, TestData.screenName)
        XCTAssertEqual(userEngagement.textSize, .large)
        XCTAssertEqual(userEngagement.authType, TestData.authType)
        XCTAssertEqual(userEngagement.scaleFactor, TestData.scaleFactor)
    }

    // MARK: dictionary

    func testDictionaryContainsAllFields() {
        // given
        let userEngagement = UserEngagement(
            screenName: TestData.screenName,
            textSize: .small,
            authType: TestData.authType,
            scaleFactor: TestData.scaleFactor
        )
        // when
        let dictionary = userEngagement.dictionary
        // then
        XCTAssertEqual(dictionary?.count, 4)
        XCTAssertEqual(dictionary?["screen_name"] as? String, TestData.screenName)
        XCTAssertEqual(dictionary?["text_size"] as? Int, TextSize.small.rawValue)
        XCTAssertEqual(dictionary?["auth_type"] as? String, TestData.authType)
        XCTAssertEqual(dictionary?["scale_factor"] as? String, TestData.scaleFactor)
    }

    func testDictionaryOmitsNilScaleFactor() {
        // given
        let userEngagement = UserEngagement(
            screenName: TestData.screenName,
            textSize: .standard,
            authType: TestData.authType,
            scaleFactor: nil
        )
        // when
        let dictionary = userEngagement.dictionary
        // then
        XCTAssertNil(dictionary?["scale_factor"])
        XCTAssertEqual(dictionary?.count, 3)
    }

    func testDictionaryOmitsAllNilOptionals() {
        // given
        let userEngagement = UserEngagement(
            screenName: TestData.screenName,
            textSize: nil,
            authType: nil,
            scaleFactor: nil
        )
        // when
        let dictionary = userEngagement.dictionary
        // then
        XCTAssertEqual(dictionary?.count, 1)
        XCTAssertEqual(dictionary?["screen_name"] as? String, TestData.screenName)
    }

    func testDictionaryKeepsEmptyScaleFactor() {
        // given an empty string is still a value, unlike nil
        let userEngagement = UserEngagement(
            screenName: TestData.screenName,
            textSize: nil,
            authType: nil,
            scaleFactor: ""
        )
        // when
        let dictionary = userEngagement.dictionary
        // then
        XCTAssertEqual(dictionary?["scale_factor"] as? String, "")
    }

    // MARK: Equatable

    func testEqualityIgnoresNothing() {
        // given two values differing only by scaleFactor
        let lhs = UserEngagement(
            screenName: TestData.screenName,
            textSize: .large,
            authType: TestData.authType,
            scaleFactor: TestData.scaleFactor
        )
        let rhs = UserEngagement(
            screenName: TestData.screenName,
            textSize: .large,
            authType: TestData.authType,
            scaleFactor: "2.0"
        )
        // then
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertEqual(lhs, lhs)
    }
}

// MARK: TestData

private extension UserEngagementTests {
    enum TestData {
        static let screenName = "screenName"
        static let authType = "noAuth"
        static let scaleFactor = "1.5"
    }
}

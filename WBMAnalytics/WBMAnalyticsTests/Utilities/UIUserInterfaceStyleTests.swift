//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class UIUserInterfaceStyleTests: XCTestCase {

    func testUnspecifiedStringValue() {
        // given
        let userInterface: UIUserInterfaceStyle = .unspecified
        // when
        let string = userInterface.stringValue
        // then
        XCTAssertEqual(string, "unspecified")
    }

    func testLightStringValue() {
        // given
        let userInterface: UIUserInterfaceStyle = .light
        // when
        let string = userInterface.stringValue
        // then
        XCTAssertEqual(string, "light")
    }

    func testDarkStringValue() {
        // given
        let userInterface: UIUserInterfaceStyle = .dark
        // when
        let string = userInterface.stringValue
        // then
        XCTAssertEqual(string, "dark")
    }
}

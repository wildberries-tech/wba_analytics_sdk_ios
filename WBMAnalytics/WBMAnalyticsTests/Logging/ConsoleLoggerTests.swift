//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import os.log

@testable import WBMAnalytics

final class ConsoleLoggerTests: XCTestCase {

    func testDoSomething() {
        // when
        let logger = ConsoleLogger(apiKey: "")
        let mirror = ConsoleLoggerMirror(reflecting: logger)
        // then
        XCTAssertEqual(mirror.oslog, OSLog(subsystem: "WBAnalytics", category: "WBAnalytics"))
    }

}

// MARK: - Mirror

private extension ConsoleLoggerTests {

    final class ConsoleLoggerMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: ConsoleLogger) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var  oslog: OSLog { extract() }
    }
}

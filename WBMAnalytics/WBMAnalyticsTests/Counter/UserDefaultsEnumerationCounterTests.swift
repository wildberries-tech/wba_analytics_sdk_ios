//
//

import Foundation
import XCTest

@testable import WBMAnalytics

final class UserDefaultsEnumerationCounterTests: XCTestCase {

    var sut: UserDefaultsEnumerationCounter!
    var defaults: UserDefaults!

    override func setUp() {
        super.setUp()

        defaults = UserDefaults(suiteName: "TestDefaults")
        defaults.removePersistentDomain(forName: "TestDefaults")
        sut = UserDefaultsEnumerationCounter(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "TestDefaults")
        defaults = nil
        sut = nil

        super.tearDown()
    }

    func testDefaultInit() {
        // when
        let counter = UserDefaultsEnumerationCounter()

        // then
        let counterMirror = UserDefaultsEnumerationCounterMirror(reflecting: counter)
        XCTAssertEqual(
            counterMirror.defaults,
            .standard,
            "Default init is not correct"
        )
        XCTAssertEqual(
            counterMirror.queue.label,
            "WBAnalytics.UserDefaultsEnumerationCounterQueue",
            "Default init is not correct"
        )
    }

    func testIncrementedCount() {
        let key = "testKey"

        // Perform 500 increments
        for index in 1...500 {
            let count = sut.incrementedCount(for: key)
            XCTAssertEqual(count, index, "The count should be \(index) after \(index) increments")
        }

        // Verify the final count is 500
        let finalCount = sut.incrementedCount(for: key)
        XCTAssertEqual(finalCount, 501, "The count should be 501 after 500 increments and one more increment")
    }
}

private extension UserDefaultsEnumerationCounterTests {

    final class UserDefaultsEnumerationCounterMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: UserDefaultsEnumerationCounter) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var defaults: UserDefaults! { extract() }
        var queue: DispatchQueue! { extract() }
    }
}

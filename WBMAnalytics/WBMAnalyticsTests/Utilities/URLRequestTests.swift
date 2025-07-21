//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class URLRequestTests: XCTestCase {

    func testIsPrettyFalseURL() {
        // given
        var request = URLRequest(url: TestData.url)
        request.addValue("123", forHTTPHeaderField: "time")
        request.httpBody = Data("321".utf8)
        // when
        let result = request.cURL()
        // then
        XCTAssertEqual(result, TestData.prettyFalseGet)
    }

    func testIsPrettyFalsePostURL() {
        // given
        var request = URLRequest(url: TestData.url)
        request.httpMethod = "POST"
        // when
        let result = request.cURL()
        // then
        XCTAssertEqual(result, TestData.prettyFalsePOST)
    }

    func testIsPrettyTrueURL() {
        // given
        var request = URLRequest(url: TestData.url)
        request.addValue("123", forHTTPHeaderField: "time")
        // when
        let result = request.cURL(pretty: true)
        // then
        XCTAssertEqual(result, TestData.prettyTrue)
    }
}

private extension URLRequestTests {
    enum TestData {
        static let url = URL(string: "example.com")!
        static let prettyFalseGet = "curl -X GET 'example.com' -H 'time: 123' --data '321'"
        static let prettyTrue = "curl --request GET \\\n--url 'example.com' \\\n--header 'time: 123' \\\n"
        static let prettyFalsePOST = "curl -X POST 'example.com' "
    }
}

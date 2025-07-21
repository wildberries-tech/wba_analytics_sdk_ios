//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class BatchConfigTests: XCTestCase {

    func testDefaultInitBatchConfig() {
        // when
        let batchConfig = BatchConfig()

        // then
        XCTAssertEqual(
            batchConfig.sendingDelay,
            TestData.sendingDelay,
            "Default sendingDelay is not correct"
        )
        XCTAssertEqual(
            batchConfig.size,
            TestData.size,
            "Default size is not correct"
        )
        XCTAssertEqual(
            batchConfig.sendingTimerTimeout,
            TestData.sendingTimerTimeout,
            "Default sendingTimerTimeout is not correct"
        )
        XCTAssertEqual(
            batchConfig.requestTimeout,
            TestData.requestTimeout,
            "Default requestTimeout is not correct"
        )
    }

    func testDecodeBatchConfig() {
        // given
        let data = TestData.jsonString.data(using: .utf8)!

        do {
            // when
            let batchConfig = try JSONDecoder().decode(BatchConfig.self, from: data)

            // then
            XCTAssertEqual(
                batchConfig.sendingDelay,
                TestData.sendingDelay,
                "Decoded sendingDelay is not correct"
            )
            XCTAssertEqual(
                batchConfig.size,
                TestData.size,
                "Decoded size is not correct"
            )
            XCTAssertEqual(
                batchConfig.sendingTimerTimeout,
                TestData.sendingTimerTimeout,
                "Decoded sendingTimerTimeout is not correct"
            )
            XCTAssertEqual(
                batchConfig.requestTimeout,
                TestData.requestTimeout,
                "Decoded requestTimeout is not correct"
            )
        } catch {
            XCTFail("Failed to decode BatchConfig: \(error)")
        }
    }
}

private extension BatchConfigTests {
    enum TestData {
        static let sendingDelay: Double = 2.0
        static let size: Int = 200
        static let sendingTimerTimeout: Double = 10.0
        static let requestTimeout: Double = 30.0
        static let jsonString = """
           {
               "sendingDelay": \(sendingDelay),
               "size": \(size),
               "sendingTimerTimeout": \(sendingTimerTimeout),
               "requestTimeout": \(requestTimeout)
           }
           """
    }
}

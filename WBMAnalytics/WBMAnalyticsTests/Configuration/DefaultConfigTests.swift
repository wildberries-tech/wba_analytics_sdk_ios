//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class DefaultConfigTests: XCTestCase {

    func testDefaultConfigInit() throws {
        // when
        let defaultConfig = DefaultConfig()

        // then
        XCTAssertEqual(
            defaultConfig.batchSize.bytesInKb, TestData.bytesInKb,
            "Default batch size not correct"
        )
        XCTAssertEqual(
            defaultConfig.batchSize.maxBatchSizeInKbs, TestData.maxBatchSizeInKbs,
            "Default max batch size not correct"
        )
        XCTAssertEqual(defaultConfig.userEngagement.timerInterval, TestData.timerInterval, "Default timer interval not correct")
    }

    func testDecodeDefaultConfig() {
        // given
        let data = TestData.jsonString.data(using: .utf8)!

        do {
            // when
            let defaultConfig = try JSONDecoder().decode(DefaultConfig.self, from: data)

            // then
            XCTAssertEqual(defaultConfig, TestData.value, "Decoded defaultConfig is not correct")
        } catch {
            XCTFail("Failed to decode RemoteConfig: \(error)")
        }
    }
}

private extension DefaultConfigTests {
    enum TestData {
        static let bytesInKb = 1024
        static let maxBatchSizeInKbs = 512
        static let timerInterval = 30.0

        static let value: DefaultConfig = .init()
        static let jsonString = """
           {
                "analyticsURL": "https://a.wb.ru/m/batch",
                "batch": {
                    "sendingDelay": 2.0,
                    "size": 200,
                    "sendingTimerTimeout": 10.0,
                    "requestTimeout": 30
                },
               "batchSize": {
                    "bytesInKb": 1024,
                    "maxBatchSizeInKbs": 512
               },
               "userEngagement": {
                    "timerInterval": 30.0
               }
           }
           """
    }
}

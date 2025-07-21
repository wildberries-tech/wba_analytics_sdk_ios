//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class BatchSizeConfigTests: XCTestCase {

    func testDecodeBatchSizeConfigDecodable() {
        // given
        let data = TestData.jsonString.data(using: .utf8)!

        do {
            // when
            let batchSizeConfig = try JSONDecoder().decode(BatchSizeConfig.self, from: data)

            // then
            XCTAssertEqual(
                batchSizeConfig.bytesInKb,
                TestData.bytesInKb,
                "Decoded bytesInKb is not correct"
            )
            XCTAssertEqual(
                batchSizeConfig.maxBatchSizeInKbs,
                TestData.maxBatchSizeInKbs,
                "Decoded maxBatchSizeInKbs is not correct"
            )
        } catch {
            XCTFail("Failed to decode BatchSizeConfig: \(error)")
        }
    }

}

private extension BatchSizeConfigTests {
    enum TestData {
        static let bytesInKb = 1024
        static let maxBatchSizeInKbs = 512
        static let jsonString = """
           {
               "bytesInKb": 1024,
               "maxBatchSizeInKbs": 512
           }
           """
    }
}

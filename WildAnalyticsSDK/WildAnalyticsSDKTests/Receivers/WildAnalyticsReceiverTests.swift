//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class WildAnalyticsReceiverTests: XCTestCase {

    private var receiver: WildAnalyticsReceiver!
    private var networkMock: NetworkTypeProviderMock!

    override func setUp() {
        super.setUp()
        networkMock = .init()
        receiver = .init(
            apiKey: "TestKey",
            analyticsURL: TestData.url,
            isFirstLaunch: true,
            loggingOptions: LoggingOptions.default,
            networkTypeProvider: networkMock,
            batchConfig: BatchConfig()
        )
    }

    func testIdentifier() {
        // when
        let identifier = receiver.identifier
        // then
        XCTAssertEqual(identifier, TestData.identifier)
    }

}

private extension WildAnalyticsReceiverTests {
    enum TestData {
        static let identifier = "ru.wildberries.receiver_wildanalyticsreceiver"
        static let url = URL(string: "example.com")!
    }
}

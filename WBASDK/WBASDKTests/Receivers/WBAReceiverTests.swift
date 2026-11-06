//
//  Copyright © 2024 WBA. All rights reserved.
//

import XCTest

@testable import WBASDK

final class WBAReceiverTests: XCTestCase {

    private var receiver: WBAReceiver!
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

private extension WBAReceiverTests {
    enum TestData {
        static let identifier = "ru.wba.receiver_wbareceiver"
        static let url = URL(string: "example.com")!
    }
}

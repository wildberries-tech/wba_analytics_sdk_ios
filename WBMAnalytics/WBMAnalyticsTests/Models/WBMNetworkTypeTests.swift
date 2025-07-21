//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class WBMNetworkTypeTests: XCTestCase {

    func testString() {
        XCTAssertEqual(WBMNetworkType.wifi.rawValue, "Wi-Fi")
        XCTAssertEqual(WBMNetworkType.ethernet.rawValue, "Ethernet")
        XCTAssertEqual(WBMNetworkType.cellular2G.rawValue, "2G")
        XCTAssertEqual(WBMNetworkType.cellular3G.rawValue, "3G")
        XCTAssertEqual(WBMNetworkType.cellular4G.rawValue, "4G")
        XCTAssertEqual(WBMNetworkType.cellular5G.rawValue, "5G")
        XCTAssertEqual(WBMNetworkType.other.rawValue, "Other")
    }

}

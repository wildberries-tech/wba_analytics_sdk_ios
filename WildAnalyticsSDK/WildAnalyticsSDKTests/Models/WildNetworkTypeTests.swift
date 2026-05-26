//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class WildNetworkTypeTests: XCTestCase {

    func testString() {
        XCTAssertEqual(WildNetworkType.wifi.rawValue, "Wi-Fi")
        XCTAssertEqual(WildNetworkType.ethernet.rawValue, "Ethernet")
        XCTAssertEqual(WildNetworkType.cellular2G.rawValue, "2G")
        XCTAssertEqual(WildNetworkType.cellular3G.rawValue, "3G")
        XCTAssertEqual(WildNetworkType.cellular4G.rawValue, "4G")
        XCTAssertEqual(WildNetworkType.cellular5G.rawValue, "5G")
        XCTAssertEqual(WildNetworkType.other.rawValue, "Other")
    }

}

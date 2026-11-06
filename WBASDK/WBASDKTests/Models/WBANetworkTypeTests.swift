//
//  Copyright © 2024 WBA. All rights reserved.
//

import XCTest

@testable import WBASDK

final class WBANetworkTypeTests: XCTestCase {

    func testString() {
        XCTAssertEqual(WBANetworkType.wifi.rawValue, "Wi-Fi")
        XCTAssertEqual(WBANetworkType.ethernet.rawValue, "Ethernet")
        XCTAssertEqual(WBANetworkType.cellular2G.rawValue, "2G")
        XCTAssertEqual(WBANetworkType.cellular3G.rawValue, "3G")
        XCTAssertEqual(WBANetworkType.cellular4G.rawValue, "4G")
        XCTAssertEqual(WBANetworkType.cellular5G.rawValue, "5G")
        XCTAssertEqual(WBANetworkType.other.rawValue, "Other")
    }

}

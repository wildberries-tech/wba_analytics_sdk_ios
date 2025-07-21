//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class DeviceMemoryStateTests: XCTestCase {

    func testDeviceMemoryStateNormal() {
        // when
        DeviceMemoryState.setState(.normal)
        // then
        XCTAssertEqual(DeviceMemoryState.state, .normal, "Device state should be normal")
    }

    func testDeviceMemoryStateNoMemory() {
        // when
        DeviceMemoryState.setState(.noMemory)
        // then
        XCTAssertEqual(DeviceMemoryState.state, .noMemory, "Device state should be noMemory")
    }

    func testDeviceMemoryStateReset() {
        // given
        DeviceMemoryState.setState(.noMemory)
        // when
        DeviceMemoryState.setState(.normal)
        // then
        XCTAssertEqual(DeviceMemoryState.state, .normal, "Device state should be normal after reset")
    }

    func testDeviceMemoryStateDefaultValue() {
        // then
        XCTAssertEqual(DeviceMemoryState.state, .normal, "Device state should be normal after reset")
    }
}

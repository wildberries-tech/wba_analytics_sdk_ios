//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class CPUTests: XCTestCase {

    func testNameForModernCPUs() {
        XCTAssertEqual(Version.iPhone16Pro.cpu.name, "A18 Pro")
        XCTAssertEqual(Version.iPhone16.cpu.name, "A18")
        XCTAssertEqual(Version.iPhone15Pro.cpu.name, "A17 Pro")
        XCTAssertEqual(Version.iPhone14.cpu.name, "A15 Bionic")
    }

    func testNameForMacCPUs() {
        XCTAssertEqual(Version.iPadAirM2_11Inch.cpu.name, "M2")
        XCTAssertEqual(Version.iPadProM4_11Inch.cpu.name, "M4")
    }

    func testNameForLegacyCPUs() {
        XCTAssertEqual(Version.iPhone2G.cpu.name, "S5L8900")
        XCTAssertEqual(Version.iPhone7.cpu.name, "A10 Fusion")
    }

    func testNameForUnknownCPU() {
        XCTAssertEqual(Version.unknown.cpu.name, "unknown")
        XCTAssertEqual(Version.simulator.cpu.name, "unknown")
    }
}

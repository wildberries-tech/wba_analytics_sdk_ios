//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class ConfigProviderTests: XCTestCase {

    func testBundlePathParametrInit() {
        // given
        let bundleMock = BundleMock()
        bundleMock.pathStub = "any"
        // when
        _ = ConfigProvider.forTestInit(bundle: bundleMock)
        // then
        XCTAssertEqual(
            bundleMock.pathWasCalled,
            TestData.bundlePathWasCalled,
            "Should be pathWasCalled called 1 time"
        )
        XCTAssertEqual(
            bundleMock.pathReceivedOfType,
            TestData.pathOfType,
            "Should be set another pathOfType"
        )
        XCTAssertEqual(
            bundleMock.pathReceivedForResource,
            TestData.pathForResource,
            "Should be set another pathForResource"
        )
    }

    func testSetCurrentConfigDefaultInit() throws {
        // given
        let bundleMock = BundleMock()
        bundleMock.pathStub = nil
        // when
        let configProvider = ConfigProvider.forTestInit(bundle: bundleMock)
        // then
        XCTAssertEqual(
            configProvider.currentConfig as? DefaultConfig,
            DefaultConfig(),
            "Should be set another configProvider"
        )
    }

    func testBundleEqualNilInit() throws {
        // when
        let configProvider = ConfigProvider.forTestInit(bundle: nil)
        let mirror = ConfigProviderMirror(reflecting: configProvider)
        // then
        XCTAssertEqual(
            mirror.bundle,
            Bundle(for: ConfigProvider.self),
            "Should be set another bundle"
        )
    }

    func testSetBundleInit() throws {
        // given
        let bundleMock = BundleMock()
        // when
        let configProvider = ConfigProvider.forTestInit(bundle: bundleMock)
        let mirror = ConfigProviderMirror(reflecting: configProvider)
        // then
        XCTAssertEqual(
            mirror.bundle,
            bundleMock,
            "Should be set another bundle"
        )
    }

}

// MARK: - TestData

private extension ConfigProviderTests {
    enum TestData {
        static let bundlePathWasCalled = 1
        static let pathOfType = "json"
        static let pathForResource = "default_config"
    }
}

// MARK: - Mirror

private extension ConfigProviderTests {

    final class ConfigProviderMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: ConfigProvider) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var bundle: Bundle! { extract() }
    }
}

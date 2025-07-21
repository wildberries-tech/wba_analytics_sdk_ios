//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class MetaTests: XCTestCase {

    func testInit() {
        // given
        let timeZoneOffsetSeconds = TimeZone.current.secondsFromGMT()
        let hours = timeZoneOffsetSeconds / 3600
        let minutes = abs(timeZoneOffsetSeconds / 60) % 60
        let timeZoneOffset = String(format: "%+.2d%02d", hours, minutes)
        // when
        let meta = Meta(
            networkType: TestData.networkType,
            deviceId: TestData.deviceID,
            isNewUser: TestData.isNewUser
        )
        // then
        if #available(iOS 16, *) {
            XCTAssertEqual(
                meta["locale"] as? String,
                Locale.current.language.languageCode?.identifier
            )
        } else {
            XCTAssertEqual(
                meta["locale"] as? String,
                Locale.current.languageCode
            )
        }
        XCTAssertEqual(
            meta["product"] as? String,
            TestData.product
        )
        XCTAssertEqual(
            meta["os-build"] as? String,
            UIDevice.current.systemVersion
        )
        XCTAssertEqual(
            meta["tz_offset"] as? String,
            timeZoneOffset
        )
        XCTAssertEqual(
            meta["timezone"] as? String,
            TimeZone.current.identifier
        )
        XCTAssertEqual(
            meta["net_type"] as? String,
            TestData.networkType.rawValue
        )
        XCTAssertEqual(
            meta["local_time"] as? String,
            Date().asString
        )
        XCTAssertEqual(
            meta["app_id"] as? String,
            TestData.appID
        )
        XCTAssertEqual(
            meta["app_version"] as? String,
            TestData.appVersion
        )
        XCTAssertEqual(
            meta["analytics_sdk_version"] as? String,
            TestData.analyticsSDKVersion
        )
        XCTAssertEqual(
            meta["is_new_user"] as? Int,
            1
        )
        XCTAssertEqual(
            meta["model"] as? String,
            TestData.model
        )
        XCTAssertEqual(
            meta["manufacturer"] as? String,
            TestData.manufacturer
        )
        XCTAssertEqual(
            meta["mobile_device_type"] as? String,
            TestData.deviceType
        )
        XCTAssertEqual(
            meta["resolution_width"] as? CGFloat,
            UIScreen.main.bounds.size.width * UIScreen.main.scale
        )
        XCTAssertEqual(
            meta["resolution_height"] as? CGFloat,
            UIScreen.main.bounds.size.height * UIScreen.main.scale
        )
    }

}

private extension MetaTests {
    enum TestData {
        static let networkType: WBMNetworkType = .cellular3G
        static let deviceID: String = "1234"
        static let product: String = "iOS"
        static let systemVersion: String = "17.2"
        static let appID: String = "com.apple.dt.xctest.tool"
        static let appVersion: String = "16.0"
        static let analyticsSDKVersion: String = "3.4.3"
        static let deviceType: String = "computer"
        static let manufacturer: String = "Apple"
        static let model: String = "arm64"
        static let isNewUser = true
    }
}

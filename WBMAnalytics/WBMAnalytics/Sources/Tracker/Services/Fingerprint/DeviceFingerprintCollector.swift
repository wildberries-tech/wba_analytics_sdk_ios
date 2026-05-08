// Copyright © 2025 Wildberries. All rights reserved.

import Foundation
import UIKit

/// Class responsible for collecting device fingerprint (screen, platform, language, timezone, etc.)
class DeviceFingerprintCollector {

    /// Gets the device identifier (e.g., iPhone15,3)
    private func getDeviceIdentifier() -> String {
#if targetEnvironment(simulator)
        return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iPhone15,3"
#else
        var systemInfo = utsname()
        uname(&systemInfo)
        let versionCode: String = String(
            validatingUTF8: NSString(
                bytes: &systemInfo.machine,
                length: Int(_SYS_NAMELEN),
                encoding: String.Encoding.ascii.rawValue
            )!.utf8String!
        )!
        return versionCode
#endif
    }

    /// Generates a mobile browser-like user agent string
    private func generateUserAgent() -> String {
        let deviceIdiom = DeviceInfo.current.userInterfaceIdiom
        let systemVersion = DeviceInfo.current.systemVersion.replacingOccurrences(of: ".", with: "_")

        // Determine device platform string for user agent
        let platformString: String
        switch deviceIdiom {
        case .phone:
            platformString = "iPhone; CPU iPhone OS \(systemVersion) like Mac OS X"
        case .pad:
            platformString = "iPad; CPU OS \(systemVersion) like Mac OS X"
        default:
            platformString = "iPhone; CPU iPhone OS \(systemVersion) like Mac OS X"
        }

        // Standard WebKit and Safari versions used in real browsers
        let webKitVersion = "605.1.15"
        let safariVersion = "604.1"
        let browserVersion = "26.0"
        let mobileVersion = "15E148"

        return "Mozilla/5.0 (\(platformString)) AppleWebKit/\(webKitVersion) (KHTML, like Gecko) Version/\(browserVersion) Mobile/\(mobileVersion) Safari/\(safariVersion)"
    }

    /// Collects device fingerprint for the current device
    func collect() -> DeviceFingerprint {
        let size = DeviceInfo.current.screenPixelsSize
        let screenResolution = "\(Int(size.width))x\(Int(size.height))"
        let pixelRatio = "\(Int(DeviceInfo.current.screenScale))"
        let platform = DeviceInfo.current.deviceType
        var language = String(Locale.preferredLanguages.first?.split(separator: "-").first ?? "")
        let timezone = TimeZone.current.identifier
        let device = DeviceInfo.current.deviceType
        let versionOS = DeviceInfo.current.systemVersion

        #if targetEnvironment(simulator)
        if language == "en" {
            language = "en-US"
        }
        #endif

        return DeviceFingerprint(
            screen_resolution: screenResolution,
            pixel_ratio: pixelRatio,
            platform: platform,
            language: language,
            timezone: timezone,
            user_agent: generateUserAgent(),
            device: device,
            version_os: versionOS
        )
    }

}

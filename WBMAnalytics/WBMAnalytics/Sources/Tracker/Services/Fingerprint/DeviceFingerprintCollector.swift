// Copyright © 2025 Wildberries. All rights reserved.

import Foundation
import UIKit
import CoreTelephony
import SystemConfiguration
import AdSupport

/// Class responsible for collecting device fingerprint (screen, platform, language, timezone, etc.)
class DeviceFingerprintCollector {
    /// Collects device fingerprint for the current device
    func collect() -> DeviceFingerprint {
        let size = Device.version(detectSimulator: true).physicalSize
        let screen = "\(Int(size.width))x\(Int(size.height))"
        let platform = UIDevice.current.model
        var language = String(Locale.preferredLanguages.first?.split(separator: "-").first ?? "")
        let timezone = TimeZone.current.identifier

        #if targetEnvironment(simulator)
        if language == "en" {
            language = "en-US"
        }
        #endif

        return DeviceFingerprint(
            screen: screen,
            platform: platform,
            language: language,
            timezone: timezone
        )
    }

}

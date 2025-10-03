// Copyright © 2025 Wildberries. All rights reserved.

import Foundation

/// Device fingerprint model for attribution
struct DeviceFingerprint: Codable {
    /// Device screen (e.g., 1440x900)
    let screen: String
    /// Platform (e.g., MacIntel, iPhone, Android)
    let platform: String
    /// System language (e.g., ru-RU)
    let language: String
    /// Timezone (e.g., Europe/Moscow)
    let timezone: String
    /// User-Agent string (e.g., Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15...)
    let user_agent: String // swiftlint:disable:this identifier_name
    /// Device model (e.g., iPhone15,3)
    let device: String
    /// Operating system version (e.g., 18.0)
    let version_os: String // swiftlint:disable:this identifier_name

}

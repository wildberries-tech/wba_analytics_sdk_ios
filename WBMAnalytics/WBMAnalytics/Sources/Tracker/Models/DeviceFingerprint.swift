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

}

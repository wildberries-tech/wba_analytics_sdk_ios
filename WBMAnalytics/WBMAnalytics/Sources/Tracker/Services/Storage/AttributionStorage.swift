// Copyright © 2025 Wildberries. All rights reserved.

import Foundation

/// Protocol for saving and loading attribution
protocol AttributionStorageProtocol {
    /// Saves attribution
    func save(_ response: AttributionData)
    /// Loads attribution if available
    func load() -> AttributionData?
}

/// Implementation of attribution storage using UserDefaults
final class UserDefaultsAttributionStorage: AttributionStorageProtocol {

    private let key = "ru.wba.deviceFingerprint.attribution"

    func save(_ response: AttributionData) {
        if let data = try? JSONEncoder().encode(response) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    func load() -> AttributionData? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(AttributionData.self, from: data)
    }
}

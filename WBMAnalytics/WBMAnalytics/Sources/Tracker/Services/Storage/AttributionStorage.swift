// Copyright © 2025 Wildberries. All rights reserved.

import Foundation

/// Protocol for saving and loading attribution
protocol AttributionStorageProtocol {
    /// Saves attribution
    func save(_ response: AttributionData)
    /// Loads attribution if available
    func load() -> AttributionData?

    /// Save a status that attribution was requested
    func saveAtrributionDidRequested()

    /// Check if the attribution was requested
    func isAtrributionDidRequested() -> Bool
}

/// Implementation of attribution storage using UserDefaults
final class UserDefaultsAttributionStorage: AttributionStorageProtocol {

    private enum Keys {
        static let attribution = "ru.wba.deviceFingerprint.attribution"
        static let attributionDidRequested = "ru.wba.deviceFingerprint.attributionDidRequested"
    }

    func save(_ response: AttributionData) {
        saveAtrributionDidRequested()
        if let data = try? JSONEncoder().encode(response) {
            UserDefaults.standard.set(data, forKey: Keys.attribution)
        }
    }

    func load() -> AttributionData? {
        guard let data = UserDefaults.standard.data(forKey: Keys.attribution) else { return nil }
        return try? JSONDecoder().decode(AttributionData.self, from: data)
    }

    func saveAtrributionDidRequested() {
        UserDefaults.standard.set(true, forKey: Keys.attributionDidRequested)
    }

    func isAtrributionDidRequested() -> Bool {
        UserDefaults.standard.bool(forKey: Keys.attributionDidRequested)
    }
}

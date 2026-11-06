//  Copyright © 2026 WildAnalytics. All rights reserved.

import Foundation

/// Provides the locale of the operating system.
protocol SystemLocaleProviding {
    /// Language and region of the OS in BCP-47 form, e.g. `en-US`.
    ///
    /// Independent of the locale the application sets for itself; empty when unavailable.
    var systemLocaleTag: String { get }
}

/// Reads the global preferences domain, i.e. the settings of the device itself.
protocol SystemPreferencesReading {
    /// Values stored in the global domain, empty when it can't be read.
    func globalDomainValues() -> [String: Any]
}

extension UserDefaults: SystemPreferencesReading {
    func globalDomainValues() -> [String: Any] {
        persistentDomain(forName: UserDefaults.globalDomain) ?? [:]
    }
}

/// The locale Foundation resolves for the running process.
protocol LocaleSource {
    /// Identifier of the current locale, e.g. `en_RU`.
    var currentLocaleIdentifier: String { get }
    /// Languages preferred by the process, most preferred first.
    var preferredLanguages: [String] { get }
}

struct SystemLocaleSource: LocaleSource {
    var currentLocaleIdentifier: String { Locale.autoupdatingCurrent.identifier }
    var preferredLanguages: [String] { Locale.preferredLanguages }
}

/// Resolves the locale of the operating system.
///
/// Both halves are read from the phone's own language entry in the global preferences domain,
/// because that is where the user's choice lands whole: on iOS the phone language is picked as a
/// language *and* a region at once — "English (Australia)" is stored as `en-AU`. This matches
/// Android, where `toLanguageTag()` likewise returns the pair the user picked.
///
/// Two nearby values are deliberately not the primary source:
///
/// - `Locale.preferredLanguages` is read through the application's own preferences domain, so it
///   follows the language the app sets for itself, the per-app language from the system settings
///   and the localizations the app bundle ships. The global domain is affected by none of those.
/// - `AppleLocale` carries the separate Region setting, which drives formatting and can stay
///   behind the chosen language: a phone set to English (Australia) whose region is still Russia
///   keeps `en_RU`. It only fills in when the language entry carries no region of its own.
final class SystemLocaleProvider: SystemLocaleProviding {

    private enum Constants {
        static let languagesKey = "AppleLanguages"
        static let localeKey = "AppleLocale"
        static let logLabel = "SystemLocale"
        static let unknownValue = "-"
    }

    private let preferences: SystemPreferencesReading
    private let localeSource: LocaleSource
    private let logger: Logger?

    init(
        preferences: SystemPreferencesReading = UserDefaults.standard,
        localeSource: LocaleSource = SystemLocaleSource(),
        logger: Logger? = nil
    ) {
        self.preferences = preferences
        self.localeSource = localeSource
        self.logger = logger
    }

    var systemLocaleTag: String {
        // Resolved on every read so that a language or region changed while the app
        // runs is picked up.
        let values = preferences.globalDomainValues()
        let languageTag = (values[Constants.languagesKey] as? [String])?.first
        let localeIdentifier = values[Constants.localeKey] as? String
        let currentLocaleIdentifier = localeSource.currentLocaleIdentifier
        // Consulted in order, each one asked for both halves: the phone's own language entry
        // first, then the values scoped to the application, which are only worth anything when
        // the global domain can't be read at all.
        let sources: [String?] = [
            languageTag,
            localeIdentifier,
            localeSource.preferredLanguages.first,
            currentLocaleIdentifier
        ]
        let tag = LocaleTagBuilder.tag(
            language: sources.lazy.compactMap(LocaleTagBuilder.language).first,
            region: sources.lazy.compactMap(LocaleTagBuilder.region).first
        )
        // The sources go into the log as well: when a value looks wrong, they say which part of
        // the system reported what.
        logger?.debug(
            Constants.logLabel,
            "System locale resolved: \(tag)"
                + " [\(Constants.languagesKey): \(languageTag ?? Constants.unknownValue)"
                + ", \(Constants.localeKey): \(localeIdentifier ?? Constants.unknownValue)"
                + ", current: \(currentLocaleIdentifier)]"
        )
        return tag
    }
}

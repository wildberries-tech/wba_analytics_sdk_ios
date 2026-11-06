//  Copyright © 2026 WildAnalytics. All rights reserved.

import Foundation

/// Extracts the parts of a locale value and assembles them back into a `language-REGION` tag.
///
/// Accepts both shapes the system stores — a language tag (`en-TR`, `zh-Hans-CN`) and a locale
/// identifier (`en_TR`, `ru_RU@rg=auzzzz`). The parsing is done on the raw strings rather than
/// through `Locale`, because the `languageCode` / `regionCode` accessors are deprecated on
/// iOS 16 while the SDK still supports iOS 13, and their replacements are unavailable there.
enum LocaleTagBuilder {

    private enum Constants {
        static let keywordsSeparator: Character = "@"
        static let keywordSeparator: Character = ";"
        static let keywordValueSeparator: Character = "="
        static let subtagSeparator: Character = "-"
        static let identifierSubtagSeparator = "_"
        static let regionOverrideKeyword = "rg"
        /// Padding the `rg` keyword appends to a region code, as in `ruzzzz`.
        static let regionOverridePadding = "zzzz"
        static let languageLengths = 2...3
        static let alphabeticRegionLength = 2
        static let numericRegionLength = 3
        static let extensionSingletonLength = 1
    }

    /// Language subtag of a language tag or a locale identifier, lowercased.
    static func language(in value: String?) -> String? {
        guard let candidate = subtags(of: value).first,
              Constants.languageLengths.contains(candidate.count),
              candidate.allSatisfy({ $0.isLetter })
        else {
            return nil
        }
        return candidate.lowercased()
    }

    /// Region subtag of a language tag or a locale identifier, uppercased.
    ///
    /// Skips the script subtag and stops at the extension singleton (`u`, `x`), after which no
    /// region can appear. A region in the `rg` keyword wins: that is where the system puts a
    /// region chosen independently of the language.
    static func region(in value: String?) -> String? {
        if let override = regionOverride(in: value) { return override }
        for subtag in subtags(of: value).dropFirst() {
            if subtag.count == Constants.extensionSingletonLength { return nil }
            if let region = normalizedRegion(subtag) { return region }
        }
        return nil
    }

    /// Assembles a BCP-47 tag such as `en-US`.
    ///
    /// - Returns: `en-US` when both parts are known, the bare language when the region isn't,
    ///   and an empty string when even the language is unknown.
    static func tag(language: String?, region: String?) -> String {
        guard let language else { return "" }
        guard let region else { return language }
        return language + String(Constants.subtagSeparator) + region
    }

    private static func regionOverride(in value: String?) -> String? {
        guard let keywords = value?
            .split(separator: Constants.keywordsSeparator)
            .dropFirst()
            .first
        else {
            return nil
        }
        for keyword in keywords.split(separator: Constants.keywordSeparator) {
            let parts = keyword.split(separator: Constants.keywordValueSeparator, maxSplits: 1)
            guard parts.count == 2, parts[0] == Constants.regionOverrideKeyword else { continue }
            var code = String(parts[1])
            if code.hasSuffix(Constants.regionOverridePadding) {
                code.removeLast(Constants.regionOverridePadding.count)
            }
            return normalizedRegion(code)
        }
        return nil
    }

    private static func normalizedRegion(_ subtag: String) -> String? {
        if subtag.count == Constants.alphabeticRegionLength, subtag.allSatisfy({ $0.isLetter }) {
            return subtag.uppercased()
        }
        if subtag.count == Constants.numericRegionLength, subtag.allSatisfy({ $0.isNumber }) {
            return subtag
        }
        return nil
    }

    /// Splits a value into subtags, dropping keywords and unifying both separators.
    private static func subtags(of value: String?) -> [String] {
        guard let value, !value.isEmpty else { return [] }
        let base = value.split(separator: Constants.keywordsSeparator, maxSplits: 1).first ?? ""
        return base
            .replacingOccurrences(
                of: Constants.identifierSubtagSeparator,
                with: String(Constants.subtagSeparator)
            )
            .split(separator: Constants.subtagSeparator, omittingEmptySubsequences: false)
            .map(String.init)
    }
}

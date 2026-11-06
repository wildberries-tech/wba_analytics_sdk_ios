//
//  Copyright © 2026 WBA. All rights reserved.
//

import XCTest

@testable import WBASDK

final class SystemLocaleProviderTests: XCTestCase {

    private var preferences: SystemPreferencesMock!
    private var localeSource: LocaleSourceMock!
    private var logger: LoggerMock!

    override func setUp() {
        super.setUp()
        preferences = SystemPreferencesMock()
        localeSource = LocaleSourceMock()
        logger = LoggerMock()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: TestData.languagesKey)
        preferences = nil
        localeSource = nil
        logger = nil
        super.tearDown()
    }

    private func makeProvider() -> SystemLocaleProvider {
        SystemLocaleProvider(preferences: preferences, localeSource: localeSource, logger: logger)
    }

    // MARK: - Region

    func testRegionComesFromThePhoneLanguage() {
        // given
        // The phone language is English (Australia) while the separate region setting is still
        // Russia. The language the user picked is what the locale has to report.
        preferences.globalDomainValuesStub = [
            TestData.languagesKey: ["en-AU"],
            TestData.localeKey: "en_RU"
        ]
        localeSource.currentLocaleIdentifierStub = "en_RU"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "en-AU")
    }

    func testRegionOfASwissGermanPhone() {
        // given
        preferences.globalDomainValuesStub = [
            TestData.languagesKey: ["de-CH"],
            TestData.localeKey: "de_RU"
        ]
        localeSource.currentLocaleIdentifierStub = "de_RU"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "de-CH")
    }

    func testRegionFallsBackToTheGlobalLocaleWhenTheLanguageCarriesNone() {
        // given
        preferences.globalDomainValuesStub = [
            TestData.languagesKey: ["ru"],
            TestData.localeKey: "ru_KZ"
        ]
        localeSource.currentLocaleIdentifierStub = "ru_KZ"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "ru-KZ")
    }

    func testRegionFallsBackToTheCurrentLocaleLast() {
        // given
        preferences.globalDomainValuesStub = [TestData.languagesKey: ["ru"]]
        localeSource.currentLocaleIdentifierStub = "ru_AU"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "ru-AU")
    }

    // MARK: - Language

    func testLanguageComesFromTheGlobalDomainRatherThanTheCurrentLocale() {
        // given
        // The application may hold a different language than the phone.
        preferences.globalDomainValuesStub = [TestData.languagesKey: ["ru-RU"]]
        localeSource.currentLocaleIdentifierStub = "en_AU"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "ru-RU")
    }

    func testFirstPreferredLanguageIsUsed() {
        // given
        preferences.globalDomainValuesStub = [
            TestData.languagesKey: ["en-TR", "ru-TR"],
            TestData.localeKey: "en_TR"
        ]
        localeSource.currentLocaleIdentifierStub = "en_TR"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "en-TR")
    }

    func testLanguageFallsBackToTheCurrentLocaleWhenTheGlobalDomainIsEmpty() {
        // given
        preferences.globalDomainValuesStub = [:]
        localeSource.preferredLanguagesStub = ["ru-RU"]
        localeSource.currentLocaleIdentifierStub = "ru_AU"
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "ru-RU")
    }

    func testTagIsEmptyWhenNothingIsKnown() {
        // given
        preferences.globalDomainValuesStub = [:]
        // when
        let tag = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(tag, "")
    }

    func testTagIsReadEveryTimeSoSettingsChangesArePickedUp() {
        // given
        preferences.globalDomainValuesStub = [TestData.languagesKey: ["en-RU"]]
        let provider = makeProvider()
        // when
        _ = provider.systemLocaleTag
        preferences.globalDomainValuesStub = [TestData.languagesKey: ["en-AU"]]
        let tag = provider.systemLocaleTag
        // then
        XCTAssertEqual(tag, "en-AU")
    }

    // MARK: - Logging

    func testResolvedTagIsLogged() {
        // given
        preferences.globalDomainValuesStub = [
            TestData.languagesKey: ["en-AU"],
            TestData.localeKey: "en_RU"
        ]
        localeSource.currentLocaleIdentifierStub = "en_RU"
        // when
        _ = makeProvider().systemLocaleTag
        // then
        XCTAssertEqual(logger.debugReceivedLabel, "SystemLocale")
        let message = logger.debugReceivedMessage ?? ""
        XCTAssertTrue(message.hasPrefix("System locale resolved: en-AU"), message)
    }

    func testResolvedTagIsLoggedWithItsSourcesForDiagnostics() {
        // given
        preferences.globalDomainValuesStub = [
            TestData.languagesKey: ["en-AU"],
            TestData.localeKey: "en_RU"
        ]
        localeSource.currentLocaleIdentifierStub = "ru_AU"
        // when
        _ = makeProvider().systemLocaleTag
        // then
        let message = logger.debugReceivedMessage ?? ""
        XCTAssertTrue(message.contains("en-AU"), message)
        XCTAssertTrue(message.contains("en_RU"), message)
        XCTAssertTrue(message.contains("ru_AU"), message)
    }

    // MARK: - Reading the real preferences

    func testGlobalDomainReadIgnoresApplicationLanguageOverride() {
        // given
        // Setting `AppleLanguages` in the application's own domain is how an app implements
        // an in-app language switch. It must not leak into the OS locale we report.
        let defaults = UserDefaults.standard
        let systemLanguages = defaults.globalDomainValues()[TestData.languagesKey] as? [String]
        // when
        defaults.set(TestData.applicationLanguages, forKey: TestData.languagesKey)
        // then
        XCTAssertEqual(defaults.array(forKey: TestData.languagesKey) as? [String], TestData.applicationLanguages)
        XCTAssertEqual(defaults.globalDomainValues()[TestData.languagesKey] as? [String], systemLanguages)
    }

    func testTagIgnoresApplicationLanguageOverride() {
        // given
        let defaults = UserDefaults.standard
        let provider = SystemLocaleProvider(preferences: defaults, logger: logger)
        let tagBeforeOverride = provider.systemLocaleTag
        // when
        defaults.set(TestData.applicationLanguages, forKey: TestData.languagesKey)
        let tagAfterOverride = provider.systemLocaleTag
        // then
        XCTAssertFalse(tagAfterOverride.isEmpty)
        XCTAssertEqual(tagAfterOverride, tagBeforeOverride)
        XCTAssertFalse(tagAfterOverride.hasPrefix("de"))
    }

}

private extension SystemLocaleProviderTests {
    enum TestData {
        static let languagesKey = "AppleLanguages"
        static let localeKey = "AppleLocale"
        static let applicationLanguages = ["de-DE"]
    }
}

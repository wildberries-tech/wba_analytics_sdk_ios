//
//  Copyright © 2026 WildAnalytics. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class LocaleTagBuilderTests: XCTestCase {

    // MARK: - Language

    func testLanguageIsTakenFromTheFirstSubtag() {
        XCTAssertEqual(LocaleTagBuilder.language(in: "ru-RU"), "ru")
    }

    func testLanguageIsLowercased() {
        XCTAssertEqual(LocaleTagBuilder.language(in: "EN-us"), "en")
    }

    func testLanguageIgnoresScriptAndRegion() {
        XCTAssertEqual(LocaleTagBuilder.language(in: "zh-Hans-CN"), "zh")
    }

    func testLanguageIgnoresKeywords() {
        XCTAssertEqual(LocaleTagBuilder.language(in: "ru_RU@rg=auzzzz"), "ru")
    }

    func testLanguageIsNilWhenMissing() {
        XCTAssertNil(LocaleTagBuilder.language(in: "_US"))
        XCTAssertNil(LocaleTagBuilder.language(in: ""))
        XCTAssertNil(LocaleTagBuilder.language(in: nil))
    }

    // MARK: - Region

    func testRegionIsTakenFromAnIdentifier() {
        XCTAssertEqual(LocaleTagBuilder.region(in: "ru_AU"), "AU")
    }

    func testRegionIsTakenFromALanguageTag() {
        XCTAssertEqual(LocaleTagBuilder.region(in: "en-TR"), "TR")
    }

    func testRegionOverrideKeywordWinsOverTheIdentifierRegion() {
        // The system puts a region chosen independently of the language into the `rg` keyword.
        XCTAssertEqual(LocaleTagBuilder.region(in: "ru_RU@rg=auzzzz"), "AU")
    }

    func testRegionSkipsTheScriptSubtag() {
        XCTAssertEqual(LocaleTagBuilder.region(in: "zh-Hans-CN"), "CN")
    }

    func testNumericRegionIsKept() {
        XCTAssertEqual(LocaleTagBuilder.region(in: "es-419"), "419")
    }

    func testRegionIsUppercased() {
        XCTAssertEqual(LocaleTagBuilder.region(in: "en-us"), "US")
    }

    func testRegionIgnoresExtensionSubtags() {
        XCTAssertEqual(LocaleTagBuilder.region(in: "en-US-u-ca-gregory"), "US")
        XCTAssertNil(LocaleTagBuilder.region(in: "en-u-ca-gregory"))
    }

    func testRegionIsNilWhenMissing() {
        XCTAssertNil(LocaleTagBuilder.region(in: "en"))
        XCTAssertNil(LocaleTagBuilder.region(in: ""))
        XCTAssertNil(LocaleTagBuilder.region(in: nil))
    }

    // MARK: - Tag

    func testTagJoinsLanguageAndRegion() {
        XCTAssertEqual(LocaleTagBuilder.tag(language: "en", region: "US"), "en-US")
    }

    func testTagIsTheBareLanguageWithoutARegion() {
        XCTAssertEqual(LocaleTagBuilder.tag(language: "en", region: nil), "en")
    }

    func testTagIsEmptyWithoutALanguage() {
        XCTAssertEqual(LocaleTagBuilder.tag(language: nil, region: "US"), "")
        XCTAssertEqual(LocaleTagBuilder.tag(language: nil, region: nil), "")
    }
}

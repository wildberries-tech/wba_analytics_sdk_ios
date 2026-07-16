//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class IDFAProviderTests: XCTestCase {

    // MARK: - SystemIDFAProvider

    func testDisabledProviderReturnsEmptyString() {
        // given
        let provider = SystemIDFAProvider(isDisabled: true)
        // when
        let idfa = provider.currentIDFA()
        // then
        XCTAssertEqual(idfa, "")
    }

    func testEnabledProviderWithoutAuthorizationReturnsEmptyString() {
        // given
        // In the test environment App Tracking Transparency is never authorized,
        // so an enabled provider must still yield an empty identifier.
        let provider = SystemIDFAProvider(isDisabled: false)
        // when
        let idfa = provider.currentIDFA()
        // then
        XCTAssertEqual(idfa, "")
    }

    // MARK: - DelayedIDFAProvider

    func testInactiveProviderWithholdsIDFA() {
        // given
        let inner = IDFAProviderMock()
        inner.currentIDFAStub = TestData.validIDFA
        let provider = DelayedIDFAProvider(wrapped: inner, isActive: false)
        // when
        let idfa = provider.currentIDFA()
        // then
        XCTAssertEqual(idfa, "")
        XCTAssertEqual(inner.currentIDFAWasCalled, 0)
    }

    func testActiveProviderPassesThroughIDFA() {
        // given
        let inner = IDFAProviderMock()
        inner.currentIDFAStub = TestData.validIDFA
        let provider = DelayedIDFAProvider(wrapped: inner, isActive: true)
        // when
        let idfa = provider.currentIDFA()
        // then
        XCTAssertEqual(idfa, TestData.validIDFA)
    }

    func testActivateOpensTheGate() {
        // given
        let inner = IDFAProviderMock()
        inner.currentIDFAStub = TestData.validIDFA
        let provider = DelayedIDFAProvider(wrapped: inner, isActive: false)
        // when
        XCTAssertEqual(provider.currentIDFA(), "")
        provider.activate()
        // then
        XCTAssertEqual(provider.currentIDFA(), TestData.validIDFA)
    }

    // MARK: - String.isValidIDFA

    func testZeroIDFAIsInvalid() {
        XCTAssertFalse("00000000-0000-0000-0000-000000000000".isValidIDFA)
    }

    func testRegularIDFAIsValid() {
        XCTAssertTrue("01234567-1234-1234-1234-123456789012".isValidIDFA)
    }
}

private extension IDFAProviderTests {
    enum TestData {
        static let validIDFA = "01234567-1234-1234-1234-123456789012"
    }
}

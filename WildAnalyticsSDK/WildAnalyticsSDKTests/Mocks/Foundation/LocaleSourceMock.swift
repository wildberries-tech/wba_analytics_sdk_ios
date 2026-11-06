//
//  Copyright © 2026 WildAnalytics. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class LocaleSourceMock: LocaleSource {
    var currentLocaleIdentifierStub: String = ""
    var preferredLanguagesStub: [String] = []

    var currentLocaleIdentifier: String { currentLocaleIdentifierStub }
    var preferredLanguages: [String] { preferredLanguagesStub }
}

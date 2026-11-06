//
//  Copyright © 2026 WBA. All rights reserved.
//

import Foundation

@testable import WBASDK

final class LocaleSourceMock: LocaleSource {
    var currentLocaleIdentifierStub: String = ""
    var preferredLanguagesStub: [String] = []

    var currentLocaleIdentifier: String { currentLocaleIdentifierStub }
    var preferredLanguages: [String] { preferredLanguagesStub }
}

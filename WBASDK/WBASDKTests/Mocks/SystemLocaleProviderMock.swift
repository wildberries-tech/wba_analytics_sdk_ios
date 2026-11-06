//
//  Copyright © 2026 WBA. All rights reserved.
//

import Foundation

@testable import WBASDK

final class SystemLocaleProviderMock: SystemLocaleProviding {
    var systemLocaleTagStub: String = ""
    private(set) var systemLocaleTagWasCalled: Int = 0

    var systemLocaleTag: String {
        systemLocaleTagWasCalled += 1
        return systemLocaleTagStub
    }
}

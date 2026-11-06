//
//  Copyright © 2026 WildAnalytics. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class SystemLocaleProviderMock: SystemLocaleProviding {
    var systemLocaleTagStub: String = ""
    private(set) var systemLocaleTagWasCalled: Int = 0

    var systemLocaleTag: String {
        systemLocaleTagWasCalled += 1
        return systemLocaleTagStub
    }
}

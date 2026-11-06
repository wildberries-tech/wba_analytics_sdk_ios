//
//  Copyright © 2026 WildAnalytics. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class SystemPreferencesMock: SystemPreferencesReading {
    var globalDomainValuesStub: [String: Any] = [:]
    private(set) var globalDomainValuesWasCalled: Int = 0

    func globalDomainValues() -> [String: Any] {
        globalDomainValuesWasCalled += 1
        return globalDomainValuesStub
    }
}

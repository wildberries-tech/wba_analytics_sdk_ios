//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import Foundation
@testable import WildAnalyticsSDK

final class SessionValueManagerMock: SessionValueManagerProtocol {
    private var _sessionValue: String = "1234567890123456789"

    var sessionValue: String {
        get { _sessionValue }
        set { _sessionValue = newValue }
    }

    private(set) var setSessionValueReceivedValue: String?
    private(set) var setSessionValueWasCalled: Int = 0

    func setSessionValue(_ value: String?) {
        setSessionValueReceivedValue = value
        setSessionValueWasCalled += 1
    }

    private(set) var setOnSessionValueUpdatedReceivedValue: ((String?) -> Void)?
    private(set) var setOnSessionValueUpdatedWasCalled: Int = 0

    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void) {
        setOnSessionValueUpdatedReceivedValue = handler
        setOnSessionValueUpdatedWasCalled += 1
    }
}

//
//  Copyright © 2026 WBA. All rights reserved.
//

import Foundation
@testable import WBASDK

final class SessionValueManagerMock: SessionValueManagerProtocol {
    private var _sessionValue: UInt64 = 1_234_567_890_123_456_789

    var sessionValue: UInt64 {
        get { _sessionValue }
        set { _sessionValue = newValue }
    }

    private(set) var setSessionValueReceivedValue: UInt64?
    private(set) var setSessionValueWasCalled: Int = 0

    func setSessionValue(_ value: UInt64?) {
        setSessionValueReceivedValue = value
        setSessionValueWasCalled += 1
    }

    private(set) var setOnSessionValueUpdatedReceivedValue: ((UInt64?) -> Void)?
    private(set) var setOnSessionValueUpdatedWasCalled: Int = 0

    private(set) weak var setOnSessionValueUpdatedReceivedOwner: AnyObject?

    func setOnSessionValueUpdated(_ handler: @escaping (UInt64?) -> Void, for owner: AnyObject) {
        setOnSessionValueUpdatedReceivedValue = handler
        setOnSessionValueUpdatedReceivedOwner = owner
        setOnSessionValueUpdatedWasCalled += 1
    }
}

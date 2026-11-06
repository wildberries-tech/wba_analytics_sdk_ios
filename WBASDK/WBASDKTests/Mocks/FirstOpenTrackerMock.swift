//
//  Copyright © 2026 WBA. All rights reserved.
//

import Foundation

@testable import WBASDK

final class FirstOpenTrackerMock: FirstOpenTrackerProtocol {

    private(set) var trackIfNeededWasCalled: Int = 0
    private(set) var trackIfNeededReceivedApiKey: String?
    /// Controls whether the mock invokes the passed closure
    var shouldTrack = true

    func trackIfNeeded(apiKey: String, _ track: () -> Void) {
        trackIfNeededWasCalled += 1
        trackIfNeededReceivedApiKey = apiKey
        if shouldTrack {
            track()
        }
    }
}

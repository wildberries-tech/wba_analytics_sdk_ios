//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class UserEngagementTrackerMock: UserEngagementTrackerProtocol {

    // MARK: - start

    private(set) var startWasCalled: Int = 0

    func start() {
        startWasCalled += 1
    }

    // MARK: - invalidate

    private(set) var invalidateWasCalled: Int = 0

    func invalidate() {
        invalidateWasCalled += 1
    }

    // MARK: - set(screenName:)

    private(set) var setUserEngagementReceivedArguments: UserEngagement?
    private(set) var setUserEngagementWasCalled: Int = 0

    func set(userEngagement: UserEngagement?) {
        setUserEngagementReceivedArguments = userEngagement
        setUserEngagementWasCalled += 1
    }
}

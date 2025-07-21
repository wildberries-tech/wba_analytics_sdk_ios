//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class UserEngagementTrackerDelegateMock: UserEngagementTrackerDelegate {

    private(set) var didUserEngagementTrackerFireWasCalled: Int = 0
    // swiftlint:disable identifier_name
    private(set) var didUserEngagementTrackerFireReceivedUserEngagement: UserEngagement?

    func didUserEngagementTrackerFire(_ userEngagement: UserEngagement?) {
        didUserEngagementTrackerFireReceivedUserEngagement = userEngagement
        didUserEngagementTrackerFireWasCalled += 1
    }

}

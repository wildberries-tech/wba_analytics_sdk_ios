//
//  Copyright © 2024 WBA. All rights reserved.
//

import Foundation

@testable import WBASDK

final class UserEngagementTrackerDelegateMock: UserEngagementTrackerDelegate {

    private(set) var didUserEngagementTrackerFireWasCalled: Int = 0
    // swiftlint:disable identifier_name
    private(set) var didUserEngagementTrackerFireReceivedUserEngagement: UserEngagement?

    func didUserEngagementTrackerFire(_ userEngagement: UserEngagement?) {
        didUserEngagementTrackerFireReceivedUserEngagement = userEngagement
        didUserEngagementTrackerFireWasCalled += 1
    }

}

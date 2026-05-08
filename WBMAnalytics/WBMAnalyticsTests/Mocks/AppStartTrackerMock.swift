//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit

@testable import WBMAnalytics

final class AppStartTrackerMock: AppStartTrackerProtocol {

    private(set) var setupWithReceivedClosure: AppStartTracker.TrackEventClosure?
    private(set) var setupWithWasCalled: Int = 0

    func setup(with closure: @escaping AppStartTracker.TrackEventClosure) {
        setupWithReceivedClosure = closure
        setupWithWasCalled += 1
    }
}

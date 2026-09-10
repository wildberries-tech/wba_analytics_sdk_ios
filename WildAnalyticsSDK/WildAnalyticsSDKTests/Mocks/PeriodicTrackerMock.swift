//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class PeriodicTrackerMock: PeriodicTrackerProtocol {

    private(set) var setupWithReceivedClosure: (() -> Void)?
    private(set) var setupWithWasCalled: Int = 0
    private(set) var startWasCalled: Int = 0
    private(set) var invalidateWasCalled: Int = 0

    func setup(with closure: @escaping () -> Void) {
        setupWithReceivedClosure = closure
        setupWithWasCalled += 1
    }

    func start() {
        startWasCalled += 1
    }

    func invalidate() {
        invalidateWasCalled += 1
    }
}

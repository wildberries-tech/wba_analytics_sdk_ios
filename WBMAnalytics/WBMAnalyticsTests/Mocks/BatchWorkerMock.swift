//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class BatchWorkerMock: BatchWorker {

    private(set) var stateSetWasCalled: Int = 0
    private(set) var stateGetWasCalled: Int = 0

    private(set) var sendBatchDelayedReceivedId: String?
    private(set) var sendBatchDelayedReceivedEvent: (() -> Void)?
    private(set) var sendBatchDelayedWasCalled: Int = 0

    func sendBatchDelayed(id: String, event: @escaping () -> Void) {
        sendBatchDelayedReceivedId = id
        sendBatchDelayedReceivedEvent = event
        sendBatchDelayedWasCalled += 1
    }
}

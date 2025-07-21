//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class BatchSenderMock: NSObject, BatchSender {

    private(set) var sendBatchReceivedData: Data?
    private(set) var sendBatchReceivedCompletion: ((_ successfully: Bool) -> Void)?
    private(set) var sendBatchWasCalled: Int = 0

    private(set) var userTokenWasCalled: Int = 0
    private(set) var userTokenReceivedValue: String?

    func sendBatch(_ requestData: Data, completion: @escaping (_ successfully: Bool) -> Void) {
        sendBatchReceivedData = requestData
        sendBatchReceivedCompletion = completion
        sendBatchWasCalled += 1
    }

    func setUserToken(_ token: String?) {
        self.userTokenWasCalled += 1
        self.userTokenReceivedValue = token
    }
}

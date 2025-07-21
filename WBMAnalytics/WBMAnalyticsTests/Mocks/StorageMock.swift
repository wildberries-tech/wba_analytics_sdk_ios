//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class StorageMock: Storage {

    private(set) var addBatchWasCalled: Int = 0
    private(set) var addBatchReceivedBatch: Batch?
    var addBatchReceivedError: Error?

    func addBatch(_ batch: Batch) throws {
        addBatchWasCalled += 1
        addBatchReceivedBatch = batch

        if let error = addBatchReceivedError {
            throw error
        }
    }

    private(set) var nextBatchWasCalled: Int = 0
    var nextBatchStub: BatchModel?

    func nextBatch() -> BatchModel? {
        nextBatchWasCalled += 1
        return nextBatchStub
    }

    private(set) var removeBatchWasCalled: Int = 0
    private(set) var removeBatchReceivedId: String?
    var removeBatchReceivedError: Error?

    func removeBatch(with id: String) throws {
        removeBatchWasCalled += 1
        removeBatchReceivedId = id

        if let error = removeBatchReceivedError {
            throw error
        }
    }

}

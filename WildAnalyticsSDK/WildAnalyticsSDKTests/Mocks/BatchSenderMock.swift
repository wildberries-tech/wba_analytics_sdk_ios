//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class BatchSenderMock: NSObject, BatchSender {

    private let lock = NSLock()

    private(set) var sendBatchReceivedData: Data?
    private(set) var sendBatchWasCalled: Int = 0

    private var sendContinuation: CheckedContinuation<Bool, Never>?
    private var enteredWaiter: CheckedContinuation<Void, Never>?
    private var pendingEnteredSignal = false

    private(set) var userTokenWasCalled: Int = 0
    private(set) var userTokenReceivedValue: String?

    private(set) var setCustomHeadersWasCalled: Int = 0
    private(set) var setCustomHeadersReceivedValue: [String: String]?

    func sendBatch(_ requestData: Data) async -> Bool {
        lock.lock()
        sendBatchReceivedData = requestData
        sendBatchWasCalled += 1
        let waiter = enteredWaiter
        enteredWaiter = nil
        if waiter == nil {
            pendingEnteredSignal = true
        }
        lock.unlock()
        waiter?.resume()

        return await withCheckedContinuation { continuation in
            lock.lock()
            sendContinuation = continuation
            lock.unlock()
        }
    }

    /// Suspends until `sendBatch` has been entered (and is now awaiting a result).
    /// Mirrors the moment the old completion-based mock captured its completion handler.
    func awaitSendEntered() async {
        lock.lock()
        if pendingEnteredSignal {
            pendingEnteredSignal = false
            lock.unlock()
            return
        }
        await withCheckedContinuation { continuation in
            enteredWaiter = continuation
            lock.unlock()
        }
    }

    /// Resumes the pending `sendBatch` with the given result.
    /// Replacement for invoking the old `sendBatchReceivedCompletion`.
    func completeSend(_ successfully: Bool) {
        lock.lock()
        let continuation = sendContinuation
        sendContinuation = nil
        lock.unlock()
        continuation?.resume(returning: successfully)
    }

    func setUserToken(_ token: String?) {
        self.userTokenWasCalled += 1
        self.userTokenReceivedValue = token
    }

    func setCustomHeaders(_ headers: [String: String]) {
        self.setCustomHeadersWasCalled += 1
        self.setCustomHeadersReceivedValue = headers
    }
}

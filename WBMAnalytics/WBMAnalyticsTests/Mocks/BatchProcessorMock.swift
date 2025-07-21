//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class BatchProcessorMock: BatchProcessor {

    // MARK: - setup

    private(set) var setupReceivedArguments: (
        batchSender: BatchSender,
        queue: Dispatcher?,
        networkTypeProvider: NetworkTypeProviderProtocol,
        counter: EnumerationCounter,
        batchWorker: BatchWorker
    )?
    private(set) var setupWasCalled: Int = 0

    func setup(
        batchSender: BatchSender,
        queue: Dispatcher?,
        networkTypeProvider: NetworkTypeProviderProtocol,
        counter: EnumerationCounter,
        batchWorker: BatchWorker
    ) {
        setupReceivedArguments = (
            batchSender,
            queue,
            networkTypeProvider,
            counter,
            batchWorker
        )
        setupWasCalled += 1
    }

    // MARK: - launch

    private(set) var launchWasCalled: Int = 0

    func launch() {
        launchWasCalled += 1
    }

    // MARK: - update

    private(set) var updateReceivedIsNewValue: Bool?
    private(set) var updateWasCalled: Int = 0

    func update(isNewLaunch: Bool) {
        updateReceivedIsNewValue = isNewLaunch
        updateWasCalled += 1
    }

    // MARK: - addBatch

    private(set) var addBatchReceivedEvents: [Event]?
    private(set) var addBatchWasCalled: Int = 0

    func addBatch(withEvents events: [Event]) {
        addBatchReceivedEvents = events
        addBatchWasCalled += 1
    }

    // MARK: - sendEventSync

    private(set) var sendEventSyncReceivedValue: (event: Event, completion: (Bool) -> Void)?
    private(set) var sendEventSyncWasCalled: Int = 0

    func sendEventSync(event: Event, completion: @escaping (Bool) -> Void) {
        sendEventSyncReceivedValue = (event: event, completion: completion)
        sendEventSyncWasCalled += 1
    }

    // MARK: - Set User Token

    private(set) var setUserTokenReceivedValue: String?
    private(set) var setUserTokenWasCalled: Int = 0

    func setUserToken(_ token: String?) {
        setUserTokenWasCalled += 1
        setUserTokenReceivedValue = token
    }
}

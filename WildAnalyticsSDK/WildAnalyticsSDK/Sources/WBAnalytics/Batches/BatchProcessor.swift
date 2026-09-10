// Copyright © 2024 Wildberries. All rights reserved.

import Foundation
import SQLite3

protocol BatchProcessor {
    func setup(
        batchSender: BatchSender,
        queue: Dispatcher?,
        networkTypeProvider: NetworkTypeProviderProtocol,
        counter: EnumerationCounter,
        batchWorker: BatchWorker,
        idfaProvider: IDFAProvider,
        enableAutomaticEvents: Bool
    )
    func launch()
    func update(isNewLaunch: Bool)
    func addBatch(withEvents events: [Event])
    func sendEventSync(event: Event, completion: @escaping (_ successfully: Bool) -> Void)
    func setUserToken(_ token: String?)
    func setCustomHeaders(_ headers: [String: String])
    func setDeviceId(_ deviceId: String?)
}

final class BatchProcessorImpl: BatchProcessor {

    // init
    private let jsonSerializer: JSONSerialization.Type
    private let logger: Logger
    private var batchSender: BatchSender?
    // setup
    private var networkTypeProvider: NetworkTypeProviderProtocol?
    private var counter: EnumerationCounter?
    private var sendingBatch: BatchModel?
    private var queue: Dispatcher?
    private var batchWorker: BatchWorker?
    private var storage: Storage
    private var deviceId: String?
    private var idfaProvider: IDFAProvider = SystemIDFAProvider(isDisabled: false)
    // default value
    private var batches: [BatchModel] = []
    private var isNewLaunch = false
    private var enableAutomaticEvents = false
    private var state: BatchProcessingState = .normal

    private var batchesFromStorage: [BatchModel] = []
    private var userDefaultsStorage: UserDefaultsStorage?
    private var sendTask: Task<Void, Never>?

    private enum Constants {
        static let bytesInKb: Int = 1024
        static let maxBatchSizeInKbs: Int = 512
        static let logLabel = "BatchProcessor"
    }

    init(
        logger: Logger,
        storage: Storage,
        userDefaultsStorage: UserDefaultsStorage,
        batchSender: BatchSender? = nil,
        jsonSerializer: JSONSerialization.Type = JSONSerialization.self
    ) {
        self.logger = logger
        self.storage = storage
        self.userDefaultsStorage = userDefaultsStorage
        self.batchSender = batchSender
        self.jsonSerializer = jsonSerializer
    }

    func setup(
        batchSender: BatchSender,
        queue: Dispatcher?,
        networkTypeProvider: NetworkTypeProviderProtocol,
        counter: EnumerationCounter,
        batchWorker: BatchWorker,
        idfaProvider: IDFAProvider = SystemIDFAProvider(isDisabled: false),
        enableAutomaticEvents: Bool = false
    ) {
        self.batchSender = batchSender
        self.queue = queue
        self.networkTypeProvider = networkTypeProvider
        self.counter = counter
        self.batchWorker = batchWorker
        self.idfaProvider = idfaProvider
        self.enableAutomaticEvents = enableAutomaticEvents
        self.batchesFromStorage = userDefaultsStorage?.loadBatches() ?? []
        DeviceMemoryState.setState(.normal)
        batches = []
    }

    func launch() {
        sendNextBatch()
    }

    func addBatch(withEvents events: [Event]) {
        logger.debug(Constants.logLabel, "add \(events.count) events to batch...")

        let batchNum = counter?.incrementedCount(for: CounterParams.batchNum) ?? 0
        let batch = Batch(meta: getMeta(), batchNum: batchNum, events: events)

        if DeviceMemoryState.state == .normal {
            do {
                try storage.addBatch(batch)
            } catch {
                logger.error(Constants.logLabel, "Can't add batch error: \(error)")
                DeviceMemoryState.setState(.noMemory)
                batches.append(.init(id: UUID().uuidString, batch: batch))
            }
        } else {
            DeviceMemoryState.setState(.noMemory)
            batches.append(.init(id: UUID().uuidString, batch: batch))
        }
        sendNextBatch()
    }

    func setUserToken(_ token: String?) {
        batchSender?.setUserToken(token)
    }

    func setCustomHeaders(_ headers: [String: String]) {
        batchSender?.setCustomHeaders(headers)
    }

    func setDeviceId(_ deviceId: String?) {
        self.deviceId = deviceId
    }

    func sendEventSync(event: Event, completion: @escaping (_ successfully: Bool) -> Void) {
        queue?.async { [weak self] in
            guard let self else { return }
            let batchNum = counter?.incrementedCount(for: CounterParams.batchNum) ?? 0
            let batch = Batch(meta: getMeta(), batchNum: batchNum, events: [event])
            sendBatch(.init(id: UUID().uuidString, batch: batch, syncBatch: true), completion: completion)
        }
    }

    func update(isNewLaunch: Bool) {
        self.isNewLaunch = isNewLaunch
    }

    private func sendNextBatch() {
        // Check if a batch is already being sent

        if case .needRetain = state {
            return
        }
        guard sendingBatch == nil, case .normal = state else {
            logger.debug(Constants.logLabel, "batch sending proccess in progress...")
            return
        }

        if let storageNextBatch = batchesFromStorage.first {
            sendBatch(storageNextBatch)
            return
        }

        guard let nextBatch = getNextBatch() else {
            logger.debug(Constants.logLabel, "batches storage is empty")
            return
        }

        logger.debug(Constants.logLabel, "sending next batch...")

        sendBatch(nextBatch)
    }

    private func getNextBatch() -> BatchModel? {
        switch DeviceMemoryState.state {
        case .noMemory:
            return batches.first
        case .normal:
            do {
                return try storage.nextBatch()
            } catch {
                logger.warning(Constants.logLabel, "Next batch failed: \(error)")
                return nil
            }
        }
    }

    private func sendBatch(_ model: BatchModel, completion: @escaping (_ successfully: Bool) -> Void = { _ in }) {
        var completed = false
        guard let batchSender = batchSender else {
            completion(false)
            completed = true
            return
        }

        sendingBatch = model

        logger.debug(Constants.logLabel, "try to send batch with id: \(model.id), data: \(model.batch)")

        let completionBlock: (Bool) -> Void = { [weak self] successfully in
            self?.didSendBatch(model, successfully: successfully)
            if !completed {
                completion(successfully)
            }
        }

        guard jsonSerializer.isValidJSONObject(model.batch),
              let batchData = try? jsonSerializer.data(withJSONObject: model.batch) else {
            logger.error(Constants.logLabel, "failed to serialize batch with id: \(model.id)")
            completion(false)
            completed = true
            completionBlock(true)
            return
        }

        let batchSizeKbs = batchData.count / Constants.bytesInKb

        guard batchSizeKbs <= Constants.maxBatchSizeInKbs || !model.batch.isSplittable else {
            do {
                try processBatchesWithExceedSize(model.id, batch: model.batch)
            } catch {
                logger.error(Constants.logLabel, "failed to split batch with error: \(error)")
            }
            sendingBatch = nil
            completion(false)
            completed = true
            return
        }

        sendTask = Task { [weak self] in
            let successfully = await batchSender.sendBatch(batchData)
            // Hop back onto the analytics queue so batch-sending state is mutated serially,
            // matching the threading the URLSession delegate queue used to provide.
            if let queue = self?.queue {
                queue.async { completionBlock(successfully) }
            } else {
                completionBlock(successfully)
            }
        }
    }

    private func didSendBatch(_ model: BatchModel, successfully: Bool) {
        logger.debug(Constants.logLabel, "did send batch: \(model.id), successfully: \(successfully)")
        if successfully {
            queue?.async({ [weak self] in
                guard let self else { return }
                if !model.syncBatch {
                    do {
                        try self.storage.removeBatch(with: model.id)
                    } catch {
                        self.logger.error(Constants.logLabel, "attempt to remove batch failed  with error: \(error)")
                    }
                }
                sendingBatch = nil
            })
            if DeviceMemoryState.state == .noMemory {
                if let index = batches.firstIndex(where: {$0.id == model.id}) {
                    batches.remove(at: index)
                }
                sendingBatch = nil
            }
            state = .normal

            if let index = batchesFromStorage.firstIndex(where: {$0.id == model.id}) {
                batchesFromStorage.remove(at: index)
                do {
                    try userDefaultsStorage?.save(batches: batchesFromStorage)
                } catch {
                    logger.error(Constants.logLabel, "Can't save batchesFromStorage")
                }
                sendingBatch = nil
            }
        } else {
            state = .needRetain(model)
            sendingBatch = nil
        }

        // Continue sending the next batch with delay
        batchWorker?.sendBatchDelayed(id: model.id, event: { [weak self] in
            guard let self else { return }
            switch self.state {
            case .needRetain(let batchModel):
                self.sendBatch(batchModel)
            case .normal:
                self.sendNextBatch()
            }
        })
    }

    private func getMeta() -> Meta {
        let networkType = networkTypeProvider?.getCurrentNetworkType() ?? .other
        return Meta(
            networkType: networkType,
            deviceId: deviceId ?? WBAnalytics.deviceId,
            idfa: idfaProvider.currentIDFA(),
            isNewUser: isNewLaunch,
            enableAutomaticEvents: enableAutomaticEvents
        )
    }

    private func processBatchesWithExceedSize(_ batchId: String, batch: Batch) throws {
        logger.debug(Constants.logLabel, "processBatchesWithExceedSize batchIds: \(batchId)")

        if let index = batchesFromStorage.firstIndex(where: {$0.id == batchId}) {
            batchesFromStorage.remove(at: index)
        }

        try storage.removeBatch(with: batchId)
        batch.splittedEvents.forEach {
            addBatch(withEvents: $0)
        }
    }
}

extension BatchProcessorImpl {
    /// The batch processing state, used to control the data-sending logic.
    ///
    /// This enum tracks the state of batch processing and manages retrying after a failed attempt.
    ///
    /// - `needRetain(BatchModel)`:
    ///   Indicates that the batch needs to be retained for a retry.
    ///   Activated on a failed send, carrying a `BatchModel` object with the batch's information.
    ///
    /// - `normal`:
    ///   Indicates the normal state, where there's no need to retain a batch for a retry.
    ///   Used when the last send succeeded or there are no pending batches.
    ///
    enum BatchProcessingState {
        case needRetain(BatchModel)
        case normal
    }
}

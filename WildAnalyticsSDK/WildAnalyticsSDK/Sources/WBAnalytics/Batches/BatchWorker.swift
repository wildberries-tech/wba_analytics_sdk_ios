//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

/**
`BatchWorkerImpl` is a class responsible for managing the sending of event batches with exponential retry delays.

## Properties
- `batch`: An optional tuple containing the batch identifier and the retry counter.
- `queue`: A `Dispatcher` object used for asynchronous execution.
- `batchConfig`: A `BatchConfig` object containing the configuration for batch processing.

## Methods
1. `init(queue:batchConfig:)`: Initializes `BatchWorkerImpl` with a `Dispatcher` object and a `BatchConfig`.

2. `sendBatchDelayed(id:event:)`: Sends an event batch with a delay based on the batch identifier. Sets the state to `.wait` before sending and returns it to `.available` after completion. The delay is calculated using the `getDeadline(id:)` method.

3. `getDeadline(id:)`: Calculates the deadline for sending an event batch based on the batch identifier and the counter. If `count` equals `1`, a fixed delay from `batchConfig` is used. Otherwise the delay is calculated by the formula `pow(.deadlineBody, Double(count)) + .deadlineConstant`.

4. `getBatch(id:)`: Gets or creates an event batch based on the batch identifier. If a batch with the same identifier already exists and the counter is below the maximum value, the counter is incremented. Otherwise a new batch is created with the counter set to `retraitStep`.

## Usage
1. Create an instance of `BatchConfig` with the required parameters:
   ```swift
   let batchConfig = BatchConfig(sendingDelay: 2.0)
   ```

2. Create an instance of `BatchWorkerImpl` with a `Dispatcher` object and a `BatchConfig`:
   ```swift
   let queue = DispatchQueue(label: "com.example.batchworker")
   let batchWorker = BatchWorkerImpl(queue: queue, batchConfig: batchConfig)
   ```

3. Call `sendBatchDelayed(id:event:)` to send an event batch with a delay:
   ```swift
   batchWorker.sendBatchDelayed(id: "batch_1") {
       // Code for sending the event batch
   }
   ```

The delay for each batch is calculated based on the batch identifier and the counter. The maximum counter value is `maxRetraitCount`, after which the counter resets to `1`.

### Delay values:
- **count = 1**: Time = 2.0 (value from `batchConfig.sendingDelay`)
- **count = 2**: Time = 4.75
- **count = 3**: Time = 5.87
- **count = 4**: Time = 7.56
- **count = 5**: Time = 10.09
- **count = 6**: Time = 13.89
- **count = 7**: Time = 19.58
- **count = 8**: Time = 28.12
- **count = 9**: Time = 40.94
- **count = 10**: Time = 60.16

 */

import Foundation

protocol BatchWorker {
    func sendBatchDelayed(id: String, event: @escaping () -> Void)
}

final class BatchWorkerImpl: BatchWorker {

    // MARK: - Constants

    private enum Constants {
        static let maxRetraitCount = 10
        static let retraitStep = 1
        static let deadlineBody = 1.5
        static let deadlineConstant = 2.5
    }

    typealias SendBatch = (id: String, count: Int)

    private var batch: SendBatch?

    // MARK: - Properties

    private let queue: Dispatcher
    private let batchConfig: BatchConfig

    // MARK: - Init

    init(queue: Dispatcher, batchConfig: BatchConfig) {
        self.queue = queue
        self.batchConfig = batchConfig
    }

    func sendBatchDelayed(id: String, event: @escaping () -> Void) {
        queue.asyncAfter(
            deadline: deadline(for: id),
            qos: .unspecified,
            flags: []
        ) {
            event()
        }
    }

    private func deadline(for id: String) -> DispatchTime {
        let batch = batch(for: id)
        if batch.count == 1 {
            return .now() + batchConfig.sendingDelay
        } else {
            return .now() + pow(Constants.deadlineBody, Double(batch.count)) + Constants.deadlineConstant
        }
    }

    private func batch(for id: String) -> SendBatch {
        if var localBatch = batch, localBatch.id == id, localBatch.count < Constants.maxRetraitCount {
            localBatch.count += Constants.retraitStep
            batch = localBatch
            return localBatch
        } else {
            let newBatch: SendBatch = (id: id, count: Constants.retraitStep)
            self.batch = newBatch
            return newBatch
        }
    }
}

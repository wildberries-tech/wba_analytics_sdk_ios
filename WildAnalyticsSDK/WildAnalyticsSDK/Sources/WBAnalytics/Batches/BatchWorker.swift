//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

/**
`BatchWorkerImpl` - это класс, ответственный за управление отправкой пакетов событий с экспоненциальными задержками повторных попыток.

## Свойства
- `batch`: Необязательный кортеж, содержащий идентификатор пакета и счетчик повторных попыток.
- `queue`: Объект `Dispatcher`, используемый для асинхронного выполнения.
- `batchConfig`: Объект `BatchConfig`, содержащий конфигурацию для пакетной обработки.

## Методы
1. `init(queue:batchConfig:)`: Инициализирует `BatchWorkerImpl` с объектом `Dispatcher` и `BatchConfig`.

2. `sendBatchDelayed(id:event:)`: Отправляет пакет событий с задержкой, основанной на идентификаторе пакета. Устанавливает состояние в `.wait` перед отправкой и возвращает его в `.available` после завершения. Задержка рассчитывается с использованием метода `getDeadline(id:)`.

3. `getDeadline(id:)`: Рассчитывает дедлайн для отправки пакета событий на основе идентификатора пакета и счетчика. Если `count` равен `1`, используется фиксированная задержка из `batchConfig`. В противном случае задержка рассчитывается по формуле `pow(.deadlineBody, Double(count)) + .deadlineConstant`.

4. `getBatch(id:)`: Получает или создает пакет событий на основе идентификатора пакета. Если пакет с таким же идентификатором уже существует и счетчик меньше максимального значения, счетчик увеличивается. В противном случае создается новый пакет со счетчиком, равным `retraitStep`.

## Использование
1. Создайте экземпляр `BatchConfig` с необходимыми параметрами:
   ```swift
   let batchConfig = BatchConfig(sendingDelay: 2.0)
   ```

2. Создайте экземпляр `BatchWorkerImpl` с объектом `Dispatcher` и `BatchConfig`:
   ```swift
   let queue = DispatchQueue(label: "com.example.batchworker")
   let batchWorker = BatchWorkerImpl(queue: queue, batchConfig: batchConfig)
   ```

3. Вызовите `sendBatchDelayed(id:event:)` для отправки пакета событий с задержкой:
   ```swift
   batchWorker.sendBatchDelayed(id: "batch_1") {
       // Код для отправки пакета событий
   }
   ```

Задержка для каждого пакета рассчитывается на основе идентификатора пакета и счетчика. Максимальный счетчик - `maxRetraitCount`, после чего счетчик становится равен `1`.

### Значения задержки:
- **count = 1**: Time = 2.0 (значение из `batchConfig.sendingDelay`)
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

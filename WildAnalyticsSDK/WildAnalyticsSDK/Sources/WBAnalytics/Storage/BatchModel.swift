//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

struct BatchModel {
    let id: String
    let batch: Batch
    let syncBatch: Bool

    init(id: String, batch: Batch, syncBatch: Bool = false) {
        self.id = id
        self.batch = batch
        self.syncBatch = syncBatch
    }
}

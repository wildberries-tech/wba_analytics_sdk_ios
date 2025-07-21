//  Copyright © 2024 Wildberries LLC. All rights reserved.

import Foundation

protocol Config: Decodable {
    var batch: BatchConfig { get }
    var batchSize: BatchSizeConfig { get }
    var userEngagement: UserEngagementConfig { get }
}

/// Batch splitting parameters
struct BatchSizeConfig: Decodable, Equatable {
    var bytesInKb: Int
    var maxBatchSizeInKbs: Int
}

struct UserEngagementConfig: Decodable, Equatable {
    /// Timer interval for tracking user engagement
    var timerInterval: Double
}

struct DefaultConfig: Config, Equatable {

    var batch: BatchConfig
    var batchSize: BatchSizeConfig
    var userEngagement: UserEngagementConfig

    init() {
        batch = BatchConfig()
        batchSize = BatchSizeConfig(
            bytesInKb: 1024,
            maxBatchSizeInKbs: 512
        )
        userEngagement = UserEngagementConfig(timerInterval: 30.0)
    }
}

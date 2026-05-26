//  Copyright © 2024 Wildberries LLC. All rights reserved.

import Foundation

/// Сonfiguration of batch sending parameters
public struct BatchConfig: Decodable, Equatable {

    /// Delay before sending batch
    public let sendingDelay: Double
    /// Number of events in batch
    public let size: Int
    /// Timeout  which stop attempts to send a batch
    public let sendingTimerTimeout: Double
    /// Timeout  for sending batch
    public let requestTimeout: Double

    public init() {
        sendingDelay = 2.0
        size = 200
        sendingTimerTimeout = 10.0
        requestTimeout = 30
    }
}

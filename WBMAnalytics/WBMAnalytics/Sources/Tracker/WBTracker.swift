// Copyright © 2025 Wildberries. All rights reserved.

import Foundation

/// Main tracker for Wildberries analytics
final class WBTracker {
    private let logger: CompositeLogger
    private let deviceFingerprintService: DeviceFingerprintService

    /// WBTracker initialization
    /// - Parameter logger: Logger for event logging
    init(apiKey: String, logger: CompositeLogger = CompositeLogger(loggers: [])) {
        self.logger = logger
        let collector = DeviceFingerprintCollector()
        self.deviceFingerprintService = DeviceFingerprintService(
            apiKey: apiKey,
            collector: collector,
            logger: logger
        )
    }

    /// Checks device attribution via fingerprint
    /// - Parameter completion: Callback with AttributionResult or error
    public func checkAttribution(completion: ((Result<AttributionResult?, Error>) -> Void)? = nil) {
        logger.info("WBTracker", "checkAttribution started")
        deviceFingerprintService.checkAttribution { result in
            completion?(result)
        }
    }

}

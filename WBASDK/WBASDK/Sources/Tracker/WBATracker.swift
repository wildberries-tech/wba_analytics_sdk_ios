// Copyright © 2025 WBA. All rights reserved.

import Foundation

/// Main tracker for WBA analytics
final class WBATracker {
    private let logger: CompositeLogger
    private let deviceFingerprintService: DeviceFingerprintService

    /// WBATracker initialization
    /// - Parameters:
    ///   - apiKey: API Key
    ///   - logger: Logger for event logging
    ///   - sessionDelegate: Custom URLSessionDelegate for handling authentication challenges (e.g. SSL pinning).
    init(
        apiKey: String,
        logger: CompositeLogger = CompositeLogger(loggers: []),
        sessionDelegate: URLSessionDelegate? = nil
    ) {
        self.logger = logger
        let collector = DeviceFingerprintCollector()
        self.deviceFingerprintService = DeviceFingerprintService(
            apiKey: apiKey,
            collector: collector,
            logger: logger,
            sessionDelegate: sessionDelegate
        )
    }

    /// Checks device attribution via fingerprint
    /// - Parameter completion: Callback with AttributionResult or error
    public func checkAttribution(completion: ((Result<AttributionResult?, Error>) -> Void)? = nil) {
        logger.info("WBATracker", "checkAttribution started")
        deviceFingerprintService.checkAttribution { result in
            completion?(result)
        }
    }

}

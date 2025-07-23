// Copyright © 2025 Wildberries. All rights reserved.

import Foundation
import UIKit
import CoreTelephony
import SystemConfiguration
import AdSupport

/// Service for working with device fingerprint and attribution
final class DeviceFingerprintService {
    private let collector: DeviceFingerprintCollector
    private let logger: CompositeLogger
    private let attributionQueue = DispatchQueue(label: "ru.wildberries.deviceFingerprint.attribution")
    private let storage: AttributionStorageProtocol

    /// Private configuration parameters
    private enum Configuration {
        static let attributionURL = URL(string: "https://wildtracker.wb.ru/fingerprint/check")!
    }

    /// Service initialization
    /// - Parameters:
    ///   - collector: Fingerprint collector (default is standard)
    ///   - logger: Logger (default is empty)
    ///   - storage: Attribution storage (default is UserDefaults)
    init(collector: DeviceFingerprintCollector = DeviceFingerprintCollector(), logger: CompositeLogger = CompositeLogger(loggers: []), storage: AttributionStorageProtocol = UserDefaultsAttributionStorage()) {
        self.collector = collector
        self.logger = logger
        self.storage = storage
    }

    /// Checks device attribution via fingerprint
    /// - Parameter completion: Callback with AttributionData or error
    func checkAttribution(completion: @escaping (Result<AttributionData?, Error>) -> Void) {
        attributionQueue.async { [weak self] in
            guard let self = self else { return }

            if self.storage.isAtrributionDidRequested() {
                self.logger.info("DeviceFingerprintService", "Attribution already saved on disk, repeated request is not performed.")
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
                return
            }

            let fingerprint = self.collector.collect()
            self.logger.info("DeviceFingerprintService", "Fingerprint collected: \(fingerprint)")
            self.sendAttributionRequest(fingerprint) { [weak self] result in
                if case .success(let response) = result, let response {
                    self?.storage.save(response)
                    if response.isEmpty {
                        self?.logger.info("DeviceFingerprintService", "Attribution not found, isEmpty == true")
                    } else {
                        self?.logger.info("DeviceFingerprintService", "Attribution successfully saved to disk.")
                    }
                }
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    /// Sends a request to the attribution server
    /// - Parameters:
    ///   - fingerprint: Fingerprint model
    ///   - completion: Callback with result
    private func sendAttributionRequest(_ fingerprint: DeviceFingerprint, completion: @escaping (Result<AttributionData?, Error>) -> Void) {
        logger.debug("DeviceFingerprintService", "Sending request to \(Configuration.attributionURL)")
        var request = URLRequest(url: Configuration.attributionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try JSONEncoder().encode(fingerprint)
            request.httpBody = data
        } catch {
            logger.error("DeviceFingerprintService", "Request encoding error: \(error)")
            completion(.failure(error))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                self.logger.debug("DeviceFingerprintService", "Fingerprint not found")
                completion(.success(AttributionData.empty))
                return
            }

            if let error = error {
                self.logger.error("DeviceFingerprintService", "Network error: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                self.logger.error("DeviceFingerprintService", "No data in server response")
                completion(.failure(NSError(domain: "DeviceFingerprintService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let responseModel = try JSONDecoder().decode(AttributionData.self, from: data)
                self.logger.info("DeviceFingerprintService", "Successful response: \(responseModel)")
                completion(.success(responseModel))
            } catch {
                self.logger.error("DeviceFingerprintService", "Response decoding error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// Copyright © 2024 WildAnalytics. All rights reserved.

import Foundation
import UIKit

/// Thread-safe dispatcher of analytics receivers:
/// its state is guarded by an internal lock, and receiver methods are called outside of it.
public final class WildAnalyticsSDK: Sendable {

    // MARK: - Properties
    private let lock = NSLock()
    private nonisolated(unsafe) var receivers: [String: AnalyticsReceiver]
    private nonisolated(unsafe) var receiversSetupStatuses: [String: Bool]
    /// Session value handlers are registered on behalf of this object: the value is shared
    /// by all receivers, so a handler set through the facade must be called
    /// once, not once per registered receiver.
    /// Used only as an identity key, so `nonisolated(unsafe)` is safe
    private nonisolated(unsafe) let sessionValueHandlerOwner = NSObject()

    // MARK: - Private methods
    private func snapshotReceivers() -> [String: AnalyticsReceiver] {
        lock.lock()
        defer { lock.unlock() }
        return receivers
    }

    private func snapshotUnsetupReceivers() -> [AnalyticsReceiver] {
        lock.lock()
        defer { lock.unlock() }
        return receiversSetupStatuses.compactMap { identifier, status in
            status ? nil : receivers[identifier]
        }
    }

    public init() {
        receivers = [:]
        receiversSetupStatuses = [:]
    }

    // MARK: - Public methods
    public func registerReceiver(_ receiver: AnalyticsReceiver) {
        lock.lock()
        defer { lock.unlock() }
        receivers[receiver.identifier] = receiver
        receiversSetupStatuses[receiver.identifier] = false
    }

    public func setupReceiversIfPossible() {
        let pendingReceivers = snapshotUnsetupReceivers()
        pendingReceivers.forEach { $0.setup() }
    }

    public func setCommonParameters(
        _ parameters: [String: Any],
        receiverIdentifier: String
    ) {
        snapshotReceivers()[receiverIdentifier]?.setCommonParameters(parameters)
    }

    public func trackEvent(
        name: String,
        parameters: [String: Any]?,
        receiverIdentifier: String
    ) {
        snapshotReceivers()[receiverIdentifier]?.trackEvent(name: name, parameters: parameters)
    }

    public func trackEvent<P>(
        name: String,
        parameters: [P]?,
        receiverIdentifier: String
    ) where P: Encodable {
        snapshotReceivers()[receiverIdentifier]?.trackEvent(name: name, parameters: parameters)
    }

    public func trackEventWithCompletion(
        name: String,
        parameters: [String: Any]?,
        receiverIdentifier: String,
        completion: @escaping (_ successfully: Bool) -> Void
    ) throws {
        let receiver = snapshotReceivers()[receiverIdentifier]
        guard let completionReceiver = receiver as? AnalyticsCompletionReceiver else {
            throw AnalyticsError
                .invalidReceiverType(
                    "Receiver with identifier \(receiverIdentifier) is not an AnalyticsCompletionReceiver"
                )
        }
        completionReceiver.trackEventWithCompletion(
            name: name,
            parameters: parameters,
            completion: completion
        )
    }

    public func trackEventWithCompletion(
        name: String,
        parameters: [String: Any]?,
        completion: @escaping (_ successfully: Bool) -> Void
    ) throws {
        let totalReceivers = snapshotReceivers().values.compactMap { $0 as? AnalyticsCompletionReceiver }

        if totalReceivers.isEmpty {
            throw AnalyticsError.noCompletionReceiversAvailable
        }

        totalReceivers.forEach {
            $0.trackEventWithCompletion(
                name: name,
                parameters: parameters,
                completion: completion
            )
        }
    }

    public func trackEvent(name: String, parameters: [String: Any]?) {
        snapshotReceivers().values.forEach {
            $0.trackEvent(name: name, parameters: parameters)
        }
    }

    /// Sends the dynamic_link_app_open event to all registered receivers
    public func trackLaunchURL(_ url: URL, referrerURL: URL? = nil) {
        snapshotReceivers().values.forEach {
            $0.trackLaunchURL(url, referrerURL: referrerURL)
        }
    }

    /// Sends the dynamic_link_app_open event to a specific receiver
    public func trackLaunchURL(_ url: URL, referrerURL: URL? = nil, receiverIdentifier: String) {
        snapshotReceivers()[receiverIdentifier]?.trackLaunchURL(url, referrerURL: referrerURL)
    }

    public func trackUserEngagement(_ userEngagement: UserEngagement, receiverIdentifier: String) {
        snapshotReceivers()[receiverIdentifier]?.trackUserEngagement(userEngagement)
    }

    public func setUserToken(_ token: String?) {
        snapshotReceivers().values.forEach {
            $0.setUserToken(token)
        }
    }

    public func setCustomHeader(key: String, value: String) {
        snapshotReceivers().values.forEach {
            $0.setCustomHeader(key: key, value: value)
        }
    }

    public func setCustomHeaders(_ headers: [String: String]) {
        snapshotReceivers().values.forEach {
            $0.setCustomHeaders(headers)
        }
    }

    public func setOnSessionValueUpdated(_ handler: @escaping (UInt64?) -> Void) {
        snapshotReceivers().values.forEach {
            guard let receiver = $0 as? WildAnalyticsReceiver else {
                // Third-party AnalyticsReceiver implementations manage their own session value
                $0.setOnSessionValueUpdated(handler)
                return
            }
            receiver.setOnSessionValueUpdated(handler, for: sessionValueHandlerOwner)
        }
    }

    public func showLogsViewController() -> UIViewController {
        ReceiversListViewController(receivers: snapshotReceivers())
    }
}

public enum AnalyticsError: Error {
    case invalidReceiverType(String)
    case noCompletionReceiversAvailable
}

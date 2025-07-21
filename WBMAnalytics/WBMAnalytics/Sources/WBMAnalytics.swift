// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

public final class WBMAnalytics {

    // MARK: - Properties
    private var receivers: [String: AnalyticsReceiver]
    private var receiversSetupStatuses: [String: Bool]

    // MARK: - Private methods
    private func addReceiver(_ receiver: AnalyticsReceiver) {
        receivers[receiver.identifier] = receiver
        receiversSetupStatuses[receiver.identifier] = false
    }

    public init() {
        receivers = [:]
        receiversSetupStatuses = [:]
    }

    // MARK: - Public methods
    public func registerReceiver(_ receiver: AnalyticsReceiver) {
        addReceiver(receiver)
    }

    public func setupReceiversIfPossible() {
        for (identifier, status) in receiversSetupStatuses where !status {
            receivers[identifier]?.setup()
        }
    }

    public func setCommonParameters(
        _ parameters: [String: Any],
        receiverIdentifier: String
    ) {
        receivers[receiverIdentifier]?.setCommonParameters(parameters)
    }

    public func trackEvent(
        name: String,
        parameters: [String: Any]?,
        receiverIdentifier: String
    ) {
        receivers[receiverIdentifier]?.trackEvent(name: name, parameters: parameters)
    }

    public func trackEvent<P>(
        name: String,
        parameters: [P]?,
        receiverIdentifier: String
    ) where P: Encodable {
        receivers[receiverIdentifier]?.trackEvent(name: name, parameters: parameters)
    }

    public func trackEventWithCompletion(
        name: String,
        parameters: [String: Any]?,
        receiverIdentifier: String,
        completion: @escaping (_ successfully: Bool) -> Void
    ) throws {
        guard let receiver = receivers[receiverIdentifier] as? AnalyticsCompletionReceiver else {
            throw AnalyticsError
                .invalidReceiverType(
                    "Receiver with identifier \(receiverIdentifier) is not an AnalyticsCompletionReceiver"
                )
        }
        receiver.trackEventWithCompletion(
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
        let totalReceivers = receivers.values.compactMap { $0 as? AnalyticsCompletionReceiver }

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
        receivers.values.forEach {
            $0.trackEvent(name: name, parameters: parameters)
        }
    }

    public func trackUserEngagement(_ userEngagement: UserEngagement, receiverIdentifier: String) {
        receivers[receiverIdentifier]?.trackUserEngagement(userEngagement)
    }

    public func setUserToken(_ token: String?) {
        receivers.values.forEach {
            $0.setUserToken(token)
        }
    }

    public func checkAttribution(completion: ((Result<AttributionData?, Error>) -> Void)? = nil) {
        receivers.values.forEach({ $0.checkAttribution(completion: completion) })
    }

}

public enum AnalyticsError: Error {
    case invalidReceiverType(String)
    case noCompletionReceiversAvailable
}

//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit

protocol SessionValueManagerProtocol {
    var sessionValue: String { get }

    func setSessionValue(_ value: String?)
    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void)
}

final class SessionValueManager {
    static let shared = SessionValueManager()

    // MARK: - Properties

    private let notificationCenter = NotificationCenter.default
    private var currentSessionValue = ""
    private var onSessionValueUpdated: ((String?) -> Void)? {
        didSet { onSessionValueUpdated?(currentSessionValue) }
    }

    // MARK: - Init

    private init() {
        generateSessionValue()
        subscribeForNotifications()
    }

    // MARK: - Deinit

    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - SessionValueManagerProtocol

extension SessionValueManager: SessionValueManagerProtocol {
    var sessionValue: String { currentSessionValue }

    func setSessionValue(_ value: String?) {
        guard let value else {
            generateSessionValue()
            return
        }
        currentSessionValue = value
    }

    func setOnSessionValueUpdated(_ handler: @escaping (String?) -> Void) {
        onSessionValueUpdated = handler
    }
}

// MARK: - Private methods

private extension SessionValueManager {
    func subscribeForNotifications() {
        notificationCenter.addObserver(
            self,
            selector: #selector(didFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(didCloseApp),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(didCloseApp),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc func didFinishLaunching() {
        // изначально генерируем из инициализатора, т.к. didFinishLaunchingNotification
        // отрабатывает после отправки события first_open
        if currentSessionValue.isEmpty {
            generateSessionValue()
        }
        onSessionValueUpdated?(currentSessionValue)
    }

    @objc func willEnterForeground() {
        generateSessionValue()
        onSessionValueUpdated?(currentSessionValue)
    }

    @objc func didCloseApp() {
        onSessionValueUpdated?(nil)
    }

    func generateSessionValue() {
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        let randomValue = UInt64.random(in: 0...999_999)
        let shiftedTimestamp = timestamp << 20

        currentSessionValue = String(shiftedTimestamp | randomValue)
    }
}

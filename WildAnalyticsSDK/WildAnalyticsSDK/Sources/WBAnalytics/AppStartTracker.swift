//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit

protocol AppStartTrackerProtocol {
    func setup(with closure: @escaping AppStartTracker.TrackEventClosure)
}

final class AppStartTracker {
    typealias TrackEventClosure = (AppStartTracker.Input) -> Void

    // MARK: - Properties

    private static var hasInitialized = false

    private let notificationCenter: NotificationCenter
    private let dispatcher: Dispatcher

    private var trackEventClosure: TrackEventClosure?
    private var startLocation: StartLocation = .unknown
    private var attemptsCount = 0

    // MARK: - Init

    init(
        notificationCenter: NotificationCenter = .default,
        dispatcher: Dispatcher = DispatchQueue.main
    ) {
        self.notificationCenter = notificationCenter
        self.dispatcher = dispatcher

        subscribeForNotificationsIfNeeded()
    }

    // MARK: - Deinit

    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - AppStartTrackerProtocol

extension AppStartTracker: AppStartTrackerProtocol {
    func setup(with closure: @escaping TrackEventClosure) {
        trackEventClosure = closure
    }
}

// MARK: - Input

extension AppStartTracker {
    struct Input {
        let name: String
        let parameters: [String: Any]?
        let completion: (Bool) -> Void
    }
}

// MARK: - Private

private extension AppStartTracker {
    enum StartLocation: String {
        case background
        case foreground
        case unknown
    }

    enum Event {
        static let appStart = "application_start"
    }

    enum Parameter {
        static let startLocation = "start_location"
        static let cpu = "cpu"
        static let ram = "ram"
    }
}

private extension AppStartTracker {
    func subscribeForNotificationsIfNeeded() {
        guard !Self.hasInitialized else { return }
        Self.hasInitialized.toggle()
        subscribeForNotifications()
    }

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
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc func didFinishLaunching() {
        startLocation = .foreground
        trackEvent()
    }

    @objc func willEnterForeground() {
        startLocation = .background
        // Задержка добавлена из-за того, что willEnterForeground у AppStartTracker вызывается раньше, чем у SessionValueManager,
        // что приводит к старому значению sessionValue у события application_start после открытия приложения из фона
        dispatcher.asyncAfter(deadline: Constants.trackDeadline, qos: .unspecified, flags: []) { [weak self] in
            self?.trackEvent()
        }
    }

    @objc func didEnterBackground() {
        attemptsCount = 0
    }

    func trackEvent() {
        let parameters: [String: Any]? = [
            Parameter.cpu: Version(modelID: DeviceInfo.modelID).frequency,
            Parameter.ram: Int(round(Double(ProcessInfo.processInfo.physicalMemory) / Constants.bytesInGb)),
            Parameter.startLocation: startLocation.rawValue
        ]

        let input = Input(
            name: Event.appStart,
            parameters: parameters,
            completion: handleTrackEvent(_:)
        )

        trackEventClosure?(input)
    }

    func handleTrackEvent(_ isSuccess: Bool) {
        guard !isSuccess else {
            attemptsCount = 0
            return
        }

        guard attemptsCount < Constants.attemptsLimit else { return }

        attemptsCount += 1

        dispatcher.asyncAfter(deadline: Constants.retryDeadline, qos: .unspecified, flags: []) { [weak self] in
            self?.trackEvent()
        }
    }
}

// MARK: - Constants

private extension AppStartTracker {
    enum Constants {
        static let attemptsLimit = 3
        static let trackDeadline: DispatchTime = .now() + .milliseconds(500)
        static let retryDeadline: DispatchTime = .now() + .seconds(1)
        static let bytesInGb = 1024.0 * 1024.0 * 1024.0
    }
}

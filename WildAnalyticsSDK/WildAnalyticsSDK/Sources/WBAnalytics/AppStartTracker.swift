//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit

protocol AppStartTrackerProtocol {
    func setup(with closure: @escaping AppStartTracker.TrackEventClosure)
}

/// Source of the application state. UIApplication.shared may only be accessed from the main
/// thread, so the value is captured once — when AppStartTracker is created, on the caller's thread.
/// This assumes the SDK is initialized from the main thread, in application(_:didFinishLaunchingWithOptions:).
protocol ApplicationStateProviding {
    var applicationState: UIApplication.State { get }
}

struct SystemApplicationStateProvider: ApplicationStateProviding {
    var applicationState: UIApplication.State {
        UIApplication.shared.applicationState
    }
}

final class AppStartTracker {
    typealias TrackEventClosure = (AppStartTracker.Input) -> Void

    // MARK: - Properties

    private let notificationCenter: NotificationCenter
    private let dispatcher: Dispatcher

    private var trackEventClosure: TrackEventClosure?
    // Captured synchronously in init, not in trackLaunchIfNeeded: AppStartTracker is created on
    // the caller's thread inside WBAnalytics.setup(...) (typically main, during didFinishLaunching),
    // i.e. before EventsProcessorImpl hops onto its own queue and the app has a chance to become
    // .active. Reading the state later (after that queue hop) almost always yields .active -> unknown
    // instead of the correct foreground for a normal cold start.
    private var startLocation: StartLocation
    private var hasTrackedLaunch = false
    private var wasInBackground = false

    // MARK: - Init

    init(
        notificationCenter: NotificationCenter = .default,
        dispatcher: Dispatcher = DispatchQueue.main,
        applicationStateProvider: ApplicationStateProviding = SystemApplicationStateProvider()
    ) {
        self.notificationCenter = notificationCenter
        self.dispatcher = dispatcher
        // .active means the SDK was initialized after app launch, not during it,
        // so the launch source can't be determined
        self.startLocation = applicationStateProvider.applicationState == .active
            ? .unknown
            : .foreground

        subscribeForNotifications()
    }

    // MARK: - Deinit

    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - AppStartTrackerProtocol

extension AppStartTracker: AppStartTrackerProtocol {
    /// Called from EventsProcessorImpl.setup, i.e. at app launch.
    /// The event is sent from here rather than from didFinishLaunchingNotification: by this point
    /// the send closure is already set, so the event isn't lost.
    func setup(with closure: @escaping TrackEventClosure) {
        trackEventClosure = closure
        trackLaunchIfNeeded()
    }
}

// MARK: - Input

extension AppStartTracker {
    struct Input {
        let name: String
        let parameters: [String: Any]?
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
        static let processorName = "processor_name"
    }
}

private extension AppStartTracker {
    func subscribeForNotifications() {
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

    func trackLaunchIfNeeded() {
        guard !hasTrackedLaunch else { return }
        hasTrackedLaunch = true

        dispatcher.async { [weak self] in
            self?.trackEvent()
        }
    }

    @objc func willEnterForeground() {
        // Skip the first foreground of a cold start: the event was already sent from setup
        guard wasInBackground else { return }
        wasInBackground = false
        startLocation = .background

        // The delay exists because AppStartTracker's willEnterForeground fires before
        // SessionValueManager's, which would otherwise attach a stale sessionValue to application_start
        dispatcher.asyncAfter(deadline: .now() + Constants.trackDelay, qos: .unspecified, flags: []) { [weak self] in
            self?.trackEvent()
        }
    }

    @objc func didEnterBackground() {
        wasInBackground = true
    }

    func trackEvent() {
        let version = Version(modelID: DeviceInfo.modelID)
        let parameters: [String: Any]? = [
            Parameter.cpu: version.frequency,
            Parameter.ram: Int(round(Double(ProcessInfo.processInfo.physicalMemory) / Constants.bytesInGb)),
            Parameter.startLocation: startLocation.rawValue,
            Parameter.processorName: version.cpu.name
        ]

        let input = Input(name: Event.appStart, parameters: parameters)

        trackEventClosure?(input)
    }
}

// MARK: - Constants

private extension AppStartTracker {
    enum Constants {
        static let trackDelay: DispatchTimeInterval = .milliseconds(500)
        static let bytesInGb = 1024.0 * 1024.0 * 1024.0
    }
}

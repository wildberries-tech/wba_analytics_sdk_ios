//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit
import XCTest

@testable import WildAnalyticsSDK

final class AppStartTrackerTests: XCTestCase {

    // A plain NotificationCenter: AppStartTracker doesn't inherit from NSObject, so its
    // @objc methods can't be called directly from a test — only through notifications
    private var notificationCenter: NotificationCenter!
    private var dispatcherMock: DispatcherMock!
    private var applicationStateProviderMock: ApplicationStateProviderMock!
    private var subject: AppStartTracker!

    private var trackedInputs: [AppStartTracker.Input] = []

    override func setUp() {
        super.setUp()
        notificationCenter = NotificationCenter()
        dispatcherMock = .init()
        applicationStateProviderMock = .init()
        trackedInputs = []
        subject = makeSubject()
    }

    /// The application state is read at tracker creation time, so applicationStateProviderMock
    /// must be configured BEFORE calling this method.
    private func makeSubject(applicationState: UIApplication.State = .background) -> AppStartTracker {
        applicationStateProviderMock.applicationStateStub = applicationState
        return AppStartTracker(
            notificationCenter: notificationCenter,
            dispatcher: dispatcherMock,
            applicationStateProvider: applicationStateProviderMock
        )
    }

    private func setupSubject() {
        subject.setup { [weak self] input in
            self?.trackedInputs.append(input)
        }
    }

    private func postDidEnterBackground() {
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    private func postWillEnterForeground() {
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // MARK: - Init

    func testInitSubscribesToLifecycleNotifications() {
        // given
        let notificationCenterMock = NotificationCenterMock()
        // when
        let subject = AppStartTracker(
            notificationCenter: notificationCenterMock,
            dispatcher: dispatcherMock,
            applicationStateProvider: applicationStateProviderMock
        )
        // then
        XCTAssertEqual(notificationCenterMock.addObserverSelectorNameObjectWasCalled, 2)

        let firstInvocation = notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[0]
        XCTAssertEqual(firstInvocation.aSelector.description, "willEnterForeground")
        XCTAssertEqual(firstInvocation.aName, UIApplication.willEnterForegroundNotification)
        XCTAssertIdentical(firstInvocation.observer as? AppStartTracker, subject)

        let secondInvocation = notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[1]
        XCTAssertEqual(secondInvocation.aSelector.description, "didEnterBackground")
        XCTAssertEqual(secondInvocation.aName, UIApplication.didEnterBackgroundNotification)
        XCTAssertIdentical(secondInvocation.observer as? AppStartTracker, subject)
    }

    func testEveryInstanceSubscribes() {
        // given: subscribing shouldn't depend on how many trackers already exist in the process
        let notificationCenterMock = NotificationCenterMock()
        _ = AppStartTracker(
            notificationCenter: notificationCenterMock,
            dispatcher: dispatcherMock,
            applicationStateProvider: applicationStateProviderMock
        )
        let anotherNotificationCenterMock = NotificationCenterMock()
        // when
        _ = AppStartTracker(
            notificationCenter: anotherNotificationCenterMock,
            dispatcher: dispatcherMock,
            applicationStateProvider: applicationStateProviderMock
        )
        // then
        XCTAssertEqual(anotherNotificationCenterMock.addObserverSelectorNameObjectWasCalled, 2)
    }

    func testInitReadsApplicationStateExactlyOnce() {
        // given: setUp already created one instance — count reads relative to that point
        let callsBeforeInit = applicationStateProviderMock.applicationStateWasCalled
        // when
        _ = makeSubject(applicationState: .background)
        // then: the state is read exactly once, at creation time
        XCTAssertEqual(applicationStateProviderMock.applicationStateWasCalled, callsBeforeInit + 1)
    }

    // MARK: - Cold launch

    func testSetupTracksApplicationStartWithForegroundLocation() {
        // given: the tracker is created while the app isn't active yet
        subject = makeSubject(applicationState: .background)
        // when
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // then
        XCTAssertEqual(trackedInputs.count, 1)
        XCTAssertEqual(trackedInputs.first?.name, "application_start")
        XCTAssertEqual(trackedInputs.first?.parameters?["start_location"] as? String, "foreground")
    }

    func testSetupTracksUnknownLocationWhenApplicationIsAlreadyActive() {
        // given
        subject = makeSubject(applicationState: .active)
        // when
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // then
        XCTAssertEqual(trackedInputs.first?.parameters?["start_location"] as? String, "unknown")
    }

    func testApplicationStateIsSnapshottedAtCreationNotAtSetup() {
        // given: a cold start — the app isn't active yet when the tracker is created
        subject = makeSubject(applicationState: .background)
        // when: while EventsProcessorImpl hops onto its own queue, the app has time to become
        // active — this exact scenario used to produce a false "unknown" when the state was read lazily
        applicationStateProviderMock.applicationStateStub = .active
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // then: the snapshot taken at creation time is used, not the current state
        XCTAssertEqual(trackedInputs.first?.parameters?["start_location"] as? String, "foreground")
    }

    func testEventContainsDeviceParameters() {
        // when
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // then
        let parameters = trackedInputs.first?.parameters
        XCTAssertNotNil(parameters?["cpu"] as? Double)
        XCTAssertNotNil(parameters?["ram"] as? Int)
        XCTAssertEqual(
            parameters?["processor_name"] as? String,
            Version(modelID: DeviceInfo.modelID).cpu.name
        )
    }

    func testSecondSetupDoesNotTrackLaunchAgain() {
        // given
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // when
        setupSubject()
        // then: a second setup doesn't schedule another send
        XCTAssertEqual(dispatcherMock.asyncWasCalled, 1)
        XCTAssertEqual(trackedInputs.count, 1)
    }

    // MARK: - Foreground / background

    func testWillEnterForegroundWithoutBackgroundDoesNotTrack() {
        // given: the first foreground of a cold start
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // when
        postWillEnterForeground()
        // then: no delayed send is scheduled
        XCTAssertEqual(dispatcherMock.asyncAfterWasCalled, 0)
        XCTAssertEqual(trackedInputs.count, 1)
    }

    func testWillEnterForegroundAfterBackgroundTracksBackgroundLocation() {
        // given
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        // when
        postDidEnterBackground()
        postWillEnterForeground()
        dispatcherMock.asyncAfterReceivedWork?()
        // then
        XCTAssertEqual(trackedInputs.count, 2)
        XCTAssertEqual(trackedInputs.last?.parameters?["start_location"] as? String, "background")
    }

    func testSecondForegroundWithoutBackgroundDoesNotTrack() {
        // given
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        postDidEnterBackground()
        postWillEnterForeground()
        dispatcherMock.asyncAfterReceivedWork?()
        XCTAssertEqual(trackedInputs.count, 2)
        // when
        postWillEnterForeground()
        // then: without going to background again, no new send is scheduled
        XCTAssertEqual(dispatcherMock.asyncAfterWasCalled, 1)
        XCTAssertEqual(trackedInputs.count, 2)
    }

    func testWillEnterForegroundUsesIntervalDeadlineEachTime() {
        // given: the deadline must be computed at the call site, not once when a static constant
        // is first loaded — otherwise asyncAfter fires immediately starting from the second call.
        setupSubject()
        dispatcherMock.asyncReceivedWork?()
        postDidEnterBackground()
        postWillEnterForeground()
        let firstDeadline = dispatcherMock.asyncAfterReceivedDeadline
        dispatcherMock.asyncAfterReceivedWork?()
        // when: simulate a delay between the first and second background/foreground cycle
        Thread.sleep(forTimeInterval: 0.05)
        postDidEnterBackground()
        postWillEnterForeground()
        let secondDeadline = dispatcherMock.asyncAfterReceivedDeadline
        // then: the second deadline is computed fresh relative to the current moment, not inherited
        // from a static constant that was only evaluated once, on first access
        XCTAssertNotNil(firstDeadline)
        XCTAssertNotNil(secondDeadline)
        XCTAssertGreaterThan(secondDeadline!, firstDeadline!)
    }
}

//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit
import XCTest

@testable import WildAnalyticsSDK

final class AppStartTrackerTests: XCTestCase {
    private var notificationCenterMock: NotificationCenterMock!
    private var dispatcherMock: DispatcherMock!
    private var subject: AppStartTracker!

    override func setUp() {
        super.setUp()
        notificationCenterMock = .init()
        dispatcherMock = .init()
        createSubject()
    }

    func createSubject() {
        subject = .init(
            notificationCenter: notificationCenterMock,
            dispatcher: dispatcherMock
        )
    }

    // MARK: - Init

    func testInit() {
        // then
        XCTAssertEqual(notificationCenterMock.addObserverSelectorNameObjectWasCalled, 3)

        let firstInvocation = notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[0]
        XCTAssertEqual(firstInvocation.aSelector.description, "didFinishLaunching")
        XCTAssertEqual(firstInvocation.aName, UIApplication.didFinishLaunchingNotification)
        XCTAssertIdentical(firstInvocation.observer as? AppStartTracker, subject)
        XCTAssertNil(firstInvocation.anObject)

        let secondInvocation = notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[1]
        XCTAssertEqual(secondInvocation.aSelector.description, "willEnterForeground")
        XCTAssertEqual(secondInvocation.aName, UIApplication.willEnterForegroundNotification)
        XCTAssertIdentical(secondInvocation.observer as? AppStartTracker, subject)
        XCTAssertNil(secondInvocation.anObject)

        let thirdInvocation = notificationCenterMock.addObserverSelectorNameObjectReceivedInvocations[2]
        XCTAssertEqual(thirdInvocation.aSelector.description, "didEnterBackground")
        XCTAssertEqual(thirdInvocation.aName, UIApplication.didEnterBackgroundNotification)
        XCTAssertIdentical(thirdInvocation.observer as? AppStartTracker, subject)
        XCTAssertNil(thirdInvocation.anObject)
    }
}

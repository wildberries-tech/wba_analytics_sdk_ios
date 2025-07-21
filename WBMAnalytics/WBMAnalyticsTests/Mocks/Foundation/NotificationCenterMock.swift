//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

final class NotificationCenterMock: NotificationCenter, @unchecked Sendable {
    // MARK: - addObserver

    public private(set) var addObserverSelectorNameObjectWasCalled: Int = 0
    // swiftlint:disable identifier_name
    public private(set) var addObserverSelectorNameObjectReceivedArguments: (
        observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?
    )?
    // swiftlint:disable identifier_name
    public private(set) var addObserverSelectorNameObjectReceivedInvocations: [
        (observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)
    ] = []

    override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        addObserverSelectorNameObjectWasCalled += 1
        addObserverSelectorNameObjectReceivedArguments = (
            observer: observer, aSelector: aSelector, aName: aName, anObject: anObject
        )
        addObserverSelectorNameObjectReceivedInvocations
            .append((observer: observer, aSelector: aSelector, aName: aName, anObject: anObject))
    }

    // MARK: - removeObserver

    public private(set) var removeObserverNameObjectWasCalled: Int = 0
    public private(set) var removeObserverNameObjectReceivedInvocations: [
        (observerType: Any.Type, aName: NSNotification.Name?, anObject: Any?)
    ] = []
    public var removeObserverClosure: (
        (_ wasCalled: Int, _ receivedInvocations: [(observerType: Any.Type, aName: NSNotification.Name?, anObject: Any?)]) -> Void
    )?

    override func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        let observerType = type(of: observer)
        removeObserverNameObjectWasCalled += 1
        removeObserverNameObjectReceivedInvocations.append((observerType: observerType, aName: aName, anObject: anObject))
        removeObserverClosure?(removeObserverNameObjectWasCalled, removeObserverNameObjectReceivedInvocations)
    }
}

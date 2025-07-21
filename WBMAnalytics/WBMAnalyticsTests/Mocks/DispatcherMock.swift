//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class DispatcherMock: Dispatcher {

    // MARK: - Lifecycle

    public init() {}

    // MARK: - async

    public private(set) var asyncWasCalled: Int = 0
    public private(set) var asyncReceivedWork: (() -> Void)?

    func async(_ work: @escaping @Sendable @convention(block) () -> Void) {
        asyncWasCalled += 1
        asyncReceivedWork = work
    }

    // MARK: - asyncAfter

    public private(set) var asyncAfterWasCalled: Int = 0
    public private(set) var asyncAfterReceivedDeadline: DispatchTime?
    public private(set) var asyncAfterReceivedQoS: DispatchQoS?
    public private(set) var asyncAfterReceivedFlags: DispatchWorkItemFlags?
    public private(set) var asyncAfterReceivedWork: (() -> Void)?

    public func asyncAfter(
        deadline: DispatchTime,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @Sendable @convention(block) () -> Void
    ) {
        asyncAfterWasCalled += 1
        asyncAfterReceivedDeadline = deadline
        asyncAfterReceivedQoS = qos
        asyncAfterReceivedFlags = flags
        asyncAfterReceivedWork = work
    }
}

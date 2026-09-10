//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class EnumerationCounterMock: EnumerationCounter {

    private(set) var incrementedCountReceivedKey: String?
    private(set) var incrementedCountWasCalled: Int = 0
    var incrementedCountStub: Int = 0

    func incrementedCount(for key: String) -> Int {
        self.incrementedCountReceivedKey = key
        incrementedCountWasCalled += 1
        return incrementedCountStub
    }
}

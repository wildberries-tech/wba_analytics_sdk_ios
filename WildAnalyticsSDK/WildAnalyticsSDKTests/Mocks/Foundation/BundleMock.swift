//
//  Copyright © 2024 WildAnalytics. All rights reserved.
//

import Foundation

final class BundleMock: Bundle, @unchecked Sendable {

    private(set) var pathReceivedForResource: String?
    private(set) var pathReceivedOfType: String?
    private(set) var pathWasCalled: Int = 0
    var pathStub: String?

    override func path(forResource name: String?, ofType ext: String?) -> String? {
        self.pathReceivedForResource = name
        self.pathReceivedOfType = ext
        pathWasCalled += 1
        return pathStub
    }
}

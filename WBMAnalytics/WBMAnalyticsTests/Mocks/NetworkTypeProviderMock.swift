//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class NetworkTypeProviderMock: NetworkTypeProviderProtocol {
    private(set) var getCurrentNetworkTypeWasCalled: Int = 0
    var getCurrentNetworkTypeStub: WBMNetworkType!

    func getCurrentNetworkType() -> WBMNetworkType {
        getCurrentNetworkTypeWasCalled += 1
        return getCurrentNetworkTypeStub
    }
}

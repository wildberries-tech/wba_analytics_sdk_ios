//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WildAnalyticsSDK

final class NetworkTypeProviderMock: NetworkTypeProviderProtocol {
    private(set) var getCurrentNetworkTypeWasCalled: Int = 0
    var getCurrentNetworkTypeStub: WildNetworkType!

    func getCurrentNetworkType() -> WildNetworkType {
        getCurrentNetworkTypeWasCalled += 1
        return getCurrentNetworkTypeStub
    }
}

//
//  Copyright © 2024 WBA. All rights reserved.
//

import Foundation

@testable import WBASDK

final class NetworkTypeProviderMock: NetworkTypeProviderProtocol {
    private(set) var getCurrentNetworkTypeWasCalled: Int = 0
    var getCurrentNetworkTypeStub: WBANetworkType!

    func getCurrentNetworkType() -> WBANetworkType {
        getCurrentNetworkTypeWasCalled += 1
        return getCurrentNetworkTypeStub
    }
}

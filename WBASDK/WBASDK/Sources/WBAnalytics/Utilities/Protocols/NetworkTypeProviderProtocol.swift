// Copyright © 2021 WBA. All rights reserved.

import Foundation

public protocol NetworkTypeProviderProtocol {

    /// Returns the current network type.
    /// - Returns: The current network type as `WBANetworkType`.
    func getCurrentNetworkType() -> WBANetworkType
}

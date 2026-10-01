// Copyright © 2021 WildAnalytics. All rights reserved.

import Foundation

public protocol NetworkTypeProviderProtocol {

    /// Returns the current network type.
    /// - Returns: The current network type as `WildNetworkType`.
    func getCurrentNetworkType() -> WildNetworkType
}

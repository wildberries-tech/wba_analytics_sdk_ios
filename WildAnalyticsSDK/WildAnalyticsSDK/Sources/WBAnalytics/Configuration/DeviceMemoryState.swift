//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

enum DeviceMemoryState {
    case normal
    case noMemory

    static private(set) var state: DeviceMemoryState = .normal

    static func setState(_ state: DeviceMemoryState) {
        DeviceMemoryState.state = state
    }
}

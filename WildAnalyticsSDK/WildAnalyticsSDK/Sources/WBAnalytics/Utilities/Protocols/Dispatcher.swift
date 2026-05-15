//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import UIKit

protocol Dispatcher: AnyObject {
    func async(_ work: @escaping @Sendable @convention(block) () -> Void)
    func asyncAfter(
        deadline: DispatchTime,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @Sendable @convention(
            block
        ) () -> Void
    )
}

extension DispatchQueue: Dispatcher {
    func async(_ work: @escaping @Sendable @convention(block) () -> Void) {
        self.async(execute: {
            work()
        })
    }
}

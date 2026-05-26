//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

protocol EnumerationCounter {
    func incrementedCount(for key: String) -> Int
}

struct UserDefaultsEnumerationCounter: EnumerationCounter, Equatable {

    private var defaults: UserDefaults
    private let queue = DispatchQueue(label: "WBAnalytics.UserDefaultsEnumerationCounterQueue")

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func incrementedCount(for key: String) -> Int {
        return queue.sync {
            var storedValue = defaults.integer(forKey: key)
            storedValue += 1
            defaults.set(storedValue, forKey: key)
            return storedValue
        }
    }
}

enum CounterParams {
    static let batchNum = "batch_num"
    static let eventNum = "event_num"
}

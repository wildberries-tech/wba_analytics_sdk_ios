//
//  Copyright © 2024 WildAnalytics. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func sleep(milliseconds: Int) {
        let microseconds = milliseconds * 1000 // Convert milliseconds to microseconds
        usleep(useconds_t(microseconds)) // Suspend execution
    }
}

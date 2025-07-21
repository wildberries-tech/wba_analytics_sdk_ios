//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func sleep(milliseconds: Int) {
        let microseconds = milliseconds * 1000 // Переводим миллисекунды в микросекунды
        usleep(useconds_t(microseconds)) // Приостанавливаем выполнение
    }
}

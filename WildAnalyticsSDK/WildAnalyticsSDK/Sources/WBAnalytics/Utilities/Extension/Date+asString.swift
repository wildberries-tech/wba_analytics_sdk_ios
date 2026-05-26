// Copyright © 2021 Wildberries. All rights reserved.

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return dateFormatter
}()

extension Date {

    var asString: String {
        return dateFormatter.string(from: self)
    }
}

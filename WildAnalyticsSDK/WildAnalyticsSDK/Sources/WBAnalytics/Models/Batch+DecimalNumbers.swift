//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import Foundation

extension Batch {

    /// A batch in which fractional numbers are replaced with decimal ones.
    ///
    /// Needed after parsing the JSON coming from storage. `JSONSerialization` prints a `Double`
    /// with all 17 significant digits, and fractional values such as `2.65` are not representable
    /// in binary floating point — the server used to receive `2.6499999999999999`. The number
    /// itself was correct (both literals parse into the very same `Double`), but it looked like
    /// garbage in the request body and in the logs.
    ///
    /// The replacement is built from the shortest representation of the number: `String(2.65)`
    /// yields `"2.65"`, and a decimal built from that string is exact in base-10 and serializes
    /// without a tail. Integers and booleans are left untouched.
    var withDecimalNumbers: Batch {
        guard let normalized = Self.decimalized(self) as? Batch else { return self }
        return normalized
    }

    private static func decimalized(_ value: Any) -> Any {
        switch value {
        case let dictionary as [String: Any]:
            return dictionary.mapValues { decimalized($0) }
        case let array as [Any]:
            return array.map { decimalized($0) }
        case let number as NSNumber:
            return decimalized(number)
        default:
            return value
        }
    }

    private static func decimalized(_ number: NSNumber) -> NSNumber {
        // Booleans are NSNumber too, but they are not a float type and stay as they are
        guard CFNumberIsFloatType(number),
              let decimal = Decimal(string: String(number.doubleValue)) else {
            return number
        }
        return NSDecimalNumber(decimal: decimal)
    }
}

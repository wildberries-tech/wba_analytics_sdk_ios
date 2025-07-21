//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

class MirrorObject {
    private let mirror: Mirror

    init(reflecting: Any) {
        mirror = Mirror(reflecting: reflecting)
    }

    func extract<Class>(variableName: StaticString = #function) -> Class {
        extract(variableName: variableName, mirror: mirror)
    }

    private func extract<Class>(variableName: StaticString, mirror: Mirror) -> Class {
        guard let descendant = mirror.descendant("\(variableName)") as? Class else {
            guard let superclassMirror = mirror.superclassMirror else {
                fatalError("Expected Mirror for superclass")
            }
            return extract(variableName: variableName, mirror: superclassMirror)
        }
        guard let result: Class = try? XCTUnwrap(descendant) else {
            fatalError("Expected unwrapped result")
        }
        return result
    }
}

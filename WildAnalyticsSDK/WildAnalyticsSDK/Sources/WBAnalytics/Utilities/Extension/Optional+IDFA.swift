//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

extension Optional where Wrapped == () -> String {
    var idfaOrEmpty: String {
        let defaultValue = ""

        guard let closure = self else {
            return defaultValue
        }

        let idfa = closure()

        guard idfa.isValid else {
            return defaultValue
        }

        return idfa
    }
}

private extension String {
    var isValid: Bool {
        !isZeroIDFA
    }

    var isZeroIDFA: Bool {
        self == Constants.zeroIDFA
    }
}

private extension String {
    enum Constants {
        // UUID format is fixed
        static let zeroIDFA = "00000000-0000-0000-0000-000000000000"
    }
}

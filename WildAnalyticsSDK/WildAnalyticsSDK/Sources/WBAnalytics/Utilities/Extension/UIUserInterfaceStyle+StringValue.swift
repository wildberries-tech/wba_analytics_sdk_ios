// Copyright © 2024 Wildberries. All rights reserved.

import Foundation
import UIKit

extension UIUserInterfaceStyle {
    var stringValue: String {
        switch self {
        case .unspecified:
            String.interfaceStyleUnspecified
        case .light:
            String.interfaceStyleLight
        case .dark:
            String.interfaceStyleDark
        @unknown default:
            String.interfaceStyleUnspecified
        }
    }
}

private extension String {
    static let interfaceStyleDark = "dark"
    static let interfaceStyleLight = "light"
    static let interfaceStyleUnspecified = "unspecified"
}

//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

/// Data model for the `user_engagement` event
public struct UserEngagement: Equatable {

    let screenName: String
    let textSize: TextSize?
    let authType: String?
    let scaleFactor: String?

    /// UserEngagement initializer.
    /// - Parameters:
    ///   - screenName: Screen name.
    ///   - textSize: Flag indicating the preferred text size change.
    ///   - authType: The type of SDK the user was authenticated with.
    ///   - scaleFactor: The user's font size settings.
    public init(
        screenName: String,
        textSize: TextSize?,
        authType: String?,
        scaleFactor: String?
    ) {
        self.screenName = screenName
        self.textSize = textSize
        self.authType = authType
        self.scaleFactor = scaleFactor
    }

    var dictionary: [String: Any]? {
        var result: [String: Any] = [.screenName: screenName]
        if let authType {
            result[.authType] = authType
        }
        if let textSize {
            result[.textSize] = textSize.rawValue
        }
        if let scaleFactor {
            result[.scaleFactor] = scaleFactor
        }
        return result
    }
}

// MARK: - Structures

/// The preferred text size change on iOS (set in User Accessibility)
public enum TextSize: Int {
    /// Standard text size
    case standard
    /// Larger text sizes
    case large
    /// Smaller text sizes
    case small
}

// MARK: - Constants

private extension String {
    static let screenName = "screen_name"
    static let textSize = "text_size"
    static let authType = "auth_type"
    static let scaleFactor = "scale_factor"
}

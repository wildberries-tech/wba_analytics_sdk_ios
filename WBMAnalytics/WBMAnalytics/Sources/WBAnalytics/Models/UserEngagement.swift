//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

/// Модель данных для события `user_engagement`
public struct UserEngagement: Equatable {

    let screenName: String
    let textSize: TextSize?

    /// Инициализатор UserEngagement.
    /// - Parameters:
    ///   - screenName: Название экрана.
    ///   - textSize: Флаг определяющий предпочитаемое изменение размера текста.
    public init(screenName: String, textSize: TextSize?) {
        self.screenName = screenName
        self.textSize = textSize
    }

    var dictionary: [String: Any]? {
        var result: [String: Any] = [.screenName: screenName]
        if let textSize {
            result[.textSize] = textSize.rawValue
        }
        return result
    }
}

// MARK: - Structures

/// Предпочитаемое изменение размера текстов в iOS (задаетсяв в User Accessibility)
public enum TextSize: Int {
    /// Стандартный размер текста
    case standard
    /// Увеличенные размеры текста
    case large
    /// Уменьшенные размеры текста
    case small
}

// MARK: - Constants

private extension String {
    static let screenName = "screen_name"
    static let textSize = "text_size"
}

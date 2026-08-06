//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

/// Модель данных для события `user_engagement`
public struct UserEngagement: Equatable {

    let screenName: String
    let textSize: TextSize?
    let authType: String?
    let scaleFactor: String?

    /// Инициализатор UserEngagement.
    /// - Parameters:
    ///   - screenName: Название экрана.
    ///   - textSize: Флаг определяющий предпочитаемое изменение размера текста.
    ///   - authType: Тип с помощью какого сдк был авторизован пользователь
    ///   - scaleFactor: пользовательские настройки размера шрифта
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
    static let authType = "auth_type"
    static let scaleFactor = "scale_factor"
}

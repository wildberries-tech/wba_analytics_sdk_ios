// Copyright © 2025 Wildberries. All rights reserved.

import Foundation

/// Attribution server response model
public struct AttributionData: Codable {

    /// Is attribution empty
    public let isEmpty: Bool

    /// Link to follow after installation
    public let link: String?
    /// Other parameters (key: parameter value which can be any JSON type)
    public let parameters: [String: AnyValue]?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case link
        case isEmpty
    }

    init(
        isEmpty: Bool,
        link: String?,
        parameters: [String: AnyValue]?
    ) {
        self.link = link
        self.parameters = parameters
        self.isEmpty = isEmpty
    }

    static let empty: AttributionData = .init(isEmpty: true, link: nil, parameters: nil)

    /// Convert parameters to [String: Any] dictionary for compatibility
    public func parametersAsAny() -> [String: Any]? {
        return parameters?.compactMapValues { $0.anyValue }
    }

    /// Create AttributionData with parameters from [String: Any]
    public static func create(
        isEmpty: Bool = false,
        link: String?,
        parametersAny: [String: Any]?
    ) -> AttributionData {
        let convertedParameters = parametersAny?.mapValues { AnyValue.from($0) }
        return AttributionData(
            isEmpty: isEmpty,
            link: link,
            parameters: convertedParameters
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        link = try container.decodeIfPresent(String.self, forKey: .link)
        let all = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var parametersDict: [String: AnyValue] = [:]
        for key in all.allKeys {
            // Skip known keys that are not parameters
            if CodingKeys.allCases.contains(where: { $0.stringValue == key.stringValue }) {
                continue
            }
            let value = try all.decode(AnyValue.self, forKey: key)
            parametersDict[key.stringValue] = value
        }
        parameters = parametersDict.isEmpty ? nil : parametersDict
        isEmpty = false
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(link, forKey: .link)
        try container.encodeIfPresent(isEmpty, forKey: .isEmpty)
        if let parameters = parameters {
            var dynamicContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
            for (key, value) in parameters {
                let dynamicKey = DynamicCodingKeys(stringValue: key)!
                try dynamicContainer.encode(value, forKey: dynamicKey)
            }
        }
    }

    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }

}

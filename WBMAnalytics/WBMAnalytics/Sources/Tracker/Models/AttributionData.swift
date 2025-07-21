// Copyright © 2025 Wildberries. All rights reserved.

import Foundation

/// Attribution server response model
public struct AttributionData: Codable {
    /// counter ID
    public let counterId: String?
    /// Link to follow after installation
    public let link: String?
    /// Other parameters (key: array of values)
    public let parameters: [String: String]?

    enum CodingKeys: String, CodingKey {
        case counterId
        case link
    }

    init(
        counterId: String?,
        link: String?,
        parameters: [String: String]?
    ) {
        self.counterId = counterId
        self.link = link
        self.parameters = parameters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        counterId = try container.decodeIfPresent(String.self, forKey: .counterId)
        link = try container.decodeIfPresent(String.self, forKey: .link)
        let all = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var parametersDict: [String: String] = [:]
        for key in all.allKeys {
            if key.stringValue != CodingKeys.counterId.rawValue {
                let value = try all.decode(String.self, forKey: key)
                parametersDict[key.stringValue] = value
            }
        }
        parameters = parametersDict.isEmpty ? nil : parametersDict
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(counterId, forKey: .counterId)
        try container.encodeIfPresent(link, forKey: .link)
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

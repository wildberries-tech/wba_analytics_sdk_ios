//
//  AnyValue.swift
//  WBMAnalytics
//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

/// Parameter value that can be any JSON-compatible type
public enum AnyValue: Codable, Equatable {

    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyValue])
    case object([String: AnyValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([AnyValue].self) {
            self = .array(arrayValue)
        } else if let objectValue = try? container.decode([String: AnyValue].self) {
            self = .object(objectValue)
        } else {
            throw DecodingError.typeMismatch(
                AnyValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode AnyValue")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    /// Get the value as a string representation
    public var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        case .double(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        case .array(let array):
            return array.first?.stringValue
        case .object:
            return nil
        case .null:
            return nil
        }
    }

    /// Get the value as an integer if possible
    public var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        case .double(let value):
            return Int(value)
        case .string(let value):
            return Int(value)
        default:
            return nil
        }
    }

    /// Get the value as a double if possible
    public var doubleValue: Double? {
        switch self {
        case .double(let value):
            return value
        case .int(let value):
            return Double(value)
        case .string(let value):
            return Double(value)
        default:
            return nil
        }
    }

    /// Get the value as a boolean if possible
    public var boolValue: Bool? {
        switch self {
        case .bool(let value):
            return value
        case .string(let value):
            return Bool(value)
        case .int(let value):
            return value != 0
        default:
            return nil
        }
    }

    /// Get the value as an array of AnyValues
    public var arrayValue: [AnyValue]? {
        switch self {
        case .array(let value):
            return value
        default:
            return nil
        }
    }

    /// Get the value as a dictionary of AnyValues
    public var objectValue: [String: AnyValue]? {
        switch self {
        case .object(let value):
            return value
        default:
            return nil
        }
    }

    /// Check if the value is null
    public var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }

    /// Convert to Any for compatibility with existing code
    public var anyValue: Any? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .array(let value):
            return value.map { $0.anyValue }
        case .object(let value):
            return value.mapValues { $0.anyValue }
        case .null:
            return nil
        }
    }

    /// Create AnyValue from Any
    public static func from(_ any: Any?) -> AnyValue {
        guard let any = any else { return .null }

        if let string = any as? String {
            return .string(string)
        } else if let int = any as? Int {
            return .int(int)
        } else if let double = any as? Double {
            return .double(double)
        } else if let bool = any as? Bool {
            return .bool(bool)
        } else if let array = any as? [Any] {
            return .array(array.map { AnyValue.from($0) })
        } else if let object = any as? [String: Any] {
            return .object(object.mapValues { AnyValue.from($0) })
        } else {
            return .string(String(describing: any))
        }
    }
}

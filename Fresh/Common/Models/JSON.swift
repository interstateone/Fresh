//
//  JSON.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-10.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

class JSON {
    let object: AnyObject
    let path: String

    init(_ object: AnyObject, path: String = "") {
        self.object = object
        self.path = path
    }

    func get<Value: Decodable>(keys: String...) throws -> Value {
        return try get(keys: keys)
    }

    func get<Value: Decodable>(keys: String...) throws -> [Value] {
        return try get(keys: keys)
    }

    func getJSON(keys: String...) throws -> JSON {
        return try getJSON(keys: keys)
    }
    
    func getJSON(keys keys: [String]) throws -> JSON {
        var value: JSON = self
        for key in keys {
            do {
                value = try value.getSourceValue(key)
            }
            catch let error as JSONError {
                throw JSONError(path: value.path + "." + key, underlyingError: error.underlyingError)
            }
        }
        return value
    }

    func get<Value: Decodable>(keys keys: [String]) throws -> Value {
        if keys.count == 0 {
            return try Value.decode(self)
        }

        do {
            return try Value.decode(getJSON(keys: keys))
        }
        catch let error as JSONError {
            throw JSONError(path: keys.joinWithSeparator("."), underlyingError: error.underlyingError)
        }
    }

    func get<Value: Decodable>(keys keys: [String]) throws -> [Value] {
        if keys.count == 0 {
            return try [Value].decode(self)
        }

        do {
            return try [Value].decode(getJSON(keys: keys))
        }
        catch let error as JSONError {
            throw JSONError(path: keys.joinWithSeparator("."), underlyingError: error.underlyingError)
        }
    }

    func decode<Value>(decode: (JSON) throws -> Value) throws -> Value {
        do {
            return try decode(self)
        }
        catch let error as JSONError {
            throw JSONError(path: path, underlyingError: error.underlyingError)
        }
    }

    private func getSourceValue(key: String) throws -> JSON {
        guard let object = object as? [String: AnyObject] else {
            throw DecodingError.NotAnObject
        }
        guard let sourceValue = object[key] else {
            throw DecodingError.MissingKey(key: key)
        }
        return JSON(sourceValue, path: self.path + "." + key)
    }
}

/// Decodable allows simple JSON value types to be turned into native Swift primitives or more complex types like URLs or structs and objects
protocol Decodable {
    static func decode(json: JSON) throws -> Self
}

extension Decodable {
    static func decode(json: JSON) throws -> Self {
        if let value = json.object as? Self {
            return value
        }
        throw DecodingError.TypeMismatch(expected: self, actual: json.object.dynamicType)
    }
}

extension String: Decodable {}
extension Int: Decodable {}
extension Double: Decodable {}
extension Bool: Decodable {
    static func decode(json: JSON) throws -> Bool {
        if let boolValue = json.object as? Bool {
            return boolValue
        }
        // SoundCloud sometimes encodes booleans as numbers (0, 1, null)
        if let numberValue = json.object as? NSNumber {
            return numberValue.boolValue
        }
        if json.object is NSNull {
            return false
        }
        throw DecodingError.TypeMismatch(expected: self, actual: json.object.dynamicType)
    }
}
extension NSURL: Decodable {
    static func decode(json: JSON) throws -> Self {
        guard let JSONString = json.object as? String else {
            throw DecodingError.TypeMismatch(expected: String.self, actual: json.object.dynamicType)
        }
        // It's not currently possible to handle the failure case of a failable initializer when delegating from a convenience initializer, so this inefficiently works around that
        guard NSURLComponents(string: JSONString) != nil else {
            throw DecodingError.Undecodable(explanation: "Unable to create a NSURL from the string \"\(JSONString)\"")
        }
        return self.init(string: JSONString)!
    }
}
extension Array where Element: Decodable {
    static func decode(json: JSON) throws -> [Element] {
        guard let JSONArray = json.object as? [AnyObject] else {
            throw DecodingError.TypeMismatch(expected: [AnyObject].self, actual: json.object.dynamicType)
        }
        return JSONArray.map { try? Element.decode(JSON($0)) }.flatMap { $0 }
    }
}

struct JSONError: ErrorType, CustomStringConvertible {
    let path: String
    let underlyingError: ErrorType

    var description: String {
        return "JSONError at path: \(path). \(underlyingError)"
    }
}

enum DecodingError: ErrorType, CustomStringConvertible {
    /// A property was attempted to be accessed on a value that wasn't an object.
    case NotAnObject
    /// The provided key wasn't found in the object.
    case MissingKey(key: String)
    /// The expected type wasn't found. Provides both types for examination.
    case TypeMismatch(expected: Any.Type, actual: Any.Type)
    /// Decoding failed for a reason beyond an unexpected type. An explanation is provided.
    case Undecodable(explanation: String)

    var description: String {
        switch self {
        case .NotAnObject: return "A property was attempted to be accessed on a value that wasn't an object."
        case .MissingKey(let key): return "The key \"\(key)\" wasn't found in the object."
        case .TypeMismatch(let expected, let actual): return "Expected a value of type \(expected) but found one of type \(actual)."
        case .Undecodable(let explanation): return "Value was undecodable: \(explanation)."
        }
    }
}
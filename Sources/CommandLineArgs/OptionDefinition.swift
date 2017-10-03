//
//  OptionDefinition.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 19/06/2017.
//

import Foundation

public struct OptionDefinition {

    public enum DataType {
        case string
        case double
        case int
        case boolean
    }

    public let name: String
    public let type: DataType
    public let alias: String?
    public let isMultiple: Bool
    public let defaultValue: Any?
    public let isRequired: Bool
    public let documentation: String?

    public init(name: String, type: DataType, alias: String? = nil, isMultiple: Bool = false, defaultValue: Any? = nil, isRequired: Bool = false, documentation: String? = nil) {
        self.name = name
        self.type = type
        self.alias = alias
        self.isMultiple = isMultiple
        self.defaultValue = defaultValue
        self.isRequired = isRequired
        self.documentation = documentation
    }
}

extension OptionDefinition.DataType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .boolean:
            return "Boolean"
        case .double:
            return "Double"
        case .int:
            return "Int"
        case .string:
            return "String"
        }
    }
}

extension OptionDefinition: CustomStringConvertible {

    public var description: String {
        var str = "--\(self.name)"
        if let a = self.alias {
            str += ", -\(a)"
        }
        if self.isMultiple {
            str += " [\(self.type)]"
        } else {
            str += " \(self.type)"
        }

        if self.defaultValue != nil {
            str += " = \(self.defaultValue!)"
        } else if !self.isRequired {
            str += "?"
        }

        if let d = self.documentation {
            str += "\n\t\(d)"
        }

        return str
    }
}

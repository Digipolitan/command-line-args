//
//  Option.swift
//  CommandLineArgsTests
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

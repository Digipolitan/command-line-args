//
//  CommandDefinition.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 19/06/2017.
//

import Foundation

public struct CommandDefinition {

    public let name: String
    public let aliases: [String]?
    public let options: [OptionDefinition]?
    public let main: OptionDefinition?
    public let documentation: String?

    public init(name: String,
                aliases: [String]? = nil,
                options: [OptionDefinition]? = nil,
                main: OptionDefinition? = nil,
                documentation: String? = nil) {
        self.name = name
        self.aliases = aliases
        self.options = options
        self.main = main
        self.documentation = documentation
    }
}

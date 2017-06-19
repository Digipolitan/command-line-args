//
//  Command.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 19/06/2017.
//

import Foundation

public struct CommandDefinition {

    public let name: String
    public let aliases: [String]?
    public let definitions: [OptionDefinition]?
    public let `default`: OptionDefinition?
    public let documentation: String?

    public init(name: String, aliases: [String]? = nil, definitions: [OptionDefinition]? = nil, `default`: OptionDefinition? = nil, documentation: String? = nil) {
        self.name = name
        self.aliases = aliases
        self.definitions = definitions
        self.`default` = `default`
        self.documentation = documentation
    }
}

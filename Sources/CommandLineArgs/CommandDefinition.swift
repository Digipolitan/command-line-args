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
    public let definitions: [OptionDefinition]?
    public let main: OptionDefinition?
    public let documentation: String?

    public init(name: String, aliases: [String]? = nil, definitions: [OptionDefinition]? = nil, main: OptionDefinition? = nil, documentation: String? = nil) {
        self.name = name
        self.aliases = aliases
        self.definitions = definitions
        self.main = main
        self.documentation = documentation
    }
}

extension CommandDefinition: CustomStringConvertible {

    public var description: String {

        var str = "+ \(self.name)\n\n"

        if let d = self.documentation {
            str += "\(d)\n\n"
        }

        var optStr = ""

        if let m = self.main {
            str += "USAGE : \(self.name) [\(m.name.uppercased())] [OPTIONS]\n\n"
            optStr += "\(m)\n"
        }

        if let options = self.definitions {
            options.forEach { optStr += "\($0)\n" }
        }

        if optStr.count > 0 {
            str += "OPTIONS : \n\n\(optStr)"
        }

        return str
    }
}

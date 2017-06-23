//
//  Task.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 23/06/2017.
//

import Foundation

public class Task: Helpable {

    public let node: CommandNode
    public private(set) var arguments: [String: Any]

    init(node: CommandNode, arguments: [String: Any]) {
        self.node = node
        self.arguments = arguments
    }

    public func exec() throws {
        if let main = self.node.command.definition.main {
            try self.checkArguments(option: main)
        }
        if let options = self.node.command.definition.options {
            for option in options {
                try self.checkArguments(option: option)
            }
        }
        try self.node.command.run(self.arguments)
    }

    private func checkArguments(option: OptionDefinition) throws {
        if self.arguments[option.name] == nil {
            if option.defaultValue != nil {
                self.arguments[option.name] = option.defaultValue
            } else if option.isRequired {
                throw CommandLineError.missingRequiredArgument(node: node)
            }
        }
    }

    public func help() -> String {
        return self.node.help()
    }
}

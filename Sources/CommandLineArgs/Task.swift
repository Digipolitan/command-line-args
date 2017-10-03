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
        try self.checkArguments()
        try self.node.command.run(self.arguments)
    }

    private func checkArguments() throws {
        var missingParameters: [String] = []
        if let main = self.node.command.definition.main {
            if !checkArgument(option: main) {
                missingParameters.append(main.name)
            }
        }
        if let options = self.node.command.definition.options {
            for option in options {
                if !checkArgument(option: option) {
                    missingParameters.append(option.name)
                }
            }
        }
        if missingParameters.count > 0 {
            throw CommandLineError.command(node: self.node, missingParameters: missingParameters)
        }
    }

    private func checkArgument(option: OptionDefinition) -> Bool {
        if self.arguments[option.name] == nil {
            if option.defaultValue != nil {
                self.arguments[option.name] = option.defaultValue
            } else if option.isRequired {
                return false
            }
        }
        return true
    }

    public func help() -> String {
        return self.node.help()
    }
}

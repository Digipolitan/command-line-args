//
//  CommandNode.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 23/06/2017.
//

import Foundation

public class CommandNode {

    public private(set) weak var parent: CommandNode?
    public let command: Command
    public var children: [CommandNode]

    init(command: Command) {
        self.command = command
        self.children = []
    }

    public func add(child: Command) {
        let node = CommandNode(command: child)
        node.parent = self
        if let idx = self.children.index(of: child.definition.name) {
            self.children[idx].parent = nil
            self.children[idx] = node
        } else {
            self.children.append(node)
        }
    }
}

extension CommandNode: Helpable {

    public func help() -> String {

        let definition = self.command.definition
        let hasChildren = self.children.count > 0

        var str = "USAGE :\n\n"

        var commands: [String] = []

        var current: CommandNode? = self
        while let unwrap = current {
            commands.append(self.name(definition: unwrap.command.definition))
            current = unwrap.parent
        }
        commands.reverse()

        str += "\t$ \(commands.joined(separator: " "))"

        if hasChildren {
            str += " [COMMAND] [OPTIONS]\n\n"
        } else if let main = definition.main {
            str += " [\(main.name.uppercased())] [OPTIONS]\n\n"
        }

        if let documentation = definition.documentation {
            str += "\(documentation)\n\n"
        }

        if hasChildren {
            str += "COMMANDS :\n\n"

            for child in self.children {
                let childDefinition = child.command.definition
                str += "+ \(childDefinition.name)"
                if let documentation = childDefinition.documentation {
                    str += "\n  \(documentation.replacingOccurrences(of: "\n", with: "\n  "))"
                }
                str += "\n\n"
            }
        }

        var optionsArr: [String] = []

        if let main = definition.main {
            optionsArr.append(self.help(option: main))
        }
        if let options = definition.options {
            optionsArr.append(contentsOf: options.map { self.help(option: $0) })
        }

        if optionsArr.count > 0 {
            str += "OPTIONS :\n\n"
            str += optionsArr.joined(separator: "\n\n")
        }

        return str
    }

    private func help(option: OptionDefinition) -> String {
        var str = "--\(option.name)"
        if let alias = option.alias {
            str += "|-\(alias)"
        }
        
        str += " \(option.type)"
        if option.isMultiple {
            str += "[]"
        }

        if option.defaultValue != nil {
            str += " = \(option.defaultValue!)"
        } else if !option.isRequired {
            str += "?"
        }

        if let documentation = option.documentation {
            str += "\n  \(documentation.replacingOccurrences(of: "\n", with: "\n  "))"
        }
        return str
    }

    private func name(definition: CommandDefinition) -> String {
        var name = definition.name
        if let aliases = definition.aliases {
            aliases.forEach { name += "|\($0)" }
        }
        return name
    }
}

extension Array where Element == CommandNode {

    public func search(command name: String) -> Element? {
        return self.first {
            let definition = $0.command.definition
            if definition.name == name {
                return true
            }
            if let aliases = definition.aliases {
                return aliases.contains(name)
            }
            return false
        }
    }

    public func index(of name: String) -> Int? {
        return self.index { $0.command.definition.name == name }
    }
}

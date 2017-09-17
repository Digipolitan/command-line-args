//
//  CommandNode.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 23/06/2017.
//

import Foundation
import Rainbow

public class CommandNode {

    public private(set) weak var parent: CommandNode?
    public let command: Command
    public var children: [CommandNode]

    init(command: Command) {
        self.command = command
        self.children = []
    }

    @discardableResult
    public func add(child: Command) -> CommandNode {
        let node = CommandNode(command: child)
        node.parent = self
        if let idx = self.children.index(of: child.definition.name) {
            self.children[idx].parent = nil
            self.children[idx] = node
        } else {
            self.children.append(node)
        }
        return node
    }
}

extension CommandNode: Helpable {

    public func help() -> String {

        var part: [String] = []

        let definition = self.command.definition
        let hasChildren = self.children.count > 0

        part.append("Usage :".underline)

        var commands: [String] = []

        var current: CommandNode? = self
        while let unwrap = current {
            commands.append(self.name(definition: unwrap.command.definition))
            current = unwrap.parent
        }
        commands.reverse()

        var cmd = "\t$ \(commands.joined(separator: " "))"

        if hasChildren {
            cmd += " [COMMAND]"
        } else if let main = definition.main {
            cmd += " [\(main.name.uppercased())]"
        }

        var requiredOptionsArr: [String] = []
        var optionalOptionsArr: [String] = []

        let optionHelpClosure: (OptionDefinition) -> Void = {
            let help = self.help(option: $0)
            if $0.isRequired && $0.defaultValue == nil {
                requiredOptionsArr.append(help)
            } else {
                optionalOptionsArr.append(help)
            }
        }
        if let main = definition.main {
            optionHelpClosure(main)
        }
        if let options = definition.options {
            options.forEach(optionHelpClosure)
        }

        let hasOptions = requiredOptionsArr.count > 0 || optionalOptionsArr.count > 0

        if hasOptions {
            cmd += " [OPTIONS]"
        }

        part.append(cmd.green)

        if let documentation = definition.documentation {
            part.append(documentation)
        }

        if hasChildren {
            part.append("Commands :".underline)

            for child in self.children {
                let childDefinition = child.command.definition
                var childCmd = "+ \(childDefinition.name)".green
                if let documentation = childDefinition.documentation {
                    childCmd += "\n  \(documentation.replacingOccurrences(of: "\n", with: "\n  "))"
                }
                part.append(childCmd)
            }
        }

        if hasOptions {
            part.append("Options :".underline)
            if requiredOptionsArr.count > 0 {
                part.append("Required :".bold)
                part.append(contentsOf: requiredOptionsArr)
                if optionalOptionsArr.count > 0 {
                    part.append("Optional :".bold)
                    part.append(contentsOf: optionalOptionsArr)
                }
            } else {
                part.append(contentsOf: optionalOptionsArr)
            }
        }

        return part.joined(separator: "\n\n")
    }

    private func help(option: OptionDefinition) -> String {

        var name = "--\(option.name)"
        if let alias = option.alias {
            name += "|-\(alias)"
        }

        var str = name.green

        var type = "\(option.type)"
        if option.isMultiple {
            type += "[]"
        }
        str += " " + type.magenta

        if option.defaultValue != nil {
            str += " = "  + "\(option.defaultValue!)".red
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

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

    public func hierarchy() -> [CommandNode] {
        var hierarchy: [CommandNode] = []
        var current: CommandNode? = self
        while let unwrap = current {
            hierarchy.append(unwrap)
            current = unwrap.parent
        }
        return hierarchy.reversed()
    }

    public func help() -> String {

        var parts: [String] = []

        let definition = self.command.definition
        let hasChildren = self.children.count > 0

        parts.append("Usage :".underline)

        let commands: [String] = self.hierarchy().map { self.name(definition: $0.command.definition) }
        var cmd = "\t$ \(commands.joined(separator: " "))"

        if hasChildren {
            cmd += " [COMMAND]"
        } else if let main = definition.main {
            cmd += " [\(main.name.uppercased())]"
        }

        var requiredOptions: [String] = []
        var optionalOptions: [String] = []

        let optionHelpClosure: (OptionDefinition) -> Void = {
            let help = self.help(option: $0)
            if $0.isRequired && $0.defaultValue == nil {
                requiredOptions.append(help)
            } else {
                optionalOptions.append(help)
            }
        }
        if let main = definition.main {
            optionHelpClosure(main)
        }
        if let options = definition.options {
            options.forEach(optionHelpClosure)
        }

        let hasOptions = requiredOptions.count > 0 || optionalOptions.count > 0

        if hasOptions {
            cmd += " [OPTIONS]"
        }

        parts.append(cmd.green)

        if let documentation = definition.documentation {
            parts.append(documentation)
        }

        if hasChildren {
            parts.append("Commands :".underline)
            parts.append(contentsOf: self.childrenCommandHelp())
        }

        if hasOptions {
            parts.append("Options :".underline)
            parts.append(contentsOf: self.optionsHelp(required: requiredOptions, optional: optionalOptions))
        }

        return parts.joined(separator: "\n\n")
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

    private func childrenCommandHelp() -> [String] {
        var parts: [String] = []
        for child in self.children {
            let childDefinition = child.command.definition
            var childCmd = "+ \(childDefinition.name)".green
            if let documentation = childDefinition.documentation {
                childCmd += "\n  \(documentation.replacingOccurrences(of: "\n", with: "\n  "))"
            }
            parts.append(childCmd)
        }
        return parts
    }

    private func optionsHelp(required: [String], optional: [String]) -> [String] {
        var parts: [String] = []
        if required.count > 0 {
            parts.append("Required :".bold)
            parts.append(contentsOf: required)
            if optional.count > 0 {
                parts.append("Optional :".bold)
                parts.append(contentsOf: optional)
            }
        } else {
            parts.append(contentsOf: optional)
        }
        return parts
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

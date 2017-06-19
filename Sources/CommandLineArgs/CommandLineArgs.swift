import Foundation

public class CommandLineArgs {

    private var definitions: [CommandDefinition]
    private var `default`: CommandDefinition?
    private var commands: [String: Command]

    public init() {
        self.definitions = []
        self.commands = [:]
    }

    @discardableResult
    public func `default`(definition: CommandDefinition, command: Command? = nil) -> Self {
        self.default = definition
        self.commands[definition.name] = command
        return self
    }

    @discardableResult
    public func set(definition: CommandDefinition, command: Command? = nil) -> Self {
        if let idx = self.definitions.index(where: { $0.name == definition.name }) {
            self.definitions.remove(at: idx)
            self.definitions.insert(definition, at: idx)
        } else {
            self.definitions.append(definition)
        }
        self.commands[definition.name] = command
        return self
    }

    public func parse(_ arguments: [String]) throws -> (Command?, [String: Any]) {
        var res: (Command?, [String: Any]) = (nil, [:])
        if let definition = self.definitions.first(where: {
            if $0.name == arguments[0] {
                return true
            }
            if let aliases = $0.aliases {
                return aliases.index(of: arguments[0]) != nil
            }
            return false
        }) ?? self.default {
            res.0 = self.commands[definition.name]
            var current: OptionDefinition? = nil
            for idx in 1..<arguments.count {
                let arg = arguments[idx]
                let count = arg.count
                if count > 0 {
                    let startIndex = arg.startIndex
                    if arg[startIndex] == "-" {
                        current = nil
                        if count > 1 {
                            let secondIndex = arg.index(after: startIndex)
                            if arg[secondIndex] == "-" {
                                self.parse(verbose: arg.substring(from: arg.index(after: secondIndex)), output: &res.1, cmd: definition, current: &current)
                                continue
                            }
                        }
                        self.parse(alias: arg.substring(from: arg.index(after: startIndex)), output: &res.1, cmd: definition, current: &current)
                        continue
                    }
                    if let opt = current ?? definition.default {
                        let data = CommandLineArgs.convert(argument: arg, type: opt.type)
                        if opt.isMultiple {
                            var arr = res.1[opt.name] as? Array<Any> ?? []
                            arr.append(data)
                            res.1[opt.name] = arr
                        } else {
                            res.1[opt.name] = data
                        }
                    }
                }
            }
            let checkArguments = { (option: OptionDefinition) in
                if res.1[option.name] == nil {
                    if option.defaultValue != nil {
                        res.1[option.name] = option.defaultValue
                    } else if option.isRequired {
                        throw CommandLineError.missingRequiredArgument
                    }
                }
            }
            if let d = definition.default {
                try checkArguments(d)
            }
            try definition.definitions?.forEach(checkArguments)
        }
        return res
    }

    private static func convert(argument: String, type: OptionDefinition.DataType) -> Any {
        if type == .string {
            return argument
        } else if type == .boolean {
            return !(argument == "0" || argument.lowercased() == "false")
        } else if let d = Double(argument) {
            if type == .double {
                return d
            }
            return Int(d)
        }
        return 0
    }

    private func parse(verbose argument: String, output: inout [String: Any], cmd: CommandDefinition, current: inout OptionDefinition?) {
        if let index = argument.index(of: "=") {
            let name = argument.substring(to: index)
            let value = argument.substring(from: argument.index(after: index))

            if let option = cmd.definitions?.first(where: { $0.name == name }) {
                let data = CommandLineArgs.convert(argument: value, type: option.type)
                if option.isMultiple {
                    var arr = output[option.name] as? Array<Any> ?? []
                    arr.append(data)
                    output[option.name] = arr
                } else {
                    output[option.name] = data
                }
            }
        } else if let option = cmd.definitions?.first(where: { $0.name == argument }) {
            if option.type == .boolean && option.isMultiple == false {
                output[option.name] = true
            }
            current = option
        }
    }

    private func parse(alias argument: String, output: inout [String: Any], cmd: CommandDefinition, current: inout OptionDefinition?) {
        var str = ""
        for ch in argument {
            str.append(ch)
            if let option = cmd.definitions?.first(where: { $0.alias == str }) {
                if option.type == .boolean && option.isMultiple == false {
                    output[option.name] = true
                } else {
                    current = option
                }
                str = ""
            }
        }
    }
}

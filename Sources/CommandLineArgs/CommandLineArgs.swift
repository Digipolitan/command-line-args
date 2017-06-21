import Foundation

public class CommandLineArgs {

    public let name: String?
    public let documentation: String?
    public private(set) var commands: [Command]
    public private(set) var main: Command?

    public init(name: String? = nil, documentation: String? = nil) {
        self.name = name
        self.documentation = documentation
        self.commands = []
    }

    @discardableResult
    public func main(command: Command) -> Self {
        self.main = command
        return self
    }

    @discardableResult
    public func main(definition: CommandDefinition, handler: @escaping CommandHandler) -> Self {
        return self.main(command: CommandWrapper(definition: definition, handler: handler))
    }

    @discardableResult
    public func register(command: Command) -> Self {
        if let idx = self.commands.index(where: { $0.definition.name == command.definition.name }) {
            self.commands.remove(at: idx)
            self.commands.insert(command, at: idx)
        } else {
            self.commands.append(command)
        }
        return self
    }

    @discardableResult
    public func register(definition: CommandDefinition, handler: @escaping CommandHandler) -> Self {
        return self.register(command: CommandWrapper(definition: definition, handler: handler))
    }

    public func run(_ arguments: [String]) throws {
        if arguments.count > 0, let command = self.commands.first(where: {
            if $0.definition.name == arguments[0] {
                return true
            }
            if let aliases = $0.definition.aliases {
                return aliases.index(of: arguments[0]) != nil
            }
            return false
        }) ?? self.main {
            let definition = command.definition
            var current: OptionDefinition? = nil
            var res: [String: Any] = [:]
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
                                self.parse(verbose: arg.substring(from: arg.index(after: secondIndex)), output: &res, cmd: definition, current: &current)
                                continue
                            }
                        }
                        self.parse(alias: arg.substring(from: arg.index(after: startIndex)), output: &res, cmd: definition, current: &current)
                        continue
                    }
                    if let opt = current ?? definition.main {
                        let data = CommandLineArgs.convert(argument: arg, type: opt.type)
                        if opt.isMultiple {
                            var arr = res[opt.name] as? Array<Any> ?? []
                            arr.append(data)
                            res[opt.name] = arr
                        } else {
                            res[opt.name] = data
                            current = nil
                        }
                    }
                }
            }
            let checkArguments = { (option: OptionDefinition) in
                if res[option.name] == nil {
                    if option.defaultValue != nil {
                        res[option.name] = option.defaultValue
                    } else if option.isRequired {
                        throw CommandLineError.missingRequiredArgument
                    }
                }
            }
            if let d = definition.main {
                try checkArguments(d)
            }
            try definition.definitions?.forEach(checkArguments)
            try command.run(res)
        } else {
            throw CommandLineError.commandNotFound
        }
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

extension CommandLineArgs: CustomStringConvertible {

    public var description: String {

        var str = ""
        if let name = self.name {
            str += "\(name.uppercased())\n\n"
        }

        if let d = self.documentation {
            str += "\(d)\n\n"
        }

        if let name = self.name {
            str += "USAGE : \(name) [COMMAND]\n\n"
        }

        str += "COMMANDS : \n\n"

        if let m = self.main {
            str += "[!] This following command can be run without the command name\n\n\(m.definition)\n----\n"
        }

        self.commands.forEach { str += "\($0.definition)\n----\n\n" }
        
        return str
    }
}

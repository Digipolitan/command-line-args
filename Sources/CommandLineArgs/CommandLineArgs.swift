import Foundation

public class CommandLineArgs {

    public private(set) var roots: [CommandNode]

    public init() {
        self.roots = []
    }

    @discardableResult
    public func root(command: Command) -> CommandNode {
        let root = CommandNode(command: command)
        if let idx = self.roots.index(of: command.definition.name) {
            self.roots[idx] = root
        } else {
            self.roots.append(root)
        }
        return root
    }

    @discardableResult
    public func root(definition: CommandDefinition, handler: @escaping CommandHandler) -> CommandNode {
        return self.root(command: CommandWrapper(definition: definition, handler: handler))
    }

    public func build(_ arguments: [String]) throws -> Task {
        var index: Int = 0
        if let node = self.node(arguments, index: &index) {
            let args = try self.parse(arguments, from: index, with: node)
            return Task(node: node, arguments: args)
        } else {
            throw CommandLineError.commandNotFound
        }
    }

    private func node(_ arguments: [String], index: inout Int) -> CommandNode? {
        let numberOfArguments = arguments.count
        if numberOfArguments > 0 {
            if let root = self.roots.search(command: arguments[0]) {
                var last = root
                var i = 1
                while i < numberOfArguments {
                    if arguments[i].hasPrefix("-") {
                        break
                    }
                    if let child = last.children.search(command: arguments[i]) {
                        last = child
                        i += 1
                    } else if last.command.definition.main != nil {
                        break // the last command contains a main option
                    } else {
                        return nil
                    }
                }
                index = i
                return last
            }
        }
        return nil
    }

    private func parse(_ arguments: [String], from index: Int, with node: CommandNode) throws -> [String: Any] {
        var current: OptionDefinition? = nil
        var res: [String: Any] = [:]
        let definition = node.command.definition
        for idx in index..<arguments.count {
            let arg = arguments[idx]
            let count = arg.count
            if count > 0 {
                let startIndex = arg.startIndex
                if arg[startIndex] == "-" {
                    current = nil
                    if count > 1 {
                        let secondIndex = arg.index(after: startIndex)
                        if arg[secondIndex] == "-" {
                            self.parse(verbose: arg.substring(from: arg.index(after: secondIndex)), output: &res, definition: definition, current: &current)
                            continue
                        }
                    }
                    self.parse(alias: arg.substring(from: arg.index(after: startIndex)), output: &res, definition: definition, current: &current)
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

    private func parse(verbose argument: String, output: inout [String: Any], definition: CommandDefinition, current: inout OptionDefinition?) {
        if let index = argument.index(of: "=") {
            let name = argument.substring(to: index)
            let value = argument.substring(from: argument.index(after: index))

            if let option = definition.options?.first(where: { $0.name == name }) {
                let data = CommandLineArgs.convert(argument: value, type: option.type)
                if option.isMultiple {
                    var arr = output[option.name] as? Array<Any> ?? []
                    arr.append(data)
                    output[option.name] = arr
                } else {
                    output[option.name] = data
                }
            }
        } else if let option = definition.options?.first(where: { $0.name == argument }) {
            if option.type == .boolean && option.isMultiple == false {
                output[option.name] = true
            }
            current = option
        }
    }

    private func parse(alias argument: String, output: inout [String: Any], definition: CommandDefinition, current: inout OptionDefinition?) {
        var str = ""
        for ch in argument {
            str.append(ch)
            if let option = definition.options?.first(where: { $0.alias == str }) {
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

extension CommandLineArgs: Helpable {

    public func help() -> String {
        return self.roots.map { $0.help() }.joined(separator: "\n\n")
    }

}

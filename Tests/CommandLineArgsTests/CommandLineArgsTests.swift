import XCTest
@testable import CommandLineArgs

class T: Command {

    lazy var definition: CommandDefinition = {
        var options: [OptionDefinition] = []
        options.append(OptionDefinition(name: "package", type: .string, alias: "p", isMultiple: true, isRequired: true, documentation: "The project package"))
        options.append(OptionDefinition(name: "help", type: .boolean, documentation: "Show help banner of specified command"))
        return CommandDefinition(name: "use", aliases: ["k", "d"], options: options, main: OptionDefinition(name: "file", type: .string, defaultValue: "polymorph.json", documentation: "dsqs\ndsdqs\nqd"), documentation: "Select the polymorph file to be edited")
    }()

    func run(_ arguments: [String : Any]) throws {
        print(arguments)
    }
}

class CommandLineArgsTests: XCTestCase {
    func testExample() {

        let cla = CommandLineArgs()
        let polymorph = cla.root(command: T())
        polymorph.add(child: T())

        do {
            let task = try cla.build(["use", "use"])
            if let help = task.arguments["help"] as? Bool, help == true {
                print(task.help())
            } else {
                try task.exec()
            }
        } catch CommandLineError.missingRequiredArgument(let node) {
            print("[!] Missing required parameter\n")
            print(node.help())
        } catch {
            print("[!] Command not found\n")
            print(cla.help())
        }


        /*
        let cla = CommandLineArgs(options: [
            .init(name: "hot", type: .boolean, alias: "h"),
            .init(name: "nonnull", type: .boolean, alias: "nn", isRequired: true),
            .init(name: "discount", type: .boolean, alias: "d"),
            .init(name: "courses", type: .int, alias: "c"),
            .init(name: "files", type: .string, alias: "f", isMultiple: true),
            ], default: .init(name: "action", type: .string, isMultiple: true))

        let result = try! cla.parse(arguments: ["rm", "data", "-h", "--files", "test", "test2", "-d", "--files=bonjour", "-f", "testdeouf"])
        print(result)
 */
    }


    static var allTests: [(String, (CommandLineArgsTests) -> () -> Void)] = [
        ("testExample", testExample),
    ]
}

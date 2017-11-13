import XCTest
@testable import CommandLineArgs

class TestCommand: Command {

    lazy var definition: CommandDefinition = {
        var options: [OptionDefinition] = []
        options.append(OptionDefinition(name: "package",
                                        type: .string,
                                        alias: "p",
                                        isMultiple: true,
                                        isRequired: true,
                                        documentation: "The project package"))
        options.append(OptionDefinition(name: "help",
                                        type: .boolean,
                                        documentation: "Show help banner of specified command"))
        return CommandDefinition(name: "use",
                                 aliases: ["k", "d"],
                                 options: options,
                                 main: OptionDefinition(name: "file",
                                                        type: .string,
                                                        defaultValue: "polymorph.json",
                                                        documentation: "dsqs\ndsdqs\nqd"),
                                 documentation: "Select the polymorph file to be edited")
    }()

    func run(_ arguments: [String: Any]) throws {
        print(arguments)
    }
}

class CommandLineArgsTests: XCTestCase {
    func testExample() {

        let cla = CommandLineArgs()
        let polymorph = cla.root(command: TestCommand())
        polymorph.add(child: TestCommand())

        cla.handle(["use", "use"])
    }

    static var allTests: [(String, (CommandLineArgsTests) -> () -> Void)] = [
        ("testExample", testExample)
    ]
}

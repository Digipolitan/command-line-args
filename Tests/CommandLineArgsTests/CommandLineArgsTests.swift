import XCTest
@testable import CommandLineArgs

class T: Command {

    lazy var definition: CommandDefinition = {
        var options: [OptionDefinition] = []
        options.append(OptionDefinition(name: "package", type: .string, alias: "p", isMultiple: true, documentation: "The project package"))
        return CommandDefinition(name: "use", definitions: options, main: OptionDefinition(name: "file", type: .string, defaultValue: "polymorph.json"), documentation: "Select the polymorph file to be edited")
    }()

    func run(_ arguments: [String : Any]) throws {
        print("SUCCESS")
        print(arguments)
    }
}

class CommandLineArgsTests: XCTestCase {
    func testExample() {

        let cla = CommandLineArgs(name: "polymorph")
        cla.main(command: T())
        print(cla)

        try! cla.run(["--file", "test"])

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

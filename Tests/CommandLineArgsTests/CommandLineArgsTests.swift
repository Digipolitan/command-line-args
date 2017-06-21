import XCTest
@testable import CommandLineArgs

class T: Command {

    lazy var definition: CommandDefinition = {
        return CommandDefinition(name: "use", main: OptionDefinition(name: "file", type: .string, defaultValue: "polymorph.json"))
    }()

    func run(_ arguments: [String : Any]) throws {
        print("SUCCESS")
        print(arguments)
    }
}

class CommandLineArgsTests: XCTestCase {
    func testExample() {

        let cla = CommandLineArgs()
        cla.main(command: T())

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

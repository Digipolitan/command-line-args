CommandLineArgs
=================================

[![Swift Version](https://img.shields.io/badge/swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

Swift library to parse and route command line options

## Installation

### SPM

To install CommandLineArgs with SwiftPackageManager, add the following lines to your `Package.swift`.

```swift
let package = Package(
    name: "XXX",
    products: [
        .library(
            name: "XXX",
            targets: ["XXX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Digipolitan/command-line-args.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "XXX",
            dependencies: ["CommandLineArgs"])
    ]
)
```

## The Basics

### Handle single command

1] Create the command subclass

```swift
public class MyAppCommand: Command {

    public enum Keys {
        public static let help: String = CommandLineArgs.Consts.keys.help
        public static let numbers: String = "numbers"
    }

    public enum Options {
        public static let help = OptionDefinition(name: Keys.help, type: .boolean, documentation: "Show help banner of specified command")
        public static let numbers = OptionDefinition(name: Keys.numbers, type: .int, alias: "n", isMultiple: true)
    }

    public enum Consts {
        public static let name: String = "MyAppName"
    }

    public lazy var definition: CommandDefinition = {
        return CommandDefinition(name: Consts.name, options: [
          Options.help,
          Options.numbers
          ], documentation: "My App command line tool")
    }()

    public func run(_ arguments: [String : Any]) throws {
      if let numbers = arguments[Keys.numbers] as? [Int] {
        print(numbers) // display numbers value
      }
    }
}
```

2] Register & handle the command inside the CommandLineArgs in your main.swift

```swift
var arguments = CommandLine.arguments
arguments[0] = MyAppCommand.Consts.name // Force the app name inside the first app arguments

let cla = CommandLineArgs()
cla.root(command: MyAppCommand())
cla.handle(arguments)
```

3] Execute your command line app as follow:

- Display the help banner

```sh
$ MyAppName --help
```

**Output**
```sh
Usage :

	$ MyAppName [OPTIONS]

My App command line tool

Options :

--help Boolean
  Show help banner of specified command

--numbers|-n Int[]
```

---

- Execute using full arg name

```sh
$ MyAppName --numbers 1 2
```

**Output**
```sh
[1, 2]
```

---

- Execute using alias

```sh
$ MyAppName -n 1 2 3 4
```

**Output**
```sh
[1, 2, 3, 4]
```

### Handle node command

```swift
let cla = CommandLineArgs()
let app = cla.root(command: MyAppCommand())
app.add(child: StartCommand()) // CommandDefinition name: "start"
app.add(child: StopCommand()) // CommandDefinition name: "stop"
```

* `$ MyAppName --numbers 4 3` will trigger MyAppCommand
* `$ MyAppName start XXX` will trigger StartCommand
* `$ MyAppName stop XXX` will trigger StopCommand

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

CommandLineArgs is licensed under the [BSD 3-Clause license](LICENSE).

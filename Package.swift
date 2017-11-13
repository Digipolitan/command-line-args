// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommandLineArgs",
    products: [
        .library(
            name: "CommandLineArgs",
            targets: ["CommandLineArgs"])
    ],
    dependencies: [
    .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "CommandLineArgs",
            dependencies: ["Rainbow"]),
        .testTarget(
            name: "CommandLineArgsTests",
            dependencies: ["CommandLineArgs"])
    ]
)

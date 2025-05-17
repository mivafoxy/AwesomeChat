// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyAwesomeChat",
    defaultLocalization: "ru",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyAwesomeChat",
            targets: ["MyAwesomeChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MyAwesomeChat",
            dependencies: ["SnapKit"]
        ),
        .testTarget(
            name: "MyAwesomeChatTests",
            dependencies: ["MyAwesomeChat"]
        ),
    ]
)

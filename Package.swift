// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyChat",
    defaultLocalization: "ru",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "MyChat",
            targets: ["MyChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "MyChat",
            dependencies: [
                .byName(name: "SnapKit")
            ]),
    ]
)

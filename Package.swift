// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FAChat",
    defaultLocalization: "ru",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FAChat",
            targets: ["FAChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "FAChat",
            dependencies: [
                .byName(name: "SnapKit")
            ]),
    ]
)

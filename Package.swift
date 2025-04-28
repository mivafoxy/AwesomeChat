// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FAChat",
    defaultLocalization: "ru",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FAChat",
            targets: ["FAChat"]),
    ],
    dependencies: [
        .package(
            url: "https://gitlab-01/retail/mobile/ios/designsystem/mrdskit.git",
            .upToNextMajor(from: "3.13.0")
        ),
    ],
    targets: [
        .target(
            name: "FAChat",
            dependencies: [
                .product(name: "MRDSKit", package: "mrdskit")
            ]),
    ]
)

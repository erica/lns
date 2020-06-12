// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lns",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "lns",
            targets: ["lns"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.0.6")),
    ],
    targets: [
        .target(
            name: "lns",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "lns/"
        ),
        .testTarget(
            name: "lnsTests",
            dependencies: ["lns"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

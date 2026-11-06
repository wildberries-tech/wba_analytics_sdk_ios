// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WBASDK",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "WBASDK",
            targets: ["WBASDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
    ],
    targets: [
        .target(
            name: "WBASDK",
            dependencies: [],
            path: "./WBASDK/WBASDK/Sources"
        ),
        .testTarget(
            name: "WBASDKTests",
            dependencies: ["WBASDK"],
            path: "./WBASDK/WBASDKTests"
        )
    ]
)

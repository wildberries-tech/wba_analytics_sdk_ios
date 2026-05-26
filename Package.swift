// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WildAnalyticsSDK",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "WildAnalyticsSDK",
            targets: ["WildAnalyticsSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
    ],
    targets: [
        .target(
            name: "WildAnalyticsSDK",
            dependencies: [],
            path: "./WildAnalyticsSDK/WildAnalyticsSDK/Sources"
        ),
        .testTarget(
            name: "WildAnalyticsSDKTests",
            dependencies: ["WildAnalyticsSDK"],
            path: "./WildAnalyticsSDK/WildAnalyticsSDKTests"
        )
    ]
)

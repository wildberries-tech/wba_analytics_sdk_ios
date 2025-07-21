// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WBMAnalytics",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "WBMAnalytics",
            targets: ["WBMAnalytics"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
    ],
    targets: [
        .target(
            name: "WBMAnalytics",
            dependencies: [],
            path: "./WBMAnalytics/WBMAnalytics/Sources"
        ),
        .testTarget(
            name: "WBMAnalyticsTests",
            dependencies: ["WBMAnalytics"],
            path: "./WBMAnalytics/WBMAnalyticsTests"
        )
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LifeHub",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LifeHub",
            targets: ["LifeHub"]),
    ],
    dependencies: [
        // Swift Charts is now built into iOS 16+, no external dependency needed
        // Add other dependencies here as needed
    ],
    targets: [
        .target(
            name: "LifeHub",
            dependencies: []),
        .testTarget(
            name: "LifeHubTests",
            dependencies: ["LifeHub"]),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PolarLicense",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "PolarLicense",
            targets: ["PolarLicense"]
        )
    ],
    targets: [
        .target(
            name: "PolarLicense",
            dependencies: [],
            path: "Sources/PolarLicense"
        ),
        .testTarget(
            name: "PolarLicenseTests",
            dependencies: ["PolarLicense"],
            path: "Tests/PolarLicenseTests"
        )
    ]
)

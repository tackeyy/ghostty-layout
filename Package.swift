// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ghostty-layout",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "GhosttyLayoutLib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "ghostty-layout",
            dependencies: [
                "GhosttyLayoutLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "GhosttyLayoutTests",
            dependencies: ["GhosttyLayoutLib"]
        )
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "prettymd",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "prettymd", targets: ["App"])
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: ["Core", "AIClient", "Utils"],
            path: "Sources/App"
        ),
        .target(
            name: "Core",
            dependencies: ["Utils"],
            path: "Sources/Core"
        ),
        .target(
            name: "AIClient",
            dependencies: [],
            path: "Sources/AIClient"
        ),
        .target(
            name: "Utils",
            dependencies: [],
            path: "Sources/Utils"
        ),
        .target(
            name: "Templates",
            path: "Sources/Templates",
            resources: [
                .process("README.md")
            ]
        ),
        .testTarget(
            name: "prettymdTests",
            dependencies: ["App", "Core", "AIClient", "Utils"]
        ),
    ]
)

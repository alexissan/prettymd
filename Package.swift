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
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.20.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                "Core",
                "AIClient",
                "Utils",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/App"
        ),
        .target(
            name: "Core",
            dependencies: ["Utils", "AIClient"],
            path: "Sources/Core"
        ),
        .target(
            name: "AIClient",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            path: "Sources/AIClient"
        ),
        .target(
            name: "Utils",
            dependencies: [],
            path: "Sources/Utils"
        ),
        .testTarget(
            name: "prettymdTests",
            dependencies: ["App", "Core", "AIClient", "Utils"]
        ),
    ]
)

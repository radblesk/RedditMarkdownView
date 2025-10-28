// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RedditMarkdownView",
    platforms: [
        .iOS("26.0"),
        .macOS(.v13),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RedditMarkdownView",
            targets: ["RedditMarkdownView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.6.1"),
        .package(url: "https://github.com/raspu/Highlightr", from: "2.3.0"),
        .package(url: "https://github.com/kean/Nuke", from: "12.1.6"),
        .package(url: "https://github.com/ryohey/Zoomable.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "snudown"),
        .target(
            name: "RedditMarkdownView",
            dependencies: ["snudown", "SwiftSoup", "Highlightr", "Nuke", "Zoomable"]
        ),
        .testTarget(
            name: "RedditMarkdownViewTests",
            dependencies: ["RedditMarkdownView", "snudown"])
    ]
)

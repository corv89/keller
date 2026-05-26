// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "cellar",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/rensbreur/SwiftTUI", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "cellar",
            dependencies: [
                "SwiftTUI",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "cellarTests",
            dependencies: ["cellar"],
            resources: [.copy("Fixtures")]
        ),
    ]
)

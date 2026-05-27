// swift-tools-version: 6.0
import PackageDescription

let package = Package(
            name: "keller",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "SwiftTUI", path: "Vendor/SwiftTUI"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
    name: "keller",
            dependencies: [
                "SwiftTUI",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "kellerTests",
            dependencies: ["keller"],
            resources: [.copy("Fixtures")]
        ),
    ]
)

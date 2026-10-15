// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftIntelligence",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "SwiftIntelligence", targets: ["SwiftIntelligence"])
    ],
    targets: [
        .target(
            name: "SwiftIntelligence",
            path: "Sources/SwiftIntelligence"
        ),
        .testTarget(
            name: "SwiftIntelligenceTests",
            dependencies: ["SwiftIntelligence"]
        )
    ]
)

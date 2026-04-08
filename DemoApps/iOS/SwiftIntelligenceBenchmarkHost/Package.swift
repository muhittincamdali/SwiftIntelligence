// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceBenchmarkHost",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "SwiftIntelligenceBenchmarkHost",
            targets: ["SwiftIntelligenceBenchmarkHost"]
        )
    ],
    dependencies: [
        .package(path: "../../..")
    ],
    targets: [
        .executableTarget(
            name: "SwiftIntelligenceBenchmarkHost",
            dependencies: [
                .product(name: "SwiftIntelligenceBenchmarks", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence")
            ],
            path: "Sources"
        )
    ]
)

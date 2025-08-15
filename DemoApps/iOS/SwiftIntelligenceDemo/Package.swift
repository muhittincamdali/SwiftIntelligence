// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceDemo",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "SwiftIntelligenceDemo", targets: ["SwiftIntelligenceDemo"])
    ],
    dependencies: [
        .package(path: "../../..")
    ],
    targets: [
        .executableTarget(
            name: "SwiftIntelligenceDemo",
            dependencies: [
                .product(name: "SwiftIntelligence", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceML", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceReasoning", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceImageGeneration", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNetwork", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceCache", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceMetrics", package: "SwiftIntelligence")
            ],
            path: "Sources"
        )
    ]
)
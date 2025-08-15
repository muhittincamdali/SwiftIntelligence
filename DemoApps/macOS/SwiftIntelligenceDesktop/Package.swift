// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceDesktop",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SwiftIntelligenceDesktop", targets: ["SwiftIntelligenceDesktop"])
    ],
    dependencies: [
        .package(path: "../../..")
    ],
    targets: [
        .executableTarget(
            name: "SwiftIntelligenceDesktop",
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
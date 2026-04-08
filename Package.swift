// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligence",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        // Core modules
        .library(
            name: "SwiftIntelligenceCore",
            targets: ["SwiftIntelligenceCore"]
        ),
        .library(
            name: "SwiftIntelligenceML",
            targets: ["SwiftIntelligenceML"]
        ),
        .library(
            name: "SwiftIntelligenceNLP",
            targets: ["SwiftIntelligenceNLP"]
        ),
        .library(
            name: "SwiftIntelligenceVision",
            targets: ["SwiftIntelligenceVision"]
        ),
        .library(
            name: "SwiftIntelligenceSpeech",
            targets: ["SwiftIntelligenceSpeech"]
        ),
        
        // Advanced modules
        .library(
            name: "SwiftIntelligenceReasoning",
            targets: ["SwiftIntelligenceReasoning"]
        ),
        .library(
            name: "SwiftIntelligencePrivacy",
            targets: ["SwiftIntelligencePrivacy"]
        ),
        
        // Infrastructure modules
        .library(
            name: "SwiftIntelligenceNetwork",
            targets: ["SwiftIntelligenceNetwork"]
        ),
        .library(
            name: "SwiftIntelligenceCache",
            targets: ["SwiftIntelligenceCache"]
        ),
        .library(
            name: "SwiftIntelligenceMetrics",
            targets: ["SwiftIntelligenceMetrics"]
        ),
        
        // Performance and Testing
        .library(
            name: "SwiftIntelligenceBenchmarks",
            targets: ["SwiftIntelligenceBenchmarks"]
        ),
        .executable(
            name: "Benchmarks",
            targets: ["Benchmarks"]
        )
    ],
    dependencies: [
        // Using only Apple's native frameworks, no external dependencies
    ],
    targets: [
        // MARK: - Core Module
        .target(
            name: "SwiftIntelligenceCore",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - AI/ML Modules
        .target(
            name: "SwiftIntelligenceML",
            dependencies: ["SwiftIntelligenceCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceNLP",
            dependencies: ["SwiftIntelligenceCore", "SwiftIntelligenceML"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceVision",
            dependencies: ["SwiftIntelligenceCore", "SwiftIntelligenceML"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceSpeech",
            dependencies: ["SwiftIntelligenceCore", "SwiftIntelligenceNLP"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "SwiftIntelligenceReasoning",
            dependencies: ["SwiftIntelligenceCore", "SwiftIntelligenceML"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - Infrastructure Modules
        .target(
            name: "SwiftIntelligencePrivacy",
            dependencies: ["SwiftIntelligenceCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceNetwork",
            dependencies: ["SwiftIntelligenceCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceCache",
            dependencies: ["SwiftIntelligenceCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceMetrics",
            dependencies: ["SwiftIntelligenceCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        .target(
            name: "SwiftIntelligenceBenchmarks",
            dependencies: ["SwiftIntelligenceCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .executableTarget(
            name: "Benchmarks",
            dependencies: ["SwiftIntelligenceBenchmarks"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - Test Targets
        .testTarget(
            name: "SwiftIntelligenceCoreTests",
            dependencies: ["SwiftIntelligenceCore"]
        ),
        
        .testTarget(
            name: "SwiftIntelligenceMLTests",
            dependencies: ["SwiftIntelligenceML"]
        ),
        
        .testTarget(
            name: "SwiftIntelligenceNLPTests",
            dependencies: ["SwiftIntelligenceNLP"]
        ),
        
        .testTarget(
            name: "SwiftIntelligenceVisionTests",
            dependencies: ["SwiftIntelligenceVision"]
        ),
        
        .testTarget(
            name: "SwiftIntelligenceSpeechTests",
            dependencies: ["SwiftIntelligenceSpeech"]
        ),

        .testTarget(
            name: "SwiftIntelligenceBenchmarksDeviceTests",
            dependencies: ["SwiftIntelligenceBenchmarks"]
        )
    ]
)

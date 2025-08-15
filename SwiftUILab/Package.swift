// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftUILab",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        // Core Components Library
        .library(
            name: "SwiftUILab",
            targets: ["SwiftUILab"]
        ),
        
        // Component Categories
        .library(
            name: "SwiftUILabButtons",
            targets: ["SwiftUILabButtons"]
        ),
        .library(
            name: "SwiftUILabInputs",
            targets: ["SwiftUILabInputs"]
        ),
        .library(
            name: "SwiftUILabCards",
            targets: ["SwiftUILabCards"]
        ),
        .library(
            name: "SwiftUILabCharts",
            targets: ["SwiftUILabCharts"]
        ),
        .library(
            name: "SwiftUILabNavigation",
            targets: ["SwiftUILabNavigation"]
        ),
        .library(
            name: "SwiftUILabAnimations",
            targets: ["SwiftUILabAnimations"]
        ),
        .library(
            name: "SwiftUILabLayouts",
            targets: ["SwiftUILabLayouts"]
        ),
        .library(
            name: "SwiftUILabForms",
            targets: ["SwiftUILabForms"]
        ),
        .library(
            name: "SwiftUILabModals",
            targets: ["SwiftUILabModals"]
        ),
        .library(
            name: "SwiftUILabLists",
            targets: ["SwiftUILabLists"]
        ),
        .library(
            name: "SwiftUILabMedia",
            targets: ["SwiftUILabMedia"]
        ),
        .library(
            name: "SwiftUILabEffects",
            targets: ["SwiftUILabEffects"]
        )
    ],
    dependencies: [
        // SwiftIntelligence Integration for AI-powered components
        .package(path: "../")
    ],
    targets: [
        // Main target
        .target(
            name: "SwiftUILab",
            dependencies: [
                "SwiftUILabButtons",
                "SwiftUILabInputs",
                "SwiftUILabCards",
                "SwiftUILabCharts",
                "SwiftUILabNavigation",
                "SwiftUILabAnimations",
                "SwiftUILabLayouts",
                "SwiftUILabForms",
                "SwiftUILabModals",
                "SwiftUILabLists",
                "SwiftUILabMedia",
                "SwiftUILabEffects"
            ],
            path: "Sources/SwiftUILab"
        ),
        
        // Component Categories (120+ components total)
        
        // Buttons & Actions (10 components)
        .target(
            name: "SwiftUILabButtons",
            dependencies: [],
            path: "Sources/Components/Buttons"
        ),
        
        // Input Controls (10 components)
        .target(
            name: "SwiftUILabInputs",
            dependencies: [],
            path: "Sources/Components/Inputs"
        ),
        
        // Cards & Containers (10 components)
        .target(
            name: "SwiftUILabCards",
            dependencies: [],
            path: "Sources/Components/Cards"
        ),
        
        // Charts & Graphs (10 components)
        .target(
            name: "SwiftUILabCharts",
            dependencies: [],
            path: "Sources/Components/Charts"
        ),
        
        // Navigation Components (10 components)
        .target(
            name: "SwiftUILabNavigation",
            dependencies: [],
            path: "Sources/Components/Navigation"
        ),
        
        // Animation Components (10 components)
        .target(
            name: "SwiftUILabAnimations",
            dependencies: [],
            path: "Sources/Components/Animations"
        ),
        
        // Layout Components (10 components)
        .target(
            name: "SwiftUILabLayouts",
            dependencies: [],
            path: "Sources/Components/Layouts"
        ),
        
        // Form Components (10 components)
        .target(
            name: "SwiftUILabForms",
            dependencies: [],
            path: "Sources/Components/Forms"
        ),
        
        // Modal & Sheet Components (10 components)
        .target(
            name: "SwiftUILabModals",
            dependencies: [],
            path: "Sources/Components/Modals"
        ),
        
        // List & Collection Components (10 components)
        .target(
            name: "SwiftUILabLists",
            dependencies: [],
            path: "Sources/Components/Lists"
        ),
        
        // Media Components (10 components)
        .target(
            name: "SwiftUILabMedia",
            dependencies: [],
            path: "Sources/Components/Media"
        ),
        
        // Visual Effects (10 components)
        .target(
            name: "SwiftUILabEffects",
            dependencies: [],
            path: "Sources/Components/Effects"
        ),
        
        // Tests
        .testTarget(
            name: "SwiftUILabTests",
            dependencies: ["SwiftUILab"]
        )
    ]
)
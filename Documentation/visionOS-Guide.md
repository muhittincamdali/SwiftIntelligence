# visionOS Guide

This guide reflects the active package graph.

## Current Status

`SwiftIntelligence` currently supports `visionOS` as a package platform in the main package manifest.

What is active today:

- `SwiftIntelligenceVision` can be consumed on `visionOS`
- the package manifest declares `visionOS(.v1)`
- modular imports are the supported integration path

What is not active today:

- a restored public umbrella product named `SwiftIntelligence`
- a separate shipping `SwiftIntelligenceVisionOS` product in the active package graph

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittinc/SwiftIntelligence.git", from: "1.2.1")
]
```

Example target:

```swift
target(
    name: "MyVisionOSApp",
    dependencies: [
        .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
        .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence")
    ]
)
```

## Basic Integration

```swift
import SwiftUI
import SwiftIntelligenceCore
import SwiftIntelligenceVision

@MainActor
final class VisionViewModel: ObservableObject {
    private let engine = VisionEngine.shared

    func start() async throws {
        SwiftIntelligenceCore.shared.configure(with: .production)
        try await engine.initialize()
    }

    func stop() async {
        await engine.shutdown()
    }
}
```

## Recommended Usage Pattern

- configure `SwiftIntelligenceCore` once
- initialize `VisionEngine` when the vision feature starts
- shut the engine down when the feature ends
- prefer modular imports over umbrella imports

## Spatial UI Boundary

This repository does not currently expose a stable, active public abstraction for:

- immersive space orchestration
- RealityKit scene composition
- gesture systems
- spatial window management

Those concerns belong in the host app until a dedicated, active `visionOS` product is restored to the package graph.

## Recommended Near-Term Scope

Use SwiftIntelligence on `visionOS` today for:

- image classification
- object detection
- OCR
- segmentation
- image enhancement

Do not build product plans around inactive umbrella APIs or legacy `SwiftIntelligenceVisionOS` assumptions.

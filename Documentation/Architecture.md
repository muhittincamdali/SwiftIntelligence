# SwiftIntelligence Architecture

This document describes the current modular architecture, not the historical umbrella design.

## Design Goal

SwiftIntelligence is organized as a set of focused modules rather than a single catch-all framework. The active package graph prioritizes:

- explicit adoption
- smaller public surface area
- easier Swift 6 concurrency migration
- testable module boundaries
- on-device execution using Apple-native frameworks

## Active Module Graph

```text
SwiftIntelligenceCore
├── SwiftIntelligenceML
├── SwiftIntelligenceNLP
├── SwiftIntelligenceVision
├── SwiftIntelligenceSpeech
├── SwiftIntelligenceReasoning
├── SwiftIntelligencePrivacy
├── SwiftIntelligenceNetwork
├── SwiftIntelligenceCache
├── SwiftIntelligenceMetrics
└── SwiftIntelligenceBenchmarks
```

Practical runtime dependencies today:

- `SwiftIntelligenceNLP` depends on `Core` and `ML`
- `SwiftIntelligenceVision` depends on `Core` and `ML`
- `SwiftIntelligenceSpeech` depends on `Core` and `NLP`
- `SwiftIntelligencePrivacy` depends on `Core`

## Layering

### 1. Foundation Layer

Apple frameworks do the heavy lifting:

- Vision
- NaturalLanguage
- Speech
- AVFoundation
- Core ML
- CryptoKit

### 2. Core Layer

`SwiftIntelligenceCore` centralizes:

- configuration
- logging
- performance monitoring
- error handling

This is the shared runtime spine for the rest of the graph.

### 3. Capability Layers

Each capability module exposes a focused entry point:

- `NLPEngine.shared`
- `VisionEngine.shared`
- `SpeechEngine.shared`
- `SwiftIntelligenceML`
- `SwiftIntelligencePrivacy`

This keeps ownership clear and prevents a monolithic orchestration layer from becoming a dumping ground.

### 4. Support Layers

The remaining modules exist to support scaling and proof:

- `Reasoning`
- `Network`
- `Cache`
- `Metrics`
- `Benchmarks`

## Runtime Patterns

### Shared Configuration

The current repo uses `SwiftIntelligenceCore.shared.configure(with:)` as the common setup point.

Typical presets:

- `.development`
- `.production`
- `.testing`

### Main-Actor Engines

Some engines are `@MainActor` because they coordinate framework objects with thread-affinity constraints or observable UI state:

- `NLPEngine`
- `VisionEngine`
- `SpeechEngine`
- `SwiftIntelligenceCore`

### Actor-Isolated Workloads

Workloads that benefit from isolated mutable state use actors:

- `SwiftIntelligenceML`
- `SwiftIntelligencePrivacy`

This split is intentional: UI-leaning engines stay predictable on the main actor, while stateful backend-style services use actor isolation.

## Caching Strategy

The architecture currently uses local caches inside modules rather than a global cache bus:

- `NLPEngine` uses `NSCache`
- `VisionEngine` caches images and result wrappers
- `SpeechEngine` caches recognition and voice artifacts
- `SwiftIntelligenceML` caches inference results inside the actor

This keeps cache invalidation close to feature logic, at the cost of some duplication.

## Performance Strategy

The repo’s current performance stance is pragmatic:

- sequential correctness first
- benchmark-backed claims second
- parallelization only where it does not create Swift 6 concurrency drift

That is why parts of the codebase intentionally moved from task groups back to predictable sequential loops during stabilization.

## Concurrency Strategy

The active migration rule is simple:

- prefer safe ownership boundaries over opportunistic parallelism
- remove callback-driven mutation when direct request execution is enough
- use `sending` where ownership transfer is the real fix
- accept sequential fallback if it removes unsafe task-group or closure-capture patterns

This keeps the package viable while Swift 6 hardening continues.

## Documentation Boundary

Historical references to:

- umbrella `IntelligenceEngine`
- non-active products
- speculative distributed orchestration

are no longer architecture truth. Treat them as legacy until explicitly restored to the package graph.

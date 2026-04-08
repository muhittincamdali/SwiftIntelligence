# SwiftIntelligenceVision vs Apple Vision

Last updated: 2026-04-07

This page answers one adoption question:

**When should an Apple developer stay on raw `Vision` requests, and when is `SwiftIntelligenceVision` the better workflow layer?**

## Short Answer

Choose raw `Vision` when:

- you need one request type such as OCR or classification
- you want the tightest possible control over request configuration and scheduling
- you do not need a shared package abstraction

Choose `SwiftIntelligenceVision` when:

- you need multiple vision capabilities behind one maintained module
- OCR, classification, or detection need to continue into `NLP` or `Privacy`
- your team wants a cleaner package-level API than multiple request handlers and result-mapping layers

## Side-by-Side

| Concern | Raw `Vision` | `SwiftIntelligenceVision` |
| --- | --- | --- |
| Setup | create requests and handlers per use case | initialize `VisionEngine` once |
| OCR + classification + detection | multiple request pipelines | one engine with dedicated methods |
| Caching and shared lifecycle | app-specific | handled in the maintained module |
| Cross-module chaining | app-specific glue code | designed to feed into `NLP`, `Privacy`, and metrics surfaces |
| Lowest-level request control | stronger | weaker |
| Narrow single-feature screen | often better | often unnecessary |

## Code Shape

Raw `Vision` often starts with request-specific handlers:

```swift
import Vision

let request = VNRecognizeTextRequest()
let handler = VNImageRequestHandler(cgImage: image)
try handler.perform([request])
```

`SwiftIntelligenceVision` compresses the maintained multi-step path into one engine:

```swift
import SwiftIntelligenceVision

let engine = VisionEngine.shared
try await engine.initialize()
defer { Task { await engine.shutdown() } }

let classification = try await engine.classifyImage(image, options: .default)
let document = try await engine.analyzeDocument(image, options: .default)
```

## Migration Heuristic

Stay on raw `Vision` if your codebase looks like this:

- one narrow feature
- a small number of request types
- no need for package-level reuse across teams or products

Move to `SwiftIntelligenceVision` if your codebase is accumulating:

- repeated request-handler boilerplate
- repeated output normalization
- multiple vision features that need one lifecycle surface
- OCR output that immediately feeds NLP or privacy-aware post-processing

## Current Proof

What is proven today:

- repo-level proof posture is `release-grade` at the `Mac + iPhone` policy floor
- multi-step `Vision -> NLP -> Privacy` flow is showcased in [../Showcase.md](../Showcase.md)
- example validation runs through `bash Scripts/validate-examples.sh`

What is not yet proven:

- raw single-feature performance leadership over direct `Vision` requests
- stronger public demo quality than Apple’s flagship showcase repos

## Best-Fit Decision

Use raw `Vision` if you want per-request control with minimal abstraction.

Use `SwiftIntelligenceVision` if you want a maintained workflow layer that reduces orchestration code and makes multi-step Apple-native pipelines easier to ship.

## Sources

- [Apple Vision docs](https://developer.apple.com/documentation/vision)
- [Vision Comparison](Vision.md)
- [Showcase](../Showcase.md)
- [Getting Started](../Getting-Started.md)

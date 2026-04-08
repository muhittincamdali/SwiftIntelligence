# IntelligentCamera Demo Guide

This is the flagship first-run flow for SwiftIntelligence.

## What It Proves

- `Vision` classifies the sample frame and extracts OCR text
- `NLP` turns extracted text into a short summary
- `Privacy` tokenizes sensitive text before previewing it
- the package graph composes cleanly across multiple modules instead of a single wrapper

## Required Products

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Open This File

- [IntelligentCameraApp.swift](IntelligentCameraApp.swift)

## Fastest Run Path

1. Create a new Apple app target in Xcode with SwiftUI enabled.
2. Add the four required package products from this repo.
3. Replace the default app entry file with [IntelligentCameraApp.swift](IntelligentCameraApp.swift).
4. Run on `macOS 14+` or `iOS 17+`.
5. Tap `Analyze Frame`.

This is the fastest real app-level proof path in the repo. It does not depend on private services or external model downloads.

## What Success Looks Like

- `Status` ends with `Vision -> NLP -> Privacy zinciri tamamlandi`
- `Top labels` is not empty
- `OCR` shows the sample invoice and meeting text
- `Summary` is generated from OCR output
- `Privacy preview` contains tokenized output, not raw text

## Platform Notes

- `macOS` is the fastest local maintainer path
- `iOS` is the strongest product-facing path
- no simulator-only claim should be used as mobile release evidence
- no external backend is required for this flow

## Failure Signals

- empty `Top labels` usually means the vision pipeline did not initialize cleanly
- empty `OCR` means document analysis did not extract the sample text
- empty `Privacy preview` after OCR success means the privacy tokenization step did not run
- `Basarisiz` status means the thrown error should be inspected before making any public claim

## Local Verification

```bash
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

## Shareable Demo Pack

Use this pack when preparing a release post, short demo recording, or evaluator handoff:

- [Generated Flagship Demo Pack](../../../Documentation/Generated/Flagship-Demo-Pack.md)
- [Canonical Media Location](../../../Documentation/Assets/Flagship-Demo/README.md)
- [Published Screenshot](../../../Documentation/Assets/Flagship-Demo/intelligent-camera-success.png)
- [Published Recording](../../../Documentation/Assets/Flagship-Demo/intelligent-camera-run.mp4)
- [Published Caption](../../../Documentation/Assets/Flagship-Demo/caption.txt)
- immutable release asset: `flagship-demo-share-pack.tar.gz`
- published assets already show `Top labels`, `OCR`, `Summary`, and `Privacy preview` together
- the published recording covers app launch to `Analyze Frame` success

## Related Docs

- [Getting Started](../../../Documentation/Getting-Started.md#five-minute-success-path)
- [Showcase](../../../Documentation/Showcase.md)
- [Examples Status](../../README.md)

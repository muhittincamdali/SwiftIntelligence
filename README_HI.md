# SwiftIntelligence

> हिन्दी | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Apple platforms ke liye modular on-device AI toolkit. Yeh `Vision`, `NaturalLanguage`, `Speech` aur `Privacy` ko ek practical product flow me jodta hai.

## Current status

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Strongest path: `Vision -> NLP -> Privacy`
- Public proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Yahin se shuru karein

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Installation

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.2")
```

Recommended entry path:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Local validation

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

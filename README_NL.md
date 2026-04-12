# SwiftIntelligence

> Nederlands | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Een modulaire on-device AI toolkit voor Apple-platformen. Verbindt `Vision`, `NaturalLanguage`, `Speech` en `Privacy` in een echte productflow.

## Huidige status

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Sterkste pad: `Vision -> NLP -> Privacy`
- Publieke bewijslaag: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Start hier

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Installatie

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.0")
```

Aanbevolen startpad:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Lokale validatie

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

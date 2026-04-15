# SwiftIntelligence

> Deutsch | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Ein modulares On-Device-AI-Toolkit fuer Apple-Plattformen. Es verbindet `Vision`, `NaturalLanguage`, `Speech` und `Privacy` in einem nachvollziehbaren Produktpfad.

## Aktueller Stand

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Staerkster Pfad: `Vision -> NLP -> Privacy`
- Oeffentliche Nachweisflaeche: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Hier anfangen

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Installation

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.1")
```

Empfohlener Einstieg:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Lokale Validierung

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

# SwiftIntelligence

> Polski | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

Modularny toolkit AI on-device dla platform Apple. Laczy `Vision`, `NaturalLanguage`, `Speech` i `Privacy` w jeden realny przeplyw produktu.

## Obecny stan

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Najsilniejsza sciezka: `Vision -> NLP -> Privacy`
- Publiczny proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Zacznij tutaj

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Instalacja

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.0")
```

Zalecana sciezka startowa:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Walidacja lokalna

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

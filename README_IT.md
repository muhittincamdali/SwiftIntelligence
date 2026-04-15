# SwiftIntelligence

> Italiano | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Toolkit AI modulare on-device per piattaforme Apple. Collega `Vision`, `NaturalLanguage`, `Speech` e `Privacy` in un percorso di prodotto reale.

## Stato attuale

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Percorso piu forte: `Vision -> NLP -> Privacy`
- Superficie pubblica di prova: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Inizia da qui

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Installazione

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.1")
```

Percorso consigliato:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Verifica locale

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

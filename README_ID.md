# SwiftIntelligence

> Bahasa Indonesia | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Toolkit AI modular on-device untuk platform Apple. Dirancang untuk menggabungkan `Vision`, `NaturalLanguage`, `Speech`, dan `Privacy` dalam satu alur kerja yang nyata.

## Status saat ini

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Jalur terkuat: `Vision -> NLP -> Privacy`
- Bukti publik: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Mulai dari sini

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Instalasi

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.1")
```

Jalur awal yang disarankan:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Validasi lokal

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

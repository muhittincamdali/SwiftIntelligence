# SwiftIntelligence

> Turkce | [English](README.md) | [README Languages](Documentation/README-Languages.md)

> Localization note: `README.md` remains the canonical and most complete README surface.

Apple platformlari icin modular, privacy-first, on-device AI toolkit. `Vision`, `NaturalLanguage`, `Speech`, benchmark ve release proof yuzeylerini tek urun akisinda birlestirir.

## Hizli Durum

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- En guclu yol: `Vision -> NLP -> Privacy`
- Flagship demo: [IntelligentCamera](Examples/DemoApps/IntelligentCamera/README.md)
- Public trust surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Ne Icin Uygun

- birden fazla Apple-native AI capability ayni uygulama akisinda lazimsa
- demo, benchmark ve release proof yuzeyi birlikte gerekiyorsa
- raw Apple framework glue code'unu azaltmak istiyorsan

## Ne Icin Uygun Degil

- low-level runtime veya Python-first tooling ariyorsan
- tek bir raw Apple API zaten problemini cozuyorsa
- speech-only veya LLM-only specialist package istiyorsan

## Baslangic

- [5-Minute Success Path](Documentation/Getting-Started.md#five-minute-success-path)
- [Documentation Hub](Documentation/README.md)
- [Competitive Matrix](Documentation/Comparisons/Competitive-Matrix.md)
- [Showcase](Documentation/Showcase.md)
- [Trust Start](Documentation/Trust-Start.md)

## Onerilen Kurulum

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.1")
```

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Lokal Dogrulama

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
bash Scripts/prepare-release.sh
```

## Diger Diller

- [README Languages](Documentation/README-Languages.md)
- [English README](README.md)

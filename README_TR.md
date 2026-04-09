<div align="center">
  <img src="Documentation/Assets/Readme/swiftintelligence-hero.svg" width="100%" alt="SwiftIntelligence hero banner" />
</div>

<div align="center">

[![Turkce](https://img.shields.io/badge/Dil-Turkce-F05138?style=for-the-badge&labelColor=0D1117)](README_TR.md)
[![English](https://img.shields.io/badge/Language-English-0A84FF?style=for-the-badge&labelColor=0D1117)](README.md)
[![Release](https://img.shields.io/github/v/release/muhittincamdali/SwiftIntelligence?display_name=tag&style=for-the-badge&logo=github)](https://github.com/muhittincamdali/SwiftIntelligence/releases)
[![Publish Readiness](https://img.shields.io/badge/Publish%20Readiness-ready-34C759?style=for-the-badge)](Documentation/Generated/Benchmark-Readiness.md)
[![Proof Posture](https://img.shields.io/badge/Proof%20Posture-release--grade-FF9F0A?style=for-the-badge)](Documentation/Generated/Public-Proof-Status.md)
[![Showcase Media](https://img.shields.io/badge/Showcase%20Media-published-BF5AF2?style=for-the-badge)](Documentation/Assets/Flagship-Demo/README.md)

<br />

[![Baslangic](https://img.shields.io/badge/Ilk%20Adim-5%20Dakika%20Basari%20Yolu-F05138?style=for-the-badge&labelColor=0D1117)](Documentation/Getting-Started.md#five-minute-success-path)
[![Flagship Demo](https://img.shields.io/badge/Flagship%20Demo-IntelligentCamera-0A84FF?style=for-the-badge&labelColor=0D1117)](Examples/DemoApps/IntelligentCamera/README.md)
[![Required Devices](https://img.shields.io/badge/Required%20Devices-Mac%20%2B%20iPhone-5AC8FA?style=for-the-badge&labelColor=0D1117)](Documentation/Generated/Release-Benchmark-Matrix.md)
[![README Languages](https://img.shields.io/badge/README%20Languages-18-111827?style=for-the-badge&labelColor=0D1117)](Documentation/README-Languages.md)
[![License](https://img.shields.io/badge/License-MIT-1F2937?style=for-the-badge&labelColor=0D1117)](LICENSE)

</div>

<p align="center">
  <strong>SwiftIntelligence</strong>, Apple gelistiricileri icin
  <code>Vision</code>, <code>NaturalLanguage</code>, <code>Speech</code>, privacy controls,
  benchmarks ve release proof yuzeylerini tek bir urun hikayesinde birlestiren modular bir on-device AI toolkit'tir.
</p>

<p align="center">
  Bu repo generic cross-platform inference runtime degildir. Apple-native bir developer toolkit'tir:
  daha hizli entegrasyon, daha net benchmarking ve daha durust public claim yuzeyi icin tasarlandi.
</p>

<p align="center">
  <code>iOS 17+</code>
  <code>macOS 14+</code>
  <code>tvOS 17+</code>
  <code>watchOS 10+</code>
  <code>visionOS 1+</code>
  <code>Mac + iPhone release floor</code>
</p>

<p align="center">
  <a href="README.md">English README</a> •
  <a href="Documentation/README-Languages.md">README Languages</a> •
  <a href="Documentation/Getting-Started.md">Getting Started</a> •
  <a href="Documentation/Comparisons/README.md">Comparisons</a> •
  <a href="Documentation/Positioning.md">Positioning</a> •
  <a href="Documentation/Showcase.md">Showcase</a> •
  <a href="Documentation/Generated/Public-Proof-Status.md">Public Proof Status</a>
</p>

<p align="center">
  Diller:
  <a href="README.md">EN</a> •
  <a href="README_AR.md">AR</a> •
  <a href="README_DE.md">DE</a> •
  <a href="README_ES.md">ES</a> •
  <a href="README_FR.md">FR</a> •
  <a href="README_HI.md">HI</a> •
  <a href="README_ID.md">ID</a> •
  <a href="README_IT.md">IT</a> •
  <a href="README_JA.md">JA</a> •
  <a href="README_KO.md">KO</a> •
  <a href="README_NL.md">NL</a> •
  <a href="README_PL.md">PL</a> •
  <a href="README_PT-BR.md">PT-BR</a> •
  <a href="README_RU.md">RU</a> •
  <a href="README_TR.md">TR</a> •
  <a href="README_UK.md">UK</a> •
  <a href="README_VI.md">VI</a> •
  <a href="README_ZH-CN.md">ZH-CN</a>
</p>

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Neden Daha Guclu?

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>Apple-Native</h3>
      <p><code>Vision</code>, <code>NaturalLanguage</code>, <code>Speech</code>, <code>Core ML</code> ve privacy-aware akislari merkeze alir. Apple API'lerini anlamsiz bir abstraction altina saklamaz.</p>
    </td>
    <td width="33%" valign="top">
      <h3>Kanit Odakli</h3>
      <p>Public claim'ler generated proof surfaces, immutable release bundle'lar, benchmark artifact'lari ve acik device policy ile baglidir.</p>
    </td>
    <td width="33%" valign="top">
      <h3>Modular Uygulama Yuzeyi</h3>
      <p>Gereken modulleri secerek alirsin. Binary surface daha kontrollu kalir, ilk degerlendirme de maintained flagship path uzerinden yapilir.</p>
    </td>
  </tr>
</table>

## Hizli Gercek Durum

| Sinyal | Mevcut durum |
| --- | --- |
| Kategori | Apple platformlari icin modular on-device AI toolkit |
| En guclu path | `Vision -> NLP -> Privacy` |
| Flagship demo | [`IntelligentCamera`](Examples/DemoApps/IntelligentCamera/README.md) |
| Publish readiness | `ready` |
| Distribution posture | `release-grade` |
| Required release floor | `Mac + iPhone` |
| Flagship media | `published` |
| Public proof | [`Public-Proof-Status.md`](Documentation/Generated/Public-Proof-Status.md) |

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Urun Yuzeyi

<p align="center">
  <img src="Documentation/Assets/Readme/swiftintelligence-capability-board.svg" width="100%" alt="SwiftIntelligence capability board" />
</p>

| Hat | Ne saglar | Ilk guclu link |
| --- | --- | --- |
| Vision | Classification, OCR, detection, segmentation, enhancement | [IntelligentCamera](Examples/DemoApps/IntelligentCamera/README.md) |
| NaturalLanguage | Summary, entities, keywords, topics, language-aware analysis | [NLP vs NaturalLanguage](Documentation/Comparisons/NLP-vs-NaturalLanguage.md) |
| Speech | Voice output ve assistant-style akislar | [Speech vs Apple Speech](Documentation/Comparisons/Speech-vs-AppleSpeech.md) |
| Privacy | Tokenization, anonymization, daha guvenli AI boundaries | [Privacy vs CryptoKit + Security](Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md) |
| Benchmarks | Threshold, history, manifest, regression validation | [Benchmark Baselines](Documentation/Benchmark-Baselines.md) |
| Release Proof | Public proof status, blockers, immutable release bundle | [Latest Release Proof](Documentation/Generated/Latest-Release-Proof.md) |

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Flagship Deneyim

<p align="center">
  <a href="Examples/DemoApps/IntelligentCamera/README.md">
    <img src="Documentation/Assets/Flagship-Demo/intelligent-camera-success.png" width="100%" alt="SwiftIntelligence IntelligentCamera demo screenshot" />
  </a>
</p>

<p align="center">
  Gercek repo-native flagship media.
  <a href="Documentation/Assets/Flagship-Demo/intelligent-camera-run.mp4">Recording</a> •
  <a href="Documentation/Assets/Flagship-Demo/caption.txt">Caption</a> •
  <a href="Documentation/Assets/Flagship-Demo/README.md">Media policy</a>
</p>

`IntelligentCamera`, bu repo icin en hizli ve en durust deger testi.

- `SwiftIntelligenceVision` ile classification, OCR ve detection
- `SwiftIntelligenceNLP` ile summary
- `SwiftIntelligencePrivacy` ile tokenized privacy preview
- release ve proof zincirinden kopuk olmayan demo path

Ilk bakman gereken tek sey olacaksa bu olsun:

```bash
bash Scripts/validate-flagship-demo.sh
```

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Mimari Sinyali

<p align="center">
  <img src="Documentation/Assets/Readme/swiftintelligence-architecture-board.svg" width="100%" alt="SwiftIntelligence architecture board" />
</p>

| Katman | Maintain edilen yuzey |
| --- | --- |
| Uygulama akislar | `IntelligentCamera`, `SmartTranslator`, `VoiceAssistant`, yeni flagship demolar |
| Perception | `SwiftIntelligenceVision`, `SwiftIntelligenceML` |
| Language | `SwiftIntelligenceNLP`, `SwiftIntelligenceSpeech`, `SwiftIntelligenceReasoning` |
| Trust ve transport | `SwiftIntelligencePrivacy`, `SwiftIntelligenceNetwork`, `SwiftIntelligenceMetrics`, `SwiftIntelligenceCache` |
| Release operating system | `SwiftIntelligenceBenchmarks`, generated proof docs, release bundle, media pack |

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Nereden Baslamali?

| Hedef | Kurulum | Ilk sayfa |
| --- | --- | --- |
| En guclu urun hikayesini gormek | `Core + Vision + NLP + Privacy` | [5-Minute Success Path](Documentation/Getting-Started.md#five-minute-success-path) |
| Raw Apple NLP ile karsilastirmak | `Core + NLP` | [NLP vs NaturalLanguage](Documentation/Comparisons/NLP-vs-NaturalLanguage.md) |
| Raw Apple Vision ile karsilastirmak | `Core + Vision` | [Vision vs Apple Vision](Documentation/Comparisons/Vision-vs-AppleVision.md) |
| Privacy kontrol katmani eklemek | `Privacy + protected feature module` | [Privacy vs CryptoKit + Security](Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md) |
| Public claim dogrulamak | none | [Public Proof Status](Documentation/Generated/Public-Proof-Status.md) |
| Performance posture incelemek | `Benchmarks` | [Benchmark Baselines](Documentation/Benchmark-Baselines.md) |

> Birden fazla Apple framework'unu tek akista birlestirmek istiyorsan SwiftIntelligence kullan.
> Sadece tek bir low-level Apple API cagrisi istiyorsan raw API yeterli olabilir.

## Kimler Icin?

- Apple platformlarinda on-device feature gelistiren ekipler
- `Vision`, `NaturalLanguage`, `Speech` ve privacy-sensitive data akisini birlikte yonetmek isteyenler
- benchmark, release discipline ve proof surfaces'e onem veren maintainers

## Kimler Icin Degil?

- cross-platform inference runtime arayanlar
- Python-first training, quantization veya model conversion odakli ekipler
- sadece tek bir Apple framework API cagrisi isteyen ve package layer istemeyenler

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## En Guclu Kurulum Yolu

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.0")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
            .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
            .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
            .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
        ]
    )
]
```

Sonra repo'yu public docs ile ayni cizgide dogrula:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

## Modul Yuzeyi

<details open>
<summary><strong>Ana moduller</strong></summary>

| Modul | Rol |
| --- | --- |
| `SwiftIntelligenceCore` | Shared configuration, logging, runtime utilities |
| `SwiftIntelligenceML` | On-device training, prediction, evaluation, cache management |
| `SwiftIntelligenceNLP` | Sentiment, entities, keywords, summaries, topics |
| `SwiftIntelligenceVision` | Classification, detection, OCR, segmentation, enhancement |
| `SwiftIntelligenceSpeech` | Speech-related types, synthesis, voice catalogs |
| `SwiftIntelligencePrivacy` | Tokenization, anonymization, secure storage, compliance helpers |
| `SwiftIntelligenceReasoning` | Higher-level reasoning primitives |
| `SwiftIntelligenceNetwork` | Network-layer helpers |
| `SwiftIntelligenceCache` | Cache primitives |
| `SwiftIntelligenceMetrics` | Metrics and observability support |
| `SwiftIntelligenceBenchmarks` | Benchmark runners, artifacts, thresholds, baselines |

</details>

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Proof Yuzeyi

Bu repoda README dili, release dili ve proof dili birbirinden kopmamasi icin tasarlandi.

| Neyi dogrulamak istiyorsun? | Baslangic |
| --- | --- |
| current public claim envelope | [Public Proof Status](Documentation/Generated/Public-Proof-Status.md) |
| immutable release-grade bundle | [Latest Release Proof](Documentation/Generated/Latest-Release-Proof.md) |
| readiness ve required device matrix | [Benchmark Readiness](Documentation/Generated/Benchmark-Readiness.md) |
| release blockers | [Release Blockers](Documentation/Generated/Release-Blockers.md) |
| benchmark gecmisi ve methodology | [Benchmark History](Documentation/Generated/Benchmark-History.md), [Benchmark Methodology](Documentation/Generated/Benchmark-Methodology.md) |
| release evidence flow | [Release Process](Documentation/Release-Process.md) |

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## GitHub Yuzeyi

<p align="center">
  <img src="Documentation/Assets/Readme/swiftintelligence-trust-board.svg" width="100%" alt="SwiftIntelligence trust and distribution board" />
</p>

| Yuzey | Mevcut posture | Link |
| --- | --- | --- |
| About | kategori net, Apple-native scope net | [GitHub Distribution](Documentation/GitHub-Distribution.md) |
| README | landing-page hissi veren, 18 dilli giris yuzeyi | [README Languages](Documentation/README-Languages.md) |
| Releases | immutable proof-linked release assets | [Releases](https://github.com/muhittincamdali/SwiftIntelligence/releases) |
| License | MIT | [LICENSE](LICENSE) |
| Code of Conduct | Contributor Covenant 2.1 | [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) |
| Contributing | yuksek kalite bar'i ve public-claim kurallari | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Security | advisory-first intake | [SECURITY.md](SECURITY.md) |
| Support | issue routing ve maintainer validation floor | [SUPPORT.md](SUPPORT.md) |
| Copilot | repo-level custom instructions | [.github/copilot-instructions.md](.github/copilot-instructions.md) |
| Funding | GitHub Sponsors support path | [.github/FUNDING.yml](.github/FUNDING.yml) |
| Packages | 11 Swift product | [Package.swift](Package.swift) |
| Deployments | public Pages URL yok; repo-native docs ve release assets esas yuzey | [Documentation Index](Documentation/README.md) |

### Destek

- [GitHub Sponsors](https://github.com/sponsors/muhittincamdali)
- [Funding configuration](.github/FUNDING.yml)

### Otomasyon Notu

GitHub-hosted runner'lar su an external account-level billing lock nedeniyle bloklu. Bu nedenle repo icin authoritative quality floor su local gate setidir:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
bash Scripts/prepare-release.sh
```

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Aktivite ve Community

[![Star History Chart](https://api.star-history.com/svg?repos=muhittincamdali/SwiftIntelligence&type=Date)](https://star-history.com/#muhittincamdali/SwiftIntelligence&Date)

[![Contributors](https://contrib.rocks/image?repo=muhittincamdali/SwiftIntelligence)](https://github.com/muhittincamdali/SwiftIntelligence/graphs/contributors)

## Gelistirme

```bash
swift build
bash Scripts/validate-examples.sh
swift test
bash Scripts/prepare-release.sh
```

## Dokumanlar

- [README.md](README.md)
- [Documentation Index](Documentation/README.md)
- [Positioning](Documentation/Positioning.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)
- [Flagship Media](Documentation/Assets/Flagship-Demo/README.md)
- [GitHub Distribution](Documentation/GitHub-Distribution.md)

## Katki

Pull request acmadan once [CONTRIBUTING.md](CONTRIBUTING.md) oku. Security bildirimleri public issue yerine [SECURITY.md](SECURITY.md) uzerinden gitmeli.

## Lisans

SwiftIntelligence, [MIT License](LICENSE) ile dagitilir.

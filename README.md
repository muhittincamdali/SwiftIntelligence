<div align="center">
  <img src="Documentation/Assets/Readme/swiftintelligence-hero.svg" width="100%" alt="SwiftIntelligence hero banner" />
</div>

<div align="center">

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Apple Platforms](https://img.shields.io/badge/Apple-iOS%2017%2B%20%7C%20macOS%2014%2B%20%7C%20tvOS%2017%2B%20%7C%20watchOS%2010%2B%20%7C%20visionOS%201%2B-0A84FF?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com)
[![Publish Readiness](https://img.shields.io/badge/Publish%20Readiness-ready-34C759?style=for-the-badge)](Documentation/Generated/Benchmark-Readiness.md)
[![Proof Posture](https://img.shields.io/badge/Proof%20Posture-release--grade-FF9F0A?style=for-the-badge)](Documentation/Generated/Public-Proof-Status.md)
[![Required Devices](https://img.shields.io/badge/Required%20Devices-Mac%20%2B%20iPhone-5AC8FA?style=for-the-badge)](Documentation/Generated/Release-Benchmark-Matrix.md)
[![License](https://img.shields.io/badge/License-MIT-111827?style=for-the-badge)](LICENSE)

<br />

[![Start Here](https://img.shields.io/badge/Start%20Here-5%20Minute%20Success%20Path-F05138?style=for-the-badge&labelColor=0D1117)](Documentation/Getting-Started.md#five-minute-success-path)
[![Flagship Demo](https://img.shields.io/badge/Flagship%20Demo-IntelligentCamera-0A84FF?style=for-the-badge&labelColor=0D1117)](Examples/DemoApps/IntelligentCamera/README.md)
[![Proof Surface](https://img.shields.io/badge/Proof%20Surface-Public%20Status-34C759?style=for-the-badge&labelColor=0D1117)](Documentation/Generated/Public-Proof-Status.md)
[![Showcase Media](https://img.shields.io/badge/Showcase%20Media-published-BF5AF2?style=for-the-badge&labelColor=0D1117)](Documentation/Assets/Flagship-Demo/README.md)

</div>

<p align="center">
  <strong>SwiftIntelligence</strong> is a modular, privacy-first AI toolkit for Apple developers who want a real product path across
  <code>Vision</code>, <code>NaturalLanguage</code>, <code>Speech</code>, privacy controls, benchmarks, and release proof.
</p>

<p align="center">
  It is not a generic cross-platform inference runtime. It is an Apple-native developer toolkit built to make on-device AI flows easier to compose,
  easier to validate, and harder to fake.
</p>

<p align="center">
  <a href="Documentation/Getting-Started.md">Getting Started</a> •
  <a href="Documentation/Comparisons/README.md">Comparisons</a> •
  <a href="Documentation/Positioning.md">Positioning</a> •
  <a href="Documentation/Showcase.md">Showcase</a> •
  <a href="Documentation/Generated/Public-Proof-Status.md">Public Proof Status</a> •
  <a href="Documentation/Generated/Latest-Release-Proof.md">Latest Release Proof</a> •
  <a href="ROADMAP.md">Roadmap</a>
</p>

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Why This Repo Feels Different

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>Apple-Native by Design</h3>
      <p>Built around <code>Vision</code>, <code>NaturalLanguage</code>, <code>Speech</code>, <code>Core ML</code>, and privacy-aware workflows instead of hiding Apple APIs behind a vague abstraction layer.</p>
    </td>
    <td width="33%" valign="top">
      <h3>Proof, Not Hype</h3>
      <p>Public claims are tied to benchmark artifacts, generated proof surfaces, immutable release bundles, and explicit device coverage policy.</p>
    </td>
    <td width="33%" valign="top">
      <h3>Modular Product Surface</h3>
      <p>Adopt only the modules you need, keep the binary surface smaller, and evaluate the strongest path first with a maintained flagship flow.</p>
    </td>
  </tr>
</table>

## At a Glance

| Signal | Current truth |
| --- | --- |
| Positioning | Modular on-device AI toolkit for Apple platforms |
| Strongest path | `Vision -> NLP -> Privacy` |
| Flagship demo | [`IntelligentCamera`](Examples/DemoApps/IntelligentCamera/README.md) |
| Publish readiness | `ready` |
| Distribution posture | `release-grade` |
| Required release floor | `Mac + iPhone` |
| Flagship media | `published` |
| Benchmarks | Generated, versioned, release-linked |
| Public proof | [`Public-Proof-Status.md`](Documentation/Generated/Public-Proof-Status.md) |

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Flagship Experience

<p align="center">
  <a href="Examples/DemoApps/IntelligentCamera/README.md">
    <img src="Documentation/Assets/Flagship-Demo/intelligent-camera-success.png" width="100%" alt="SwiftIntelligence IntelligentCamera flagship demo screenshot" />
  </a>
</p>

<p align="center">
  Real repo-native flagship media for the maintained demo path.
  <a href="Documentation/Assets/Flagship-Demo/intelligent-camera-run.mp4">Recording</a> •
  <a href="Documentation/Assets/Flagship-Demo/caption.txt">Caption</a> •
  <a href="Documentation/Assets/Flagship-Demo/README.md">Media policy</a>
</p>

`IntelligentCamera` is the fastest honest proof of value in this repo. It combines:

- `SwiftIntelligenceVision` for classification, OCR, and detection
- `SwiftIntelligenceNLP` for summary generation
- `SwiftIntelligencePrivacy` for tokenized privacy preview
- generated proof surfaces so the demo path is not separated from release discipline

If you only test one thing first, test this path.

```bash
bash Scripts/validate-flagship-demo.sh
```

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Start Here

| Your goal | Install | Best first page |
| --- | --- | --- |
| Evaluate the strongest product story | `Core + Vision + NLP + Privacy` | [5-Minute Success Path](Documentation/Getting-Started.md#five-minute-success-path) |
| Compare against raw Apple NLP APIs | `Core + NLP` | [NLP vs NaturalLanguage](Documentation/Comparisons/NLP-vs-NaturalLanguage.md) |
| Compare against raw Apple Vision APIs | `Core + Vision` | [Vision vs Apple Vision](Documentation/Comparisons/Vision-vs-AppleVision.md) |
| Add privacy controls around AI features | `Privacy + protected feature module` | [Privacy vs CryptoKit + Security](Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md) |
| Validate trust before adoption | none | [Public Proof Status](Documentation/Generated/Public-Proof-Status.md) |
| Review performance posture | `Benchmarks` | [Benchmark Baselines](Documentation/Benchmark-Baselines.md) |

> Use SwiftIntelligence if you want a maintained Apple-native workflow across modules.
> Stay on raw Apple APIs if you only need a single untouched framework call and do not want an additional package layer.

## Who This Is For

- Apple-platform teams shipping on-device features with `Vision`, `NaturalLanguage`, `Speech`, and privacy-sensitive data
- engineers who want a stronger developer path than raw framework-by-framework assembly
- maintainers who care about evidence, release discipline, benchmark thresholds, and example validation

## Who Should Not Use This

- teams looking for a cross-platform inference runtime
- teams centered on Python-first training, model conversion, or quantization tooling
- apps that only need one low-level Apple API call without a multi-module workflow

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Install the Strongest Path

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.0.0")
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

Then validate the repo the same way the public docs describe it:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

## Module Surface

<details open>
<summary><strong>Core modules and what they do</strong></summary>

| Module | Role |
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

## Proof Surface

This repo is designed so README language, release language, and proof language do not drift apart.

| If you want to verify... | Start here |
| --- | --- |
| current public claim envelope | [Public Proof Status](Documentation/Generated/Public-Proof-Status.md) |
| immutable release-grade bundle | [Latest Release Proof](Documentation/Generated/Latest-Release-Proof.md) |
| readiness and required device matrix | [Benchmark Readiness](Documentation/Generated/Benchmark-Readiness.md) |
| release blockers | [Release Blockers](Documentation/Generated/Release-Blockers.md) |
| benchmark history and methodology | [Benchmark History](Documentation/Generated/Benchmark-History.md), [Benchmark Methodology](Documentation/Generated/Benchmark-Methodology.md) |
| release evidence flow | [Release Process](Documentation/Release-Process.md) |

Public performance wording is expected to stay inside the current claim envelope documented in the generated proof pages.

## Benchmarks

Run the standard benchmark profile:

```bash
bash Scripts/run-benchmarks.sh standard
```

Collect additional optional device evidence:

```bash
bash Scripts/run-benchmarks-for-device.sh \
  --profile standard \
  --output-dir Benchmarks/Results/device-run \
  --device-name "iPhone 16" \
  --device-model "iPhone17,3" \
  --device-class iPhone \
  --platform-family iOS \
  --export-archive /absolute/path/to/benchmark-export.tar.gz
```

Import an external evidence bundle:

```bash
bash Scripts/import-benchmark-evidence.sh \
  /absolute/path/to/benchmark-export.tar.gz \
  iphone-baseline-2026-04-02
```

Under the current release policy, the required immutable device classes are `Mac` and `iPhone`. Additional classes are expansion, not release blockers.

<img alt="" src="https://capsule-render.vercel.app/api?type=rect&color=0:F05138,45:FF9F0A,100:0A84FF&height=3&section=header"/>

## Documentation Map

<details open>
<summary><strong>Best first docs</strong></summary>

- [Getting Started](Documentation/Getting-Started.md)
- [Documentation Index](Documentation/README.md)
- [Positioning](Documentation/Positioning.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)
- [Flagship Media](Documentation/Assets/Flagship-Demo/README.md)
- [GitHub Distribution](Documentation/GitHub-Distribution.md)

</details>

<details>
<summary><strong>Generated proof and release docs</strong></summary>

- [Proof Snapshot](Documentation/Generated/Proof-Snapshot.md)
- [Benchmark History](Documentation/Generated/Benchmark-History.md)
- [Benchmark Comparison](Documentation/Generated/Benchmark-Comparison.md)
- [Benchmark Timeline](Documentation/Generated/Benchmark-Timeline.md)
- [Release Benchmark Matrix](Documentation/Generated/Release-Benchmark-Matrix.md)
- [Release Proof Timeline](Documentation/Generated/Release-Proof-Timeline.md)
- [Latest Release Proof](Documentation/Generated/Latest-Release-Proof.md)
- [Benchmark Readiness](Documentation/Generated/Benchmark-Readiness.md)
- [Release Candidate Plan](Documentation/Generated/Release-Candidate-Plan.md)
- [Device Capture Packets](Documentation/Generated/Device-Capture-Packets.md)
- [Device Evidence Intake](Documentation/Generated/Device-Evidence-Intake.md)
- [Device Evidence Queue](Documentation/Generated/Device-Evidence-Queue.md)
- [Device Evidence Handoff](Documentation/Generated/Device-Evidence-Handoff.md)
- [Release Blockers](Documentation/Generated/Release-Blockers.md)
- [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

</details>

## Development

```bash
swift build
bash Scripts/validate-examples.sh
swift test
bash Scripts/prepare-release.sh
```

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Security reports should go through [SECURITY.md](SECURITY.md), not public issues.

## License

SwiftIntelligence is released under the [MIT License](LICENSE).

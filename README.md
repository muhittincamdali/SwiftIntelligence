<div align="center">

# SwiftIntelligence

### Modular on-device AI for Apple platforms

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B%20%7C%20tvOS%2017%2B%20%7C%20watchOS%2010%2B%20%7C%20visionOS%201%2B-007AFF?style=for-the-badge&logo=apple)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift)](https://swift.org/package-manager/)

**Privacy-first • Native frameworks only • Modular Apple AI toolkit**

[Getting Started](Documentation/Getting-Started.md) • [Documentation Index](Documentation/README.md) • [Positioning](Documentation/Positioning.md) • [GitHub Distribution](Documentation/GitHub-Distribution.md) • [Benchmarks](Documentation/Benchmark-Baselines.md) • [Roadmap](ROADMAP.md) • [Security](SECURITY.md) • [Contributing](CONTRIBUTING.md)

</div>

---

## Why SwiftIntelligence?

SwiftIntelligence is a modular AI toolkit for Apple platforms built on native frameworks such as Vision, NaturalLanguage, Speech, Core ML, and AVFoundation.

It is intentionally positioned as a modular Apple AI developer toolkit, not as a generic cross-platform inference runtime. The current competitive framing is documented in [Documentation/Positioning.md](Documentation/Positioning.md).

The current package graph is intentionally modular:

- `SwiftIntelligenceCore`
- `SwiftIntelligenceML`
- `SwiftIntelligenceNLP`
- `SwiftIntelligenceVision`
- `SwiftIntelligenceSpeech`
- `SwiftIntelligenceReasoning`
- `SwiftIntelligencePrivacy`
- `SwiftIntelligenceNetwork`
- `SwiftIntelligenceCache`
- `SwiftIntelligenceMetrics`
- `SwiftIntelligenceBenchmarks`

This keeps adoption explicit, reduces binary surface area, and makes Swift 6 concurrency hardening easier to validate.

## Current Status

- Active modular package graph is building cleanly.
- `swift test` is passing on the current branch.
- Publish readiness is `ready` under the current required device matrix: `Mac + iPhone`.
- The current public proof posture is `release-grade`.
- CI now exercises build, example validation, tests, `smoke` benchmark evidence, and proof-surface validators.
- Security automation includes CodeQL, dependency review, and OpenSSF Scorecard workflows.
- Vision and NLP concurrency migration work is actively maintained.
- Performance claims are expected to be backed by benchmark artifacts in [Documentation/Benchmark-Baselines.md](Documentation/Benchmark-Baselines.md).
- The current claim envelope and immutable release proof are published in [Documentation/Generated/Public-Proof-Status.md](Documentation/Generated/Public-Proof-Status.md) and [Documentation/Generated/Latest-Release-Proof.md](Documentation/Generated/Latest-Release-Proof.md).
- Competitive positioning and win conditions are documented in [Documentation/Positioning.md](Documentation/Positioning.md).

## Why Adopt Now

- strongest current path is a real multi-module Apple-native flow: `Vision -> NLP -> Privacy`
- flagship demo has its own guide and smoke-check: [IntelligentCamera](Examples/DemoApps/IntelligentCamera/README.md), `bash Scripts/validate-flagship-demo.sh`
- flagship media path now includes published repo-native screenshot and recording assets: [Flagship Media](Documentation/Assets/Flagship-Demo/README.md), [Screenshot](Documentation/Assets/Flagship-Demo/intelligent-camera-success.png), [Recording](Documentation/Assets/Flagship-Demo/intelligent-camera-run.mp4)
- release proof is not hand-wavy: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md) and [Latest Release Proof](Documentation/Generated/Latest-Release-Proof.md)
- required release device floor is already covered with immutable `Mac + iPhone` evidence

## Who This Is For

- Apple-platform teams that want to compose `Vision`, `NaturalLanguage`, `Speech`, and privacy controls inside one Swift package workflow
- teams that want a stronger developer path than raw framework-by-framework integration
- maintainers who care about proof surfaces, example validation, and release discipline before making public claims

## Who Should Not Use This

- teams looking for a cross-platform inference runtime
- teams whose main problem is model conversion, quantization, or Python-first ML tooling
- teams that only need one untouched Apple framework API and do not want an additional package layer

## Installation

Fastest honest first install is the flagship path: `Vision -> NLP -> Privacy`.

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

If you do not need the flagship path, module-first entry points live in [Getting Started](Documentation/Getting-Started.md) and the raw Apple API comparisons live in [Documentation/Comparisons](Documentation/Comparisons/README.md).

## 5-Minute Success Path

Fastest honest first win in this repo:

1. Add `SwiftIntelligenceCore`, `SwiftIntelligenceVision`, `SwiftIntelligenceNLP`, and `SwiftIntelligencePrivacy`.
2. Open the flagship `IntelligentCamera` flow.
3. Verify the repo and examples locally.

Use this if you want to evaluate the repo on its strongest axis: `Vision -> NLP -> Privacy`.

Install the minimal flagship set:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

Then start with:

- [Getting Started](Documentation/Getting-Started.md)
- [Intelligent Camera demo guide](Examples/DemoApps/IntelligentCamera/README.md)
- [Intelligent Camera demo source](Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift)
- [Showcase proof narrative](Documentation/Showcase.md)
- [Latest immutable release proof](Documentation/Generated/Latest-Release-Proof.md)

Local verification:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

## Quick Start By Module

| First goal | Products | Start here |
| --- | --- | --- |
| `Vision -> NLP -> Privacy` flagship flow | `Core + Vision + NLP + Privacy` | [Getting Started](Documentation/Getting-Started.md#five-minute-success-path) |
| NLP-first app | `Core + NLP` | [NLP vs NaturalLanguage](Documentation/Comparisons/NLP-vs-NaturalLanguage.md) |
| Vision-first app | `Core + Vision` | [Vision vs Apple Vision](Documentation/Comparisons/Vision-vs-AppleVision.md) |
| Speech-first app | `Speech` | [Speech vs Apple Speech](Documentation/Comparisons/Speech-vs-AppleSpeech.md) |
| Privacy-aware AI flow | `Privacy + protected feature module` | [Privacy vs CryptoKit + Security](Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md) |
| Benchmarks and proof surfaces | `Benchmarks` | [Documentation/Benchmark-Baselines.md](Documentation/Benchmark-Baselines.md) |

If you are unsure where to begin, use the flagship path first. Only stay on raw Apple APIs when you need direct low-level control and do not need the multi-module workflow this repo optimizes for.

## Module Map

| Module | Scope |
| --- | --- |
| `SwiftIntelligenceCore` | Shared configuration, logging, metrics, runtime utilities |
| `SwiftIntelligenceML` | On-device training, prediction, evaluation, cache management |
| `SwiftIntelligenceNLP` | Sentiment, entities, keywords, summaries, topics |
| `SwiftIntelligenceVision` | Classification, detection, OCR, segmentation, enhancement |
| `SwiftIntelligenceSpeech` | Voice catalogs, synthesis, speech-related types |
| `SwiftIntelligencePrivacy` | Tokenization, anonymization, compliance, secure storage |
| `SwiftIntelligenceReasoning` | Higher-level reasoning primitives |
| `SwiftIntelligenceNetwork` | Network-layer helpers |
| `SwiftIntelligenceCache` | Cache primitives |
| `SwiftIntelligenceMetrics` | Metrics and observability support |
| `SwiftIntelligenceBenchmarks` | Benchmark runners and performance baselines |

## Documentation

Start here:

- [Documentation Index](Documentation/README.md)
- [Positioning](Documentation/Positioning.md)
- [GitHub Distribution](Documentation/GitHub-Distribution.md)
- [Module Comparisons](Documentation/Comparisons/README.md)
- [5-Minute Success Path](Documentation/Getting-Started.md#five-minute-success-path)
- [Intelligent Camera demo guide](Examples/DemoApps/IntelligentCamera/README.md)
- [NLP vs NaturalLanguage](Documentation/Comparisons/NLP-vs-NaturalLanguage.md)
- [Vision vs Apple Vision](Documentation/Comparisons/Vision-vs-AppleVision.md)
- [Speech vs Apple Speech](Documentation/Comparisons/Speech-vs-AppleSpeech.md)
- [Privacy vs CryptoKit + Security](Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md)
- [Showcase](Documentation/Showcase.md)
- [Flagship Media](Documentation/Assets/Flagship-Demo/README.md)
- [Generated Proof Snapshot](Documentation/Generated/Proof-Snapshot.md)
- [Generated Benchmark History](Documentation/Generated/Benchmark-History.md)
- [Generated Benchmark Comparison](Documentation/Generated/Benchmark-Comparison.md)
- [Generated Benchmark Methodology](Documentation/Generated/Benchmark-Methodology.md)
- [Generated Benchmark Timeline](Documentation/Generated/Benchmark-Timeline.md)
- [Generated Release Benchmark Matrix](Documentation/Generated/Release-Benchmark-Matrix.md)
- [Generated Release Proof Timeline](Documentation/Generated/Release-Proof-Timeline.md)
- [Generated Latest Release Proof](Documentation/Generated/Latest-Release-Proof.md)
- [Generated Benchmark Readiness](Documentation/Generated/Benchmark-Readiness.md)
- [Generated Release Candidate Plan](Documentation/Generated/Release-Candidate-Plan.md)
- [Generated Device Capture Packets](Documentation/Generated/Device-Capture-Packets.md)
- [Generated Device Evidence Intake](Documentation/Generated/Device-Evidence-Intake.md)
- [Generated Device Evidence Queue](Documentation/Generated/Device-Evidence-Queue.md)
- [Generated Device Evidence Handoff](Documentation/Generated/Device-Evidence-Handoff.md)
- [Generated Release Blockers](Documentation/Generated/Release-Blockers.md)
- [Generated Public Proof Status](Documentation/Generated/Public-Proof-Status.md)
- [Getting Started](Documentation/Getting-Started.md)
- [Architecture](Documentation/Architecture.md)
- [API Reference](Documentation/API-Reference.md)
- [Performance Baselines](Documentation/Benchmark-Baselines.md)
- [Security Guide](Documentation/Security.md)

## Benchmarks

Public performance claims should be backed by generated benchmark output:

```bash
bash Scripts/run-benchmarks.sh standard
```

For optional additional device evidence collection, use:

```bash
bash Scripts/run-benchmarks-for-device.sh --profile standard --output-dir Benchmarks/Results/device-run --device-name "iPhone 16" --device-model "iPhone17,3" --device-class iPhone --platform-family iOS --export-archive /absolute/path/to/benchmark-export.tar.gz
```

If the benchmark run was captured on another machine, import it with:

```bash
bash Scripts/import-benchmark-evidence.sh /absolute/path/to/benchmark-export.tar.gz iphone-baseline-2026-04-02
```

Artifacts are written under `Benchmarks/Results/latest`.
Each validated artifact set now also carries normalized `device-metadata.json`, a manifest, and a SHA-256 checksum list.
Release validation also applies regression thresholds against the latest immutable release baseline when one exists.
Under the current release policy, the required immutable device classes are `Mac` and `iPhone`; extra device classes are optional expansion rather than release blockers.

The current public proof surface is summarized in [Documentation/Showcase.md](Documentation/Showcase.md).
Historical evidence, methodology, timeline, release matrix, release proof surfaces, and latest-vs-release deltas are published in [Documentation/Generated/Benchmark-History.md](Documentation/Generated/Benchmark-History.md), [Documentation/Generated/Benchmark-Methodology.md](Documentation/Generated/Benchmark-Methodology.md), [Documentation/Generated/Benchmark-Timeline.md](Documentation/Generated/Benchmark-Timeline.md), [Documentation/Generated/Release-Benchmark-Matrix.md](Documentation/Generated/Release-Benchmark-Matrix.md), [Documentation/Generated/Release-Proof-Timeline.md](Documentation/Generated/Release-Proof-Timeline.md), [Documentation/Generated/Latest-Release-Proof.md](Documentation/Generated/Latest-Release-Proof.md), and [Documentation/Generated/Benchmark-Comparison.md](Documentation/Generated/Benchmark-Comparison.md).
Current publish readiness is summarized in [Documentation/Generated/Benchmark-Readiness.md](Documentation/Generated/Benchmark-Readiness.md).
The next execution waves for release-grade benchmark evidence are summarized in [Documentation/Generated/Release-Candidate-Plan.md](Documentation/Generated/Release-Candidate-Plan.md).
Exact device capture commands for any future expansion waves are generated in [Documentation/Generated/Device-Evidence-Plan.md](Documentation/Generated/Device-Evidence-Plan.md).
Ready-to-hand-off capture/import packets for future device classes are generated in [Documentation/Generated/Device-Capture-Packets.md](Documentation/Generated/Device-Capture-Packets.md).
Maintainer-facing intake summaries for those packetized waves are generated in [Documentation/Generated/Device-Evidence-Intake.md](Documentation/Generated/Device-Evidence-Intake.md).
The current device-evidence execution queue is generated in [Documentation/Generated/Device-Evidence-Queue.md](Documentation/Generated/Device-Evidence-Queue.md).
The current release-proof blocker summary is generated in [Documentation/Generated/Release-Blockers.md](Documentation/Generated/Release-Blockers.md).
The current public claim/distribution envelope is generated in [Documentation/Generated/Public-Proof-Status.md](Documentation/Generated/Public-Proof-Status.md).
High-visibility benchmark/performance wording is also gated by `Scripts/validate-public-claims.sh` until multi-device readiness becomes `ready`.

## Development

```bash
swift build
bash Scripts/validate-examples.sh
swift test
```

The repository currently treats package build, example validation, and test correctness as the primary release gate.
Release notes are expected to come from curated `CHANGELOG.md` entries plus immutable benchmark evidence.
Public installation snippets are expected to match the latest numbered release in `CHANGELOG.md`.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Security reports should go through [SECURITY.md](SECURITY.md), not public issues.

## License

SwiftIntelligence is released under the [MIT License](LICENSE).

# SwiftIntelligence Showcase

Last updated: 2026-04-07

This page exists to answer one question quickly:

**What can this repository prove today without hand-wavy claims?**

For the machine-derived snapshot built from the current benchmark artifacts, see [Generated/Proof-Snapshot.md](Generated/Proof-Snapshot.md).
For the generated benchmark history, methodology, timeline, release matrix, release proof surfaces, and latest-vs-release diff, see [Generated/Benchmark-History.md](Generated/Benchmark-History.md), [Generated/Benchmark-Methodology.md](Generated/Benchmark-Methodology.md), [Generated/Benchmark-Timeline.md](Generated/Benchmark-Timeline.md), [Generated/Release-Benchmark-Matrix.md](Generated/Release-Benchmark-Matrix.md), [Generated/Release-Proof-Timeline.md](Generated/Release-Proof-Timeline.md), [Generated/Latest-Release-Proof.md](Generated/Latest-Release-Proof.md), and [Generated/Benchmark-Comparison.md](Generated/Benchmark-Comparison.md).

## Current Proof Envelope

- publish readiness: `ready`
- distribution posture: `release-grade`
- required release device classes covered: `Mac, iPhone`
- pending device evidence queue: `0`
- current public claim envelope: [Generated/Public-Proof-Status.md](Generated/Public-Proof-Status.md)
- current release blocker surface: [Generated/Release-Blockers.md](Generated/Release-Blockers.md)

## Why Adopt Now

- the repo has a maintained flagship workflow instead of isolated wrapper demos
- the strongest path is compile-validated independently through `bash Scripts/validate-flagship-demo.sh`
- release messaging is backed by immutable proof, not only maintainer-local benchmark output
- current release-grade floor is already covered at `Mac + iPhone`

## Flagship Flows

### 1. Intelligent Camera

Flow:

`Vision -> NLP -> Privacy`

Proof surface:

- example source: [Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift](../Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift)
- demo guide: [Examples/DemoApps/IntelligentCamera/README.md](../Examples/DemoApps/IntelligentCamera/README.md)
- shareable demo pack: [Generated/Flagship-Demo-Pack.md](Generated/Flagship-Demo-Pack.md)
- canonical media location: [Assets/Flagship-Demo/README.md](Assets/Flagship-Demo/README.md)
- flagship smoke-check: `bash Scripts/validate-flagship-demo.sh`
- validated by: `bash Scripts/validate-examples.sh`

What it proves:

- image classification
- object detection
- document/OCR analysis
- text summarization on recognized text
- privacy tokenization on extracted content

Why it matters:

This is the strongest current proof that `SwiftIntelligence` is more useful as a multi-module Apple workflow than as a single isolated wrapper.

### 2. Smart Translator

Flow:

`NLP -> Privacy -> Speech`

Proof surface:

- example source: [Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift](../Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift)
- validated by: `bash Scripts/validate-examples.sh`

What it proves:

- language-aware text analysis
- summary and keyword extraction
- privacy-aware preprocessing
- translation pipeline hook
- speech synthesis on translated output

Why it matters:

It shows that the repo can connect language features to actual user-facing output rather than stopping at diagnostics.

### 3. Voice Assistant

Flow:

`NLP -> Privacy -> Speech`

Proof surface:

- example source: [Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift](../Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift)
- validated by: `bash Scripts/validate-examples.sh`

What it proves:

- intent inference from text commands
- summary and entity extraction
- optional privacy redaction
- synthesized spoken response

Why it matters:

It is the clearest "assistant-style" demo in the maintained graph, even if speech recognition and agentic logic are not yet the repo’s strongest differentiator.

## Benchmark Evidence

Current working-pointer benchmark snapshot from the generated artifacts in `Benchmarks/Results/latest`:

- generated at: `2026-04-02T02:43:10Z`
- profile: `standard`
- device class: `Mac`
- total workloads: `25`
- performance score: `55.28`
- average execution time: `0.0791s`

Latest immutable release proof:

- release bundle: `iphone-baseline-2026-04-07`
- device class: `iPhone`
- device name: `iPhone 15 Pro Max`
- provenance: `physical-device-test`
- performance score: `38.59`
- average execution time: `0.0793s`

Top current signals:

- fastest workload: `ML_Prediction_Small` at `0.0061s`
- slowest workload: `ML_Model_Loading` at `0.3111s`
- strongest repo-level integrated workload: `Integration_Multi_Modal`

Proof surface:

- [benchmark-summary.md](../Benchmarks/Results/latest/benchmark-summary.md)
- [benchmark-report.json](../Benchmarks/Results/latest/benchmark-report.json)
- [environment.json](../Benchmarks/Results/latest/environment.json)
- [Generated/Latest-Release-Proof.md](Generated/Latest-Release-Proof.md)
- [Generated/Benchmark-Readiness.md](Generated/Benchmark-Readiness.md)
- [Generated/Public-Proof-Status.md](Generated/Public-Proof-Status.md)

Interpretation rule:

- `latest` is the working pointer and currently reflects the maintainer Mac environment
- immutable release proof is the public trust surface for release messaging
- cross-hardware deltas are directional, not definitive leaderboard claims

## Maintainer Validation Path

These are the minimum proof commands behind the current showcase:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
bash Scripts/run-benchmarks.sh standard
bash Scripts/prepare-release.sh
```

## Shareable Demo Pack

For release posts, screenshots, short recordings, or quick evaluator handoff, use:

- [Generated/Flagship-Demo-Pack.md](Generated/Flagship-Demo-Pack.md)
- [Assets/Flagship-Demo/README.md](Assets/Flagship-Demo/README.md)
- [Assets/Flagship-Demo/intelligent-camera-success.png](Assets/Flagship-Demo/intelligent-camera-success.png)
- [Assets/Flagship-Demo/intelligent-camera-run.mp4](Assets/Flagship-Demo/intelligent-camera-run.mp4)
- [Assets/Flagship-Demo/caption.txt](Assets/Flagship-Demo/caption.txt)
- [Generated/Flagship-Media-Status.md](Generated/Flagship-Media-Status.md)
- immutable bundle asset: `flagship-demo-share-pack.tar.gz`
- [Examples/DemoApps/IntelligentCamera/README.md](../Examples/DemoApps/IntelligentCamera/README.md)
- [Generated/Public-Proof-Status.md](Generated/Public-Proof-Status.md)
- [Generated/Latest-Release-Proof.md](Generated/Latest-Release-Proof.md)

Current flagship media is now published under the canonical directory with a real screenshot, short recording, and caption for the maintained `IntelligentCamera` path.

## What This Showcase Does Not Prove

It does not prove:

- category leadership yet
- does not prove best-in-class benchmark performance against every competitor
- strongest LLM runtime
- complete production readiness for inactive products

It proves that the active modular graph has a real, validated, multi-module story with release-grade proof at the current `Mac + iPhone` policy floor.

# SwiftIntelligence Showcase

Last updated: 2026-04-10

This page answers one evaluator question:

**What can this repository prove today that is useful to a real Apple app team?**

## What this repo proves today

- a maintained `Vision -> NLP -> Privacy` flagship workflow
- secondary text-and-voice workflows that compile against the active package graph
- benchmark and release evidence tied to public claim boundaries
- release-grade trust posture at the current `Mac + iPhone` device floor

If you want the machine-generated trust surfaces, start with:

- [Public Proof Status](Generated/Public-Proof-Status.md)
- [Latest Release Proof](Generated/Latest-Release-Proof.md)
- [Proof Snapshot](Generated/Proof-Snapshot.md)

## Adopt now if...

- your app needs more than one Apple-native AI capability
- you care about public proof and release truth, not only local demos
- you want a maintained best-first path instead of choosing from disconnected examples

Do not adopt because of this page if you need:

- a low-level inference runtime first
- a speech-only specialist package first
- category leadership proof that exceeds the current evidence envelope

## Showcase ladder

| Level | Example | What it proves | Current maturity |
| --- | --- | --- | --- |
| 1 | [IntelligentCamera](../Examples/DemoApps/IntelligentCamera/README.md) | repo's strongest multi-module product path | flagship |
| 2 | `SmartTranslator` | text analysis, privacy preprocessing, speech output composition | maintained secondary |
| 3 | `VoiceAssistant` | assistant-style response pipeline on Apple-native surfaces | maintained secondary |

## 1. IntelligentCamera

Flow:

`Vision -> NLP -> Privacy`

Why it matters:

- strongest maintained demo in the repo
- current best proof that SwiftIntelligence is more than a thin wrapper set
- the clearest path from README promise to real app-facing output

What it proves:

- image classification
- object detection
- OCR and extracted text processing
- summary generation
- privacy tokenization on extracted content

Where to verify:

- [demo guide](../Examples/DemoApps/IntelligentCamera/README.md)
- [flagship demo pack](Generated/Flagship-Demo-Pack.md)
- [flagship media policy](Assets/Flagship-Demo/README.md)
- command: `bash Scripts/validate-flagship-demo.sh`

## 2. SmartTranslator

Flow:

`NLP -> Privacy -> Speech`

<p align="center">
  <a href="Assets/SmartTranslator-Demo/smarttranslator-success.png">
    <img src="Assets/SmartTranslator-Demo/smarttranslator-success.png" width="100%" alt="SmartTranslator demo screenshot" />
  </a>
</p>

Why it matters:

- shows the repo can drive user-visible output, not only analysis
- proves a second, non-vision workflow exists in the maintained graph

Current limitation:

- this now has real media and a maintained guide, but it is still not productized at flagship level

Where to verify:

- guide: [SmartTranslator demo guide](../Examples/DemoApps/SmartTranslator/README.md)
- media policy: [SmartTranslator demo media](Assets/SmartTranslator-Demo/README.md)
- screenshot: [smarttranslator-success.png](Assets/SmartTranslator-Demo/smarttranslator-success.png)
- recording: [smarttranslator-run.mp4](Assets/SmartTranslator-Demo/smarttranslator-run.mp4)
- source: [SmartTranslatorApp.swift](../Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift)
- command: `bash Scripts/capture-smarttranslator-media.sh`

## 3. VoiceAssistant

Flow:

`NLP -> Privacy -> Speech`

<p align="center">
  <a href="Assets/VoiceAssistant-Demo/voiceassistant-success.png">
    <img src="Assets/VoiceAssistant-Demo/voiceassistant-success.png" width="100%" alt="VoiceAssistant demo screenshot" />
  </a>
</p>

Why it matters:

- shows intent-like command processing and spoken response
- keeps the repo's assistant story grounded in real Apple-native modules

Current limitation:

- not yet a flagship path
- not proof of speech recognition leadership or agentic runtime leadership

Where to verify:

- guide: [VoiceAssistant demo guide](../Examples/DemoApps/VoiceAssistant/README.md)
- media policy: [VoiceAssistant demo media](Assets/VoiceAssistant-Demo/README.md)
- screenshot: [voiceassistant-success.png](Assets/VoiceAssistant-Demo/voiceassistant-success.png)
- recording: [voiceassistant-run.mp4](Assets/VoiceAssistant-Demo/voiceassistant-run.mp4)
- source: [VoiceAssistantApp.swift](../Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift)
- command: `bash Scripts/capture-voiceassistant-media.sh`

## Benchmark and release truth

Current release/trust envelope:

- publish readiness: `ready`
- distribution posture: `release-grade`
- required release device classes covered: `Mac, iPhone`
- pending device evidence queue: `0`

Current proof entry points:

- [Trust Start](Trust-Start.md)
- [Public Proof Status](Generated/Public-Proof-Status.md)
- [Benchmark Readiness](Generated/Benchmark-Readiness.md)
- [Latest Release Proof](Generated/Latest-Release-Proof.md)
- [Release Blockers](Generated/Release-Blockers.md)

Interpretation rules:

- `Benchmarks/Results/latest` is the working pointer, not the canonical release marketing surface
- immutable release bundles are the public release-truth surface
- cross-device deltas are directional, not leaderboard claims

## Maintainer validation path

These are the minimum commands behind the current showcase:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
bash Scripts/prepare-release.sh
```

## What this page does not prove

This page does not prove:

- category leadership
- best-in-class performance against every rival
- speech-specific category dominance
- complete production readiness for every source-level demo

It proves that the active maintained graph has a real product story, a real validation path, and a release-grade trust surface.

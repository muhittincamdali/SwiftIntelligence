# SwiftIntelligenceSpeech vs Apple Speech

Last updated: 2026-04-07

This page answers one adoption question:

**When should an Apple developer stay on raw `Speech` and `AVSpeechSynthesizer`, and when is `SwiftIntelligenceSpeech` the better workflow layer?**

## Short Answer

Choose raw Apple speech APIs when:

- you only need recognition or synthesis, not both
- you want the smallest possible wrapper surface
- your app already owns audio-session and recognition-task orchestration directly

Choose `SwiftIntelligenceSpeech` when:

- speech must connect to `NLP` or `Privacy`
- you want one maintained surface for voices, synthesis, and speech-related configuration
- you want less repeated recognizer/synthesizer wiring across screens or products

## Side-by-Side

| Concern | Raw `Speech` + `AVSpeechSynthesizer` | `SwiftIntelligenceSpeech` |
| --- | --- | --- |
| Setup | manage recognizer, authorization, audio session, and synthesis separately | one maintained speech module |
| Voice discovery | direct `AVSpeechSynthesisVoice` use | exposed through speech helpers |
| Recognition lifecycle | app-specific | wrapped in the engine |
| Synthesis lifecycle | app-specific | wrapped in the engine |
| Cross-module chaining | manual glue | designed to connect into `NLP` and `Privacy` |
| Lowest-level control | stronger | weaker |

## Code Shape

Raw Apple speech code often starts like this:

```swift
import Speech
import AVFoundation

SFSpeechRecognizer.requestAuthorization { status in
    // handle authorization
}

let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
let synthesizer = AVSpeechSynthesizer()
```

`SwiftIntelligenceSpeech` compresses the maintained app-level path:

```swift
import SwiftIntelligenceSpeech

let voices = SpeechEngine.availableVoices(for: "en-US")
let result = try await SpeechEngine.shared.synthesizeSpeech(
    from: "Hello from SwiftIntelligence.",
    options: .default
)
```

## Migration Heuristic

Stay on raw Apple speech APIs if your codebase looks like this:

- one narrow recognition or synthesis feature
- direct control over authorization and audio lifecycle matters more than reuse
- no need for shared composition with text-understanding or privacy flows

Move to `SwiftIntelligenceSpeech` if your codebase is accumulating:

- repeated authorization and lifecycle setup
- repeated voice catalog logic
- repeated glue between speech output and text-processing workflows

## Current Proof

What is proven today:

- repo-level proof posture is `release-grade` at the `Mac + iPhone` policy floor
- speech code paths are exercised by `swift test`
- speech features are documented as part of the maintained modular graph

What is not yet proven:

- public benchmark leadership against raw Apple speech APIs
- flagship public speech demo quality on par with the strongest speech repos

## Best-Fit Decision

Use raw Apple speech APIs if you want primitive control with minimal abstraction.

Use `SwiftIntelligenceSpeech` if you want a cleaner app-level surface that composes with the rest of the package graph.

## Sources

- [Apple Speech docs](https://developer.apple.com/documentation/speech)
- [Speech Comparison](Speech.md)
- [Getting Started](../Getting-Started.md)

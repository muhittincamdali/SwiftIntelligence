# VoiceAssistant Demo Guide

This is the assistant-style secondary demo in SwiftIntelligence.

## What It Proves

- `NLP` can infer intent-like signals from command text
- `Privacy` can redact command content before downstream handling
- `Speech` can synthesize the generated response
- the repo can produce an assistant-style flow without claiming agent-runtime leadership

## Required Products

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence")
```

## Open This File

- [VoiceAssistantApp.swift](VoiceAssistantApp.swift)

## Fastest Run Path

1. Create a new Apple app target in Xcode with SwiftUI enabled.
2. Add the four required package products from this repo.
3. Replace the default app entry file with [VoiceAssistantApp.swift](VoiceAssistantApp.swift).
4. Run on `macOS 14+` or `iOS 17+`.
5. Tap `Process`, then tap `Speak`.

## What Success Looks Like

- `Intent` is not `-`
- `Detected language` is not empty
- `Summary` is generated from the command text
- `Redacted` contains a tokenized preview when privacy mode is enabled
- `Assistant Response` contains a synthesized response block
- history accumulates previous commands and responses

## Best For

- teams evaluating assistant-style UI without claiming full agent-runtime scope
- apps that need command interpretation, redaction, response generation, and spoken output in one screen
- evaluators comparing a lighter secondary path against the flagship demo

## Not For

- teams expecting speech-recognition category leadership proof
- teams expecting autonomous tool use or agent orchestration proof
- teams deciding between raw framework assembly and the repo at category level without first reading comparisons

## Compare First

- [Speech vs Apple Speech](../../../Documentation/Comparisons/Speech-vs-AppleSpeech.md)
- [Privacy vs CryptoKit + Security](../../../Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md)
- [SwiftIntelligence vs Top Rivals](../../../Documentation/Comparisons/Competitive-Matrix.md)

## Current Limitations

- this demo now has real media, but it is still not a flagship proof path
- this is not proof of speech recognition leadership
- this is not proof of agent orchestration or autonomous tool use
- this demo proves assistant-style composition on Apple-native modules, not a full conversational agent stack

## Local Verification

```bash
bash Scripts/capture-voiceassistant-media.sh
bash Scripts/validate-examples.sh
swift test
```

## Related Docs

- [Examples Hub](../../README.md)
- [Showcase](../../../Documentation/Showcase.md)
- [Competitive Matrix](../../../Documentation/Comparisons/Competitive-Matrix.md)
- [Media Policy](../../../Documentation/Assets/VoiceAssistant-Demo/README.md)
- [Screenshot](../../../Documentation/Assets/VoiceAssistant-Demo/voiceassistant-success.png)
- [Recording](../../../Documentation/Assets/VoiceAssistant-Demo/voiceassistant-run.mp4)
- [Speech vs Apple Speech](../../../Documentation/Comparisons/Speech-vs-AppleSpeech.md)
- [Positioning](../../../Documentation/Positioning.md)

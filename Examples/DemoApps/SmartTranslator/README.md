# SmartTranslator Demo Guide

This is the strongest text-first secondary demo in SwiftIntelligence.

## What It Proves

- `NLP` can analyze, summarize, and extract keywords from source text
- `Privacy` can tokenize source content before downstream handling
- `Speech` can speak translated output for a user-facing result
- the package graph supports a second maintained workflow beyond the flagship vision path

## Required Products

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence")
```

## Open This File

- [SmartTranslatorApp.swift](SmartTranslatorApp.swift)

## Fastest Run Path

1. Create a new Apple app target in Xcode with SwiftUI enabled.
2. Add the four required package products from this repo.
3. Replace the default app entry file with [SmartTranslatorApp.swift](SmartTranslatorApp.swift).
4. Run on `macOS 14+` or `iOS 17+`.
5. Tap `Translate`, then tap `Speak`.

## What Success Looks Like

- `Detected` is not empty
- `Summary` is generated from the source text
- `Keywords` shows language-aware extraction
- `Server preview` shows tokenized output rather than raw text
- `Cikti` contains translated text
- `Speech` ends with a synthesized output status

## Current Limitations

- the translation path is a real module call, but the demo clearly marks placeholder-level confidence when the underlying translation capability is still limited
- this demo now has real media, but it is still not a flagship proof path

## Local Verification

```bash
bash Scripts/capture-smarttranslator-media.sh
bash Scripts/validate-examples.sh
swift test
```

## Related Docs

- [Examples Hub](../../README.md)
- [Showcase](../../../Documentation/Showcase.md)
- [Media Policy](../../../Documentation/Assets/SmartTranslator-Demo/README.md)
- [Screenshot](../../../Documentation/Assets/SmartTranslator-Demo/smarttranslator-success.png)
- [Recording](../../../Documentation/Assets/SmartTranslator-Demo/smarttranslator-run.mp4)
- [Speech vs Apple Speech](../../../Documentation/Comparisons/Speech-vs-AppleSpeech.md)
- [Privacy vs CryptoKit + Security](../../../Documentation/Comparisons/Privacy-vs-CryptoKit-Security.md)

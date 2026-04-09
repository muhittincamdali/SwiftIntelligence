# Comparisons Hub

This folder exists to close decisions, not to dump loose feature lists.

## Decision order

1. Read the [Competitive Matrix](Competitive-Matrix.md) if you are choosing between SwiftIntelligence and other real repositories.
2. Read the module-level pages if you are deciding whether to adopt one product lane or stay on raw Apple APIs.
3. Read the proof pages only after the product and comparison story is already clear.

## Start with the repo-level comparison

- [SwiftIntelligence vs top rivals](Competitive-Matrix.md)

That page covers:

- `coremltools`
- `MLX`
- `WhisperKit`
- `swift-transformers`
- `AnyLanguageModel`

## Module-level comparisons

- [NLP overview](NLP.md)
- [SwiftIntelligenceNLP vs Apple NaturalLanguage](NLP-vs-NaturalLanguage.md)
- [Vision overview](Vision.md)
- [SwiftIntelligenceVision vs Apple Vision](Vision-vs-AppleVision.md)
- [Speech overview](Speech.md)
- [SwiftIntelligenceSpeech vs Apple Speech](Speech-vs-AppleSpeech.md)
- [Privacy overview](Privacy.md)
- [SwiftIntelligencePrivacy vs CryptoKit + Security](Privacy-vs-CryptoKit-Security.md)

## Current proof envelope

- publish readiness: `ready`
- distribution posture: `release-grade`
- required release device classes covered: `Mac, iPhone`
- canonical trust page: [../Generated/Public-Proof-Status.md](../Generated/Public-Proof-Status.md)
- latest immutable release proof: [../Generated/Latest-Release-Proof.md](../Generated/Latest-Release-Proof.md)

## Comparison rules

- compare against primary sources first
- compare against real alternatives people actually choose
- separate raw framework capability from developer workflow value
- state where SwiftIntelligence loses as clearly as where it wins
- do not claim superiority without current proof or product evidence

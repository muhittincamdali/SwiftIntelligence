# Module Comparisons

This folder breaks `SwiftIntelligence` positioning down to the module level.

Use these pages when deciding whether a maintained module should be adopted, expanded, or repositioned.

Current repo-level proof envelope:

- publish readiness: `ready`
- distribution posture: `release-grade`
- required release device classes covered: `Mac, iPhone`
- current source of truth: [../Generated/Public-Proof-Status.md](../Generated/Public-Proof-Status.md)
- latest immutable device proof: [../Generated/Latest-Release-Proof.md](../Generated/Latest-Release-Proof.md)

## Decision Shortcut

Use `SwiftIntelligence` when:

- you want a maintained multi-module Apple AI toolkit instead of hand-assembling each framework integration
- you want a flagship path with docs, demo, smoke-check, and release proof already wired together
- you care about adoption guidance and public-proof discipline, not just thin wrappers

Stay on raw Apple APIs when:

- one framework already solves the problem cleanly
- you need direct low-level control more than a higher-level workflow
- the package layer would add more surface area than value for your use case

Best first module:

- unsure: start with `Vision + NLP + Privacy`
- text-first: start with `NLP`
- image/document-first: start with `Vision`
- voice-first: start with `Speech`
- protection/compliance-first: start with `Privacy`

## Available Comparisons

- [NLP](NLP.md)
- [SwiftIntelligenceNLP vs Apple NaturalLanguage](NLP-vs-NaturalLanguage.md)
- [Vision](Vision.md)
- [SwiftIntelligenceVision vs Apple Vision](Vision-vs-AppleVision.md)
- [Speech](Speech.md)
- [SwiftIntelligenceSpeech vs Apple Speech](Speech-vs-AppleSpeech.md)
- [Privacy](Privacy.md)
- [SwiftIntelligencePrivacy vs CryptoKit + Security](Privacy-vs-CryptoKit-Security.md)

## Comparison Rules

- compare against primary sources first
- prefer official framework docs and upstream repositories
- separate "better developer experience" from "better raw capability"
- do not claim module leadership without current benchmark or adoption proof

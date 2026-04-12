# SwiftIntelligenceNLP vs Apple NaturalLanguage

Last updated: 2026-04-12

This page answers one adoption question:

**When should an Apple developer stay on raw `NaturalLanguage`, and when is `SwiftIntelligenceNLP` the better layer?**

## Short Answer

Choose raw `NaturalLanguage` when:

- you need one narrow feature such as tokenization, tagging, or custom `NLModel` inference
- you want the smallest possible dependency surface
- your team is already comfortable wiring fallback logic, language detection, and result shaping manually

Choose `SwiftIntelligenceNLP` when:

- NLP is one stage in a larger app workflow
- you want sentiment, entities, keywords, summaries, and topic extraction behind one entry point
- you expect to chain text analysis into `Privacy`, `Speech`, or `Vision`

## Side-by-Side

| Concern | Raw `NaturalLanguage` | `SwiftIntelligenceNLP` |
| --- | --- | --- |
| Setup | assemble recognizer/tokenizer/tagger/model pieces yourself | one maintained module plus `NLPEngine.shared` |
| Multi-signal analysis | combine multiple APIs manually | `analyze(text:options:)` returns one aggregated result |
| Language detection | explicit recognizer setup | built into the engine flow |
| Cross-module chaining | app-specific glue code | designed to plug into `Privacy`, `Speech`, and `Vision` |
| Lowest-level control | stronger | weaker |
| Narrow single-feature use case | often better | often unnecessary |

## Code Shape

Raw `NaturalLanguage` usually starts with separate primitives:

```swift
import NaturalLanguage

let recognizer = NLLanguageRecognizer()
recognizer.processString(text)

let tokenizer = NLTokenizer(unit: .word)
tokenizer.string = text

let tagger = NLTagger(tagSchemes: [.nameType, .sentimentScore])
tagger.string = text
```

`SwiftIntelligenceNLP` compresses the common multi-step path into one call:

```swift
import SwiftIntelligenceCore
import SwiftIntelligenceNLP

SwiftIntelligenceCore.shared.configure(with: .production)

let result = try await NLPEngine.shared.analyze(
    text: text,
    options: NLPOptions(
        includeSentiment: true,
        includeEntities: true,
        includeKeywords: true,
        includeLanguageDetection: true
    )
)
```

## Migration Heuristic

Stay on raw `NaturalLanguage` if your codebase looks like this:

- one screen
- one text feature
- no need for cross-module composition
- no maintainer desire for a shared abstraction

Move to `SwiftIntelligenceNLP` if your codebase is accumulating:

- repeated recognizer/tokenizer/tagger setup
- repeated result normalization
- duplicate fallback logic
- pressure to connect text understanding with privacy or speech flows

## Current Proof

What is proven today:

- repo-level proof posture is `release-grade` at the `Mac + iPhone` policy floor
- `SwiftIntelligenceNLP` is exercised by `swift test`
- maintained package onboarding exists in [../Getting-Started.md](../Getting-Started.md)
- multi-module flows are validated in [../Showcase.md](../Showcase.md)

What is not yet proven:

- module-specific public benchmark leadership versus raw `NaturalLanguage`
- broad ecosystem adoption advantage

## Best-Fit Decision

Use raw `NaturalLanguage` if you want primitive control.

Use `SwiftIntelligenceNLP` if you want faster app-level composition and less glue code.

## Sources

- [Apple NaturalLanguage docs](https://developer.apple.com/documentation/naturallanguage)
- [NLP Comparison](NLP.md)
- [Getting Started](../Getting-Started.md)
- [Showcase](../Showcase.md)

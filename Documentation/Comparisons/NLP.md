# NLP Comparison

Last updated: 2026-04-12

## Category

`SwiftIntelligenceNLP` competes as an Apple-platform NLP convenience layer, not as a frontier transformer runtime.

## Primary Alternatives

| Alternative | Why Developers Use It |
| --- | --- |
| [Apple NaturalLanguage](https://developer.apple.com/documentation/naturallanguage) | native tokenization, language detection, tagging, embeddings, and custom `NLModel` support |
| [huggingface/swift-transformers](https://github.com/huggingface/swift-transformers) | direct Swift transformer inference path |
| [huggingface/AnyLanguageModel](https://github.com/huggingface/AnyLanguageModel) | higher-level Swift language-model package |
| custom app code on top of `NLTokenizer` / `NLTagger` | minimal dependency surface for simple text features |

GitHub snapshot on 2026-04-07:

- `huggingface/swift-transformers`: 1,296 stars
- `huggingface/AnyLanguageModel`: 818 stars

## Decision Table

| Choose | When |
| --- | --- |
| `SwiftIntelligenceNLP` | you want Apple-native NLP inside a broader multi-module workflow |
| `NaturalLanguage` directly | you only need a narrow tokenizer/tagger/model path with minimal abstraction |
| `swift-transformers` or `AnyLanguageModel` | you want transformer-centric runtime gravity, model-specific workflows, or LLM-oriented APIs |

## Where SwiftIntelligenceNLP Wins

- one entry point for sentiment, entities, keywords, summaries, topics, and translation helpers
- better fit when NLP is one piece of a larger Apple-native workflow
- easier adoption for teams that do not want to wire `NLTokenizer`, `NLTagger`, and fallback logic themselves
- cleaner integration path with `Privacy`, `Speech`, and `Vision`

## Where It Loses

- not the best choice for state-of-the-art transformer inference
- not the best choice when developers only need one tiny NaturalLanguage feature
- not yet backed by public comparison pages or stronger benchmark proof against direct alternatives

## Best-Fit User

Choose `SwiftIntelligenceNLP` if you want:

- Apple-native text analysis
- one package-level workflow across multiple AI capabilities
- validated examples and a maintainer-controlled modular graph

Choose the alternatives if you want:

- direct transformer-centric inference
- custom `NLModel` work without extra abstraction
- the smallest possible dependency surface

## Brutal Gap List

- public comparisons versus raw `NaturalLanguage` APIs are still missing
- benchmark evidence is repo-level, not yet NLP-module-specific
- the repo still needs stronger "first NLP success" storytelling

## Current Proof Posture

- repo-level release proof is now `release-grade` at the `Mac + iPhone` policy floor
- NLP claims are still validated more strongly by tests/examples than by module-specific public benchmark slices
- use [../Generated/Public-Proof-Status.md](../Generated/Public-Proof-Status.md) for the current allowed claim envelope
- detailed raw-API adoption guide: [NLP-vs-NaturalLanguage.md](NLP-vs-NaturalLanguage.md)

## Win Condition

`SwiftIntelligenceNLP` wins when a developer can go from install to validated text-analysis success faster than they can with raw `NaturalLanguage`, while still staying inside Apple-native primitives.

## Sources

- [Apple NaturalLanguage docs](https://developer.apple.com/documentation/naturallanguage)
- [huggingface/swift-transformers](https://github.com/huggingface/swift-transformers)
- [huggingface/AnyLanguageModel](https://github.com/huggingface/AnyLanguageModel)

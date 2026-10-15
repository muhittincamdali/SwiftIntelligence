# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-15

A rewrite. The 1.x package had grown to 16 modules and about 50,000 lines, most of which
returned simulated results (random confidences, fixed sentences, provider stubs), and the June
2026 commits left a manifest that no longer resolved. 2.0.0 is one library target with a
smaller, working scope: search, question answering, redaction and text analysis for an app's
own documents, on the device. No 1.x API was kept.

### Added

- `KnowledgeBase`: an actor that chunks, optionally redacts, embeds and indexes documents, and
  searches them in `semantic`, `keyword` or `hybrid` mode with metadata filters. Batches are
  added atomically; replacing a document keeps its place.
- Saving and restoring a knowledge base: `dataRepresentation()`, `save(to:options:)`,
  `init(data:…)` and `init(contentsOf:…)`, with checks for the embedder, the format version and
  the consistency of the saved data (`KnowledgeBaseError`).
- Answers: `GroundedPrompt` and `GroundedAnswer` (citations such as `[1]`, `[1, 3]`),
  `KnowledgeBase.groundedPrompt(for:…)` for any model, and on iOS 26 and macOS 26
  `KnowledgeBase.answer(_:…)` with Apple's on-device model and `KnowledgeSearchTool` for
  Foundation Models sessions (`AnswerError`).
- Embeddings: the `TextEmbedder` protocol, `HashingEmbedder` (no model, deterministic),
  `SentenceEmbedder` (`NLEmbedding`) and `ContextualEmbedder` (`NLContextualEmbedding`).
- Indexes and ranking: `VectorIndex` (exact cosine search with Accelerate, `Codable`),
  `KeywordIndex` (BM25) and `RankFusion` (reciprocal rank fusion).
- `PersonalDataRedactor` for email addresses, phone numbers, links, postal addresses, payment
  card numbers (Luhn), IBANs (mod 97 and country lengths), IP addresses and names, with
  placeholders that `RedactedText.restoringOriginals(in:)` reverses. Matching runs on a folded
  copy of the text, so full-width characters, invisible format characters, typographic dashes
  and spaces, tabs, slashes, underscores and line breaks inside card numbers and IBANs, quoted
  or punctuated email local parts, spaces or a line break around the "@", spaces before a dot
  of the domain, address literals ("jane@[192.0.2.1]") and overlapping matches do not leave
  data visible.
- `TextAnalyzer` (language, language guesses, sentiment, names, keywords, sentences) and
  `TextChunker` (sentence-based passages with overlap).
- Input checks at every public entry point: NaN and infinite vectors are rejected, crafted
  saved data with impossible sizes or vectors that are not unit length fails to decode instead
  of trapping or returning empty searches, and out-of-range numbers are clamped as documented.
- DocC catalog with the articles Getting Started, Searching Documents, Answering Questions and
  Redacting Personal Data, published to GitHub Pages by the Documentation workflow.
- `Examples/KnowledgeDemo`, an iOS and macOS app whose `ReadmeSamples.swift` holds the README
  code, which the tests run; README screenshots captured from it by
  `scripts/capture-example-screens.sh`.
- Swift Testing suites that run on macOS and an iPhone simulator; tests that need a system
  model the simulator lacks are skipped there with the reason.
- `.spi.yml` for the Swift Package Index.

### Changed

- **Breaking:** one `SwiftIntelligence` library instead of the 1.x module products; iOS 18 and
  macOS 15 minimum; Swift tools 6.2 and the Swift 6 language mode. tvOS, watchOS and visionOS
  are no longer declared because the package is not built or tested for them.
- CI runs through the shared workflows in `muhittincamdali/.github` (build and tests on macOS,
  iOS builds and simulator tests, DocC to GitHub Pages, link and wording checks), plus a
  repository workflow that builds the example app. Actions are pinned to commit SHAs.

### Removed

- The 1.x modules and their documentation, benchmarks, demo apps, templates, fastlane lanes,
  Makefile and CocoaPods podspec, and the release workflow that rebuilt GitHub releases from
  scripts that no longer existed.
- The local code of conduct and support page; the shared ones in `muhittincamdali/.github`
  apply.

## [1.2.2] - 2026-04-15

Last release of the 1.x modular package (workflow and release-note changes only). Its code is
at the `v1.2.2` tag.

## [1.2.1] - 2026-04-15

README and demo gallery changes of the 1.x package.

## [1.2.0] - 2026-04-08

Package graph, examples and CI changes of the 1.x package, and benchmark tooling that 2.0.0
removed.

## [1.1.0] - 2025-08-16

Second 1.x release.

## [1.0.0] - 2025-08-15

First public release of the 1.x multi-module package.

[Unreleased]: https://github.com/muhittincamdali/SwiftIntelligence/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/SwiftIntelligence/compare/v1.2.2...v2.0.0
[1.2.2]: https://github.com/muhittincamdali/SwiftIntelligence/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/muhittincamdali/SwiftIntelligence/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/muhittincamdali/SwiftIntelligence/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/muhittincamdali/SwiftIntelligence/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/muhittincamdali/SwiftIntelligence/releases/tag/v1.0.0

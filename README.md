<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-light.svg" alt="SwiftIntelligence: On-device search, answers and redaction for your app's text, built on Apple's frameworks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="Latest version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

A Swift package that makes the text in your iOS or macOS app searchable and answerable on the
device. Add notes, help articles or messages to a `KnowledgeBase`, then search them by words
and by meaning, have Apple's on-device model answer questions from them with citations, and
remove email addresses, card numbers and other personal data before anything is stored or sent
to a model. It is built on NaturalLanguage, Accelerate and Foundation Models, has no
dependencies, and nothing leaves the device unless your app sends it.

## Highlights

- **Hybrid search** — every passage is indexed twice, by its words (BM25) and as a vector, and
  the two rankings are merged with reciprocal rank fusion, so a search finds both exact codes
  such as "E-4012" and passages that use other words.
- **Answers with sources** — on iOS 26 and macOS 26, `answer(_:)` asks Apple's on-device model
  to answer only from the best passages and to cite them; `groundedPrompt(for:)` builds the
  same prompt for any other model, and `KnowledgeSearchTool` lets a Foundation Models session
  search by itself.
- **Redaction you can reverse** — eight kinds of personal data become placeholders such as
  `[EMAIL_1]` that a model can still refer to, and `restoringOriginals(in:)` puts the values
  back into its answer. Card numbers and IBANs must pass their check digits, and full-width
  digits, zero-width characters and groups split by spaces, tabs, dashes, dots, slashes,
  underscores or one line break do not hide a value.
- **Three embedders, or your own** — a hashing embedder that works everywhere with no model,
  Apple's sentence embedding, and Apple's contextual embedding; conform to `TextEmbedder` to
  plug in a Core ML or server model.
- **Saved between launches** — `save(to:)` writes one file with the redacted passages and their
  vectors, and loading checks that the embedder and the data match.
- **Tested** — 156 Swift Testing tests on macOS and 155 on an iPhone simulator, covering
  redaction bypass attempts, crafted saved files, NaN and overflowing inputs, every README
  sample, and an answer from the on-device model where it is available.

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Paste it into the search field at the top right of the window. Leave **Dependency Rule** at
**Up to Next Major Version** from `2.0.0`, then click **Add Package**. In the next window,
choose your app target next to **SwiftIntelligence** and click **Add Package** again.

**2. Import the module**

```swift
import SwiftIntelligence
```

Put this line at the top of the Swift file where you use the package.

**3. Use it**

In a new Xcode app (**File › New › Project… › App**), replace everything in `ContentView.swift`
with:

```swift
import SwiftUI
import SwiftIntelligence

struct ContentView: View {
    @State private var answer = "Searching…"

    var body: some View {
        Text(answer)
            .padding()
            .task { answer = await Self.bestMatch() }
    }

    static func bestMatch() async -> String {
        do {
            let knowledge = KnowledgeBase()
            try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
            try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")
            let results = try await knowledge.search("How do I return an item for a refund?")
            return results.first?.text ?? "Nothing found"
        } catch {
            return "Search failed: \(error)"
        }
    }
}
```

Press **Run** (⌘R). The app searches the two texts and shows the best match: "You can return
any item within 30 days of delivery for a full refund."

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftIntelligence", package: "SwiftIntelligence")
    ])
]
```

## Usage

Every sample below is compiled by the [example app](Examples/KnowledgeDemo) and run by the
package tests ([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)).

### Search your documents

Add documents with an identifier and optional metadata, then search in the default hybrid mode,
or by words (`.keyword`) or meaning (`.semantic`) only:

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

Adding a document with an existing identifier replaces it, `remove(id:)` deletes it, and
`search(_:limit:mode:matching:)` takes metadata pairs that results must have.

### Answer questions with the on-device model

On iOS 26 and macOS 26 with Apple Intelligence on, the system model answers from the passages
that match the question and cites them as `[1]`, `[2]`, …:

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

It throws `AnswerError.noRelevantPassages` without asking the model when nothing matches, and
`AnswerError.modelUnavailable` when Apple Intelligence is off or not supported. For another
model, `knowledge.groundedPrompt(for:)` returns the prompt and its numbered sources.

### Redact personal data

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

Pass a redactor to `KnowledgeBase(redactor:)` and only redacted passages are indexed and saved.
Redaction is a safety net, not a guarantee: data that is spelled out ("jane at example dot
com") is not found, and names come from a statistical model.

### Search by meaning

The default `HashingEmbedder` matches shared words and word forms. Apple's sentence embedding
also matches related words:

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apple's embeddings are small general models and the iOS simulator does not have them; keep the
default hybrid mode unless your own tests show that semantic search alone is better for your
texts.

### Save and restore

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Restore with the same embedder; a different one throws `KnowledgeBaseError.embedderMismatch`.

### Analyze text

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## Demo

The example app on an iPhone simulator, searching, answering and redacting eight help-center
articles:

| Search | Ask | Redact |
| --- | --- | --- |
| ![Search screen, light](docs/images/example-search-light.png) | ![Ask screen, light](docs/images/example-ask-light.png) | ![Redact screen, light](docs/images/example-redact-light.png) |
| ![Search screen, dark](docs/images/example-search-dark.png) | ![Ask screen, dark](docs/images/example-ask-dark.png) | ![Redact screen, dark](docs/images/example-redact-dark.png) |

The answer on the Ask screen is the on-device model's own wording from that run. The
screenshots are captured from [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) by
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). To run the app,
open `KnowledgeDemo.xcodeproj` in Xcode, choose an iPhone simulator or **My Mac**, and press
**Run**; [Examples/README.md](Examples/README.md) has the details.

## Documentation

Reference documentation and articles:

- [API reference](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/)
  (DocC, published to GitHub Pages from `main`)
- Build it locally in Xcode with **Product › Build Documentation**, or from the command line:

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted)
  — add the package, index and search, save between launches, analyze a text
  ([source](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments)
  — search modes, choosing an embedder, metadata filters and passage size
  ([source](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions)
  — on-device answers, prompts for other models, streaming and the search tool
  ([source](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata)
  — the eight kinds, replacement styles, restoring values, and what is not caught
  ([source](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## Requirements

| Platform | Minimum version |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| Toolchain | Swift 6.2 · Xcode 26+ |

Answers from the on-device model need iOS 26 or macOS 26 on a device that supports Apple
Intelligence, with Apple Intelligence turned on. The iOS simulator lacks the NaturalLanguage
name, sentiment and part-of-speech models and the sentence embedding: there `TextAnalyzer`
finds no names or keywords, the redactor finds no names, and `SentenceEmbedder` throws. CI
builds with the default Xcode of GitHub's `macos-26` runner image; the package is developed
with Xcode 27.

## Architecture

- `Text/` — `TextAnalyzer`, `TextChunker` and the shared term normalization (case, accent and
  width folding; `NLTokenizer` word boundaries, so Chinese and Japanese split into words).
- `Privacy/` — `PersonalDataRedactor`. Patterns run on a folded copy of the text
  (`FoldedText`) whose map leads every match back to the original characters; check digits
  (`Checksums`) confirm cards and IBANs; `NSDataDetector` finds phone numbers, links and
  addresses, and `NLTagger` names.
- `Embedding/` — the `TextEmbedder` protocol and its three implementations.
- `Search/` — `VectorIndex` (exact cosine search with one Accelerate matrix multiplication),
  `KeywordIndex` (BM25), `RankFusion` and the `KnowledgeBase` actor that ties them together and
  saves them.
- `Generation/` — `GroundedPrompt`, `GroundedAnswer` and, behind `canImport(FoundationModels)`
  and availability checks, `answer(_:)` and `KnowledgeSearchTool`.

`KnowledgeBase` computes every vector of a batch before it changes anything, so an embedding
error leaves it unchanged. Indexes are exact and in memory: they suit the documents of one user
or one app, up to tens of thousands of passages.

## Roadmap

- Text from PDFs and images (PDFKit and the Vision text recognizer) as document sources.
- A Core ML sentence-encoder embedder for stronger semantic search than Apple's built-in
  embeddings.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).

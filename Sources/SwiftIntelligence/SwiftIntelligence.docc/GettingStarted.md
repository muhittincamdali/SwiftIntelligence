# Getting Started

Add the package, index a few documents and search them.

## Add the package

In Xcode choose **File > Add Package Dependencies…**, paste
`https://github.com/muhittincamdali/SwiftIntelligence.git` into the search field at the top
right, leave **Dependency Rule** at **Up to Next Major Version** from `2.0.0`, choose
**Add Package**, and in the next sheet add the **SwiftIntelligence** library to your app
target. Use 2.0.0 or later: the 1.x releases had a different, unrelated API. In a package, add
it to `Package.swift` instead:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "2.0.0")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "SwiftIntelligence", package: "SwiftIntelligence")
    ])
]
```

The package needs Swift 6.2 tools (Xcode 26 or later) and runs on iOS 18 and macOS 15.
Answers from the on-device model need iOS 26 or macOS 26 with Apple Intelligence turned on.

## Index and search

A ``KnowledgeBase`` is an actor, so call it with `await` from any task:

```swift
import SwiftIntelligence

let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
```

Each ``SearchResult`` names its document, the passage and a score. Adding a document with an
identifier that is already there replaces it; ``KnowledgeBase/remove(id:)`` deletes one.

## Keep the index between launches

Embedding documents takes time, so save the knowledge base and read it back on the next
launch:

```swift
let file = URL.applicationSupportDirectory.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Restore it with the same embedder; a different one throws
``KnowledgeBaseError/embedderMismatch(saved:current:)`` because its vectors would not compare.

## Analyze a text

``TextAnalyzer`` reads the language, sentiment, names and keywords of a single text:

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
analysis.language              // .english
analysis.entities.map(\.text)  // ["Tim Cook", "Cupertino"]
```

The name, sentiment and keyword features use NaturalLanguage models that Macs and devices
have but the iOS simulator does not; there they return no names, `nil` sentiment and no
keywords.

## Next steps

- <doc:SearchingDocuments> explains the search modes and how to choose an embedder.
- <doc:AnsweringQuestions> adds answers from the on-device model.
- <doc:RedactingPersonalData> removes personal data before it is indexed or sent to a model.

# ``SwiftIntelligence``

Search, question answering, redaction and text analysis for your app's documents, on the device, with Apple's frameworks.

## Overview

SwiftIntelligence turns the text your app already has (notes, help articles, messages,
scanned receipts) into something users can search and ask questions about, without a server
and without sending the text anywhere. It is one Swift package with no dependencies, built on
NaturalLanguage, Accelerate and, where available, Foundation Models.

```swift
import SwiftIntelligence

let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
results.first?.documentID   // "returns"
```

A ``KnowledgeBase`` splits documents into passages, can remove personal data from them with
a ``PersonalDataRedactor``, and indexes every passage twice: as a vector for search by meaning
and by its words for keyword search. Hybrid search merges both rankings. On iOS 26 and
macOS 26, ``KnowledgeBase/answer(_:limit:mode:matching:model:)`` has Apple's on-device model
answer from the best passages and cite them.

Each piece also works on its own: ``TextAnalyzer`` for language, sentiment, names and
keywords; ``TextChunker`` to split long text; ``VectorIndex`` and ``KeywordIndex`` for your own
vectors and texts; ``RankFusion`` to merge rankings.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:SearchingDocuments>
- <doc:AnsweringQuestions>
- <doc:RedactingPersonalData>

### Knowledge base

- ``KnowledgeBase``
- ``SearchMode``
- ``SearchResult``
- ``KnowledgeBaseError``

### Answers

- ``GroundedPrompt``
- ``GroundedAnswer``
- ``KnowledgeSearchTool``
- ``AnswerError``

### Embeddings

- ``TextEmbedder``
- ``HashingEmbedder``
- ``SentenceEmbedder``
- ``ContextualEmbedder``
- ``EmbeddingError``

### Indexes and ranking

- ``VectorIndex``
- ``KeywordIndex``
- ``RankFusion``
- ``ScoredID``
- ``IndexError``

### Personal data

- ``PersonalDataRedactor``
- ``PersonalDataKind``
- ``PersonalDataMatch``
- ``RedactedText``

### Text analysis

- ``TextAnalyzer``
- ``TextAnalysis``
- ``LanguageGuess``
- ``NamedEntity``
- ``Keyword``
- ``TextChunker``
- ``TextChunk``

# Searching Documents

Choose a search mode and an embedder, filter by metadata, and keep passages a useful size.

## Overview

``KnowledgeBase/search(_:limit:mode:matching:)`` ranks passages in one of three
``SearchMode``s:

| Mode | Ranks by | Finds |
| --- | --- | --- |
| ``SearchMode/keyword`` | BM25 over the words of each passage | exact names, codes and numbers, such as "E-4012" |
| ``SearchMode/semantic`` | cosine similarity of the passage and query vectors | passages that share meaning with the query, as far as the embedder knows it |
| ``SearchMode/hybrid`` (default) | both lists merged with reciprocal rank fusion | either kind; a passage near the top of both rises |

Scores are only comparable within one result list: cosine similarity for semantic search,
BM25 for keyword search and the fused rank score for hybrid search.

## Choose an embedder

The embedder turns passages and queries into vectors. Three come with the package; conform
your own type to ``TextEmbedder`` to use another model, for example a Core ML sentence
encoder.

| Embedder | Model | Languages | Notes |
| --- | --- | --- | --- |
| ``HashingEmbedder`` (default) | none | all | Matches shared words and word parts ("invoice", "invoices"); the same vectors on every device; works in the simulator and in tests. Does not know synonyms. |
| ``SentenceEmbedder`` | `NLEmbedding.sentenceEmbedding` | English, Spanish, French, German, Italian, Portuguese, Simplified Chinese | Knows that "laptop" and "computer" are related. Not in the iOS simulator. |
| ``ContextualEmbedder`` | `NLContextualEmbedding` | one model per writing system, for example every Latin-script language | Assets may need a download: call ``ContextualEmbedder/prepare()`` first. |

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apple's embeddings are small, general models. They tell related topics apart, but the margin
between the best and the second-best passage is often small; hybrid search, which also counts
shared words, is the safer default. Measure with your own documents and questions before
relying on semantic search alone.

## Filter by metadata

Give documents metadata when you add them and pass the pairs a result must have:

```swift
try await knowledge.add([
    .init(id: "returns-de", text: "Rücksendungen sind 30 Tage lang möglich.", metadata: ["language": "de"]),
    .init(id: "returns-en", text: "Returns are possible for 30 days.", metadata: ["language": "en"]),
])
let german = try await knowledge.search("Rücksendung", matching: ["language": "de"])
```

## Passage size

``TextChunker`` splits each document at sentence boundaries into passages of at most 800
characters, repeating one sentence between neighbors so a fact on a boundary is still found.
Smaller passages make results more precise and prompts shorter; larger ones keep more context
together:

```swift
let knowledge = KnowledgeBase(chunker: TextChunker(maximumLength: 400, overlap: 1))
```

## Scale

``VectorIndex`` compares the query with every stored vector in one matrix multiplication
(exact search, no approximate index), and ``KeywordIndex`` keeps an inverted index in memory.
Both suit the documents of one user or one app: thousands to tens of thousands of passages.
The whole knowledge base lives in memory and is saved as one file.

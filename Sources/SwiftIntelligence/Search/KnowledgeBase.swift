import Foundation

/// A searchable collection of your app's documents: notes, help articles, messages, scanned
/// receipts. Everything is computed and stored on the device.
///
/// Adding a document splits it into passages with a ``TextChunker``, optionally redacts
/// personal data with a ``PersonalDataRedactor``, and indexes every passage twice: as a vector
/// from the ``TextEmbedder`` for search by meaning, and by its words for keyword search.
/// ``search(_:limit:mode:matching:)`` returns the best passages;
/// ``answer(_:limit:mode:matching:model:)`` has Apple's on-device model answer from them, and
/// ``groundedPrompt(for:limit:mode:matching:passageBudget:)`` builds the same prompt for any
/// other model.
///
/// ```swift
/// let knowledge = KnowledgeBase()
/// try await knowledge.add("Returns are accepted within 30 days of delivery.", id: "returns")
/// let results = try await knowledge.search("How long do I have to send it back?")
/// ```
public actor KnowledgeBase {
    /// A document to add.
    public struct Document: Hashable, Sendable {
        public let id: String
        public let text: String
        public let metadata: [String: String]

        public init(id: String, text: String, metadata: [String: String] = [:]) {
            self.id = id
            self.text = text
            self.metadata = metadata
        }
    }

    struct StoredDocument: Codable, Hashable, Sendable {
        let id: String
        let metadata: [String: String]
        let passages: [String]
    }

    /// Hybrid search fuses this many candidates per requested result from each ranking.
    private static let candidatesPerResult = 4
    private static let minimumCandidates = 20

    /// Computes the vectors of passages and queries.
    public nonisolated let embedder: any TextEmbedder
    /// Splits documents into passages.
    public nonisolated let chunker: TextChunker
    /// Removes personal data from documents before they are indexed, when set.
    public nonisolated let redactor: PersonalDataRedactor?

    var documents: [String: StoredDocument] = [:]
    var documentOrder: [String] = []
    var vectors: VectorIndex
    var keywords = KeywordIndex()

    /// Creates an empty knowledge base.
    ///
    /// - Parameters:
    ///   - embedder: Computes vectors. ``HashingEmbedder`` works everywhere without a model;
    ///     ``SentenceEmbedder`` and ``ContextualEmbedder`` also match passages that use other
    ///     words for the same thing.
    ///   - chunker: Splits documents into passages.
    ///   - redactor: Replaces personal data in documents before they are stored. The original
    ///     values are not kept.
    public init(embedder: any TextEmbedder = HashingEmbedder(), chunker: TextChunker = TextChunker(), redactor: PersonalDataRedactor? = nil) {
        self.init(embedder: embedder, chunker: chunker, redactor: redactor, contents: nil)
    }

    /// The indexed state, as restored from saved data.
    struct Contents {
        let documents: [String: StoredDocument]
        let order: [String]
        let vectors: VectorIndex
        let keywords: KeywordIndex
    }

    init(embedder: any TextEmbedder, chunker: TextChunker, redactor: PersonalDataRedactor?, contents: Contents?) {
        self.embedder = embedder
        self.chunker = chunker
        self.redactor = redactor
        self.vectors = contents?.vectors ?? VectorIndex(dimension: embedder.dimension)
        if let contents {
            documents = contents.documents
            documentOrder = contents.order
            keywords = contents.keywords
        }
    }

    /// The number of documents.
    public var count: Int { documents.count }

    /// The number of indexed passages across all documents.
    public var passageCount: Int { vectors.count }

    /// The identifiers of the documents, in the order they were first added. Replacing a
    /// document keeps its place.
    public var documentIDs: [String] { documentOrder }

    /// Whether a document with this identifier has been added.
    public func contains(id: String) -> Bool { documents[id] != nil }

    /// The metadata of a document, or `nil` if there is no such document.
    public func metadata(for id: String) -> [String: String]? { documents[id]?.metadata }

    /// The indexed passages of a document, after redaction.
    public func passages(for id: String) -> [String]? { documents[id]?.passages }

    /// Adds a document, replacing any document with the same identifier.
    ///
    /// - Returns: The document's identifier.
    @discardableResult
    public func add(_ text: String, id: String = UUID().uuidString, metadata: [String: String] = [:]) async throws -> String {
        try await add([Document(id: id, text: text, metadata: metadata)])
        return id
    }

    /// Adds documents, replacing any documents with the same identifiers.
    ///
    /// All vectors are computed before anything is stored, so an embedding error leaves the
    /// knowledge base unchanged.
    public func add(_ newDocuments: [Document]) async throws {
        var prepared: [(StoredDocument, [[Float]])] = []
        for document in newDocuments {
            let text = redactor?.redact(document.text).text ?? document.text
            let passages = chunker.chunks(of: text).map(\.text)
            var embeddings: [[Float]] = []
            for passage in passages {
                let embedding = try await embedder.embed(passage)
                // Checked here, before anything is stored, so a bad vector cannot leave a
                // document half indexed.
                try vectors.validate(embedding)
                embeddings.append(embedding)
            }
            prepared.append((StoredDocument(id: document.id, metadata: document.metadata, passages: passages), embeddings))
        }
        // No suspension point from here on: concurrent calls cannot interleave their changes.
        for (document, embeddings) in prepared {
            try store(document, embeddings: embeddings)
        }
    }

    /// Removes a document and its passages. Does nothing for an unknown identifier.
    public func remove(id: String) {
        removePassages(of: id)
        guard documents.removeValue(forKey: id) != nil else { return }
        documentOrder.removeAll { $0 == id }
    }

    /// Removes every document.
    public func removeAll() {
        documents = [:]
        documentOrder = []
        vectors = VectorIndex(dimension: embedder.dimension)
        keywords = KeywordIndex()
    }

    /// The passages that best match `query`, best first.
    ///
    /// - Parameters:
    ///   - limit: The most passages to return.
    ///   - mode: How to rank; ``SearchMode/hybrid`` by default.
    ///   - metadata: Only documents whose metadata contains all of these key-value pairs.
    public func search(
        _ query: String,
        limit: Int = 5,
        mode: SearchMode = .hybrid,
        matching metadata: [String: String] = [:]
    ) async throws -> [SearchResult] {
        guard limit > 0, !documents.isEmpty, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        // The only suspension point; everything after it reads one consistent state.
        let queryVector = mode == .keyword ? nil : try await embedder.embed(query)
        let candidateCount = mode == .hybrid ? Self.hybridCandidateCount(for: limit) : limit
        let isIncluded = includedPassages(matching: metadata)
        // A similarity of 0 or less means nothing in common, not a weak match.
        let semantic = try queryVector.map { try vectors.search($0, limit: candidateCount, where: isIncluded).filter { $0.score > 0 } } ?? []
        let keyword = mode == .semantic ? [] : keywords.search(query, limit: candidateCount, where: isIncluded)
        let ranked = switch mode {
        case .semantic: semantic
        case .keyword: keyword
        case .hybrid: RankFusion.fuse([.init(semantic), .init(keyword)])
        }
        return ranked.prefix(limit).compactMap(result)
    }

    /// How many candidates hybrid search takes from each ranking. Clamped so that a very
    /// large `limit` cannot overflow.
    static func hybridCandidateCount(for limit: Int) -> Int {
        let (product, overflow) = limit.multipliedReportingOverflow(by: candidatesPerResult)
        return overflow ? Int.max : max(product, minimumCandidates)
    }

    func store(_ document: StoredDocument, embeddings: [[Float]]) throws {
        let isNew = documents[document.id] == nil
        removePassages(of: document.id)
        for (index, passage) in document.passages.enumerated() {
            let key = Self.passageKey(document.id, index)
            try vectors.insert(embeddings[index], for: key)
            keywords.insert(passage, for: key)
        }
        documents[document.id] = document
        if isNew { documentOrder.append(document.id) }
    }

    private func removePassages(of id: String) {
        guard let document = documents[id] else { return }
        for index in document.passages.indices {
            let key = Self.passageKey(id, index)
            vectors.remove(key)
            keywords.remove(key)
        }
    }

    private func includedPassages(matching metadata: [String: String]) -> (String) -> Bool {
        guard !metadata.isEmpty else { return { _ in true } }
        let documents = documents
        return { key in
            guard let (id, _) = Self.parsePassageKey(key), let stored = documents[id] else { return false }
            return metadata.allSatisfy { stored.metadata[$0.key] == $0.value }
        }
    }

    private func result(for scored: ScoredID) -> SearchResult? {
        guard let (id, index) = Self.parsePassageKey(scored.id),
              let document = documents[id], document.passages.indices.contains(index) else { return nil }
        return SearchResult(documentID: id, passageIndex: index, text: document.passages[index], score: scored.score, metadata: document.metadata)
    }

    /// Passage keys are "<document id>#<index>"; the index is parsed from the last "#", so
    /// document identifiers may contain "#" themselves.
    static func passageKey(_ documentID: String, _ index: Int) -> String {
        "\(documentID)#\(index)"
    }

    static func parsePassageKey(_ key: String) -> (String, Int)? {
        guard let separator = key.lastIndex(of: "#"), let index = Int(key[key.index(after: separator)...]) else { return nil }
        return (String(key[..<separator]), index)
    }
}

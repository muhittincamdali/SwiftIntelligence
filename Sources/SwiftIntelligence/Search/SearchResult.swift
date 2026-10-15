/// How ``KnowledgeBase/search(_:limit:mode:matching:)`` ranks passages.
public enum SearchMode: String, Hashable, Sendable, CaseIterable {
    /// By meaning: the cosine similarity of embeddings.
    case semantic
    /// By shared words: BM25.
    case keyword
    /// Both rankings merged with reciprocal rank fusion. Finds passages that say the same
    /// thing in other words and passages with an exact name, code or number.
    case hybrid
}

/// A passage that matches a search.
public struct SearchResult: Hashable, Sendable, Identifiable {
    /// The document the passage comes from.
    public let documentID: String
    /// The position of the passage in its document, starting at 0.
    public let passageIndex: Int
    /// The passage text (after redaction, if the knowledge base redacts).
    public let text: String
    /// The relevance score; higher is better. Its scale depends on the mode: cosine
    /// similarity for ``SearchMode/semantic``, BM25 for ``SearchMode/keyword`` and the fused
    /// rank score for ``SearchMode/hybrid``. Compare scores within one result list only.
    public let score: Double
    /// The metadata of the document.
    public let metadata: [String: String]

    public var id: String { "\(documentID)#\(passageIndex)" }

    public init(documentID: String, passageIndex: Int, text: String, score: Double, metadata: [String: String]) {
        self.documentID = documentID
        self.passageIndex = passageIndex
        self.text = text
        self.score = score
        self.metadata = metadata
    }
}


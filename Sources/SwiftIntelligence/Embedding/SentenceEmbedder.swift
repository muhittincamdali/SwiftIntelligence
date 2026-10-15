import NaturalLanguage

/// Apple's built-in sentence embedding (`NLEmbedding.sentenceEmbedding(for:)`).
///
/// The system ships it for English, Spanish, French, German, Italian, Portuguese and
/// Simplified Chinese. It places texts with related meaning close together even when they
/// share no words ("car" and "vehicle"). The initializer throws for other languages, and on
/// devices or simulators where the model is missing.
///
/// ```swift
/// let embedder = try SentenceEmbedder(language: .english)
/// let knowledge = KnowledgeBase(embedder: embedder)
/// ```
public actor SentenceEmbedder: TextEmbedder {
    public nonisolated let identifier: String
    public nonisolated let dimension: Int
    /// The language the embedding was created for.
    public nonisolated let language: NLLanguage
    private let embedding: NLEmbedding

    /// Loads the sentence embedding for `language`.
    ///
    /// - Throws: ``EmbeddingError/unsupportedLanguage(_:)`` when the system has no sentence
    ///   embedding for the language.
    public init(language: NLLanguage = .english) throws {
        guard let embedding = NLEmbedding.sentenceEmbedding(for: language) else {
            throw EmbeddingError.unsupportedLanguage(language)
        }
        self.embedding = embedding
        self.language = language
        self.dimension = embedding.dimension
        self.identifier = "nl-sentence-\(language.rawValue)-r\(embedding.revision)-\(embedding.dimension)"
    }

    public func embed(_ text: String) async throws -> [Float] {
        guard let vector = embedding.vector(for: text) else { throw EmbeddingError.noVector }
        return VectorMath.normalized(vector.map(Float.init))
    }
}

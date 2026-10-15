import Foundation
import NaturalLanguage

/// Apple's contextual embedding model (`NLContextualEmbedding`), averaged over the tokens of
/// a text.
///
/// One model covers a whole writing system: the Latin-script model handles English, Turkish,
/// German, Spanish and other Latin-script languages, so texts in different languages can be
/// searched together. The model files are system assets that may not be on the device yet:
/// call ``prepare()`` once (it downloads them if needed) before embedding.
///
/// Text longer than the model's ``maximumSequenceLength`` tokens is embedded from its
/// beginning only; keep passages short with ``TextChunker``.
///
/// ```swift
/// let embedder = try ContextualEmbedder(language: .turkish)
/// try await embedder.prepare()
/// let knowledge = KnowledgeBase(embedder: embedder)
/// ```
public actor ContextualEmbedder: TextEmbedder {
    public nonisolated let identifier: String
    public nonisolated let dimension: Int
    /// The longest text, in model tokens, that the model reads.
    public nonisolated let maximumSequenceLength: Int
    private let model: NLContextualEmbedding
    private let language: NLLanguage
    private var isLoaded = false

    /// Finds the contextual embedding model for `language`.
    ///
    /// - Throws: ``EmbeddingError/unsupportedLanguage(_:)`` when no model covers the language.
    public init(language: NLLanguage = .english) throws {
        guard let model = NLContextualEmbedding(language: language) else {
            throw EmbeddingError.unsupportedLanguage(language)
        }
        self.model = model
        self.language = language
        self.dimension = model.dimension
        self.maximumSequenceLength = model.maximumSequenceLength
        self.identifier = "nl-contextual-\(model.modelIdentifier)-r\(model.revision)"
    }

    /// Whether the model's assets are on the device.
    public var hasAssets: Bool { model.hasAvailableAssets }

    /// Downloads the model's assets if they are missing, then loads the model.
    ///
    /// - Throws: ``EmbeddingError/assetsNotAvailable`` when the download is not possible, for
    ///   example without a network connection.
    public func prepare() async throws {
        if !model.hasAvailableAssets {
            let result = try await model.requestAssets()
            guard result == .available else { throw EmbeddingError.assetsNotAvailable }
        }
        try loadIfNeeded()
    }

    public func embed(_ text: String) async throws -> [Float] {
        guard model.hasAvailableAssets else { throw EmbeddingError.assetsNotAvailable }
        try loadIfNeeded()
        let result = try model.embeddingResult(for: text, language: language)
        var tokens: [[Float]] = []
        result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, _ in
            tokens.append(vector.map(Float.init))
            return true
        }
        guard let mean = VectorMath.mean(tokens) else { throw EmbeddingError.noVector }
        return VectorMath.normalized(mean)
    }

    private func loadIfNeeded() throws {
        guard !isLoaded else { return }
        try model.load()
        isLoaded = true
    }
}

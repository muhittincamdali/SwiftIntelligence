import Foundation
import NaturalLanguage

/// Turns text into a vector so that texts with similar meaning get similar vectors.
///
/// The package has three embedders:
///
/// - ``HashingEmbedder``: matches shared words and word parts. Works for every language and
///   needs no model, but does not know synonyms.
/// - ``SentenceEmbedder``: Apple's sentence embedding for one of seven languages; knows
///   that "car" and "vehicle" are related.
/// - ``ContextualEmbedder``: Apple's contextual embedding model for a whole writing system
///   (for example every Latin-script language); its assets may need a download first.
///
/// Conform your own type to use another model, for example a Core ML model.
public protocol TextEmbedder: Sendable {
    /// Names the model and its settings. ``KnowledgeBase`` stores it with a saved index and
    /// refuses to load the index with a different embedder, whose vectors would not compare.
    var identifier: String { get }
    /// The length of every vector this embedder returns.
    var dimension: Int { get }
    /// The vector for `text`, with ``dimension`` elements.
    func embed(_ text: String) async throws -> [Float]
}

/// Errors from the embedders in this package.
public enum EmbeddingError: Error, Hashable, Sendable {
    /// The system has no embedding of this kind for the language.
    case unsupportedLanguage(NLLanguage)
    /// The contextual embedding's assets are not on the device yet; call
    /// ``ContextualEmbedder/prepare()`` first.
    case assetsNotAvailable
    /// The model could not produce a vector for the text, for example because it has no
    /// known words.
    case noVector
}

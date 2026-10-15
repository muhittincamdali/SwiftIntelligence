import Foundation

/// Errors from saving and loading a ``KnowledgeBase``.
public enum KnowledgeBaseError: Error, Hashable, Sendable {
    /// The saved knowledge base was built with a different embedder, whose vectors cannot be
    /// compared with the current one's. Load it with the embedder named in `saved`, or add the
    /// documents again.
    case embedderMismatch(saved: String, current: String)
    /// The data was written by a newer version of this package.
    case unsupportedFormat(Int)
    /// The data decodes, but its parts do not fit together, for example a passage without a
    /// vector. It was changed or damaged after it was saved.
    case inconsistentData(String)
}

extension KnowledgeBase {
    /// The saved form: the documents with their redacted passages, and the passage vectors.
    /// The keyword index is rebuilt from the passages on load.
    struct Snapshot: Codable {
        static let currentFormat = 1

        let format: Int
        let embedder: String
        let documents: [StoredDocument]
        let vectors: VectorIndex
    }

    /// The knowledge base as a binary property list, for ``init(data:embedder:chunker:redactor:)``.
    ///
    /// Only passages are saved, after redaction; the original document texts are not.
    public func dataRepresentation() throws -> Data {
        let snapshot = Snapshot(
            format: Snapshot.currentFormat,
            embedder: embedder.identifier,
            documents: documentOrder.compactMap { documents[$0] },
            vectors: vectors
        )
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return try encoder.encode(snapshot)
    }

    /// Writes the knowledge base to `url`.
    ///
    /// - Parameters:
    ///   - url: The file to write; it is replaced if it exists.
    ///   - options: How to write; atomic by default. On iOS, add `.completeFileProtection` to
    ///     keep the file encrypted while the device is locked.
    public func save(to url: URL, options: Data.WritingOptions = [.atomic]) throws {
        try dataRepresentation().write(to: url, options: options)
    }

    /// Restores a knowledge base from ``dataRepresentation()``.
    ///
    /// - Parameters:
    ///   - data: Data from ``dataRepresentation()``.
    ///   - embedder: Must be the embedder the data was saved with (the same
    ///     ``TextEmbedder/identifier``); its vectors are compared with the saved ones.
    ///   - chunker: Splits documents added from now on.
    ///   - redactor: Redacts documents added from now on.
    /// - Throws: ``KnowledgeBaseError`` when the data comes from another embedder, a newer
    ///   format or does not fit together; `DecodingError` when it is not a saved knowledge base.
    public init(
        data: Data,
        embedder: any TextEmbedder = HashingEmbedder(),
        chunker: TextChunker = TextChunker(),
        redactor: PersonalDataRedactor? = nil
    ) throws {
        let snapshot = try PropertyListDecoder().decode(Snapshot.self, from: data)
        guard snapshot.format <= Snapshot.currentFormat else {
            throw KnowledgeBaseError.unsupportedFormat(snapshot.format)
        }
        guard snapshot.embedder == embedder.identifier, snapshot.vectors.dimension == embedder.dimension else {
            throw KnowledgeBaseError.embedderMismatch(saved: snapshot.embedder, current: embedder.identifier)
        }
        self.init(embedder: embedder, chunker: chunker, redactor: redactor, contents: try Self.restore(snapshot))
    }

    /// Reads a knowledge base saved with ``save(to:options:)``.
    ///
    /// - Parameters:
    ///   - url: The file written by ``save(to:options:)``.
    ///   - embedder: Must be the embedder the file was saved with.
    ///   - chunker: Splits documents added from now on.
    ///   - redactor: Redacts documents added from now on.
    /// - Throws: The errors of ``init(data:embedder:chunker:redactor:)``, or a file error.
    public init(
        contentsOf url: URL,
        embedder: any TextEmbedder = HashingEmbedder(),
        chunker: TextChunker = TextChunker(),
        redactor: PersonalDataRedactor? = nil
    ) throws {
        try self.init(data: Data(contentsOf: url), embedder: embedder, chunker: chunker, redactor: redactor)
    }

    /// Checks that every passage has a vector and every vector a passage, and rebuilds the
    /// keyword index.
    private static func restore(_ snapshot: Snapshot) throws -> Contents {
        var documents: [String: StoredDocument] = [:]
        var keywords = KeywordIndex()
        var passageCount = 0
        for document in snapshot.documents {
            guard documents.updateValue(document, forKey: document.id) == nil else {
                throw KnowledgeBaseError.inconsistentData("The document \"\(document.id)\" appears twice.")
            }
            for (index, passage) in document.passages.enumerated() {
                let key = passageKey(document.id, index)
                guard snapshot.vectors.contains(key) else {
                    throw KnowledgeBaseError.inconsistentData("The passage \(key) has no vector.")
                }
                keywords.insert(passage, for: key)
            }
            passageCount += document.passages.count
        }
        guard passageCount == snapshot.vectors.count else {
            throw KnowledgeBaseError.inconsistentData("There are \(snapshot.vectors.count) vectors for \(passageCount) passages.")
        }
        return Contents(documents: documents, order: snapshot.documents.map(\.id), vectors: snapshot.vectors, keywords: keywords)
    }
}

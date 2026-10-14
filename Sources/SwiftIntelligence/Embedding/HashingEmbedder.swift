/// An embedder that needs no model: it hashes words and three-letter word parts into a
/// fixed-size vector (feature hashing).
///
/// Texts that share words, or forms of the same word ("invoice", "invoices"), get similar
/// vectors in any language, and the result is the same on every device and every run. It does
/// not know that different words mean the same thing; use ``SentenceEmbedder`` or
/// ``ContextualEmbedder`` for that. ``KnowledgeBase`` uses it by default because it works
/// everywhere, including in tests and on the simulator.
public struct HashingEmbedder: TextEmbedder, Hashable {
    /// Whole words count fully; word parts let related forms and typos match a little.
    private static let wordWeight: Float = 1
    private static let trigramWeight: Float = 0.5

    public let dimension: Int

    public var identifier: String { "hashing-v1-\(dimension)" }

    /// Creates an embedder.
    ///
    /// - Parameter dimension: The vector length. Larger vectors have fewer collisions between
    ///   unrelated words. Values below 16 are raised to 16.
    public init(dimension: Int = 512) {
        self.dimension = max(16, dimension)
    }

    public func embed(_ text: String) async throws -> [Float] {
        vector(for: text)
    }

    /// The vector, unit length unless the text has no words (then all zeros).
    func vector(for text: String) -> [Float] {
        var vector = [Float](repeating: 0, count: dimension)
        for term in SearchTerms.terms(in: text) {
            add(term, weight: Self.wordWeight, to: &vector)
            for trigram in Self.trigrams(of: term) {
                add(trigram, weight: Self.trigramWeight, to: &vector)
            }
        }
        return VectorMath.normalized(vector)
    }

    /// One hash picks the slot and the sign, so collisions cancel out on average instead of
    /// adding up.
    private func add(_ feature: String, weight: Float, to vector: inout [Float]) {
        let hash = Self.fnv1a(feature)
        let slot = Int(hash % UInt64(dimension))
        vector[slot] += hash >> 63 == 0 ? weight : -weight
    }

    /// Three-character pieces of the word with boundary markers: "cat" gives "#ca", "cat", "at#".
    static func trigrams(of term: String) -> [String] {
        let characters = Array("#\(term)#")
        guard characters.count > 3 else { return [] }
        return (0...(characters.count - 3)).map { String(characters[$0..<($0 + 3)]) }
    }

    /// 64-bit FNV-1a. Swift's `Hasher` is seeded per process, so it cannot be used for
    /// vectors that are saved and compared later.
    static func fnv1a(_ text: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return hash
    }
}

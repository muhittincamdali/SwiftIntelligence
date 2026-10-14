import NaturalLanguage
import Testing
@testable import SwiftIntelligence

@Suite("VectorMath")
struct VectorMathTests {
    @Test("normalizes to unit length and leaves zero vectors alone")
    func normalize() {
        #expect(VectorMath.normalized([3, 4]) == [0.6, 0.8])
        #expect(VectorMath.normalized([0, 0, 0]) == [0, 0, 0])
    }

    @Test("computes cosine similarity independent of length")
    func cosine() {
        #expect(VectorMath.cosineSimilarity([1, 0], [5, 0]) == 1)
        #expect(VectorMath.cosineSimilarity([1, 0], [0, 2]) == 0)
        #expect(VectorMath.cosineSimilarity([1, 1], [-1, -1]) == -1)
        #expect(VectorMath.cosineSimilarity([0, 0], [1, 1]) == 0)
    }

    @Test("averages vectors element by element")
    func mean() {
        #expect(VectorMath.mean([[1, 2], [3, 6]]) == [2, 4])
        #expect(VectorMath.mean([]) == nil)
    }
}

@Suite("HashingEmbedder")
struct HashingEmbedderTests {
    let embedder = HashingEmbedder()

    private func similarity(_ lhs: String, _ rhs: String) -> Float {
        VectorMath.cosineSimilarity(embedder.vector(for: lhs), embedder.vector(for: rhs))
    }

    @Test("returns unit vectors of the configured dimension")
    func shape() async throws {
        let vector = try await HashingEmbedder(dimension: 64).embed("Quarterly report")
        #expect(vector.count == 64)
        #expect(abs(VectorMath.dot(vector, vector) - 1) < 0.0001)
    }

    @Test("returns a zero vector for text without words")
    func empty() {
        #expect(embedder.vector(for: "  ...  ").allSatisfy { $0 == 0 })
    }

    @Test("gives the same vector on every call, so saved vectors stay comparable")
    func deterministic() {
        #expect(embedder.vector(for: "Delivery is delayed") == embedder.vector(for: "Delivery is delayed"))
        #expect(HashingEmbedder.fnv1a("a") == 0xaf63_dc4c_8601_ec8c)
    }

    @Test("ranks texts with shared words above unrelated ones")
    func sharedWords() {
        let query = "invoice payment overdue"
        #expect(similarity(query, "The invoice payment is overdue by ten days") > similarity(query, "The garden needs watering"))
    }

    @Test("matches other forms of a word through word parts")
    func wordForms() {
        #expect(similarity("invoices", "invoice") > similarity("invoices", "delivery"))
        #expect(similarity("faturalar", "fatura") > similarity("faturalar", "teslimat"))
    }

    @Test("ignores case and accents")
    func folding() {
        #expect(similarity("CAFÉ Menü", "cafe menu") > 0.999)
    }

    @Test("builds trigrams with word boundaries")
    func trigrams() {
        #expect(HashingEmbedder.trigrams(of: "cat") == ["#ca", "cat", "at#"])
        #expect(HashingEmbedder.trigrams(of: "a") == [])
    }

    @Test("names its settings in the identifier and clamps tiny dimensions")
    func identifier() {
        #expect(HashingEmbedder(dimension: 256).identifier == "hashing-v1-256")
        #expect(HashingEmbedder(dimension: 2).dimension == 16)
    }
}

@Suite("SentenceEmbedder", .enabled(if: NLEmbedding.sentenceEmbedding(for: .english) != nil, "needs the English sentence embedding"))
struct SentenceEmbedderTests {
    @Test("places related sentences closer than unrelated ones")
    func meaning() async throws {
        let embedder = try SentenceEmbedder(language: .english)
        let car = try await embedder.embed("I parked my car in the garage.")
        let vehicle = try await embedder.embed("The vehicle is in the garage.")
        let recipe = try await embedder.embed("Whisk the eggs with sugar until fluffy.")
        #expect(car.count == embedder.dimension)
        #expect(VectorMath.cosineSimilarity(car, vehicle) > VectorMath.cosineSimilarity(car, recipe))
        #expect(embedder.identifier.hasPrefix("nl-sentence-en-"))
    }
}

@Test("SentenceEmbedder throws for a language without a sentence embedding")
func sentenceEmbedderUnsupported() {
    #expect(throws: EmbeddingError.unsupportedLanguage(.icelandic)) {
        try SentenceEmbedder(language: .icelandic)
    }
}

@Suite("ContextualEmbedder", .enabled(if: NLContextualEmbedding(language: .english)?.hasAvailableAssets == true, "needs the Latin-script contextual embedding assets"))
struct ContextualEmbedderTests {
    @Test("embeds related texts in different languages close together")
    func crossLanguage() async throws {
        let embedder = try ContextualEmbedder(language: .english)
        try await embedder.prepare()
        let english = try await embedder.embed("The train to the airport leaves every ten minutes.")
        let unrelated = try await embedder.embed("Chocolate cake recipe with cocoa and butter.")
        let related = try await embedder.embed("Trains to the airport depart frequently.")
        #expect(english.count == embedder.dimension)
        #expect(abs(VectorMath.dot(english, english) - 1) < 0.001)
        #expect(VectorMath.cosineSimilarity(english, related) > VectorMath.cosineSimilarity(english, unrelated))
    }

    @Test("embeds text longer than the model's sequence length")
    func longText() async throws {
        let embedder = try ContextualEmbedder(language: .english)
        try await embedder.prepare()
        let text = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 200)
        let vector = try await embedder.embed(text)
        #expect(vector.count == embedder.dimension)
    }
}

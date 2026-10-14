import Foundation
import Testing
@testable import SwiftIntelligence

/// Inputs at the edges of every public entry point: NaN, infinity, huge and negative numbers,
/// and crafted saved data. Each must produce an error or a clamped value, never a trap.
@Suite("Input validation")
struct InputValidationTests {
    @Test("VectorIndex rejects NaN and infinite vectors and queries")
    func nonFiniteVectors() throws {
        var index = VectorIndex(dimension: 2)
        #expect(throws: IndexError.nonFiniteValue) { try index.insert([.nan, 1], for: "a") }
        #expect(throws: IndexError.nonFiniteValue) { try index.insert([.infinity, 1], for: "a") }
        #expect(index.count == 0)
        try index.insert([1, 0], for: "a")
        #expect(throws: IndexError.nonFiniteValue) { try index.search([.nan, 0], limit: 1) }
        #expect(throws: IndexError.nonFiniteValue) { try index.search([-.infinity, 0], limit: 1) }
    }

    @Test("VectorIndex raises a dimension below 1 to 1")
    func dimensionFloor() throws {
        var index = VectorIndex(dimension: -4)
        #expect(index.dimension == 1)
        try index.insert([2], for: "a")
        #expect(try index.search([3], limit: .max).map(\.id) == ["a"])
    }

    @Test("normalizes vectors with huge values without overflowing to zero")
    func hugeValues() {
        let normalized = VectorMath.normalized([1.5e38, 2e38])
        #expect(abs(normalized[0] - 0.6) < 1e-6)
        #expect(abs(normalized[1] - 0.8) < 1e-6)
        #expect(VectorMath.normalized([.greatestFiniteMagnitude, .greatestFiniteMagnitude]).allSatisfy { abs($0 - 0.70710677) < 1e-6 })
    }

    @Test("normalizes vectors whose largest value is subnormal instead of returning NaN", arguments: [
        [Float.leastNormalMagnitude / 12, 0, 0, 0],   // about 1e-39
        [Float.leastNonzeroMagnitude, -Float.leastNonzeroMagnitude, 0, 0],
        [Float.leastNormalMagnitude / 4, Float.leastNormalMagnitude / 3, 0, 0],
    ])
    func subnormalValues(vector: [Float]) {
        let normalized = VectorMath.normalized(vector)
        #expect(VectorMath.isFinite(normalized))
        #expect(abs(VectorMath.dot(normalized, normalized) - 1) < 1e-5)
        #expect(VectorMath.cosineSimilarity(normalized, vector.map { $0 * 0x1p100 }) > 0.9999)
    }

    @Test("KnowledgeBase saves and loads a document whose embedding is subnormal")
    func knowledgeBaseSubnormal() async throws {
        let knowledge = KnowledgeBase(embedder: SubnormalEmbedder())
        try await knowledge.add("tiny vector", id: "a")
        let restored = try KnowledgeBase(data: try await knowledge.dataRepresentation(), embedder: SubnormalEmbedder())
        #expect(await restored.documentIDs == ["a"])
        #expect(try await restored.search("tiny", mode: .semantic).map(\.documentID) == ["a"])
    }

    @Test("rejects saved vector data with a crafted dimension or values", arguments: [
        #"{"dimension":0,"ids":[],"vectors":""}"#,
        #"{"dimension":-1,"ids":["a"],"vectors":"AAAAAA=="}"#,
        #"{"dimension":4611686018427387904,"ids":["a","b","c","d"],"vectors":""}"#,
        #"{"dimension":9223372036854775807,"ids":["a"],"vectors":"AAAAAA=="}"#,
        #"{"dimension":1,"ids":["a"],"vectors":"AADAfw=="}"#,
        #"{"dimension":1,"ids":["a"],"vectors":"AACAfw=="}"#,
        #"{"dimension":1,"ids":["a"],"vectors":"5rFhfw=="}"#,       // 3e38, finite but not unit length
        #"{"dimension":2,"ids":["a"],"vectors":"AAAAPwAAAD8="}"#,   // [0.5, 0.5]
    ])
    func craftedVectorData(json: String) {
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(VectorIndex.self, from: Data(json.utf8)) }
    }

    @Test("HashingEmbedder keeps its dimension between 16 and 65,536")
    func hashingDimension() {
        #expect(HashingEmbedder(dimension: .min).dimension == 16)
        #expect(HashingEmbedder(dimension: .max).dimension == 65_536)
    }

    @Test("KeywordIndex replaces invalid BM25 parameters", arguments: [
        (Double.nan, Double.nan, 1.2, 0.75),
        (-1, -1, 1.2, 0),
        (.infinity, 2, 1.2, 1),
        (0, 0.5, 0, 0.5),
    ])
    func bm25Parameters(saturation: Double, normalization: Double, expectedSaturation: Double, expectedNormalization: Double) {
        let index = KeywordIndex(termSaturation: saturation, lengthNormalization: normalization)
        #expect(index.termSaturation == expectedSaturation)
        #expect(index.lengthNormalization == expectedNormalization)
    }

    @Test("KeywordIndex scores stay finite with extreme parameters")
    func bm25Finite() {
        var index = KeywordIndex(termSaturation: 0, lengthNormalization: 1)
        index.insert("alpha beta", for: "a")
        index.insert("gamma", for: "b")
        let results = index.search("alpha", limit: .max)
        #expect(results.map(\.id) == ["a"])
        #expect(results.allSatisfy { $0.score.isFinite })
    }

    @Test("RankFusion ignores lists with NaN weights and invalid smoothing")
    func fusionInputs() {
        let a = RankFusion.RankedList([ScoredID(id: "a", score: 1)], weight: .nan)
        let b = RankFusion.RankedList([ScoredID(id: "b", score: 1)], weight: .infinity)
        let c = RankFusion.RankedList([ScoredID(id: "c", score: 1)])
        #expect(RankFusion.fuse([a, b, c]).map(\.id) == ["c"])
        for smoothing in [Double.nan, -61, .infinity] {
            let fused = RankFusion.fuse([c], smoothing: smoothing)
            #expect(fused.first?.score == 1 / (RankFusion.defaultSmoothing + 1))
        }
        #expect(RankFusion.fuse([c], smoothing: 0).first?.score == 1)
    }

    @Test("TextAnalyzer returns no guesses for a maximum of zero or less")
    func languageGuessMaximum() {
        #expect(TextAnalyzer().languageGuesses(for: "Hello world, how are you?", maximum: 0).isEmpty)
        #expect(TextAnalyzer().languageGuesses(for: "Hello world, how are you?", maximum: -5).isEmpty)
        #expect(TextAnalyzer().keywords(in: "Invoices and invoices", limit: .min).isEmpty)
    }

    @Test("TextChunker clamps its settings and handles extreme values")
    func chunkerLimits() {
        let tiny = TextChunker(maximumLength: .min, overlap: .min)
        #expect(tiny.maximumLength == 1)
        #expect(tiny.overlap == 0)
        let chunks = tiny.chunks(of: "ab. c")
        #expect(chunks.map(\.text).joined() == "abc")
        #expect(chunks.allSatisfy { $0.text.count == 1 })
        let huge = TextChunker(maximumLength: .max, overlap: .max)
        #expect(huge.chunks(of: "One. Two. Three.").map(\.text) == ["One. Two. Three."])
    }

    @Test("KnowledgeBase rejects a NaN embedding and stays unchanged")
    func knowledgeBaseNaN() async throws {
        let knowledge = KnowledgeBase(embedder: NaNEmbedder())
        await #expect(throws: IndexError.nonFiniteValue) { try await knowledge.add("ok then bad", id: "a") }
        #expect(await knowledge.count == 0)
        #expect(await knowledge.passageCount == 0)
    }

    @Test("KnowledgeBase rejects an embedder that returns the wrong length")
    func knowledgeBaseDimension() async throws {
        let knowledge = KnowledgeBase(embedder: ShortEmbedder())
        await #expect(throws: IndexError.dimensionMismatch(expected: 8, actual: 3)) { try await knowledge.add("text", id: "a") }
        #expect(await knowledge.count == 0)
    }
}

private struct NaNEmbedder: TextEmbedder {
    let identifier = "nan"
    let dimension = 4
    func embed(_ text: String) async throws -> [Float] { [.nan, 0, 0, 0] }
}

private struct ShortEmbedder: TextEmbedder {
    let identifier = "short"
    let dimension = 8
    func embed(_ text: String) async throws -> [Float] { [1, 2, 3] }
}

private struct SubnormalEmbedder: TextEmbedder {
    let identifier = "subnormal"
    let dimension = 4
    func embed(_ text: String) async throws -> [Float] { [.leastNormalMagnitude / 12, 0, 0, 0] }
}

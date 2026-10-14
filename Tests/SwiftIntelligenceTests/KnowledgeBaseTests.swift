import Foundation
import Testing
@testable import SwiftIntelligence

/// An embedder that fails on demand, to check that a failed add changes nothing.
private struct FailingEmbedder: TextEmbedder {
    struct Failure: Error {}
    let failOn: String
    let identifier = "failing"
    let dimension = 16

    func embed(_ text: String) async throws -> [Float] {
        if text.contains(failOn) { throw Failure() }
        return HashingEmbedder(dimension: dimension).vector(for: text)
    }
}

/// Maps "x", "y" and "-x" to fixed directions, so similarities are known exactly.
private struct AxisEmbedder: TextEmbedder {
    let identifier = "axis"
    let dimension = 2

    func embed(_ text: String) async throws -> [Float] {
        switch text {
        case "x": [1, 0]
        case "-x": [-1, 0]
        default: [0, 1]
        }
    }
}

@Suite("KnowledgeBase")
struct KnowledgeBaseTests {
    private func sample() async throws -> KnowledgeBase {
        let knowledge = KnowledgeBase()
        try await knowledge.add([
            .init(id: "returns", text: "Returns are accepted within 30 days of delivery.", metadata: ["topic": "orders"]),
            .init(id: "shipping", text: "Standard shipping takes three to five business days.", metadata: ["topic": "orders"]),
            .init(id: "warranty", text: "The warranty covers manufacturing defects for two years.", metadata: ["topic": "product"]),
            .init(id: "codes", text: "Error code E-4012 means the battery needs service.", metadata: ["topic": "product"]),
        ])
        return knowledge
    }

    @Test("finds the passage that shares words with the query, in every mode", arguments: SearchMode.allCases)
    func search(mode: SearchMode) async throws {
        let knowledge = try await sample()
        let results = try await knowledge.search("How long does shipping take?", limit: 2, mode: mode)
        #expect(results.first?.documentID == "shipping")
        #expect(results.first?.text == "Standard shipping takes three to five business days.")
        #expect(results.first?.metadata == ["topic": "orders"])
    }

    @Test("finds an exact code through keyword ranking in hybrid search")
    func exactCode() async throws {
        let knowledge = try await sample()
        let results = try await knowledge.search("E-4012")
        #expect(results.first?.documentID == "codes")
    }

    @Test("filters by metadata")
    func metadataFilter() async throws {
        let knowledge = try await sample()
        let results = try await knowledge.search("battery days", limit: 10, matching: ["topic": "product"])
        #expect(!results.isEmpty)
        #expect(results.allSatisfy { $0.metadata["topic"] == "product" })
        #expect(try await knowledge.search("days", matching: ["topic": "missing"]).isEmpty)
    }

    @Test("returns nothing for an empty query, a zero limit or an empty knowledge base")
    func emptyCases() async throws {
        let knowledge = try await sample()
        #expect(try await knowledge.search("   ").isEmpty)
        #expect(try await knowledge.search("shipping", limit: 0).isEmpty)
        #expect(try await knowledge.search("shipping", limit: -3).isEmpty)
        #expect(try await KnowledgeBase().search("shipping").isEmpty)
    }

    @Test("accepts the largest possible limit without overflowing")
    func hugeLimit() async throws {
        let knowledge = try await sample()
        let results = try await knowledge.search("days", limit: .max)
        #expect(results == (try await knowledge.search("days", limit: 100)))
        #expect(!results.isEmpty)
        #expect(KnowledgeBase.hybridCandidateCount(for: .max) == .max)
        #expect(KnowledgeBase.hybridCandidateCount(for: 2) == 20)
        #expect(KnowledgeBase.hybridCandidateCount(for: 10) == 40)
    }

    @Test("drops passages whose vector points away from the query in semantic mode")
    func noFalseSemanticHits() async throws {
        let knowledge = KnowledgeBase(embedder: AxisEmbedder())
        try await knowledge.add([.init(id: "x", text: "x"), .init(id: "y", text: "y"), .init(id: "minus", text: "-x")])
        #expect(try await knowledge.search("x", mode: .semantic).map(\.documentID) == ["x"])
    }

    @Test("replaces a document with the same identifier and keeps its place")
    func replace() async throws {
        let knowledge = try await sample()
        try await knowledge.add("Returns are free for members.", id: "returns")
        #expect(await knowledge.count == 4)
        #expect(await knowledge.documentIDs == ["returns", "shipping", "warranty", "codes"])
        #expect(await knowledge.passages(for: "returns") == ["Returns are free for members."])
        #expect(try await knowledge.search("delivery", mode: .keyword).isEmpty)
    }

    @Test("removes one document or all of them")
    func remove() async throws {
        let knowledge = try await sample()
        await knowledge.remove(id: "shipping")
        await knowledge.remove(id: "unknown")
        #expect(await knowledge.count == 3)
        #expect(await !knowledge.contains(id: "shipping"))
        #expect(try await knowledge.search("shipping", mode: .keyword).isEmpty)
        await knowledge.removeAll()
        #expect(await knowledge.count == 0)
        #expect(await knowledge.passageCount == 0)
    }

    @Test("splits long documents into passages and reports which one matched")
    func passages() async throws {
        let knowledge = KnowledgeBase(chunker: TextChunker(maximumLength: 40, overlap: 0))
        let text = "Our office opens at nine. Parking is behind the building. The cafeteria serves lunch at noon."
        try await knowledge.add(text, id: "office")
        #expect(await knowledge.passages(for: "office")?.count == 3)
        let result = try #require(try await knowledge.search("lunch cafeteria", limit: 1).first)
        #expect(result.passageIndex == 2)
        #expect(result.id == "office#2")
    }

    @Test("redacts personal data before indexing when given a redactor")
    func redaction() async throws {
        let knowledge = KnowledgeBase(redactor: PersonalDataRedactor(kinds: [.emailAddress], replacement: .tag))
        try await knowledge.add("Escalations go to jane.doe@example.com.", id: "contacts")
        #expect(await knowledge.passages(for: "contacts") == ["Escalations go to [EMAIL]."])
        #expect(try await knowledge.search("jane.doe@example.com", mode: .keyword).isEmpty)
    }

    @Test("leaves the knowledge base unchanged when an embedding fails")
    func atomicAdd() async throws {
        let knowledge = KnowledgeBase(embedder: FailingEmbedder(failOn: "boom"))
        try await knowledge.add("First document", id: "one")
        await #expect(throws: FailingEmbedder.Failure.self) {
            try await knowledge.add([.init(id: "two", text: "Fine"), .init(id: "three", text: "boom")])
        }
        #expect(await knowledge.documentIDs == ["one"])
        #expect(await knowledge.passageCount == 1)
    }

    @Test("parses passage keys from the last separator, so identifiers may contain '#'")
    func passageKeys() {
        let key = KnowledgeBase.passageKey("notes#2024", 7)
        #expect(key == "notes#2024#7")
        #expect(KnowledgeBase.parsePassageKey(key)?.0 == "notes#2024")
        #expect(KnowledgeBase.parsePassageKey(key)?.1 == 7)
        #expect(KnowledgeBase.parsePassageKey("no-separator") == nil)
        #expect(KnowledgeBase.parsePassageKey("doc#99999999999999999999999") == nil)
    }
}

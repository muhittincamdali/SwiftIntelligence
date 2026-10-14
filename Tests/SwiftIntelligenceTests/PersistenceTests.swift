import Foundation
import Testing
@testable import SwiftIntelligence

@Suite("KnowledgeBase persistence")
struct PersistenceTests {
    private func sample() async throws -> KnowledgeBase {
        let knowledge = KnowledgeBase(redactor: PersonalDataRedactor(kinds: [.emailAddress], replacement: .tag))
        try await knowledge.add([
            .init(id: "returns", text: "Returns are accepted within 30 days. Ask returns@example.com.", metadata: ["topic": "orders"]),
            .init(id: "codes", text: "Error code E-4012 means the battery needs service.", metadata: ["topic": "product"]),
        ])
        return knowledge
    }

    private func snapshot(_ knowledge: KnowledgeBase) async throws -> KnowledgeBase.Snapshot {
        try PropertyListDecoder().decode(KnowledgeBase.Snapshot.self, from: try await knowledge.dataRepresentation())
    }

    private func encode(_ snapshot: KnowledgeBase.Snapshot) throws -> Data {
        try PropertyListEncoder().encode(snapshot)
    }

    @Test("restores documents, order, metadata and search results from a file")
    func roundTrip() async throws {
        let original = try await sample()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("knowledge-\(UUID().uuidString).plist")
        defer { try? FileManager.default.removeItem(at: url) }
        try await original.save(to: url)

        let restored = try KnowledgeBase(contentsOf: url)
        #expect(await restored.documentIDs == ["returns", "codes"])
        #expect(await restored.metadata(for: "codes") == ["topic": "product"])
        #expect(await restored.passages(for: "returns") == (await original.passages(for: "returns")))
        for mode in SearchMode.allCases {
            let before = try await original.search("battery error code", mode: mode)
            let after = try await restored.search("battery error code", mode: mode)
            #expect(after == before)
            #expect(after.first?.documentID == "codes")
        }
    }

    @Test("saves only redacted passages")
    func savesRedactedText() async throws {
        let data = try await sample().dataRepresentation()
        #expect(data.range(of: Data("returns@example.com".utf8)) == nil)
        #expect(data.range(of: Data("[EMAIL]".utf8)) != nil)
    }

    @Test("keeps working after a restore: add, replace and remove")
    func editAfterRestore() async throws {
        let restored = try KnowledgeBase(data: try await sample().dataRepresentation())
        try await restored.add("Shipping takes three days.", id: "shipping")
        try await restored.add("Error code E-5000 means the fan is blocked.", id: "codes")
        await restored.remove(id: "returns")
        #expect(await restored.documentIDs == ["codes", "shipping"])
        #expect(try await restored.search("4012 accepted", mode: .keyword).isEmpty)
        #expect(try await restored.search("5000", mode: .keyword).first?.documentID == "codes")
    }

    @Test("refuses data saved with another embedder")
    func embedderMismatch() async throws {
        let data = try await sample().dataRepresentation()
        #expect(throws: KnowledgeBaseError.embedderMismatch(saved: "hashing-v1-512", current: "hashing-v1-256")) {
            try KnowledgeBase(data: data, embedder: HashingEmbedder(dimension: 256))
        }
    }

    @Test("refuses data from a newer format")
    func newerFormat() async throws {
        let saved = try await snapshot(sample())
        let newer = KnowledgeBase.Snapshot(format: 99, embedder: saved.embedder, documents: saved.documents, vectors: saved.vectors)
        #expect(throws: KnowledgeBaseError.unsupportedFormat(99)) { try KnowledgeBase(data: try encode(newer)) }
    }

    @Test("refuses a passage without a vector, extra vectors and duplicate documents")
    func inconsistentData() async throws {
        let saved = try await snapshot(sample())
        var fewerVectors = saved.vectors
        fewerVectors.remove("codes#0")
        let missing = KnowledgeBase.Snapshot(format: 1, embedder: saved.embedder, documents: saved.documents, vectors: fewerVectors)
        #expect(throws: KnowledgeBaseError.inconsistentData("The passage codes#0 has no vector.")) { try KnowledgeBase(data: try encode(missing)) }

        var moreVectors = saved.vectors
        try moreVectors.insert(Array(repeating: 1, count: 512), for: "ghost#0")
        let extra = KnowledgeBase.Snapshot(format: 1, embedder: saved.embedder, documents: saved.documents, vectors: moreVectors)
        #expect(throws: KnowledgeBaseError.self) { try KnowledgeBase(data: try encode(extra)) }

        let duplicate = KnowledgeBase.Snapshot(format: 1, embedder: saved.embedder, documents: saved.documents + [saved.documents[0]], vectors: saved.vectors)
        #expect(throws: KnowledgeBaseError.inconsistentData("The document \"returns\" appears twice.")) { try KnowledgeBase(data: try encode(duplicate)) }
    }

    @Test("throws a decoding error for data that is not a saved knowledge base", arguments: [
        Data(), Data("not a property list".utf8), Data(repeating: 0xFF, count: 64),
    ])
    func garbage(data: Data) {
        #expect(throws: DecodingError.self) { try KnowledgeBase(data: data) }
    }

    @Test("round-trips an empty knowledge base")
    func empty() async throws {
        let restored = try KnowledgeBase(data: try await KnowledgeBase().dataRepresentation())
        #expect(await restored.count == 0)
        #expect(try await restored.search("anything").isEmpty)
    }
}

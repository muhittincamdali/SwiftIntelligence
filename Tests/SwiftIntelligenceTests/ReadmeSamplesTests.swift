import Foundation
import NaturalLanguage
import Testing
@testable import SwiftIntelligence
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Runs the README samples (ReadmeSamples.swift, shared with the example app) and checks what
/// their comments say they print.
@Suite("README samples")
struct ReadmeSamplesTests {
    @Test("quick start finds the returns policy")
    func quickStart() async throws {
        let results = try await ReadmeSamples.quickStart()
        #expect(results.first?.documentID == "returns")
        #expect(results.first?.text.hasPrefix("You can return any item within 30 days") == true)
    }

    @Test("quick start view's search shows the returns policy")
    func quickStartView() async {
        #expect(await QuickStartView.bestMatch() == "You can return any item within 30 days of delivery for a full refund.")
    }

    @Test("redaction sample replaces and restores")
    func redact() {
        let redacted = ReadmeSamples.redact()
        #expect(redacted.text == "Mail [EMAIL_1] or pay with [CARD_1].")
        #expect(redacted.restoringOriginals(in: "I wrote to [EMAIL_1].") == "I wrote to jane@example.com.")
    }

    @Test("analysis sample finds the language", .enabled(if: SystemModels.hasNameTagger && SystemModels.hasSentimentModel, "needs the NaturalLanguage name and sentiment models"))
    func analyze() throws {
        let analysis = ReadmeSamples.analyze()
        #expect(analysis.language == .english)
        #expect(analysis.entities.map(\.text) == ["Tim Cook", "Cupertino"])
        #expect(try #require(analysis.sentiment) > 0)
    }

    @Test("semantic sample finds a passage without shared words", .enabled(if: NLEmbedding.sentenceEmbedding(for: .english) != nil, "needs the English sentence embedding"))
    func searchByMeaning() async throws {
        let results = try await ReadmeSamples.searchByMeaning()
        #expect(results.first?.documentID == "warranty")
    }

    @Test("save sample restores the same documents")
    func saveAndRestore() async throws {
        let folder = FileManager.default.temporaryDirectory.appending(path: "readme-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: folder) }
        let knowledge = KnowledgeBase()
        try await knowledge.add("Returns are accepted within 30 days of delivery.", id: "returns")
        let restored = try await ReadmeSamples.saveAndRestore(knowledge, in: folder)
        #expect(await restored.documentIDs == ["returns"])
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    @Test("answer sample answers from the returns policy", .enabled(if: Self.modelAvailable(), "needs the on-device language model"))
    func answer() async throws {
        let knowledge = KnowledgeBase()
        try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
        try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
        try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")
        let answer = try await ReadmeSamples.answer(from: knowledge)
        #expect(answer.sources.first?.documentID == "returns")
        #expect(answer.text.contains("30"))
    }

    static func modelAvailable() -> Bool {
        guard #available(iOS 26.0, macOS 26.0, *) else { return false }
        return SystemLanguageModel.default.availability == .available
    }
    #endif
}

// The code samples of the README, compiled by the example app and run by the package tests
// (through the symlink Tests/SwiftIntelligenceTests/ReadmeSamples.swift). Copy changes to the
// README by hand; the tests fail when a sample stops working.
import Foundation
import NaturalLanguage
import SwiftIntelligence
import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: Quick start, step 3 (named ContentView in the README)

struct QuickStartView: View {
    @State private var answer = "Searching…"

    var body: some View {
        Text(answer)
            .padding()
            .task {
                do {
                    let knowledge = KnowledgeBase()
                    try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
                    try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")
                    let results = try await knowledge.search("How do I return an item for a refund?")
                    answer = results.first?.text ?? "Nothing found"
                } catch {
                    answer = "Search failed: \(error)"
                }
            }
    }
}

enum ReadmeSamples {
    // MARK: Search

    static func quickStart() async throws -> [SearchResult] {
        let knowledge = KnowledgeBase()
        try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
        try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
        try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

        let results = try await knowledge.search("How do I return an item for a refund?")
        print(results.first?.documentID ?? "nothing found")  // returns
        print(results.first?.text ?? "")                     // You can return any item within 30 days …
        return results
    }

    // MARK: Answer with the on-device model

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    static func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
        let answer = try await knowledge.answer("How long do I have to return an item?")
        print(answer.text)                              // for example "Within 30 days of delivery [1]."
        print(answer.citedSources.map(\.documentID))    // ["returns"]
        return answer
    }
    #endif

    // MARK: Redact personal data

    static func redact() -> RedactedText {
        let redactor = PersonalDataRedactor()
        let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
        print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

        // After a model has answered from the redacted text, put the values back.
        let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
        print(reply)          // "I wrote to jane@example.com."
        return redacted
    }

    // MARK: Analyze text

    static func analyze() -> TextAnalysis {
        let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
        print(analysis.language?.rawValue ?? "unknown")  // "en"
        print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
        print(analysis.sentiment ?? 0)                   // a positive score
        return analysis
    }

    // MARK: Search by meaning

    static func searchByMeaning() async throws -> [SearchResult] {
        let embedder = try SentenceEmbedder(language: .english)
        let knowledge = KnowledgeBase(embedder: embedder)
        try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
        try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

        // No word in common with the warranty text.
        let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
        print(results.first?.documentID ?? "nothing found")  // warranty
        return results
    }

    // MARK: Save and restore

    static func saveAndRestore(_ knowledge: KnowledgeBase, in folder: URL = .applicationSupportDirectory) async throws -> KnowledgeBase {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file = folder.appending(path: "knowledge.plist")
        try await knowledge.save(to: file)

        // On the next launch:
        return try KnowledgeBase(contentsOf: file)
    }
}

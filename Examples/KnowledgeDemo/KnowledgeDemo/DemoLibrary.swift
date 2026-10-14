import Foundation
import NaturalLanguage
import SwiftIntelligence

/// The help-center articles the demo searches, and the knowledge base built from them.
@MainActor
@Observable
final class DemoLibrary {
    struct Article: Identifiable {
        let id: String
        let title: String
        let text: String
    }

    static let articles: [Article] = [
        Article(id: "returns", title: "Returns", text: "You can return any item within 30 days of delivery for a full refund. Items must be unused and in their original packaging. Start a return from the Orders page; we email a prepaid label."),
        Article(id: "refunds", title: "Refunds", text: "Refunds go back to the original payment method within five business days after the returned item arrives at our warehouse. Shipping costs are refunded only for damaged items."),
        Article(id: "shipping", title: "Shipping", text: "Orders placed before 2 pm ship the same day. Standard delivery takes three to five business days; express delivery arrives the next business day."),
        Article(id: "warranty", title: "Warranty", text: "Every laptop and phone comes with a two-year warranty against manufacturing defects. Accidental damage, such as a cracked screen, is not covered."),
        Article(id: "battery", title: "Battery service", text: "Error code E-4012 means the battery needs service. Book a repair in the Support app; a replacement battery costs 89 euros outside the warranty."),
        Article(id: "support", title: "Contact", text: "Our support team answers calls from 9 to 5 on weekdays and replies to chat messages around the clock."),
        Article(id: "privacy", title: "Privacy", text: "We keep order history for seven years to meet tax law. You can download or delete your account data from Settings at any time."),
        Article(id: "gift-cards", title: "Gift cards", text: "Gift cards never expire and can be combined with other payment methods. Lost gift cards can be replaced with the original receipt."),
    ]

    let knowledge: KnowledgeBase
    /// A short description of the embedder, shown in the search screen.
    let embedderName: String
    private(set) var isReady = false

    init() {
        // Apple's sentence embedding where the system has it (not on the simulator); the
        // hashing embedder everywhere else.
        if let sentence = try? SentenceEmbedder(language: .english) {
            knowledge = KnowledgeBase(embedder: sentence)
            embedderName = "Sentence embedding (\(sentence.dimension) dimensions)"
        } else {
            let hashing = HashingEmbedder()
            knowledge = KnowledgeBase(embedder: hashing)
            embedderName = "Hashing embedder (\(hashing.dimension) dimensions)"
        }
    }

    func load() async {
        guard !isReady else { return }
        let documents = Self.articles.map { KnowledgeBase.Document(id: $0.id, text: $0.text, metadata: ["title": $0.title]) }
        try? await knowledge.add(documents)
        isReady = true
    }

    static func title(of documentID: String) -> String {
        articles.first { $0.id == documentID }?.title ?? documentID
    }
}

import NaturalLanguage
import Testing
@testable import SwiftIntelligence

@Suite("TextAnalyzer")
struct TextAnalyzerTests {
    let analyzer = TextAnalyzer()

    @Test("detects the dominant language", arguments: [
        ("The weather is lovely today and we are going to the beach.", NLLanguage.english),
        ("Bugün hava çok güzel, sahile gidiyoruz ve akşam yemeği yiyeceğiz.", .turkish),
        ("Heute ist das Wetter schön und wir gehen an den Strand.", .german),
        ("Hoy hace buen tiempo y vamos a ir a la playa por la tarde.", .spanish),
    ])
    func language(text: String, expected: NLLanguage) {
        #expect(analyzer.language(of: text) == expected)
    }

    @Test("returns no language for text without letters")
    func undeterminedLanguage() {
        #expect(analyzer.language(of: "1234 5678 !!") == nil)
        #expect(analyzer.language(of: "") == nil)
    }

    @Test("orders language guesses by probability")
    func guesses() {
        let guesses = analyzer.languageGuesses(for: "Das ist ein kurzer deutscher Satz über Bücher.", maximum: 3)
        #expect(guesses.first?.language == .german)
        #expect(guesses.count <= 3)
        #expect(guesses.map(\.probability) == guesses.map(\.probability).sorted(by: >))
    }

    @Test("scores positive and negative text on opposite sides of zero", .enabled(if: SystemModels.hasSentimentModel, "needs the NaturalLanguage sentiment model"))
    func sentiment() throws {
        let positive = try #require(analyzer.sentiment(of: "I love this app. It is fast, beautiful and a joy to use."))
        let negative = try #require(analyzer.sentiment(of: "This is terrible. It crashes all the time and I hate it."))
        #expect(positive > 0)
        #expect(negative < 0)
        #expect((-1...1).contains(positive) && (-1...1).contains(negative))
    }

    @Test("has no sentiment for empty text")
    func emptySentiment() {
        #expect(analyzer.sentiment(of: "") == nil)
    }

    @Test("finds people, places and organizations with their ranges", .enabled(if: SystemModels.hasNameTagger, "needs the NaturalLanguage name model"))
    func entities() {
        let text = "Tim Cook said Apple will open a new office in Berlin next year."
        let entities = analyzer.entities(in: text)
        #expect(entities.contains { $0.text == "Tim Cook" && $0.kind == .person })
        #expect(entities.contains { $0.text == "Berlin" && $0.kind == .place })
        #expect(entities.contains { $0.text == "Apple" && $0.kind == .organization })
        for entity in entities {
            #expect(String(text[entity.range]) == entity.text)
        }
    }

    @Test("splits sentences and trims them")
    func sentences() {
        let sentences = analyzer.sentences(in: "  First sentence.   Second one?\n\nThird!  ")
        #expect(sentences == ["First sentence.", "Second one?", "Third!"])
    }

    @Test("counts nouns in their dictionary form, most frequent first", .enabled(if: SystemModels.hasPartOfSpeechTagger, "needs the NaturalLanguage part-of-speech model"))
    func keywords() {
        let text = "The invoice is late. Two invoices were paid. The customer asked about the invoice and the delivery."
        let keywords = analyzer.keywords(in: text, limit: 3)
        #expect(keywords.first == Keyword(term: "invoice", count: 3))
        #expect(keywords.count == 3)
        #expect(!keywords.contains { $0.term == "the" })
    }

    @Test("returns no keywords for a zero limit")
    func zeroLimit() {
        #expect(analyzer.keywords(in: "Invoices and invoices.", limit: 0).isEmpty)
    }

    @Test("bundles every result in analyze", .enabled(if: SystemModels.hasNameTagger, "needs the NaturalLanguage name model"), .enabled(if: SystemModels.hasPartOfSpeechTagger, "needs the NaturalLanguage part-of-speech model"))
    func analyze() {
        let analysis = analyzer.analyze("Apple opened a store in Paris. People loved the store.")
        #expect(analysis.language == .english)
        #expect(analysis.sentenceCount == 2)
        #expect(analysis.wordCount == 10)
        #expect(analysis.keywords.first?.term == "store")
        #expect(analysis.entities.contains { $0.text == "Paris" })
    }
}

import NaturalLanguage
import Testing

/// Whether the system has the NaturalLanguage models some tests need. The iOS simulator ships
/// without the name, sentiment and part-of-speech models, so tests that need them run on macOS
/// and on devices. The probes call NaturalLanguage directly, not the package, so a bug in the
/// package cannot switch its own tests off; on macOS the models are required.
enum SystemModels {
    static let hasNameTagger: Bool = {
        let text = "Tim Cook visited Paris."
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        return tagger.tag(at: text.startIndex, unit: .word, scheme: .nameType).0 == .personalName
    }()

    static let hasSentimentModel: Bool = {
        let text = "I love this. It is wonderful."
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let score = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0.flatMap { Double($0.rawValue) }
        return (score ?? 0) > 0
    }()

    static let hasPartOfSpeechTagger: Bool = {
        let text = "The invoices are late."
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let word = text.range(of: "invoices")!
        return tagger.tag(at: word.lowerBound, unit: .word, scheme: .lexicalClass).0 == .noun
    }()
}

#if os(macOS)
@Test("macOS has the NaturalLanguage models, so no model test is skipped there")
func macOSHasModels() {
    #expect(SystemModels.hasNameTagger)
    #expect(SystemModels.hasSentimentModel)
    #expect(SystemModels.hasPartOfSpeechTagger)
}
#endif

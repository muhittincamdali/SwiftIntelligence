import Foundation
import NaturalLanguage

/// Reads language, sentiment, names, keywords and sentences from text with Apple's
/// NaturalLanguage framework.
///
/// Everything runs on the device; nothing is downloaded or sent anywhere. Accuracy follows the
/// system models: English is covered best, and sentiment is only available for some languages.
///
/// ```swift
/// let analyzer = TextAnalyzer()
/// let analysis = analyzer.analyze("Tim Cook presented the new iPhone in Cupertino.")
/// analysis.entities.map(\.text)   // ["Tim Cook", "Cupertino"]
/// ```
public struct TextAnalyzer: Sendable {
    /// Words shorter than this are not reported as keywords.
    private static let minimumKeywordLength = 3

    public init() {}

    /// Runs every analysis on `text`.
    public func analyze(_ text: String, keywordLimit: Int = 5) -> TextAnalysis {
        TextAnalysis(
            language: language(of: text),
            sentiment: sentiment(of: text),
            entities: entities(in: text),
            keywords: keywords(in: text, limit: keywordLimit),
            sentenceCount: sentences(in: text).count,
            wordCount: SearchTerms.terms(in: text).count
        )
    }

    /// The dominant language of `text`, or `nil` when it cannot be determined.
    public func language(of text: String) -> NLLanguage? {
        let language = NLLanguageRecognizer.dominantLanguage(for: text)
        return language == .undetermined ? nil : language
    }

    /// The most likely languages of `text`, most likely first.
    public func languageGuesses(for text: String, maximum: Int = 3) -> [LanguageGuess] {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.languageHypotheses(withMaximum: maximum)
            .map { LanguageGuess(language: $0.key, probability: $0.value) }
            .sorted { $0.probability > $1.probability }
    }

    /// The sentiment of `text` from -1 (negative) to 1 (positive).
    ///
    /// Each paragraph is scored separately and the scores are averaged, weighted by paragraph
    /// length. Returns `nil` for empty text and for languages without a sentiment model.
    public func sentiment(of text: String) -> Double? {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        var weightedSum = 0.0
        var totalLength = 0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, range in
            if let tag, let score = Double(tag.rawValue) {
                let length = text.distance(from: range.lowerBound, to: range.upperBound)
                weightedSum += score * Double(length)
                totalLength += length
            }
            return true
        }
        return totalLength == 0 ? nil : weightedSum / Double(totalLength)
    }

    /// People, places and organizations in `text`, in order of appearance.
    public func entities(in text: String) -> [NamedEntity] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        var entities: [NamedEntity] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, range in
            if let kind = tag.flatMap(Self.entityKind) {
                entities.append(NamedEntity(text: String(text[range]), kind: kind, range: range))
            }
            return true
        }
        return entities
    }

    /// The sentences of `text`, without surrounding whitespace.
    public func sentences(in text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        return tokenizer.tokens(for: text.startIndex..<text.endIndex)
            .map { text[$0].trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// The most frequent nouns in `text`, most frequent first; ties keep the order of first
    /// appearance.
    ///
    /// Nouns are counted in their dictionary form ("invoices" counts as "invoice") where the
    /// language has a lemmatizer, and lowercased otherwise.
    public func keywords(in text: String, limit: Int = 5) -> [Keyword] {
        guard limit > 0 else { return [] }
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
        var counts: [String: Int] = [:]
        var order: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
            guard tag == .noun else { return true }
            let lemma = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lemma).0?.rawValue
            let term = (lemma ?? String(text[range])).lowercased()
            guard term.count >= Self.minimumKeywordLength else { return true }
            if counts[term] == nil { order.append(term) }
            counts[term, default: 0] += 1
            return true
        }
        let ranked = order.enumerated().sorted { lhs, rhs in
            let (left, right) = (counts[lhs.element]!, counts[rhs.element]!)
            return left != right ? left > right : lhs.offset < rhs.offset
        }
        return ranked.prefix(limit).map { Keyword(term: $0.element, count: counts[$0.element]!) }
    }

    private static func entityKind(_ tag: NLTag) -> NamedEntity.Kind? {
        switch tag {
        case .personalName: .person
        case .placeName: .place
        case .organizationName: .organization
        default: nil
        }
    }
}

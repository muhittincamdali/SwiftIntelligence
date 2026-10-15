import NaturalLanguage

/// A language and how likely it is that a text is written in it.
public struct LanguageGuess: Hashable, Sendable {
    /// The language.
    public let language: NLLanguage
    /// A probability between 0 and 1.
    public let probability: Double

    public init(language: NLLanguage, probability: Double) {
        self.language = language
        self.probability = probability
    }
}

/// A person, place or organization mentioned in a text.
public struct NamedEntity: Hashable, Sendable {
    /// The kind of thing a ``NamedEntity`` names.
    public enum Kind: String, Hashable, Sendable, CaseIterable {
        case person
        case place
        case organization
    }

    /// The name as it appears in the text.
    public let text: String
    /// What the name refers to.
    public let kind: Kind
    /// Where the name is in the analyzed string.
    public let range: Range<String.Index>

    public init(text: String, kind: Kind, range: Range<String.Index>) {
        self.text = text
        self.kind = kind
        self.range = range
    }
}

/// A word that occurs often in a text, in its dictionary form where the language supports it.
public struct Keyword: Hashable, Sendable {
    /// The lowercased dictionary form, for example "invoice" for "Invoices".
    public let term: String
    /// How many times the word occurs.
    public let count: Int

    public init(term: String, count: Int) {
        self.term = term
        self.count = count
    }
}

/// Everything ``TextAnalyzer/analyze(_:keywordLimit:)`` finds in one pass.
public struct TextAnalysis: Hashable, Sendable {
    /// The dominant language, or `nil` when the text is too short or mixed to tell.
    public let language: NLLanguage?
    /// The sentiment from -1 (negative) to 1 (positive), or `nil` when the language has no
    /// sentiment model.
    public let sentiment: Double?
    /// People, places and organizations, in order of appearance.
    public let entities: [NamedEntity]
    /// The most frequent nouns, most frequent first.
    public let keywords: [Keyword]
    /// The number of sentences.
    public let sentenceCount: Int
    /// The number of words.
    public let wordCount: Int

    public init(
        language: NLLanguage?,
        sentiment: Double?,
        entities: [NamedEntity],
        keywords: [Keyword],
        sentenceCount: Int,
        wordCount: Int
    ) {
        self.language = language
        self.sentiment = sentiment
        self.entities = entities
        self.keywords = keywords
        self.sentenceCount = sentenceCount
        self.wordCount = wordCount
    }
}

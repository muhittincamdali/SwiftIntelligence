import Foundation
import SwiftIntelligenceCore
@preconcurrency import NaturalLanguage

// MARK: - NLP Analysis Result Types

public struct NLPAnalysisResult: Codable, Sendable {
    public let sentiment: SentimentResult?
    public let entities: [NamedEntity]
    public let keywords: [Keyword]
    public let topics: [Topic]
    public let languageConfidence: [LanguageConfidence]
    public let readability: ReadabilityMetrics?
    public let summary: SummaryResult?
    
    public init(
        sentiment: SentimentResult? = nil,
        entities: [NamedEntity] = [],
        keywords: [Keyword] = [],
        topics: [Topic] = [],
        languageConfidence: [LanguageConfidence] = [],
        readability: ReadabilityMetrics? = nil,
        summary: SummaryResult? = nil
    ) {
        self.sentiment = sentiment
        self.entities = entities
        self.keywords = keywords
        self.topics = topics
        self.languageConfidence = languageConfidence
        self.readability = readability
        self.summary = summary
    }
}

public struct NLPTrainingData: Codable, Sendable {
    public let texts: [String]
    public let labels: [String]?
    public let language: String
    public let modelType: NLPModelType
    
    public init(texts: [String], labels: [String]? = nil, language: String = "en", modelType: NLPModelType = .custom) {
        self.texts = texts
        self.labels = labels
        self.language = language
        self.modelType = modelType
    }
}

public struct NLPTrainingResult: Codable, Sendable {
    public let modelId: String
    public let accuracy: Float
    public let loss: Float
    public let epochs: Int
    public let trainingTime: TimeInterval
    
    public init(modelId: String, accuracy: Float, loss: Float, epochs: Int, trainingTime: TimeInterval) {
        self.modelId = modelId
        self.accuracy = accuracy
        self.loss = loss
        self.epochs = epochs
        self.trainingTime = trainingTime
    }
}

// MARK: - NLP Protocol

/// Protocol for all NLP models
public protocol NLPModelProtocol: Sendable {
    var modelType: NLPModelType { get }
    var language: String { get }
    
    func generateEmbeddings(_ text: String) async throws -> [Double]
    func analyze(_ text: String) async throws -> NLPAnalysisResult
    mutating func train(with data: NLPTrainingData) async throws -> NLPTrainingResult
}

// MARK: - NLP Model Types

public enum NLPModelType: String, Codable, Sendable, CaseIterable {
    case languageModel
    case embedding
    case sentiment
    case classification
    case entityRecognition
    case summarization
    case translation
    case custom
}

// MARK: - Core NLP Types

public struct NLPOptions: Hashable, Codable {
    public let includeSentiment: Bool
    public let includeEntities: Bool
    public let includeKeywords: Bool
    public let includeTopics: Bool
    public let includeLanguageDetection: Bool
    public let includeReadability: Bool
    public let maxKeywords: Int
    public let maxTopics: Int
    
    public init(
        includeSentiment: Bool = true,
        includeEntities: Bool = true,
        includeKeywords: Bool = true,
        includeTopics: Bool = false,
        includeLanguageDetection: Bool = false,
        includeReadability: Bool = false,
        maxKeywords: Int = 10,
        maxTopics: Int = 5
    ) {
        self.includeSentiment = includeSentiment
        self.includeEntities = includeEntities
        self.includeKeywords = includeKeywords
        self.includeTopics = includeTopics
        self.includeLanguageDetection = includeLanguageDetection
        self.includeReadability = includeReadability
        self.maxKeywords = maxKeywords
        self.maxTopics = maxTopics
    }
    
    public nonisolated(unsafe) static let `default` = NLPOptions()
    
    public nonisolated(unsafe) static let comprehensive = NLPOptions(
        includeSentiment: true,
        includeEntities: true,
        includeKeywords: true,
        includeTopics: true,
        includeLanguageDetection: true,
        includeReadability: true,
        maxKeywords: 20,
        maxTopics: 10
    )
    
    public nonisolated(unsafe) static let basic = NLPOptions(
        includeSentiment: true,
        includeEntities: false,
        includeKeywords: true,
        includeTopics: false,
        includeLanguageDetection: false,
        includeReadability: false,
        maxKeywords: 5,
        maxTopics: 3
    )
}

public struct NLPResult: Codable, ConfidenceProvider {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let originalText: String
    public let detectedLanguage: NLLanguage
    public let tokens: [String]
    public let sentences: [String]
    public let analysisResults: [String: Any]
    
    private enum CodingKeys: String, CodingKey {
        case id, timestamp, processingTime, confidence, metadata
        case originalText, detectedLanguage, tokens, sentences
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        originalText: String,
        detectedLanguage: NLLanguage,
        tokens: [String],
        sentences: [String],
        analysisResults: [String: Any]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.originalText = originalText
        self.detectedLanguage = detectedLanguage
        self.tokens = tokens
        self.sentences = sentences
        self.analysisResults = analysisResults
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        processingTime = try container.decode(TimeInterval.self, forKey: .processingTime)
        confidence = try container.decode(Float.self, forKey: .confidence)
        metadata = try container.decode([String: String].self, forKey: .metadata)
        originalText = try container.decode(String.self, forKey: .originalText)
        detectedLanguage = try container.decode(NLLanguage.self, forKey: .detectedLanguage)
        tokens = try container.decode([String].self, forKey: .tokens)
        sentences = try container.decode([String].self, forKey: .sentences)
        analysisResults = [:] // Cannot decode [String: Any] directly
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(processingTime, forKey: .processingTime)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(originalText, forKey: .originalText)
        try container.encode(detectedLanguage, forKey: .detectedLanguage)
        try container.encode(tokens, forKey: .tokens)
        try container.encode(sentences, forKey: .sentences)
    }
}

// MARK: - Sentiment Analysis

public struct SentimentResult: Codable, ConfidenceProvider, Sendable {
    public let sentiment: Sentiment
    public let score: Float // -1.0 (very negative) to 1.0 (very positive)
    public let confidence: Float
    public let positiveWords: [String]
    public let negativeWords: [String]
    
    public enum Sentiment: String, CaseIterable, Codable, Sendable {
        case positive = "positive"
        case negative = "negative"
        case neutral = "neutral"
        
        public var emoji: String {
            switch self {
            case .positive: return "😊"
            case .negative: return "😞"
            case .neutral: return "😐"
            }
        }
        
        public var description: String {
            switch self {
            case .positive: return "Positive"
            case .negative: return "Negative"
            case .neutral: return "Neutral"
            }
        }
    }
    
    public init(
        sentiment: Sentiment,
        score: Float,
        confidence: Float,
        positiveWords: [String] = [],
        negativeWords: [String] = []
    ) {
        self.sentiment = sentiment
        self.score = score
        self.confidence = confidence
        self.positiveWords = positiveWords
        self.negativeWords = negativeWords
    }
}

// MARK: - Named Entity Recognition

public struct NamedEntity: Codable, Sendable {
    public let text: String
    public let type: EntityType
    public let range: String // Encoded range
    public let confidence: Float
    
    public enum EntityType: String, CaseIterable, Codable, Sendable {
        case person = "person"
        case location = "location"
        case organization = "organization"
        case date = "date"
        case money = "money"
        case phoneNumber = "phone_number"
        case email = "email"
        case url = "url"
        case other = "other"
        
        public var emoji: String {
            switch self {
            case .person: return "👤"
            case .location: return "📍"
            case .organization: return "🏢"
            case .date: return "📅"
            case .money: return "💰"
            case .phoneNumber: return "📱"
            case .email: return "📧"
            case .url: return "🔗"
            case .other: return "❓"
            }
        }
        
        public var description: String {
            switch self {
            case .person: return "Person"
            case .location: return "Location"
            case .organization: return "Organization"
            case .date: return "Date"
            case .money: return "Money"
            case .phoneNumber: return "Phone Number"
            case .email: return "Email"
            case .url: return "URL"
            case .other: return "Other"
            }
        }
    }
    
    public init(text: String, type: EntityType, range: String, confidence: Float) {
        self.text = text
        self.type = type
        self.range = range
        self.confidence = confidence
    }
    
    public init(text: String, type: EntityType, range: Range<String.Index>, confidence: Float) {
        self.text = text
        self.type = type
        self.range = "\(range.lowerBound.utf16Offset(in: text)):\(range.upperBound.utf16Offset(in: text))"
        self.confidence = confidence
    }
}

// MARK: - Keywords and Topics

public struct Keyword: Codable, Hashable, Sendable {
    public let word: String
    public let score: Float
    public let frequency: Int
    
    public init(word: String, score: Float, frequency: Int) {
        self.word = word
        self.score = score
        self.frequency = frequency
    }
}

public struct Topic: Codable, Sendable {
    public let id: String
    public let label: String
    public let keywords: [Keyword]
    public let confidence: Float
    
    public init(id: String, label: String, keywords: [Keyword], confidence: Float) {
        self.id = id
        self.label = label
        self.keywords = keywords
        self.confidence = confidence
    }
}

// MARK: - Language Detection

public struct LanguageConfidence: Codable, Sendable {
    public let language: NLLanguage
    public let confidence: Float
    
    public var languageName: String {
        return Locale.current.localizedString(forLanguageCode: language.rawValue) ?? language.rawValue
    }
    
    public init(language: NLLanguage, confidence: Float) {
        self.language = language
        self.confidence = confidence
    }
}

// MARK: - Text Summarization

public struct SummaryResult: Codable, Sendable {
    public let originalText: String
    public let summary: String
    public let compressionRatio: Float
    public let selectedSentences: [ScoredSentence]
    
    public init(
        originalText: String,
        summary: String,
        compressionRatio: Float,
        selectedSentences: [ScoredSentence]
    ) {
        self.originalText = originalText
        self.summary = summary
        self.compressionRatio = compressionRatio
        self.selectedSentences = selectedSentences
    }
}

public struct ScoredSentence: Codable, Sendable {
    public let sentence: String
    public let score: Float
    public let position: Int
    
    public init(sentence: String, score: Float, position: Int) {
        self.sentence = sentence
        self.score = score
        self.position = position
    }
}

// MARK: - Translation

public struct TranslationResult: Codable, ConfidenceProvider {
    public let originalText: String
    public let translatedText: String
    public let sourceLanguage: NLLanguage
    public let targetLanguage: NLLanguage
    public let confidence: Float
    
    public init(
        originalText: String,
        translatedText: String,
        sourceLanguage: NLLanguage,
        targetLanguage: NLLanguage,
        confidence: Float
    ) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.confidence = confidence
    }
}

// MARK: - Readability Analysis

public struct ReadabilityMetrics: Codable, Sendable {
    public let fleschScore: Float // 0-100, higher is easier
    public let averageSentenceLength: Float
    public let averageWordLength: Float
    public let complexity: Complexity
    
    public enum Complexity: String, CaseIterable, Codable, Sendable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        
        public var emoji: String {
            switch self {
            case .easy: return "🟢"
            case .medium: return "🟡"
            case .hard: return "🔴"
            }
        }
        
        public var description: String {
            switch self {
            case .easy: return "Easy to read"
            case .medium: return "Moderate difficulty"
            case .hard: return "Difficult to read"
            }
        }
    }
    
    public init(
        fleschScore: Float,
        averageSentenceLength: Float,
        averageWordLength: Float,
        complexity: Complexity
    ) {
        self.fleschScore = fleschScore
        self.averageSentenceLength = averageSentenceLength
        self.averageWordLength = averageWordLength
        self.complexity = complexity
    }
}

// MARK: - Turkish-Specific Analysis

public struct TurkishAnalysisResult: Codable, ConfidenceProvider {
    public let morphologicalAnalysis: [MorphologicalUnit]
    public let turkishEntities: [TurkishEntity]
    public let dialectDetection: String
    public let confidence: Float
    
    public init(
        morphologicalAnalysis: [MorphologicalUnit],
        turkishEntities: [TurkishEntity],
        dialectDetection: String,
        confidence: Float
    ) {
        self.morphologicalAnalysis = morphologicalAnalysis
        self.turkishEntities = turkishEntities
        self.dialectDetection = dialectDetection
        self.confidence = confidence
    }
}

public struct MorphologicalUnit: Codable {
    public let surface: String
    public let lemma: String
    public let pos: String // Part of speech
    public let features: [String]
    
    public init(surface: String, lemma: String, pos: String, features: [String]) {
        self.surface = surface
        self.lemma = lemma
        self.pos = pos
        self.features = features
    }
}

public struct TurkishEntity: Codable {
    public let text: String
    public let type: TurkishEntityType
    public let confidence: Float
    
    public enum TurkishEntityType: String, CaseIterable, Codable {
        case turkishPerson = "turkish_person"
        case turkishLocation = "turkish_location"
        case turkishOrganization = "turkish_organization"
        case turkishCurrency = "turkish_currency"
        case turkishDate = "turkish_date"
        
        public var description: String {
            switch self {
            case .turkishPerson: return "Turkish Person"
            case .turkishLocation: return "Turkish Location"
            case .turkishOrganization: return "Turkish Organization"
            case .turkishCurrency: return "Turkish Currency"
            case .turkishDate: return "Turkish Date"
            }
        }
    }
    
    public init(text: String, type: TurkishEntityType, confidence: Float) {
        self.text = text
        self.type = type
        self.confidence = confidence
    }
}

// MARK: - Errors

public enum NLPError: LocalizedError {
    case invalidText
    case modelNotInitialized
    case modelPredictionFailed
    case processingFailed(Error)
    case unsupportedLanguage(NLLanguage)
    case insufficientMemory
    case networkError
    case translationNotSupported
    
    public var errorDescription: String? {
        switch self {
        case .invalidText:
            return "Invalid or empty text provided"
        case .modelNotInitialized:
            return "NLP model not initialized"
        case .modelPredictionFailed:
            return "Model prediction failed"
        case .processingFailed(let error):
            return "NLP processing failed: \(error.localizedDescription)"
        case .unsupportedLanguage(let language):
            return "Unsupported language: \(language.rawValue)"
        case .insufficientMemory:
            return "Insufficient memory for NLP operation"
        case .networkError:
            return "Network error during NLP operation"
        case .translationNotSupported:
            return "Translation not supported for this language pair"
        }
    }
}

// MARK: - Configuration
// NLPConfiguration is defined in Configuration/NLPConfiguration.swift

// MARK: - Extensions for NLLanguage

extension NLLanguage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension NLLanguage {
    public var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .russian: return "🇷🇺"
        case .simplifiedChinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        default: return "🌍"
        }
    }
    
    public var localizedName: String {
        return Locale.current.localizedString(forLanguageCode: self.rawValue) ?? self.rawValue
    }
}

// MARK: - Additional NLP Result Types


// MARK: - SwiftIntelligence NLP Components

public enum TokenizationType: String, Sendable {
    case words
    case sentences
    case paragraphs
    case custom
}

public enum SentimentType: String, Sendable {
    case positive
    case negative
    case neutral
    case mixed
}

public struct SentimentScores: Sendable {
    public let positive: Double
    public let negative: Double
    public let neutral: Double
    
    public init(positive: Double, negative: Double, neutral: Double) {
        self.positive = positive
        self.negative = negative
        self.neutral = neutral
    }
}

// Removed duplicate SentimentAnalysisResult - use SentimentResult instead

/// NLP tokenizer
public struct NLPTokenizer {
    public let language: String
    private let tokenizer: NLTokenizer
    
    public init(language: String) {
        self.language = language
        self.tokenizer = NLTokenizer(unit: .word)
        
        let nlLanguage = NLLanguage(rawValue: language)
        self.tokenizer.setLanguage(nlLanguage)
    }
    
    public func tokenize(_ text: String, type: TokenizationType) async -> [String] {
        switch type {
        case .words:
            return tokenizeWords(text)
        case .sentences:
            return tokenizeSentences(text)
        case .paragraphs:
            return tokenizeParagraphs(text)
        case .custom:
            return tokenizeWords(text) // Default to words for custom
        }
    }
    
    private func tokenizeWords(_ text: String) -> [String] {
        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let token = String(text[tokenRange])
            if !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tokens.append(token)
            }
            return true
        }
        return tokens
    }
    
    private func tokenizeSentences(_ text: String) -> [String] {
        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        var sentences: [String] = []
        
        sentenceTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let sentence = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
            return true
        }
        return sentences
    }
    
    private func tokenizeParagraphs(_ text: String) -> [String] {
        let paragraphTokenizer = NLTokenizer(unit: .paragraph)
        var paragraphs: [String] = []
        
        paragraphTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let paragraph = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !paragraph.isEmpty {
                paragraphs.append(paragraph)
            }
            return true
        }
        return paragraphs
    }
}

/// NLP vocabulary
public struct NLPVocabulary: Sendable {
    public let language: String
    private let words: Set<String>
    
    public init(language: String, customWords: [String] = []) {
        self.language = language
        
        // Initialize with basic vocabulary for the language
        var vocabulary: Set<String> = []
        vocabulary.formUnion(customWords)
        
        // Add common words for the language (simplified)
        vocabulary.formUnion(Self.getCommonWords(for: language))
        
        self.words = vocabulary
    }
    
    public func contains(_ word: String) -> Bool {
        return words.contains(word.lowercased())
    }
    
    public func size() -> Int {
        return words.count
    }
    
    public func getWords() -> [String] {
        return Array(words).sorted()
    }
    
    private static func getCommonWords(for language: String) -> [String] {
        // Simplified common words - in production, this would load from language-specific dictionaries
        switch language {
        case "en":
            return ["the", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "from", "up", "about", "into", "through", "during", "before", "after", "above", "below", "between", "among", "under", "over", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "can", "must", "this", "that", "these", "those", "a", "an", "what", "who", "where", "when", "why", "how"]
        case "tr":
            return ["ve", "ile", "bir", "bu", "şu", "o", "da", "de", "ki", "mi", "mı", "mu", "mü", "için", "gibi", "kadar", "daha", "en", "çok", "az", "var", "yok", "olan", "oldu", "olur", "ama", "fakat", "ancak", "veya", "yahut", "hem", "ne", "nasıl", "neden", "niçin", "nerede", "ne zaman", "kim", "kimi", "kimin", "hangi", "hangisi"]
        case "fr":
            return ["le", "de", "et", "à", "un", "il", "être", "et", "en", "avoir", "que", "pour", "dans", "ce", "son", "une", "sur", "avec", "ne", "se", "pas", "tout", "plus", "par", "grand", "en", "une", "être", "et", "de", "il", "avoir", "ne", "je", "son", "que", "se", "qui", "ce", "dans", "en", "du", "elle", "au", "de", "ce", "le", "pour", "sont", "avec", "ils"]
        case "de":
            return ["der", "die", "und", "in", "den", "von", "zu", "das", "mit", "sich", "des", "auf", "für", "ist", "im", "dem", "nicht", "ein", "eine", "als", "auch", "es", "an", "werden", "aus", "er", "hat", "dass", "sie", "nach", "wird", "bei", "einer", "um", "am", "sind", "noch", "wie", "einem", "über", "einen", "so", "zum", "war", "haben", "nur", "oder", "aber", "vor", "zur", "bis", "mehr"]
        case "es":
            return ["el", "la", "de", "que", "y", "a", "en", "un", "ser", "se", "no", "te", "lo", "le", "da", "su", "por", "son", "con", "para", "al", "una", "su", "los", "todo", "pero", "más", "hacer", "o", "poder", "decir", "este", "ir", "otro", "ese", "la", "si", "me", "ya", "ver", "porque", "dar", "cuando", "él", "muy", "sin", "vez", "mucho", "saber", "qué", "sobre"]
        case "it":
            return ["il", "di", "che", "e", "la", "il", "un", "a", "essere", "lo", "tutto", "per", "una", "in", "con", "avere", "tu", "non", "io", "questo", "bene", "sì", "fare", "corso", "lei", "noi", "ora", "ma", "mi", "qui", "ciao", "quello", "molto", "bene", "tutti", "cosa", "nome", "bene", "venire", "da", "sapere", "suo", "mio", "tempo", "se", "no", "casa", "scrivere", "madre", "terra", "finestra"]
        default:
            return []
        }
    }
}

/// NLP sentiment analyzer
public actor NLPSentimentAnalyzer: Sendable {
    private var sentimentAnalyzers: [String: NLTagger] = [:]
    
    public init() {
        Task {
            await setupSentimentAnalyzers()
        }
    }
    
    private func setupSentimentAnalyzers() {
        let supportedLanguages = ["en", "tr", "fr", "de", "es", "it"]
        
        for language in supportedLanguages {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            let _ = NLLanguage(rawValue: language)
            // We'll set the language when we have actual text to analyze
            sentimentAnalyzers[language] = tagger
        }
    }
    
    public func analyze(_ text: String, language: String = "en") async -> SentimentResult {
        guard let tagger = sentimentAnalyzers[language] else {
            // Fallback to simple rule-based sentiment
            return performRuleBasedSentiment(text)
        }
        
        tagger.string = text
        
        let (tag, confidenceRange) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let sentimentScore = tag?.rawValue, let score = Double(sentimentScore) {
            let sentiment: SentimentType
            let positiveScore: Double
            let negativeScore: Double
            let neutralScore: Double
            
            if score > 0.1 {
                sentiment = .positive
                positiveScore = min(score + 0.5, 1.0)
                negativeScore = max(0.0, 0.5 - score)
                neutralScore = max(0.0, 1.0 - positiveScore - negativeScore)
            } else if score < -0.1 {
                sentiment = .negative
                negativeScore = min(abs(score) + 0.5, 1.0)
                positiveScore = max(0.0, 0.5 - abs(score))
                neutralScore = max(0.0, 1.0 - positiveScore - negativeScore)
            } else {
                sentiment = .neutral
                neutralScore = 0.7
                positiveScore = 0.15
                negativeScore = 0.15
            }
            
            let scores = SentimentScores(
                positive: positiveScore,
                negative: negativeScore,
                neutral: neutralScore
            )
            
            // Calculate confidence based on the score magnitude
            let calculatedConfidence = min(1.0, abs(score) + 0.5)
            
            return SentimentResult(
                sentiment: .positive, // Convert from SentimentType to Sentiment enum
                score: Float(scores.positive - scores.negative), // Convert to -1.0 to 1.0 range
                confidence: Float(calculatedConfidence),
                positiveWords: [], 
                negativeWords: []
            )
        } else {
            return performRuleBasedSentiment(text)
        }
    }
    
    private func performRuleBasedSentiment(_ text: String) -> SentimentResult {
        let positiveWords = ["good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome", "love", "like", "happy", "joy", "perfect", "best", "brilliant", "outstanding", "superb", "magnificent", "marvelous", "terrific", "fabulous"]
        let negativeWords = ["bad", "terrible", "awful", "horrible", "disgusting", "hate", "dislike", "sad", "angry", "worst", "terrible", "dreadful", "appalling", "atrocious", "abysmal", "deplorable", "pathetic", "useless", "worthless", "disappointing"]
        
        let lowercaseText = text.lowercased()
        var positiveCount = 0
        var negativeCount = 0
        
        for word in positiveWords {
            if lowercaseText.contains(word) {
                positiveCount += 1
            }
        }
        
        for word in negativeWords {
            if lowercaseText.contains(word) {
                negativeCount += 1
            }
        }
        
        let total = positiveCount + negativeCount
        let sentiment: SentimentType
        let confidence: Double
        let positiveScore: Double
        let negativeScore: Double
        let neutralScore: Double
        
        if total == 0 {
            sentiment = .neutral
            confidence = 0.5
            positiveScore = 0.33
            negativeScore = 0.33
            neutralScore = 0.34
        } else if positiveCount > negativeCount {
            sentiment = .positive
            confidence = Double(positiveCount) / Double(total)
            positiveScore = confidence
            negativeScore = 1.0 - confidence
            neutralScore = 0.1
        } else if negativeCount > positiveCount {
            sentiment = .negative
            confidence = Double(negativeCount) / Double(total)
            negativeScore = confidence
            positiveScore = 1.0 - confidence
            neutralScore = 0.1
        } else {
            sentiment = .mixed
            confidence = 0.5
            positiveScore = 0.45
            negativeScore = 0.45
            neutralScore = 0.1
        }
        
        let scores = SentimentScores(
            positive: positiveScore,
            negative: negativeScore,
            neutral: neutralScore
        )
        
        return SentimentResult(
            sentiment: .neutral, // Convert from SentimentType to Sentiment enum
            score: Float(positiveScore - negativeScore), // Convert to -1.0 to 1.0 range
            confidence: Float(confidence),
            positiveWords: [],
            negativeWords: []
        )
    }
}

// MARK: - Text Classification Results

public struct TextClassificationResult: Codable, Sendable {
    public let predictedCategory: String
    public let confidence: Double
    public let allScores: [String: Double]
    public let processingTime: TimeInterval
    
    public init(predictedCategory: String, confidence: Double, allScores: [String: Double], processingTime: TimeInterval) {
        self.predictedCategory = predictedCategory
        self.confidence = confidence
        self.allScores = allScores
        self.processingTime = processingTime
    }
}

// MARK: - Text Similarity Results

public struct TextSimilarityResult: Codable, Sendable {
    public let jaccardSimilarity: Double
    public let cosineSimilarity: Double
    public let averageSimilarity: Double
    public let processingTime: TimeInterval
    
    public init(jaccardSimilarity: Double, cosineSimilarity: Double, averageSimilarity: Double, processingTime: TimeInterval) {
        self.jaccardSimilarity = jaccardSimilarity
        self.cosineSimilarity = cosineSimilarity
        self.averageSimilarity = averageSimilarity
        self.processingTime = processingTime
    }
}

// MARK: - Language Detection Results

public struct LanguageDetectionResult: Sendable {
    public let detectedLanguage: String
    public let confidence: Double
    public let allLanguages: [String: Double]
    public let processingTime: TimeInterval
    
    public init(detectedLanguage: String, confidence: Double, allLanguages: [String: Double], processingTime: TimeInterval) {
        self.detectedLanguage = detectedLanguage
        self.confidence = confidence
        self.allLanguages = allLanguages
        self.processingTime = processingTime
    }
}

// MARK: - Entity Extraction Results

public struct EntityExtractionResult: Sendable {
    public let entities: [NamedEntity]
    public let entityCount: Int
    public let processingTime: TimeInterval
    
    public init(entities: [NamedEntity], entityCount: Int, processingTime: TimeInterval) {
        self.entities = entities
        self.entityCount = entityCount
        self.processingTime = processingTime
    }
}

// MARK: - Tokenization Results Extended

public struct TokenizationResult: Sendable {
    public let tokens: [String]
    public let tokenCount: Int
    public let language: String
    public let type: TokenizationType
    public let processingTime: TimeInterval
    
    public init(tokens: [String], tokenCount: Int, language: String, type: TokenizationType, processingTime: TimeInterval) {
        self.tokens = tokens
        self.tokenCount = tokenCount
        self.language = language
        self.type = type
        self.processingTime = processingTime
    }
}

// MARK: - Text Embedding Results Extended

public struct TextEmbeddingResult: Sendable {
    public let embeddings: [Double]
    public let dimension: Int
    public let modelType: String
    public let processingTime: TimeInterval
    
    public init(embeddings: [Double], dimension: Int, modelType: String, processingTime: TimeInterval) {
        self.embeddings = embeddings
        self.dimension = dimension
        self.modelType = modelType
        self.processingTime = processingTime
    }
}

// MARK: - Performance Metrics

/// NLP engine performance metrics
public struct NLPPerformanceMetrics: Sendable {
    public var languageDetectionCount: Int = 0
    public var tokenizationCount: Int = 0
    public var sentimentAnalysisCount: Int = 0
    public var embeddingGenerationCount: Int = 0
    public var entityExtractionCount: Int = 0
    public var textClassificationCount: Int = 0
    
    public var averageLanguageDetectionTime: TimeInterval = 0.0
    public var averageTokenizationTime: TimeInterval = 0.0
    public var averageSentimentAnalysisTime: TimeInterval = 0.0
    public var averageEmbeddingTime: TimeInterval = 0.0
    public var averageEntityExtractionTime: TimeInterval = 0.0
    public var averageClassificationTime: TimeInterval = 0.0
    
    public var totalTokensProcessed: Int = 0
    public var totalEntitiesExtracted: Int = 0
    
    public init() {}
}
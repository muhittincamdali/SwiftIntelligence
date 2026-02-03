// MARK: - NLP Processor Template
// SwiftIntelligence Framework
// Created by Muhittin Camdali

import Foundation
import NaturalLanguage
import SwiftIntelligence

// MARK: - NLP Processor Protocol

/// Protocol for natural language processing tasks
public protocol NLPProcessorProtocol {
    /// Process text and return analysis results
    func process(_ text: String) async throws -> NLPResult
    
    /// Analyze sentiment of text
    func analyzeSentiment(_ text: String) -> SentimentScore
    
    /// Extract named entities
    func extractEntities(_ text: String) -> [NamedEntity]
    
    /// Tokenize text
    func tokenize(_ text: String) -> [Token]
}

// MARK: - NLP Result

/// Result of NLP analysis
public struct NLPResult: Sendable {
    public let text: String
    public let language: String?
    public let sentiment: SentimentScore
    public let entities: [NamedEntity]
    public let tokens: [Token]
    public let keyPhrases: [String]
    public let processingTime: TimeInterval
    
    public init(
        text: String,
        language: String?,
        sentiment: SentimentScore,
        entities: [NamedEntity],
        tokens: [Token],
        keyPhrases: [String],
        processingTime: TimeInterval
    ) {
        self.text = text
        self.language = language
        self.sentiment = sentiment
        self.entities = entities
        self.tokens = tokens
        self.keyPhrases = keyPhrases
        self.processingTime = processingTime
    }
}

// MARK: - Sentiment Score

/// Sentiment analysis result
public struct SentimentScore: Sendable {
    public let score: Double
    public let label: SentimentLabel
    public let confidence: Double
    
    public enum SentimentLabel: String, Sendable {
        case positive
        case negative
        case neutral
        case mixed
    }
    
    public init(score: Double) {
        self.score = score
        self.confidence = abs(score)
        
        if score > 0.3 {
            self.label = .positive
        } else if score < -0.3 {
            self.label = .negative
        } else {
            self.label = .neutral
        }
    }
}

// MARK: - Named Entity

/// Named entity extracted from text
public struct NamedEntity: Sendable, Identifiable {
    public let id = UUID()
    public let text: String
    public let type: EntityType
    public let range: Range<String.Index>?
    
    public enum EntityType: String, Sendable, CaseIterable {
        case person = "Person"
        case organization = "Organization"
        case location = "Location"
        case date = "Date"
        case money = "Money"
        case percentage = "Percentage"
        case other = "Other"
    }
    
    public init(text: String, type: EntityType, range: Range<String.Index>? = nil) {
        self.text = text
        self.type = type
        self.range = range
    }
}

// MARK: - Token

/// Token from text tokenization
public struct Token: Sendable, Identifiable {
    public let id = UUID()
    public let text: String
    public let lemma: String?
    public let partOfSpeech: PartOfSpeech
    public let range: Range<String.Index>?
    
    public enum PartOfSpeech: String, Sendable {
        case noun, verb, adjective, adverb
        case pronoun, preposition, conjunction
        case determiner, interjection
        case particle, punctuation
        case other
    }
    
    public init(
        text: String,
        lemma: String? = nil,
        partOfSpeech: PartOfSpeech = .other,
        range: Range<String.Index>? = nil
    ) {
        self.text = text
        self.lemma = lemma
        self.partOfSpeech = partOfSpeech
        self.range = range
    }
}

// MARK: - NLP Processor Implementation

/// Default implementation of NLP processor
public final class NLPProcessor: NLPProcessorProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let sentimentTagger: NLTagger
    private let entityTagger: NLTagger
    private let tokenizer: NLTokenizer
    
    // MARK: - Initialization
    
    public init() {
        self.sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])
        self.entityTagger = NLTagger(tagSchemes: [.nameType])
        self.tokenizer = NLTokenizer(unit: .word)
    }
    
    // MARK: - Process
    
    public func process(_ text: String) async throws -> NLPResult {
        let startTime = Date()
        
        // Detect language
        let language = detectLanguage(text)
        
        // Analyze sentiment
        let sentiment = analyzeSentiment(text)
        
        // Extract entities
        let entities = extractEntities(text)
        
        // Tokenize
        let tokens = tokenize(text)
        
        // Extract key phrases
        let keyPhrases = extractKeyPhrases(text)
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        return NLPResult(
            text: text,
            language: language,
            sentiment: sentiment,
            entities: entities,
            tokens: tokens,
            keyPhrases: keyPhrases,
            processingTime: processingTime
        )
    }
    
    // MARK: - Sentiment Analysis
    
    public func analyzeSentiment(_ text: String) -> SentimentScore {
        sentimentTagger.string = text
        
        var totalScore: Double = 0
        var count: Int = 0
        
        sentimentTagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        ) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }
        
        let averageScore = count > 0 ? totalScore / Double(count) : 0
        return SentimentScore(score: averageScore)
    }
    
    // MARK: - Entity Extraction
    
    public func extractEntities(_ text: String) -> [NamedEntity] {
        entityTagger.string = text
        var entities: [NamedEntity] = []
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        entityTagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, range in
            if let tag = tag {
                let entityType = mapNLTagToEntityType(tag)
                let entity = NamedEntity(
                    text: String(text[range]),
                    type: entityType,
                    range: range
                )
                entities.append(entity)
            }
            return true
        }
        
        return entities
    }
    
    // MARK: - Tokenization
    
    public func tokenize(_ text: String) -> [Token] {
        tokenizer.string = text
        var tokens: [Token] = []
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let tokenText = String(text[range])
            let token = Token(text: tokenText, range: range)
            tokens.append(token)
            return true
        }
        
        return tokens
    }
    
    // MARK: - Language Detection
    
    public func detectLanguage(_ text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage?.rawValue
    }
    
    // MARK: - Key Phrase Extraction
    
    public func extractKeyPhrases(_ text: String) -> [String] {
        let tokens = tokenize(text)
        
        // Simple key phrase extraction based on noun sequences
        var keyPhrases: [String] = []
        var currentPhrase: [String] = []
        
        for token in tokens {
            // Check if token is significant (length > 3, not a stop word)
            if token.text.count > 3 && !isStopWord(token.text) {
                currentPhrase.append(token.text)
            } else {
                if currentPhrase.count >= 2 {
                    keyPhrases.append(currentPhrase.joined(separator: " "))
                }
                currentPhrase = []
            }
        }
        
        if currentPhrase.count >= 2 {
            keyPhrases.append(currentPhrase.joined(separator: " "))
        }
        
        return keyPhrases
    }
    
    // MARK: - Helper Methods
    
    private func mapNLTagToEntityType(_ tag: NLTag) -> NamedEntity.EntityType {
        switch tag {
        case .personalName: return .person
        case .organizationName: return .organization
        case .placeName: return .location
        default: return .other
        }
    }
    
    private func isStopWord(_ word: String) -> Bool {
        let stopWords = Set([
            "the", "a", "an", "is", "are", "was", "were", "be", "been",
            "being", "have", "has", "had", "do", "does", "did", "will",
            "would", "could", "should", "may", "might", "must", "shall",
            "can", "need", "dare", "ought", "used", "to", "of", "in",
            "for", "on", "with", "at", "by", "from", "as", "into",
            "through", "during", "before", "after", "above", "below"
        ])
        return stopWords.contains(word.lowercased())
    }
}

// MARK: - Usage Example

/*
 let processor = NLPProcessor()
 
 // Full analysis
 let result = try await processor.process("Apple Inc. announced new products in California.")
 print("Language: \(result.language ?? "unknown")")
 print("Sentiment: \(result.sentiment.label)")
 print("Entities: \(result.entities.map { "\($0.text) (\($0.type))" })")
 
 // Quick sentiment check
 let sentiment = processor.analyzeSentiment("I love this product!")
 print("Score: \(sentiment.score), Label: \(sentiment.label)")
 */

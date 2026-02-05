// NLPEngine.swift
// SwiftIntelligence - Natural Language Processing
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import NaturalLanguage
import CoreML

/// High-performance Natural Language Processing engine
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public actor NLPEngine {
    
    // MARK: - Singleton
    
    public static let shared = NLPEngine()
    
    // MARK: - Properties
    
    private let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .sentimentScore])
    private var embeddingModel: NLEmbedding?
    private var cache = NSCache<NSString, AnyObject>()
    
    // MARK: - Initialization
    
    private init() {
        cache.countLimit = 100
        
        // Load English word embeddings
        embeddingModel = NLEmbedding.wordEmbedding(for: .english)
    }
    
    // MARK: - Sentiment Analysis
    
    /// Analyze sentiment of text
    public func analyzeSentiment(_ text: String) async throws -> SentimentResult {
        guard !text.isEmpty else {
            throw NLPError.emptyText
        }
        
        // Check cache
        let cacheKey = NSString(string: "sentiment_\(text.hashValue)")
        if let cached = cache.object(forKey: cacheKey) as? SentimentResult {
            return cached
        }
        
        tagger.string = text
        
        var totalScore: Double = 0
        var count = 0
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .sentence,
            scheme: .sentimentScore,
            options: [.omitWhitespace]
        ) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }
        
        let score = count > 0 ? Float(totalScore / Double(count)) : 0.0
        
        let label: SentimentResult.SentimentLabel = {
            switch score {
            case ..<(-0.6): return .veryNegative
            case ..<(-0.2): return .negative
            case ..<0.2: return .neutral
            case ..<0.6: return .positive
            default: return .veryPositive
            }
        }()
        
        let result = SentimentResult(
            score: score,
            label: label,
            confidence: min(1.0, abs(score) + 0.5)
        )
        
        cache.setObject(result as AnyObject, forKey: cacheKey)
        
        return result
    }
    
    // MARK: - Entity Extraction
    
    /// Extract named entities from text
    public func extractEntities(from text: String) async throws -> [Entity] {
        guard !text.isEmpty else {
            throw NLPError.emptyText
        }
        
        tagger.string = text
        
        var entities: [Entity] = []
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: [.omitWhitespace, .omitPunctuation, .joinNames]
        ) { tag, range in
            guard let tag = tag else { return true }
            
            let entityType: Entity.EntityType = {
                switch tag {
                case .personalName: return .person
                case .organizationName: return .organization
                case .placeName: return .place
                default: return .other
                }
            }()
            
            if entityType != .other {
                let entity = Entity(
                    text: String(text[range]),
                    type: entityType,
                    range: range,
                    confidence: 0.85
                )
                entities.append(entity)
            }
            
            return true
        }
        
        return entities
    }
    
    // MARK: - Language Detection
    
    /// Detect language of text
    public func detectLanguage(_ text: String) async throws -> LanguageResult {
        guard !text.isEmpty else {
            throw NLPError.emptyText
        }
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let dominantLanguage = recognizer.dominantLanguage else {
            throw NLPError.languageDetectionFailed
        }
        
        let hypotheses = recognizer.languageHypotheses(withMaximum: 1)
        let confidence = hypotheses[dominantLanguage] ?? 0.5
        
        let languageName = Locale.current.localizedString(forIdentifier: dominantLanguage.rawValue) ?? dominantLanguage.rawValue
        
        return LanguageResult(
            languageCode: dominantLanguage.rawValue,
            languageName: languageName,
            confidence: Float(confidence)
        )
    }
    
    // MARK: - Text Summarization
    
    /// Summarize text content
    public func summarize(_ text: String, maxLength: Int) async throws -> String {
        guard !text.isEmpty else {
            throw NLPError.emptyText
        }
        
        // Split into sentences
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [(String, Float)] = []
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                // Score based on position and length
                let positionScore = Float(sentences.count == 0 ? 1.0 : 0.5)
                let lengthScore = min(1.0, Float(sentence.count) / 100.0)
                sentences.append((sentence, positionScore + lengthScore))
            }
            return true
        }
        
        // Sort by score and take top sentences
        let sortedSentences = sentences.sorted { $0.1 > $1.1 }
        
        var summary = ""
        var wordCount = 0
        
        for (sentence, _) in sortedSentences {
            let words = sentence.split(separator: " ").count
            if wordCount + words <= maxLength {
                summary += sentence + " "
                wordCount += words
            } else {
                break
            }
        }
        
        return summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Keyword Extraction
    
    /// Extract keywords from text
    public func extractKeywords(from text: String, count: Int) async throws -> [Keyword] {
        guard !text.isEmpty else {
            throw NLPError.emptyText
        }
        
        tagger.string = text
        
        var wordFrequency: [String: Int] = [:]
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in
            guard let tag = tag else { return true }
            
            // Only consider nouns and verbs
            if tag == .noun || tag == .verb {
                let word = String(text[range]).lowercased()
                if word.count > 2 {
                    wordFrequency[word, default: 0] += 1
                }
            }
            
            return true
        }
        
        // Calculate TF-IDF-like score
        let maxFreq = Float(wordFrequency.values.max() ?? 1)
        
        let keywords = wordFrequency.map { word, freq in
            let tf = Float(freq) / maxFreq
            let idf = log(Float(text.count) / Float(freq + 1))
            return Keyword(text: word, relevance: tf * idf)
        }
        .sorted { $0.relevance > $1.relevance }
        .prefix(count)
        
        return Array(keywords)
    }
    
    // MARK: - Semantic Similarity
    
    /// Calculate semantic similarity between texts
    public func similarity(_ text1: String, _ text2: String) async throws -> Float {
        guard !text1.isEmpty && !text2.isEmpty else {
            throw NLPError.emptyText
        }
        
        // Use word embeddings for similarity
        guard let embedding = embeddingModel else {
            // Fallback to Jaccard similarity
            return jaccardSimilarity(text1, text2)
        }
        
        // Get vectors for each text
        let vector1 = averageEmbedding(for: text1, embedding: embedding)
        let vector2 = averageEmbedding(for: text2, embedding: embedding)
        
        guard let v1 = vector1, let v2 = vector2 else {
            return jaccardSimilarity(text1, text2)
        }
        
        // Cosine similarity
        return cosineSimilarity(v1, v2)
    }
    
    // MARK: - Text Classification
    
    /// Classify text into categories
    public func classify(
        _ text: String,
        categories: [String]
    ) async throws -> TextClassificationResult {
        guard !text.isEmpty else {
            throw NLPError.emptyText
        }
        
        guard !categories.isEmpty else {
            throw NLPError.noCategories
        }
        
        // Use similarity-based classification
        var scores: [String: Float] = [:]
        
        for category in categories {
            let similarity = try await similarity(text, category)
            scores[category] = similarity
        }
        
        // Normalize scores
        let total = scores.values.reduce(0, +)
        if total > 0 {
            for key in scores.keys {
                scores[key]! /= total
            }
        }
        
        guard let (topCategory, topScore) = scores.max(by: { $0.value < $1.value }) else {
            throw NLPError.classificationFailed
        }
        
        return TextClassificationResult(
            category: topCategory,
            confidence: topScore,
            allScores: scores
        )
    }
    
    // MARK: - Reset
    
    public func reset() async {
        cache.removeAllObjects()
    }
    
    // MARK: - Helpers
    
    private func jaccardSimilarity(_ text1: String, _ text2: String) -> Float {
        let words1 = Set(text1.lowercased().split(separator: " ").map(String.init))
        let words2 = Set(text2.lowercased().split(separator: " ").map(String.init))
        
        let intersection = words1.intersection(words2).count
        let union = words1.union(words2).count
        
        return union > 0 ? Float(intersection) / Float(union) : 0
    }
    
    private func averageEmbedding(for text: String, embedding: NLEmbedding) -> [Double]? {
        let words = text.lowercased().split(separator: " ").map(String.init)
        
        var vectors: [[Double]] = []
        for word in words {
            if let vector = embedding.vector(for: word) {
                vectors.append(vector)
            }
        }
        
        guard !vectors.isEmpty else { return nil }
        
        let dimension = vectors[0].count
        var average = [Double](repeating: 0, count: dimension)
        
        for vector in vectors {
            for i in 0..<dimension {
                average[i] += vector[i]
            }
        }
        
        for i in 0..<dimension {
            average[i] /= Double(vectors.count)
        }
        
        return average
    }
    
    private func cosineSimilarity(_ v1: [Double], _ v2: [Double]) -> Float {
        guard v1.count == v2.count else { return 0 }
        
        var dotProduct: Double = 0
        var norm1: Double = 0
        var norm2: Double = 0
        
        for i in 0..<v1.count {
            dotProduct += v1[i] * v2[i]
            norm1 += v1[i] * v1[i]
            norm2 += v2[i] * v2[i]
        }
        
        let denominator = sqrt(norm1) * sqrt(norm2)
        return denominator > 0 ? Float(dotProduct / denominator) : 0
    }
}

// MARK: - NLP Errors

public enum NLPError: LocalizedError {
    case emptyText
    case languageDetectionFailed
    case classificationFailed
    case noCategories
    case embeddingNotAvailable
    
    public var errorDescription: String? {
        switch self {
        case .emptyText: return "Text cannot be empty"
        case .languageDetectionFailed: return "Language detection failed"
        case .classificationFailed: return "Text classification failed"
        case .noCategories: return "No categories provided"
        case .embeddingNotAvailable: return "Word embeddings not available"
        }
    }
}

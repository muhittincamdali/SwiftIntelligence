import Foundation
import SwiftIntelligenceCore
import NaturalLanguage

// MARK: - N-Gram Language Model

public struct NGramLanguageModel: NLPModelProtocol, Sendable {
    
    public let modelType: NLPModelType = .languageModel
    public let language: String
    
    private let n: Int
    private var ngramCounts: [String: Int] = [:]
    private var vocabulary: Set<String> = []
    
    public init(n: Int = 3, language: String = "en") {
        self.n = n
        self.language = language
    }
    
    public func generateEmbeddings(_ text: String) async throws -> [Double] {
        // Simple word frequency-based embeddings
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let dimension = 100 // Fixed dimension
        
        var embedding = Array(repeating: 0.0, count: dimension)
        
        for (index, word) in words.enumerated() {
            let hash = abs(word.hashValue) % dimension
            embedding[hash] += 1.0 / Double(words.count)
        }
        
        // Normalize
        let magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
        if magnitude > 0 {
            embedding = embedding.map { $0 / magnitude }
        }
        
        return embedding
    }
    
    public func analyze(_ text: String) async throws -> NLPAnalysisResult {
        let startTime = Date()
        
        // Generate embeddings
        let embeddings = try await generateEmbeddings(text)
        let embeddingResult = TextEmbeddingResult(
            embeddings: embeddings,
            dimension: embeddings.count,
            modelType: "ngram",
            processingTime: Date().timeIntervalSince(startTime)
        )
        
        let totalProcessingTime = Date().timeIntervalSince(startTime)
        
        return NLPAnalysisResult(
            embeddings: embeddingResult,
            processingTime: totalProcessingTime
        )
    }
    
    public func train(with data: NLPTrainingData) async throws -> NLPTrainingResult {
        let startTime = Date()
        
        // Build n-gram model from training texts
        for text in data.texts {
            let tokens = tokenize(text)
            vocabulary.formUnion(tokens)
            
            for i in 0...(tokens.count - n) {
                let ngram = tokens[i..<(i + n)].joined(separator: " ")
                ngramCounts[ngram, default: 0] += 1
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Calculate accuracy based on vocabulary coverage
        let totalTokens = data.texts.joined().components(separatedBy: .whitespacesAndNewlines).count
        let coveredTokens = vocabulary.count
        let accuracy = Float(coveredTokens) / Float(totalTokens)
        
        return NLPTrainingResult(
            accuracy: min(accuracy, 1.0),
            loss: 1.0 - min(accuracy, 1.0),
            epochs: 1, // Single pass for n-gram model
            duration: duration,
            modelType: .languageModel,
            metadata: [
                "n": String(n),
                "vocabulary_size": String(vocabulary.count),
                "ngram_count": String(ngramCounts.count)
            ]
        )
    }
    
    private func tokenize(_ text: String) -> [String] {
        return text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
    
    /// Get probability of a word sequence
    public func getProbability(for sequence: [String]) -> Double {
        guard sequence.count >= n else { return 0.0 }
        
        let ngram = sequence.joined(separator: " ")
        let count = ngramCounts[ngram] ?? 0
        
        // Simple maximum likelihood estimation
        let totalCount = ngramCounts.values.reduce(0, +)
        return totalCount > 0 ? Double(count) / Double(totalCount) : 0.0
    }
}

// MARK: - Simple Word Embedding Model

public struct SimpleWordEmbeddingModel: NLPModelProtocol, Sendable {
    
    public let modelType: NLPModelType = .embedding
    public let language: String
    
    private let dimension: Int
    private var wordVectors: [String: [Double]] = [:]
    
    public init(dimension: Int = 100, language: String = "en") {
        self.dimension = dimension
        self.language = language
    }
    
    public func generateEmbeddings(_ text: String) async throws -> [Double] {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        guard !words.isEmpty else {
            return Array(repeating: 0.0, count: dimension)
        }
        
        var embedding = Array(repeating: 0.0, count: dimension)
        var validWords = 0
        
        for word in words {
            if let wordVector = wordVectors[word] {
                for i in 0..<dimension {
                    embedding[i] += wordVector[i]
                }
                validWords += 1
            } else {
                // Generate pseudo-random embedding for unknown words
                let wordEmbedding = generateRandomEmbedding(for: word)
                for i in 0..<dimension {
                    embedding[i] += wordEmbedding[i]
                }
                validWords += 1
            }
        }
        
        // Average the embeddings
        if validWords > 0 {
            embedding = embedding.map { $0 / Double(validWords) }
        }
        
        return embedding
    }
    
    public func analyze(_ text: String) async throws -> NLPAnalysisResult {
        let startTime = Date()
        
        // Generate embeddings
        let embeddings = try await generateEmbeddings(text)
        let embeddingResult = TextEmbeddingResult(
            embeddings: embeddings,
            dimension: embeddings.count,
            modelType: "simple_embedding",
            processingTime: Date().timeIntervalSince(startTime)
        )
        
        let totalProcessingTime = Date().timeIntervalSince(startTime)
        
        return NLPAnalysisResult(
            embeddings: embeddingResult,
            processingTime: totalProcessingTime
        )
    }
    
    public func train(with data: NLPTrainingData) async throws -> NLPTrainingResult {
        let startTime = Date()
        
        // Simple training: create random embeddings for each unique word
        for text in data.texts {
            let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            
            for word in words {
                if wordVectors[word] == nil {
                    wordVectors[word] = generateRandomEmbedding(for: word)
                }
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Calculate accuracy based on vocabulary coverage
        let allWords = data.texts.joined().lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let uniqueWords = Set(allWords)
        let accuracy = Float(wordVectors.count) / Float(uniqueWords.count)
        
        return NLPTrainingResult(
            accuracy: min(accuracy, 1.0),
            loss: 1.0 - min(accuracy, 1.0),
            epochs: 1, // Single pass for simple model
            duration: duration,
            modelType: .embedding,
            metadata: [
                "dimension": String(dimension),
                "vocabulary_size": String(wordVectors.count),
                "total_unique_words": String(uniqueWords.count)
            ]
        )
    }
    
    private func generateRandomEmbedding(for word: String) -> [Double] {
        // Generate deterministic pseudo-random embedding based on word hash
        var generator = SeededRandomGenerator(seed: UInt64(abs(word.hashValue)))
        
        var embedding = Array(repeating: 0.0, count: dimension)
        for i in 0..<dimension {
            embedding[i] = generator.nextGaussian() * 0.1 // Small variance
        }
        
        // Normalize
        let magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
        if magnitude > 0 {
            embedding = embedding.map { $0 / magnitude }
        }
        
        return embedding
    }
    
    /// Get similarity between two texts
    public func similarity(text1: String, text2: String) async throws -> Double {
        let embedding1 = try await generateEmbeddings(text1)
        let embedding2 = try await generateEmbeddings(text2)
        
        return cosineSimilarity(embedding1, embedding2)
    }
    
    private func cosineSimilarity(_ vec1: [Double], _ vec2: [Double]) -> Double {
        guard vec1.count == vec2.count else { return 0.0 }
        
        let dotProduct = zip(vec1, vec2).map(*).reduce(0, +)
        let magnitude1 = sqrt(vec1.map { $0 * $0 }.reduce(0, +))
        let magnitude2 = sqrt(vec2.map { $0 * $0 }.reduce(0, +))
        
        if magnitude1 == 0 || magnitude2 == 0 {
            return 0.0
        }
        
        return dotProduct / (magnitude1 * magnitude2)
    }
}

// MARK: - Basic Text Classifier

public struct BasicTextClassifier: NLPModelProtocol, Sendable {
    
    public let modelType: NLPModelType = .classification
    public let language: String
    
    private var categoryKeywords: [String: [String]] = [:]
    private var categories: [String] = []
    
    public init(categories: [String] = ["positive", "negative", "neutral"], language: String = "en") {
        self.categories = categories
        self.language = language
        
        // Initialize with basic keyword patterns
        setupDefaultKeywords()
    }
    
    private mutating func setupDefaultKeywords() {
        categoryKeywords["positive"] = [
            "good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome", "love", "like", "happy", "joy", "perfect", "best", "brilliant", "outstanding", "superb", "magnificent", "marvelous", "terrific", "fabulous", "delightful", "pleased", "satisfied", "thrilled"
        ]
        
        categoryKeywords["negative"] = [
            "bad", "terrible", "awful", "horrible", "disgusting", "hate", "dislike", "sad", "angry", "worst", "dreadful", "appalling", "atrocious", "abysmal", "deplorable", "pathetic", "useless", "worthless", "disappointing", "frustrated", "annoyed", "upset", "miserable"
        ]
        
        categoryKeywords["neutral"] = [
            "okay", "fine", "average", "normal", "regular", "standard", "typical", "ordinary", "usual", "common", "fair", "adequate", "acceptable", "moderate", "reasonable"
        ]
    }
    
    public func generateEmbeddings(_ text: String) async throws -> [Double] {
        // Create feature vector based on keyword presence
        var embedding: [Double] = []
        
        let lowercaseText = text.lowercased()
        
        for category in categories {
            let keywords = categoryKeywords[category] ?? []
            var categoryScore = 0.0
            
            for keyword in keywords {
                if lowercaseText.contains(keyword) {
                    categoryScore += 1.0 / Double(keywords.count)
                }
            }
            
            embedding.append(categoryScore)
        }
        
        // Add text length feature (normalized)
        let textLength = min(Double(text.count) / 1000.0, 1.0)
        embedding.append(textLength)
        
        // Add word count feature (normalized)
        let wordCount = min(Double(text.components(separatedBy: .whitespacesAndNewlines).count) / 100.0, 1.0)
        embedding.append(wordCount)
        
        return embedding
    }
    
    public func analyze(_ text: String) async throws -> NLPAnalysisResult {
        let startTime = Date()
        
        let lowercaseText = text.lowercased()
        var scores: [String: Double] = [:]
        
        for category in categories {
            let keywords = categoryKeywords[category] ?? []
            var score = 0.0
            
            for keyword in keywords {
                if lowercaseText.contains(keyword) {
                    score += 1.0 / Double(keywords.count)
                }
            }
            
            scores[category] = score
        }
        
        let bestCategory = scores.max(by: { $0.value < $1.value })?.key ?? categories.first ?? "unknown"
        let confidence = scores[bestCategory] ?? 0.0
        
        let classificationResult = TextClassificationResult(
            predictedCategory: bestCategory,
            confidence: confidence,
            allScores: scores,
            processingTime: Date().timeIntervalSince(startTime)
        )
        
        let totalProcessingTime = Date().timeIntervalSince(startTime)
        
        return NLPAnalysisResult(
            classification: classificationResult,
            processingTime: totalProcessingTime
        )
    }
    
    public func train(with data: NLPTrainingData) async throws -> NLPTrainingResult {
        let startTime = Date()
        
        // Update keyword patterns based on training data
        for (text, label) in zip(data.texts, data.labels) {
            let words = text.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty && $0.count > 2 } // Filter short words
            
            // Add frequent words from training data to category keywords
            if var existingKeywords = categoryKeywords[label] {
                for word in words {
                    if !existingKeywords.contains(word) && words.filter({ $0 == word }).count > 1 {
                        existingKeywords.append(word)
                    }
                }
                categoryKeywords[label] = Array(existingKeywords.prefix(50)) // Limit keyword count
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Evaluate accuracy on training data
        var correct = 0
        for (text, expectedLabel) in zip(data.texts, data.labels) {
            let analysis = try await analyze(text)
            if analysis.classification?.predictedCategory == expectedLabel {
                correct += 1
            }
        }
        
        let accuracy = Float(correct) / Float(data.texts.count)
        
        return NLPTrainingResult(
            accuracy: accuracy,
            loss: 1.0 - accuracy,
            epochs: 1, // Single pass for keyword-based classifier
            duration: duration,
            modelType: .classification,
            metadata: [
                "categories": categories.joined(separator: ","),
                "total_keywords": String(categoryKeywords.values.reduce(0) { $0 + $1.count }),
                "training_samples": String(data.texts.count)
            ]
        )
    }
    
    /// Get the keywords for a specific category
    public func getKeywords(for category: String) -> [String] {
        return categoryKeywords[category] ?? []
    }
    
    /// Add custom keywords to a category
    public mutating func addKeywords(_ keywords: [String], to category: String) {
        categoryKeywords[category, default: []].append(contentsOf: keywords)
    }
}

// MARK: - Utility: Seeded Random Generator

private struct SeededRandomGenerator {
    private var seed: UInt64
    
    init(seed: UInt64) {
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        seed = seed &* 1103515245 &+ 12345
        return seed
    }
    
    mutating func nextDouble() -> Double {
        return Double(next() % 1000000) / 1000000.0
    }
    
    mutating func nextGaussian() -> Double {
        // Box-Muller transform
        let u1 = nextDouble()
        let u2 = nextDouble()
        return sqrt(-2.0 * log(u1)) * cos(2.0 * Double.pi * u2)
    }
}
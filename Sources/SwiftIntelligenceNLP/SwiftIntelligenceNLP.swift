import Foundation
import SwiftIntelligenceCore
import SwiftIntelligenceML
import NaturalLanguage

/// Natural Language Processing Engine - Advanced text analysis and understanding
public actor SwiftIntelligenceNLP {
    
    // MARK: - Properties
    
    public let moduleID = "NLP"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - NLP Components
    
    private var languageModels: [String: any NLPModelProtocol] = [:]
    private var tokenizers: [String: NLPTokenizer] = [:]
    private var vocabularies: [String: NLPVocabulary] = [:]
    private var languageDetector: NLLanguageRecognizer?
    private var sentimentAnalyzer: NLPSentimentAnalyzer?
    
    // MARK: - Configuration
    
    private var supportedLanguages: Set<String> = ["en", "tr", "fr", "de", "es", "it"]
    private let maxTextLength = 10000
    private let logger = IntelligenceLogger()
    
    // MARK: - Performance Metrics
    
    private var performanceMetrics = NLPPerformanceMetrics()
    
    // MARK: - Initialization
    
    public init() async throws {
        try await initializeNLPEngine()
    }
    
    private func initializeNLPEngine() async throws {
        status = .initializing
        logger.info("Initializing NLP Engine...", category: "NLP")
        
        // Initialize language detection
        languageDetector = NLLanguageRecognizer()
        
        // Initialize sentiment analyzer
        sentimentAnalyzer = NLPSentimentAnalyzer()
        
        // Setup default tokenizers
        await setupDefaultTokenizers()
        
        // Initialize language models
        await setupLanguageModels()
        
        // Load vocabularies
        await loadDefaultVocabularies()
        
        status = .ready
        logger.info("NLP Engine initialized successfully", category: "NLP")
    }
    
    private func setupDefaultTokenizers() async {
        logger.debug("Setting up tokenizers", category: "NLP")
        
        for language in supportedLanguages {
            let tokenizer = NLPTokenizer(language: language)
            tokenizers[language] = tokenizer
        }
        
        logger.debug("Tokenizers configured for \(supportedLanguages.count) languages", category: "NLP")
    }
    
    private func setupLanguageModels() async {
        logger.debug("Setting up language models", category: "NLP")
        
        // Basic N-gram model
        let ngramModel = NGramLanguageModel(n: 3)
        languageModels["ngram"] = ngramModel
        
        // Simple word embedding model
        let embeddingModel = SimpleWordEmbeddingModel(dimension: 100)
        languageModels["embedding"] = embeddingModel
        
        logger.debug("Language models configured", category: "NLP")
    }
    
    private func loadDefaultVocabularies() async {
        logger.debug("Loading vocabularies", category: "NLP")
        
        for language in supportedLanguages {
            let vocabulary = NLPVocabulary(language: language)
            vocabularies[language] = vocabulary
        }
        
        logger.debug("Vocabularies loaded for \(supportedLanguages.count) languages", category: "NLP")
    }
    
    // MARK: - Language Detection
    
    /// Detect the language of input text
    public func detectLanguage(_ text: String) async throws -> LanguageDetectionResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw IntelligenceError(code: "EMPTY_TEXT", message: "Input text is empty")
        }
        
        let startTime = Date()
        
        languageDetector?.processString(text)
        let dominantLanguage = languageDetector?.dominantLanguage?.rawValue ?? "unknown"
        
        var confidenceScores: [String: Double] = [:]
        let hypotheses = languageDetector?.languageHypotheses(withMaximum: 5) ?? [:]
        
        for (language, confidence) in hypotheses {
            confidenceScores[language.rawValue] = confidence
        }
        
        let duration = Date().timeIntervalSince(startTime)
        await updateLanguageDetectionMetrics(duration: duration)
        
        logger.debug("Language detected: \(dominantLanguage)", category: "NLP")
        
        return LanguageDetectionResult(
            detectedLanguage: dominantLanguage,
            confidence: confidenceScores[dominantLanguage] ?? 0.0,
            allLanguages: confidenceScores,
            processingTime: duration
        )
    }
    
    // MARK: - Text Tokenization
    
    /// Tokenize text into words, sentences, or custom tokens
    public func tokenize(_ text: String, type: TokenizationType = .words, language: String = "en") async throws -> TokenizationResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        guard text.count <= maxTextLength else {
            throw IntelligenceError(code: "TEXT_TOO_LONG", message: "Text exceeds maximum length")
        }
        
        let startTime = Date()
        
        guard let tokenizer = tokenizers[language] else {
            throw IntelligenceError(code: "LANGUAGE_NOT_SUPPORTED", message: "Language \(language) not supported")
        }
        
        let tokens = await tokenizer.tokenize(text, type: type)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateTokenizationMetrics(duration: duration, tokenCount: tokens.count)
        
        return TokenizationResult(
            tokens: tokens,
            tokenCount: tokens.count,
            language: language,
            type: type,
            processingTime: duration
        )
    }
    
    // MARK: - Sentiment Analysis
    
    /// Analyze sentiment of text
    public func analyzeSentiment(_ text: String, language: String = "en") async throws -> SentimentResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        guard let sentimentAnalyzer = sentimentAnalyzer else {
            throw IntelligenceError(code: "SENTIMENT_ANALYZER_NOT_AVAILABLE", message: "Sentiment analyzer not initialized")
        }
        
        let startTime = Date()
        
        let result = await sentimentAnalyzer.analyze(text, language: language)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateSentimentAnalysisMetrics(duration: duration)
        
        logger.debug("Sentiment analyzed: \(result.sentiment)", category: "NLP")
        
        return result
    }
    
    // MARK: - Text Embedding
    
    /// Generate word embeddings for text
    public func generateEmbeddings(_ text: String, modelType: String = "embedding") async throws -> TextEmbeddingResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        guard let model = languageModels[modelType] else {
            throw IntelligenceError(code: "MODEL_NOT_FOUND", message: "Model \(modelType) not found")
        }
        
        let startTime = Date()
        
        let embeddings = try await model.generateEmbeddings(text)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateEmbeddingMetrics(duration: duration)
        
        return TextEmbeddingResult(
            embeddings: embeddings,
            dimension: embeddings.count,
            modelType: modelType,
            processingTime: duration
        )
    }
    
    // MARK: - Named Entity Recognition
    
    /// Extract named entities from text
    public func extractEntities(_ text: String) async throws -> EntityExtractionResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        let startTime = Date()
        
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var entities: [NamedEntity] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let entity = String(text[tokenRange])
                let entityType = mapNLTagToEntityType(tag)
                
                entities.append(NamedEntity(
                    text: entity,
                    type: entityType,
                    range: tokenRange,
                    confidence: 0.85 // NLTagger doesn't provide confidence scores
                ))
            }
            return true
        }
        
        let duration = Date().timeIntervalSince(startTime)
        await updateEntityExtractionMetrics(duration: duration, entityCount: entities.count)
        
        return EntityExtractionResult(
            entities: entities,
            entityCount: entities.count,
            processingTime: duration
        )
    }
    
    // MARK: - Text Classification
    
    /// Classify text into predefined categories
    public func classifyText(_ text: String, categories: [String]) async throws -> TextClassificationResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        let startTime = Date()
        
        // Simple keyword-based classification (placeholder)
        var scores: [String: Double] = [:]
        let lowercaseText = text.lowercased()
        
        for category in categories {
            let categoryKeywords = generateKeywordsForCategory(category)
            var score = 0.0
            
            for keyword in categoryKeywords {
                if lowercaseText.contains(keyword) {
                    score += 1.0 / Double(categoryKeywords.count)
                }
            }
            
            scores[category] = score
        }
        
        let bestCategory = scores.max(by: { $0.value < $1.value })?.key ?? categories.first ?? "unknown"
        let confidence = scores[bestCategory] ?? 0.0
        
        let duration = Date().timeIntervalSince(startTime)
        await updateClassificationMetrics(duration: duration)
        
        return TextClassificationResult(
            predictedCategory: bestCategory,
            confidence: confidence,
            allScores: scores,
            processingTime: duration
        )
    }
    
    // MARK: - Text Similarity
    
    /// Calculate similarity between two texts
    public func calculateSimilarity(text1: String, text2: String) async throws -> TextSimilarityResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NLP_NOT_READY", message: "NLP Engine not ready")
        }
        
        let startTime = Date()
        
        // Tokenize both texts
        let tokens1 = await tokenizers["en"]?.tokenize(text1, type: .words) ?? []
        let tokens2 = await tokenizers["en"]?.tokenize(text2, type: .words) ?? []
        
        // Calculate Jaccard similarity
        let set1 = Set(tokens1)
        let set2 = Set(tokens2)
        let intersection = set1.intersection(set2)
        let union = set1.union(set2)
        
        let jaccardSimilarity = union.isEmpty ? 0.0 : Double(intersection.count) / Double(union.count)
        
        // Calculate cosine similarity (simplified)
        let cosineSimilarity = calculateCosineSimilarity(tokens1: tokens1, tokens2: tokens2)
        
        let duration = Date().timeIntervalSince(startTime)
        
        return TextSimilarityResult(
            jaccardSimilarity: jaccardSimilarity,
            cosineSimilarity: cosineSimilarity,
            averageSimilarity: (jaccardSimilarity + cosineSimilarity) / 2.0,
            processingTime: duration
        )
    }
    
    // MARK: - Performance Metrics
    
    private func updateLanguageDetectionMetrics(duration: TimeInterval) async {
        performanceMetrics.languageDetectionCount += 1
        performanceMetrics.averageLanguageDetectionTime = (performanceMetrics.averageLanguageDetectionTime + duration) / 2.0
    }
    
    private func updateTokenizationMetrics(duration: TimeInterval, tokenCount: Int) async {
        performanceMetrics.tokenizationCount += 1
        performanceMetrics.averageTokenizationTime = (performanceMetrics.averageTokenizationTime + duration) / 2.0
        performanceMetrics.totalTokensProcessed += tokenCount
    }
    
    private func updateSentimentAnalysisMetrics(duration: TimeInterval) async {
        performanceMetrics.sentimentAnalysisCount += 1
        performanceMetrics.averageSentimentAnalysisTime = (performanceMetrics.averageSentimentAnalysisTime + duration) / 2.0
    }
    
    private func updateEmbeddingMetrics(duration: TimeInterval) async {
        performanceMetrics.embeddingGenerationCount += 1
        performanceMetrics.averageEmbeddingTime = (performanceMetrics.averageEmbeddingTime + duration) / 2.0
    }
    
    private func updateEntityExtractionMetrics(duration: TimeInterval, entityCount: Int) async {
        performanceMetrics.entityExtractionCount += 1
        performanceMetrics.averageEntityExtractionTime = (performanceMetrics.averageEntityExtractionTime + duration) / 2.0
        performanceMetrics.totalEntitiesExtracted += entityCount
    }
    
    private func updateClassificationMetrics(duration: TimeInterval) async {
        performanceMetrics.textClassificationCount += 1
        performanceMetrics.averageClassificationTime = (performanceMetrics.averageClassificationTime + duration) / 2.0
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> NLPPerformanceMetrics {
        return performanceMetrics
    }
    
    // MARK: - Utility Methods
    
    private func mapNLTagToEntityType(_ tag: NLTag) -> NamedEntity.EntityType {
        switch tag {
        case .personalName:
            return .person
        case .placeName:
            return .location
        case .organizationName:
            return .organization
        default:
            return .other
        }
    }
    
    private func generateKeywordsForCategory(_ category: String) -> [String] {
        // Simple keyword generation based on category name
        let keywords = category.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted)
        return keywords.filter { !$0.isEmpty }
    }
    
    private func calculateCosineSimilarity(tokens1: [String], tokens2: [String]) -> Double {
        let allTokens = Set(tokens1 + tokens2)
        var vector1: [Double] = []
        var vector2: [Double] = []
        
        for token in allTokens {
            let count1 = tokens1.filter { $0 == token }.count
            let count2 = tokens2.filter { $0 == token }.count
            vector1.append(Double(count1))
            vector2.append(Double(count2))
        }
        
        let dotProduct = zip(vector1, vector2).map(*).reduce(0, +)
        let magnitude1 = sqrt(vector1.map { $0 * $0 }.reduce(0, +))
        let magnitude2 = sqrt(vector2.map { $0 * $0 }.reduce(0, +))
        
        if magnitude1 == 0 || magnitude2 == 0 {
            return 0.0
        }
        
        return dotProduct / (magnitude1 * magnitude2)
    }
    
    /// Clear all caches
    public func clearCaches() async {
        // Clear any cached results
        logger.info("NLP caches cleared", category: "NLP")
    }
    
    /// Get supported languages
    public func getSupportedLanguages() async -> [String] {
        return Array(supportedLanguages)
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceNLP: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeNLPEngine()
    }
    
    public func shutdown() async throws {
        status = .shutdown
        languageModels.removeAll()
        tokenizers.removeAll()
        vocabularies.removeAll()
        languageDetector = nil
        sentimentAnalyzer = nil
        logger.info("NLP Engine shutdown complete", category: "NLP")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "NLP_NOT_READY", message: "NLP Engine not ready"))
        }
        
        if languageModels.isEmpty {
            warnings.append(ValidationWarning(code: "NO_LANGUAGE_MODELS", message: "No language models loaded"))
        }
        
        if tokenizers.isEmpty {
            warnings.append(ValidationWarning(code: "NO_TOKENIZERS", message: "No tokenizers configured"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let metrics = [
            "language_models": String(languageModels.count),
            "tokenizers": String(tokenizers.count),
            "supported_languages": String(supportedLanguages.count),
            "total_tokenizations": String(performanceMetrics.tokenizationCount),
            "total_sentiment_analyses": String(performanceMetrics.sentimentAnalysisCount)
        ]
        
        switch status {
        case .ready:
            return HealthStatus(
                status: .healthy,
                message: "NLP Engine operational with \(languageModels.count) models",
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "NLP Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "NLP Engine not ready",
                metrics: metrics
            )
        }
    }
}
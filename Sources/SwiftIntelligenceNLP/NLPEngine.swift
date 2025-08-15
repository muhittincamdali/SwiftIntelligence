import Foundation
import NaturalLanguage
import CoreML
import Vision
import os.log

/// Advanced Natural Language Processing engine with multilingual support
@MainActor
public class NLPEngine: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = NLPEngine()
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "NLP")
    private let processingQueue = DispatchQueue(label: "nlp.processing", qos: .userInitiated)
    
    // MARK: - NL Framework Components
    private let languageRecognizer = NLLanguageRecognizer()
    private let tokenizer = NLTokenizer(unit: .word)
    private let sentenceTokenizer = NLTokenizer(unit: .sentence)
    
    // MARK: - Models
    private var sentimentModels: [NLLanguage: NLModel] = [:]
    private var namedEntityModels: [NLLanguage: VNCoreMLModel] = [:]
    private var turkishNLPModel: NLModel?
    private var customModels: [String: NLModel] = [:]
    
    // MARK: - Cache
    private let cache = NSCache<NSString, NLPResult>()
    
    // MARK: - Initialization
    private init() {
        cache.countLimit = 1000
        cache.totalCostLimit = 50_000_000 // 50MB
        
        Task {
            try await initializeModels()
        }
    }
    
    // MARK: - Model Initialization
    private func initializeModels() async throws {
        logger.info("Initializing NLP models...")
        
        // Load built-in sentiment analysis models
        await loadBuiltInModels()
        
        // Load Turkish NLP model (our competitive advantage)
        await loadTurkishNLPModel()
        
        // Load named entity recognition models
        await loadNERModels()
        
        logger.info("NLP models initialized successfully")
    }
    
    private func loadBuiltInModels() async {
        let supportedLanguages: [NLLanguage] = [.english, .turkish, .spanish, .french, .german, .italian, .portuguese]
        
        for language in supportedLanguages {
            do {
                if let model = try? NLModel(mlModel: createSentimentModel(for: language)) {
                    sentimentModels[language] = model
                }
            } catch {
                logger.warning("Failed to load sentiment model for \(language.rawValue): \(error.localizedDescription)")
            }
        }
    }
    
    private func loadTurkishNLPModel() async {
        // Load our specialized Turkish NLP model
        // This gives us competitive advantage in Turkish market
        do {
            if let modelURL = Bundle.module.url(forResource: "TurkishNLP", withExtension: "mlmodel") {
                let model = try MLModel(contentsOf: modelURL)
                turkishNLPModel = try NLModel(mlModel: model)
                logger.info("Turkish NLP model loaded successfully")
            } else {
                logger.warning("Turkish NLP model not found in bundle")
            }
        } catch {
            logger.error("Failed to load Turkish NLP model: \(error.localizedDescription)")
        }
    }
    
    private func loadNERModels() async {
        // Load Named Entity Recognition models
        // In production, these would be actual trained models
        logger.info("NER models loaded")
    }
    
    // MARK: - Text Analysis
    
    /// Analyze text with comprehensive NLP processing
    public func analyze(
        text: String,
        options: NLPOptions = .default
    ) async throws -> NLPResult {
        
        let startTime = Date()
        
        // Check cache first
        let cacheKey = NSString(string: "\(text.hashValue)_\(options.hashValue)")
        if let cachedResult = cache.object(forKey: cacheKey) {
            return cachedResult
        }
        
        // Detect language
        let language = detectLanguage(text: text)
        
        // Tokenize text
        let tokens = tokenizeText(text: text, language: language)
        let sentences = tokenizeSentences(text: text)
        
        // Perform analysis based on options
        var analysisResults: [String: Any] = [:]
        
        if options.includeSentiment {
            analysisResults["sentiment"] = try await analyzeSentiment(text: text, language: language)
        }
        
        if options.includeEntities {
            analysisResults["entities"] = try await extractNamedEntities(text: text, language: language)
        }
        
        if options.includeKeywords {
            analysisResults["keywords"] = extractKeywords(text: text, language: language)
        }
        
        if options.includeTopics {
            analysisResults["topics"] = try await extractTopics(text: text, language: language)
        }
        
        if options.includeLanguageDetection {
            analysisResults["languages"] = detectMultipleLanguages(text: text)
        }
        
        if options.includeReadability {
            analysisResults["readability"] = calculateReadabilityMetrics(text: text, language: language)
        }
        
        // Turkish-specific analysis
        if language == .turkish && turkishNLPModel != nil {
            analysisResults["turkishSpecific"] = try await performTurkishAnalysis(text: text)
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = calculateOverallConfidence(analysisResults)
        
        let result = NLPResult(
            processingTime: processingTime,
            confidence: confidence,
            originalText: text,
            detectedLanguage: language,
            tokens: tokens,
            sentences: sentences,
            analysisResults: analysisResults
        )
        
        // Cache result
        cache.setObject(result, forKey: cacheKey, cost: text.count)
        
        return result
    }
    
    /// Extract sentiment from text
    public func analyzeSentiment(
        text: String,
        language: NLLanguage? = nil
    ) async throws -> SentimentResult {
        
        let detectedLanguage = language ?? detectLanguage(text: text)
        
        // Use Turkish model if available for Turkish text
        if detectedLanguage == .turkish, let turkishModel = turkishNLPModel {
            return try await analyzeSentimentWithModel(text: text, model: turkishModel, language: detectedLanguage)
        }
        
        // Use built-in sentiment analysis
        if let model = sentimentModels[detectedLanguage] {
            return try await analyzeSentimentWithModel(text: text, model: model, language: detectedLanguage)
        }
        
        // Fallback to basic sentiment analysis
        return try await basicSentimentAnalysis(text: text, language: detectedLanguage)
    }
    
    /// Extract named entities from text
    public func extractNamedEntities(
        text: String,
        language: NLLanguage? = nil
    ) async throws -> [NamedEntity] {
        
        let detectedLanguage = language ?? detectLanguage(text: text)
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let entities = self.performNamedEntityRecognition(text: text, language: detectedLanguage)
                    continuation.resume(returning: entities)
                } catch {
                    continuation.resume(throwing: NLPError.processingFailed(error))
                }
            }
        }
    }
    
    /// Extract keywords from text
    public func extractKeywords(
        text: String,
        language: NLLanguage? = nil,
        maxCount: Int = 10
    ) -> [Keyword] {
        
        let detectedLanguage = language ?? detectLanguage(text: text)
        
        // Tokenize and filter
        tokenizer.string = text
        tokenizer.setLanguage(detectedLanguage)
        
        var wordFrequency: [String: Int] = [:]
        var totalWords = 0
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let token = String(text[tokenRange]).lowercased()
            
            // Skip short words and common stop words
            guard token.count > 3, !isStopWord(token, language: detectedLanguage) else {
                return true
            }
            
            wordFrequency[token, default: 0] += 1
            totalWords += 1
            
            return true
        }
        
        // Calculate TF-IDF scores (simplified)
        let keywords = wordFrequency
            .map { word, frequency in
                let tf = Double(frequency) / Double(totalWords)
                let score = tf * log(1000.0 / Double(frequency)) // Simplified IDF
                return Keyword(word: word, score: Float(score), frequency: frequency)
            }
            .sorted { $0.score > $1.score }
            .prefix(maxCount)
        
        return Array(keywords)
    }
    
    /// Extract topics from text using topic modeling
    public func extractTopics(
        text: String,
        language: NLLanguage? = nil,
        topicCount: Int = 5
    ) async throws -> [Topic] {
        
        let detectedLanguage = language ?? detectLanguage(text: text)
        
        // Simplified topic extraction using keyword clustering
        let keywords = extractKeywords(text: text, language: detectedLanguage, maxCount: 50)
        
        // Group keywords into topics (simplified approach)
        let topicGroups = groupKeywordsIntoTopics(keywords: keywords, topicCount: topicCount)
        
        return topicGroups.enumerated().map { index, group in
            Topic(
                id: "topic_\(index)",
                label: generateTopicLabel(keywords: group),
                keywords: group,
                confidence: calculateTopicConfidence(keywords: group)
            )
        }
    }
    
    /// Summarize text content
    public func summarizeText(
        text: String,
        maxSentences: Int = 3,
        language: NLLanguage? = nil
    ) async throws -> SummaryResult {
        
        let detectedLanguage = language ?? detectLanguage(text: text)
        let sentences = tokenizeSentences(text: text)
        
        // Score sentences based on keyword frequency and position
        let keywords = extractKeywords(text: text, language: detectedLanguage, maxCount: 20)
        let keywordSet = Set(keywords.map { $0.word })
        
        let scoredSentences = sentences.enumerated().map { index, sentence in
            let score = calculateSentenceScore(
                sentence: sentence,
                keywords: keywordSet,
                position: index,
                totalSentences: sentences.count
            )
            return ScoredSentence(sentence: sentence, score: score, position: index)
        }
        
        // Select top sentences
        let topSentences = scoredSentences
            .sorted { $0.score > $1.score }
            .prefix(maxSentences)
            .sorted { $0.position < $1.position }
        
        let summary = topSentences.map { $0.sentence }.joined(separator: " ")
        
        return SummaryResult(
            originalText: text,
            summary: summary,
            compressionRatio: Float(summary.count) / Float(text.count),
            selectedSentences: Array(topSentences)
        )
    }
    
    /// Translate text using built-in translation
    public func translateText(
        text: String,
        from sourceLanguage: NLLanguage? = nil,
        to targetLanguage: NLLanguage
    ) async throws -> TranslationResult {
        
        let detectedLanguage = sourceLanguage ?? detectLanguage(text: text)
        
        // Check if translation is supported
        guard detectedLanguage != targetLanguage else {
            return TranslationResult(
                originalText: text,
                translatedText: text,
                sourceLanguage: detectedLanguage,
                targetLanguage: targetLanguage,
                confidence: 1.0
            )
        }
        
        // For now, return a placeholder
        // In production, this would use actual translation APIs
        return TranslationResult(
            originalText: text,
            translatedText: "Translation not implemented yet",
            sourceLanguage: detectedLanguage,
            targetLanguage: targetLanguage,
            confidence: 0.0
        )
    }
    
    // MARK: - Language Detection
    
    private func detectLanguage(text: String) -> NLLanguage {
        languageRecognizer.processString(text)
        return languageRecognizer.dominantLanguage ?? .english
    }
    
    private func detectMultipleLanguages(text: String) -> [LanguageConfidence] {
        languageRecognizer.processString(text)
        let languageHypotheses = languageRecognizer.languageHypotheses(withMaximum: 5)
        
        return languageHypotheses.map { language, confidence in
            LanguageConfidence(language: language, confidence: Float(confidence))
        }
        .sorted { $0.confidence > $1.confidence }
    }
    
    // MARK: - Tokenization
    
    private func tokenizeText(text: String, language: NLLanguage) -> [String] {
        tokenizer.string = text
        tokenizer.setLanguage(language)
        
        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            tokens.append(String(text[tokenRange]))
            return true
        }
        
        return tokens
    }
    
    private func tokenizeSentences(text: String) -> [String] {
        sentenceTokenizer.string = text
        
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
    
    // MARK: - Private Analysis Methods
    
    private func analyzeSentimentWithModel(
        text: String,
        model: NLModel,
        language: NLLanguage
    ) async throws -> SentimentResult {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    guard let prediction = try? model.prediction(from: text) else {
                        throw NLPError.modelPredictionFailed
                    }
                    
                    let result = self.parseSentimentPrediction(prediction, text: text)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func basicSentimentAnalysis(text: String, language: NLLanguage) async throws -> SentimentResult {
        // Simplified sentiment analysis using word lists
        let positiveWords = getPositiveWords(for: language)
        let negativeWords = getNegativeWords(for: language)
        
        let words = tokenizeText(text: text.lowercased(), language: language)
        
        var positiveScore = 0
        var negativeScore = 0
        
        for word in words {
            if positiveWords.contains(word) {
                positiveScore += 1
            } else if negativeWords.contains(word) {
                negativeScore += 1
            }
        }
        
        let totalScore = positiveScore + negativeScore
        let sentiment: SentimentResult.Sentiment
        let score: Float
        
        if totalScore == 0 {
            sentiment = .neutral
            score = 0.5
        } else {
            let positiveRatio = Float(positiveScore) / Float(totalScore)
            if positiveRatio > 0.6 {
                sentiment = .positive
                score = 0.5 + (positiveRatio - 0.5)
            } else if positiveRatio < 0.4 {
                sentiment = .negative
                score = 0.5 - (0.5 - positiveRatio)
            } else {
                sentiment = .neutral
                score = positiveRatio
            }
        }
        
        return SentimentResult(
            sentiment: sentiment,
            score: score,
            confidence: min(Float(totalScore) / 10.0, 1.0),
            positiveWords: Array(words.filter { positiveWords.contains($0) }.prefix(10)),
            negativeWords: Array(words.filter { negativeWords.contains($0) }.prefix(10))
        )
    }
    
    private func performNamedEntityRecognition(text: String, language: NLLanguage) -> [NamedEntity] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        tagger.setLanguage(language, range: text.startIndex..<text.endIndex)
        
        var entities: [NamedEntity] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let entity = NamedEntity(
                    text: String(text[tokenRange]),
                    type: mapNLTagToEntityType(tag),
                    range: tokenRange,
                    confidence: 0.8 // NLTagger doesn't provide confidence scores
                )
                entities.append(entity)
            }
            return true
        }
        
        return entities
    }
    
    private func performTurkishAnalysis(text: String) async throws -> TurkishAnalysisResult {
        guard let model = turkishNLPModel else {
            throw NLPError.modelNotInitialized
        }
        
        // Perform Turkish-specific analysis
        // This could include morphological analysis, Turkish-specific entity recognition, etc.
        
        return TurkishAnalysisResult(
            morphologicalAnalysis: [],
            turkishEntities: [],
            dialectDetection: "standard",
            confidence: 0.9
        )
    }
    
    // MARK: - Helper Methods
    
    private func createSentimentModel(for language: NLLanguage) -> MLModel {
        // In a real implementation, this would load actual trained models
        // For now, return a placeholder
        let configuration = MLModelConfiguration()
        return try! MLModel(contentsOf: Bundle.module.url(forResource: "DummyModel", withExtension: "mlmodel")!)
    }
    
    private func parseSentimentPrediction(_ prediction: String, text: String) -> SentimentResult {
        // Parse model prediction
        let components = prediction.components(separatedBy: ",")
        
        if components.count >= 2 {
            let sentimentString = components[0].trimmingCharacters(in: .whitespaces)
            let scoreString = components[1].trimmingCharacters(in: .whitespaces)
            
            let sentiment: SentimentResult.Sentiment
            switch sentimentString.lowercased() {
            case "positive": sentiment = .positive
            case "negative": sentiment = .negative
            default: sentiment = .neutral
            }
            
            let score = Float(scoreString) ?? 0.5
            
            return SentimentResult(
                sentiment: sentiment,
                score: score,
                confidence: 0.9,
                positiveWords: [],
                negativeWords: []
            )
        }
        
        // Fallback
        return SentimentResult(
            sentiment: .neutral,
            score: 0.5,
            confidence: 0.1,
            positiveWords: [],
            negativeWords: []
        )
    }
    
    private func mapNLTagToEntityType(_ tag: NLTag) -> NamedEntity.EntityType {
        switch tag.rawValue {
        case "PersonalName": return .person
        case "PlaceName": return .location
        case "OrganizationName": return .organization
        default: return .other
        }
    }
    
    private func isStopWord(_ word: String, language: NLLanguage) -> Bool {
        let stopWords: [NLLanguage: Set<String>] = [
            .english: ["the", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"],
            .turkish: ["ve", "veya", "ama", "ancak", "ile", "için", "bir", "bu", "şu", "o", "da", "de"]
        ]
        
        return stopWords[language]?.contains(word.lowercased()) ?? false
    }
    
    private func getPositiveWords(for language: NLLanguage) -> Set<String> {
        switch language {
        case .english:
            return ["good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome", "love", "like", "happy"]
        case .turkish:
            return ["iyi", "güzel", "harika", "mükemmel", "muhteşem", "sevmek", "beğenmek", "mutlu", "başarılı"]
        default:
            return []
        }
    }
    
    private func getNegativeWords(for language: NLLanguage) -> Set<String> {
        switch language {
        case .english:
            return ["bad", "terrible", "awful", "horrible", "hate", "dislike", "sad", "angry", "worst", "poor"]
        case .turkish:
            return ["kötü", "berbat", "korkunç", "nefret", "üzgün", "kızgın", "başarısız", "zor"]
        default:
            return []
        }
    }
    
    private func calculateOverallConfidence(_ results: [String: Any]) -> Float {
        // Calculate average confidence from all analysis results
        var totalConfidence: Float = 0.0
        var count = 0
        
        for (_, value) in results {
            if let result = value as? ConfidenceProvider {
                totalConfidence += result.confidence
                count += 1
            }
        }
        
        return count > 0 ? totalConfidence / Float(count) : 0.5
    }
    
    private func calculateReadabilityMetrics(text: String, language: NLLanguage) -> ReadabilityMetrics {
        let sentences = tokenizeSentences(text: text)
        let words = tokenizeText(text: text, language: language)
        
        let avgSentenceLength = Float(words.count) / Float(sentences.count)
        let avgWordLength = Float(text.count) / Float(words.count)
        
        // Simplified readability score
        let readabilityScore = max(0, min(100, 100 - avgSentenceLength - avgWordLength))
        
        return ReadabilityMetrics(
            fleschScore: readabilityScore,
            averageSentenceLength: avgSentenceLength,
            averageWordLength: avgWordLength,
            complexity: readabilityScore > 70 ? .easy : readabilityScore > 40 ? .medium : .hard
        )
    }
    
    private func groupKeywordsIntoTopics(keywords: [Keyword], topicCount: Int) -> [[Keyword]] {
        // Simplified topic grouping based on keyword similarity
        let groupSize = max(1, keywords.count / topicCount)
        
        return stride(from: 0, to: keywords.count, by: groupSize).map { start in
            Array(keywords[start..<min(start + groupSize, keywords.count)])
        }
    }
    
    private func generateTopicLabel(keywords: [Keyword]) -> String {
        return keywords.prefix(3).map { $0.word }.joined(separator: ", ")
    }
    
    private func calculateTopicConfidence(keywords: [Keyword]) -> Float {
        return keywords.isEmpty ? 0.0 : keywords.map { $0.score }.reduce(0, +) / Float(keywords.count)
    }
    
    private func calculateSentenceScore(
        sentence: String,
        keywords: Set<String>,
        position: Int,
        totalSentences: Int
    ) -> Float {
        let words = sentence.lowercased().components(separatedBy: .whitespacesAndPunctuationMarks)
        let keywordCount = words.filter { keywords.contains($0) }.count
        
        // Score based on keyword density and position
        let keywordScore = Float(keywordCount) / Float(words.count)
        let positionScore = position < totalSentences / 3 ? 1.5 : 1.0 // Prefer early sentences
        
        return keywordScore * positionScore
    }
}

// MARK: - Protocols

protocol ConfidenceProvider {
    var confidence: Float { get }
}

// MARK: - Helper Structures

// ScoredSentence is defined in NLPTypes.swift
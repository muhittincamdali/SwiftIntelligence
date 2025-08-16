import XCTest
import Foundation
@testable import SwiftIntelligenceNLP
@testable import SwiftIntelligenceCore

/// Comprehensive test suite for NLP Engine functionality
@MainActor
final class NLPEngineTests: XCTestCase {
    
    var nlpEngine: NLPEngine!
    
    override func setUp() async throws {
        nlpEngine = NLPEngine.shared
        
        // Configure for testing
        let testConfig = IntelligenceConfiguration.testing
        SwiftIntelligenceCore.shared.configure(with: testConfig)
    }
    
    override func tearDown() async throws {
        SwiftIntelligenceCore.shared.cleanup()
    }
    
    // MARK: - Text Analysis Tests
    
    func testBasicTextAnalysis() async throws {
        let text = "SwiftIntelligence is an amazing AI framework for iOS and macOS!"
        
        let result = try await nlpEngine.analyzeText(
            text,
            options: NLPAnalysisOptions(
                enableSentiment: true,
                enableEntities: true,
                enableKeywords: true,
                enableLanguageDetection: true
            )
        )
        
        XCTAssertEqual(result.text, text)
        XCTAssertEqual(result.language, "en")
        XCTAssertNotNil(result.sentiment)
        XCTAssertGreaterThan(result.keywords.count, 0)
        XCTAssertGreaterThan(result.entities.count, 0)
    }
    
    func testSentimentAnalysis() async throws {
        let positiveText = "I love this amazing framework! It's absolutely fantastic!"
        let negativeText = "This is terrible and awful. I hate it completely."
        let neutralText = "The weather is partly cloudy with temperatures around 20 degrees."
        
        let positiveResult = try await nlpEngine.analyzeText(
            positiveText,
            options: NLPAnalysisOptions(enableSentiment: true)
        )
        
        let negativeResult = try await nlpEngine.analyzeText(
            negativeText,
            options: NLPAnalysisOptions(enableSentiment: true)
        )
        
        let neutralResult = try await nlpEngine.analyzeText(
            neutralText,
            options: NLPAnalysisOptions(enableSentiment: true)
        )
        
        XCTAssertEqual(positiveResult.sentiment?.label, "positive")
        XCTAssertGreaterThan(positiveResult.sentiment?.confidence ?? 0, 0.7)
        
        XCTAssertEqual(negativeResult.sentiment?.label, "negative")
        XCTAssertGreaterThan(negativeResult.sentiment?.confidence ?? 0, 0.7)
        
        XCTAssertEqual(neutralResult.sentiment?.label, "neutral")
    }
    
    func testEntityRecognition() async throws {
        let text = "Apple Inc. was founded by Steve Jobs in Cupertino, California on April 1, 1976."
        
        let result = try await nlpEngine.analyzeText(
            text,
            options: NLPAnalysisOptions(enableEntities: true)
        )
        
        XCTAssertGreaterThan(result.entities.count, 0)
        
        let organizations = result.entities.filter { $0.type == "Organization" }
        let persons = result.entities.filter { $0.type == "Person" }
        let locations = result.entities.filter { $0.type == "Location" }
        let dates = result.entities.filter { $0.type == "Date" }
        
        XCTAssertTrue(organizations.contains { $0.text.contains("Apple") })
        XCTAssertTrue(persons.contains { $0.text.contains("Steve Jobs") })
        XCTAssertTrue(locations.contains { $0.text.contains("Cupertino") })
        XCTAssertTrue(dates.contains { $0.text.contains("1976") })
    }
    
    func testKeywordExtraction() async throws {
        let text = "Machine learning and artificial intelligence are transforming modern technology through advanced algorithms and neural networks."
        
        let result = try await nlpEngine.analyzeText(
            text,
            options: NLPAnalysisOptions(enableKeywords: true, maxKeywords: 5)
        )
        
        XCTAssertGreaterThan(result.keywords.count, 0)
        XCTAssertLessThanOrEqual(result.keywords.count, 5)
        
        let keywordTexts = result.keywords.map { $0.text.lowercased() }
        XCTAssertTrue(keywordTexts.contains { $0.contains("machine") || $0.contains("learning") })
        XCTAssertTrue(keywordTexts.contains { $0.contains("artificial") || $0.contains("intelligence") })
    }
    
    func testLanguageDetection() async throws {
        let englishText = "This is an English sentence for language detection."
        let spanishText = "Esta es una oración en español para detección de idioma."
        let frenchText = "Ceci est une phrase française pour la détection de langue."
        
        let englishResult = try await nlpEngine.analyzeText(
            englishText,
            options: NLPAnalysisOptions(enableLanguageDetection: true)
        )
        
        let spanishResult = try await nlpEngine.analyzeText(
            spanishText,
            options: NLPAnalysisOptions(enableLanguageDetection: true)
        )
        
        let frenchResult = try await nlpEngine.analyzeText(
            frenchText,
            options: NLPAnalysisOptions(enableLanguageDetection: true)
        )
        
        XCTAssertEqual(englishResult.language, "en")
        XCTAssertEqual(spanishResult.language, "es")
        XCTAssertEqual(frenchResult.language, "fr")
    }
    
    // MARK: - Text Summarization Tests
    
    func testTextSummarization() async throws {
        let longText = """
        SwiftIntelligence is a comprehensive artificial intelligence and machine learning framework designed specifically for Apple platforms. 
        The framework provides advanced capabilities including natural language processing, computer vision, speech recognition and synthesis, 
        and privacy-preserving machine learning. It is built using Swift's modern concurrency features and follows Apple's best practices 
        for iOS, macOS, watchOS, tvOS, and visionOS development. The framework supports on-device processing to ensure user privacy 
        and provides high-performance implementations optimized for Apple Silicon. SwiftIntelligence enables developers to easily 
        integrate AI capabilities into their applications without requiring deep machine learning expertise.
        """
        
        let summary = try await nlpEngine.summarizeText(longText, maxLength: 100)
        
        XCTAssertNotNil(summary.summary)
        XCTAssertLessThan(summary.summary.count, longText.count)
        XCTAssertLessThanOrEqual(summary.summary.count, 100)
        XCTAssertGreaterThan(summary.compressionRatio, 0)
        XCTAssertLessThan(summary.compressionRatio, 1)
    }
    
    // MARK: - Text Classification Tests
    
    func testTextClassification() async throws {
        let techText = "Apple announced new MacBook Pro models with M3 chips and improved performance."
        let sportsText = "The football team scored three goals in the championship match yesterday."
        let healthText = "Regular exercise and a balanced diet are essential for maintaining good health."
        
        let techResult = try await nlpEngine.classifyText(
            techText,
            categories: ["technology", "sports", "health", "politics"]
        )
        
        let sportsResult = try await nlpEngine.classifyText(
            sportsText,
            categories: ["technology", "sports", "health", "politics"]
        )
        
        let healthResult = try await nlpEngine.classifyText(
            healthText,
            categories: ["technology", "sports", "health", "politics"]
        )
        
        XCTAssertEqual(techResult.predictedClass, "technology")
        XCTAssertEqual(sportsResult.predictedClass, "sports")
        XCTAssertEqual(healthResult.predictedClass, "health")
        
        XCTAssertGreaterThan(techResult.confidence, 0.5)
        XCTAssertGreaterThan(sportsResult.confidence, 0.5)
        XCTAssertGreaterThan(healthResult.confidence, 0.5)
    }
    
    // MARK: - Text Similarity Tests
    
    func testTextSimilarity() async throws {
        let text1 = "The quick brown fox jumps over the lazy dog."
        let text2 = "A fast brown fox leaps over a sleepy dog."
        let text3 = "Machine learning is transforming artificial intelligence."
        
        let similarity1 = try await nlpEngine.calculateSimilarity(between: text1, and: text2)
        let similarity2 = try await nlpEngine.calculateSimilarity(between: text1, and: text3)
        
        XCTAssertGreaterThan(similarity1.similarity, 0.6)
        XCTAssertLessThan(similarity2.similarity, 0.3)
        XCTAssertEqual(similarity1.method, "cosine")
    }
    
    // MARK: - Performance Tests
    
    func testAnalysisPerformance() async throws {
        let text = "SwiftIntelligence provides comprehensive AI capabilities for Apple platforms."
        let startTime = Date()
        
        let result = try await nlpEngine.analyzeText(
            text,
            options: NLPAnalysisOptions.demo
        )
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(processingTime, 1.0) // Should complete within 1 second
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.keywords.count, 0)
    }
    
    func testBatchProcessingPerformance() async throws {
        let texts = [
            "First text for batch processing analysis.",
            "Second text with different content and structure.",
            "Third text containing various entities and keywords.",
            "Fourth text for comprehensive performance testing.",
            "Fifth text to complete the batch processing test."
        ]
        
        let startTime = Date()
        
        var results: [NLPAnalysisResult] = []
        for text in texts {
            let result = try await nlpEngine.analyzeText(
                text,
                options: NLPAnalysisOptions(enableSentiment: true, enableKeywords: true)
            )
            results.append(result)
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        let averageTime = totalTime / Double(texts.count)
        
        XCTAssertEqual(results.count, texts.count)
        XCTAssertLessThan(averageTime, 0.5) // Average should be under 0.5 seconds per text
        
        for result in results {
            XCTAssertNotNil(result.sentiment)
            XCTAssertGreaterThan(result.keywords.count, 0)
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyTextHandling() async throws {
        let emptyText = ""
        
        let result = try await nlpEngine.analyzeText(
            emptyText,
            options: NLPAnalysisOptions.demo
        )
        
        XCTAssertEqual(result.text, emptyText)
        XCTAssertEqual(result.keywords.count, 0)
        XCTAssertEqual(result.entities.count, 0)
    }
    
    func testVeryLongTextHandling() async throws {
        let longText = String(repeating: "This is a very long text for testing purposes. ", count: 1000)
        
        let result = try await nlpEngine.analyzeText(
            longText,
            options: NLPAnalysisOptions(enableSentiment: true, enableKeywords: true, maxKeywords: 10)
        )
        
        XCTAssertNotNil(result.sentiment)
        XCTAssertLessThanOrEqual(result.keywords.count, 10)
        XCTAssertGreaterThan(result.processingTime, 0)
    }
    
    func testSpecialCharactersHandling() async throws {
        let specialText = "🚀 AI & ML: 100% amazing! @SwiftIntelligence #AI #ML $$$"
        
        let result = try await nlpEngine.analyzeText(
            specialText,
            options: NLPAnalysisOptions.demo
        )
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.text, specialText)
    }
    
    func testMultilingualText() async throws {
        let multilingualText = "Hello world! Hola mundo! Bonjour le monde! Merhaba dünya!"
        
        let result = try await nlpEngine.analyzeText(
            multilingualText,
            options: NLPAnalysisOptions(enableLanguageDetection: true, enableKeywords: true)
        )
        
        XCTAssertNotNil(result.language)
        XCTAssertGreaterThan(result.keywords.count, 0)
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidInputHandling() async throws {
        // Test with malformed input
        let malformedText = String(bytes: [0xFF, 0xFE, 0xFD], encoding: .utf8) ?? ""
        
        do {
            let result = try await nlpEngine.analyzeText(
                malformedText,
                options: NLPAnalysisOptions.demo
            )
            // Should handle gracefully
            XCTAssertNotNil(result)
        } catch {
            // Error handling is also acceptable
            XCTAssertTrue(error is NLPError)
        }
    }
    
    func testConcurrentRequests() async throws {
        let texts = [
            "First concurrent text analysis request.",
            "Second concurrent text analysis request.",
            "Third concurrent text analysis request."
        ]
        
        let results = await withTaskGroup(of: NLPAnalysisResult?.self, returning: [NLPAnalysisResult].self) { group in
            for text in texts {
                group.addTask {
                    do {
                        return try await self.nlpEngine.analyzeText(
                            text,
                            options: NLPAnalysisOptions.demo
                        )
                    } catch {
                        return nil
                    }
                }
            }
            
            var collectedResults: [NLPAnalysisResult] = []
            for await result in group {
                if let result = result {
                    collectedResults.append(result)
                }
            }
            return collectedResults
        }
        
        XCTAssertEqual(results.count, texts.count)
        
        for result in results {
            XCTAssertGreaterThan(result.keywords.count, 0)
        }
    }
}

// MARK: - Test Extensions

extension NLPAnalysisOptions {
    static let demo = NLPAnalysisOptions(
        enableSentiment: true,
        enableEntities: true,
        enableKeywords: true,
        enableLanguageDetection: true,
        enableSummary: false,
        maxKeywords: 10
    )
}
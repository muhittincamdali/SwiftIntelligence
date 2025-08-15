import XCTest
@testable import SwiftIntelligenceNLP
import NaturalLanguage

final class NLPTests: XCTestCase {
    
    var nlpEngine: SwiftIntelligenceNLP!
    
    override func setUp() async throws {
        nlpEngine = try await SwiftIntelligenceNLP()
    }
    
    override func tearDown() {
        nlpEngine = nil
    }
    
    // MARK: - Sentiment Analysis Tests
    
    func testPositiveSentimentAnalysis() async throws {
        let result = try await nlpEngine.analyzeSentiment("This is absolutely amazing! I love it!")
        XCTAssertEqual(result.sentiment, .positive)
        XCTAssertGreaterThan(result.score, 0.5)
        XCTAssertGreaterThan(result.confidence, 0.7)
    }
    
    func testNegativeSentimentAnalysis() async throws {
        let result = try await nlpEngine.analyzeSentiment("This is terrible and I hate it.")
        XCTAssertEqual(result.sentiment, .negative)
        XCTAssertLessThan(result.score, -0.3)
        XCTAssertGreaterThan(result.confidence, 0.6)
    }
    
    func testNeutralSentimentAnalysis() async throws {
        let result = try await nlpEngine.analyzeSentiment("The sky is blue.")
        XCTAssertEqual(result.sentiment, .neutral)
        XCTAssertGreaterThan(result.score, -0.3)
        XCTAssertLessThan(result.score, 0.3)
    }
    
    // MARK: - Entity Recognition Tests
    
    func testPersonEntityRecognition() async throws {
        let text = "Tim Cook is the CEO of Apple."
        let entities = try await nlpEngine.extractEntities(text)
        
        let personEntities = entities.filter { $0.type == .personalName }
        XCTAssertFalse(personEntities.isEmpty)
        XCTAssertTrue(personEntities.contains { $0.text.contains("Tim Cook") })
    }
    
    func testLocationEntityRecognition() async throws {
        let text = "Apple is headquartered in Cupertino, California."
        let entities = try await nlpEngine.extractEntities(text)
        
        let locationEntities = entities.filter { $0.type == .placeName }
        XCTAssertFalse(locationEntities.isEmpty)
    }
    
    func testOrganizationEntityRecognition() async throws {
        let text = "Microsoft and Google are major tech companies."
        let entities = try await nlpEngine.extractEntities(text)
        
        let orgEntities = entities.filter { $0.type == .organizationName }
        XCTAssertGreaterThanOrEqual(orgEntities.count, 2)
    }
    
    // MARK: - Language Detection Tests
    
    func testEnglishLanguageDetection() async throws {
        let result = try await nlpEngine.detectLanguage("Hello, how are you today?")
        XCTAssertEqual(result.language, .english)
        XCTAssertGreaterThan(result.confidence, 0.9)
    }
    
    func testMultipleLanguageDetection() async throws {
        let languages = try await nlpEngine.detectLanguages("Hello world", limit: 3)
        XCTAssertFalse(languages.isEmpty)
        XCTAssertEqual(languages.first?.language, .english)
    }
    
    // MARK: - Tokenization Tests
    
    func testWordTokenization() async throws {
        let tokens = try await nlpEngine.tokenize("Hello world, how are you?", unit: .word)
        XCTAssertEqual(tokens.count, 5)
        XCTAssertTrue(tokens.contains("Hello"))
        XCTAssertTrue(tokens.contains("world"))
    }
    
    func testSentenceTokenization() async throws {
        let text = "This is sentence one. This is sentence two! Is this sentence three?"
        let sentences = try await nlpEngine.tokenize(text, unit: .sentence)
        XCTAssertEqual(sentences.count, 3)
    }
    
    // MARK: - Keyword Extraction Tests
    
    func testKeywordExtraction() async throws {
        let text = """
        Apple Inc. is an American multinational technology company headquartered in Cupertino, California.
        Apple is the world's largest technology company by revenue.
        """
        
        let keywords = try await nlpEngine.extractKeywords(from: text, limit: 5)
        XCTAssertFalse(keywords.isEmpty)
        XCTAssertLessThanOrEqual(keywords.count, 5)
        
        // Should extract important terms like "Apple", "technology", "company"
        let keywordTexts = keywords.map { $0.keyword.lowercased() }
        XCTAssertTrue(keywordTexts.contains("apple") || keywordTexts.contains("technology") || keywordTexts.contains("company"))
    }
    
    // MARK: - Text Similarity Tests
    
    func testTextSimilarity() async throws {
        let text1 = "The cat sat on the mat"
        let text2 = "The dog sat on the rug"
        let text3 = "Programming is fun"
        
        let similarity1 = try await nlpEngine.calculateSimilarity(between: text1, and: text2)
        let similarity2 = try await nlpEngine.calculateSimilarity(between: text1, and: text3)
        
        // Similar sentences should have higher similarity
        XCTAssertGreaterThan(similarity1, similarity2)
        XCTAssertGreaterThan(similarity1, 0.5)
        XCTAssertLessThan(similarity2, 0.3)
    }
    
    // MARK: - Summarization Tests
    
    func testTextSummarization() async throws {
        let longText = """
        Apple Inc. is an American multinational technology company headquartered in Cupertino, California.
        As of March 2023, Apple is the world's largest company by market capitalization.
        The company was founded by Steve Jobs, Steve Wozniak, and Ronald Wayne in 1976.
        Apple is known for its innovative products including the iPhone, iPad, Mac computers, and Apple Watch.
        The company has revolutionized multiple industries through its focus on design and user experience.
        """
        
        let summary = try await nlpEngine.summarize(longText, targetLength: 50)
        
        XCTAssertFalse(summary.isEmpty)
        XCTAssertLessThan(summary.count, longText.count)
        
        // Summary should contain key information
        XCTAssertTrue(summary.contains("Apple") || summary.contains("technology"))
    }
    
    // MARK: - Performance Tests
    
    func testSentimentAnalysisPerformance() {
        let text = "This is a test sentence for performance measurement."
        
        measure {
            let expectation = self.expectation(description: "Sentiment analysis")
            
            Task {
                _ = try? await nlpEngine.analyzeSentiment(text)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testEntityExtractionPerformance() {
        let text = "Tim Cook from Apple met with Satya Nadella from Microsoft in San Francisco."
        
        measure {
            let expectation = self.expectation(description: "Entity extraction")
            
            Task {
                _ = try? await nlpEngine.extractEntities(text)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
}
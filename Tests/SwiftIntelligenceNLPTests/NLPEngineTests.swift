@preconcurrency import XCTest
@testable import SwiftIntelligenceNLP
@testable import SwiftIntelligenceCore

final class NLPEngineTests: XCTestCase {
    private var nlpEngine: NLPEngine!

    @MainActor
    override func setUp() async throws {
        nlpEngine = NLPEngine.shared
        SwiftIntelligenceCore.shared.configure(with: .testing)
    }

    @MainActor
    override func tearDown() async throws {
        SwiftIntelligenceCore.shared.cleanup()
        nlpEngine = nil
    }

    @MainActor
    func testAnalyzeCollectsRequestedSignals() async throws {
        let text = "Apple builds amazing products in Cupertino."

        let result = try await nlpEngine.analyze(
            text: text,
            options: NLPOptions(
                includeSentiment: true,
                includeEntities: true,
                includeKeywords: true,
                includeLanguageDetection: true
            )
        )

        XCTAssertEqual(result.originalText, text)
        XCTAssertEqual(result.detectedLanguage.rawValue, "en")

        let sentiment = result.analysisResults["sentiment"] as? SentimentResult
        let entities = result.analysisResults["entities"] as? [NamedEntity]
        let keywords = result.analysisResults["keywords"] as? [Keyword]
        let languages = result.analysisResults["languages"] as? [LanguageConfidence]

        XCTAssertNotNil(sentiment)
        XCTAssertNotNil(entities)
        XCTAssertFalse(keywords?.isEmpty ?? true)
        XCTAssertFalse(languages?.isEmpty ?? true)
    }

    @MainActor
    func testSentimentAnalysisMatchesWordLists() async throws {
        let positive = try await nlpEngine.analyzeSentiment(text: "I love this fantastic framework")
        let negative = try await nlpEngine.analyzeSentiment(text: "I hate this awful bug")
        let neutral = try await nlpEngine.analyzeSentiment(text: "The release is scheduled for tomorrow")

        XCTAssertEqual(positive.sentiment, .positive)
        XCTAssertEqual(negative.sentiment, .negative)
        XCTAssertEqual(neutral.sentiment, .neutral)
    }

    @MainActor
    func testKeywordExtractionRespectsLimit() {
        let keywords = nlpEngine.extractKeywords(
            text: "Machine learning and artificial intelligence power modern machine systems.",
            maxCount: 3
        )

        XCTAssertLessThanOrEqual(keywords.count, 3)
        XCTAssertTrue(keywords.contains { $0.word.contains("machine") || $0.word.contains("learning") })
    }

    @MainActor
    func testSummarizeTextReturnsCondensedOutput() async throws {
        let text = """
        SwiftIntelligence brings on-device AI to Apple platforms.
        It includes NLP, speech, and vision modules.
        The framework focuses on privacy and performance.
        Developers can adopt it with Swift-native APIs.
        """

        let summary = try await nlpEngine.summarizeText(text: text, maxSentences: 2)

        XCTAssertFalse(summary.summary.isEmpty)
        XCTAssertLessThan(summary.summary.count, text.count)
        XCTAssertLessThanOrEqual(summary.selectedSentences.count, 2)
        XCTAssertGreaterThan(summary.compressionRatio, 0)
    }

    @MainActor
    func testExtractNamedEntitiesFindsKnownValues() async throws {
        let entities = try await nlpEngine.extractNamedEntities(
            text: "Apple opened a new office in Cupertino."
        )

        XCTAssertFalse(entities.isEmpty)
        XCTAssertTrue(entities.contains { $0.text.contains("Apple") || $0.text.contains("Cupertino") })
    }

    @MainActor
    func testExtractTopicsReturnsBoundedTopicCount() async throws {
        let topics = try await nlpEngine.extractTopics(
            text: "Swift, Apple, privacy, performance, on-device AI, and machine learning are central framework themes.",
            topicCount: 2
        )

        XCTAssertFalse(topics.isEmpty)
        XCTAssertLessThanOrEqual(topics.count, 2)
        XCTAssertTrue(topics.allSatisfy { !$0.label.isEmpty })
    }
}

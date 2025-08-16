import XCTest
import Foundation
@testable import SwiftIntelligence
@testable import SwiftIntelligenceCore
@testable import SwiftIntelligenceNLP
@testable import SwiftIntelligenceVision
@testable import SwiftIntelligenceSpeech
@testable import SwiftIntelligencePrivacy

#if canImport(UIKit)
import UIKit
#endif

/// Integration tests for the complete SwiftIntelligence framework
/// Tests multi-modal AI workflows and module interactions
@MainActor
final class IntegrationTests: XCTestCase {
    
    override func setUp() async throws {
        // Configure framework for integration testing
        let testConfig = IntelligenceConfiguration.testing
        SwiftIntelligenceCore.shared.configure(with: testConfig)
    }
    
    override func tearDown() async throws {
        SwiftIntelligenceCore.shared.cleanup()
    }
    
    // MARK: - Framework Initialization Tests
    
    func testFrameworkInitialization() async throws {
        // Test that all modules can be initialized together
        let core = SwiftIntelligenceCore.shared
        XCTAssertNotNil(core)
        XCTAssertEqual(SwiftIntelligenceCore.version, "1.0.0")
        
        let nlpEngine = NLPEngine.shared
        let visionEngine = VisionEngine.shared
        let speechEngine = SpeechEngine.shared
        
        XCTAssertNotNil(nlpEngine)
        XCTAssertNotNil(visionEngine)
        XCTAssertNotNil(speechEngine)
    }
    
    func testFrameworkHealthCheck() async throws {
        let core = SwiftIntelligenceCore.shared
        
        // Check system health
        let memoryUsage = core.memoryUsage()
        XCTAssertGreaterThan(memoryUsage.used, 0)
        XCTAssertGreaterThan(memoryUsage.total, memoryUsage.used)
        
        let cpuUsage = core.cpuUsage()
        XCTAssertGreaterThanOrEqual(cpuUsage.total, 0)
        XCTAssertLessThanOrEqual(cpuUsage.total, 100)
    }
    
    // MARK: - Multi-Modal Workflow Tests
    
    #if canImport(UIKit)
    func testVisionToNLPWorkflow() async throws {
        // Create an image with text
        guard let textImage = createTextImage(text: "SwiftIntelligence AI Framework") else {
            XCTFail("Failed to create text image")
            return
        }
        
        // 1. Extract text from image using Vision
        let visionEngine = VisionEngine.shared
        let textResult = try await visionEngine.recognizeText(
            in: textImage,
            options: TextRecognitionOptions.default
        )
        
        XCTAssertFalse(textResult.recognizedText.isEmpty)
        
        // 2. Analyze extracted text using NLP
        let nlpEngine = NLPEngine.shared
        let nlpResult = try await nlpEngine.analyzeText(
            textResult.recognizedText,
            options: NLPAnalysisOptions(
                enableSentiment: true,
                enableKeywords: true,
                enableLanguageDetection: true
            )
        )
        
        XCTAssertNotNil(nlpResult.sentiment)
        XCTAssertGreaterThan(nlpResult.keywords.count, 0)
        XCTAssertEqual(nlpResult.language, "en")
        
        // 3. Verify the workflow preserves accuracy
        let extractedText = textResult.recognizedText.lowercased()
        XCTAssertTrue(extractedText.contains("swift") || extractedText.contains("intelligence"))
    }
    #endif
    
    func testNLPToSpeechWorkflow() async throws {
        // 1. Analyze text with NLP
        let nlpEngine = NLPEngine.shared
        let originalText = "SwiftIntelligence provides amazing AI capabilities for Apple platforms!"
        
        let nlpResult = try await nlpEngine.analyzeText(
            originalText,
            options: NLPAnalysisOptions(
                enableSentiment: true,
                enableKeywords: true,
                enableSummary: true
            )
        )
        
        XCTAssertEqual(nlpResult.sentiment?.label, "positive")
        XCTAssertGreaterThan(nlpResult.keywords.count, 0)
        
        // 2. Generate summary and convert to speech
        let summary = try await nlpEngine.summarizeText(originalText, maxLength: 100)
        
        let speechEngine = SpeechEngine.shared
        let speechResult = try await speechEngine.synthesizeSpeech(
            from: summary.summary,
            options: SpeechSynthesisOptions.default
        )
        
        XCTAssertGreaterThan(speechResult.duration, 0)
        XCTAssertGreaterThan(speechResult.synthesizedAudio.count, 0)
        XCTAssertEqual(speechResult.originalText, summary.summary)
    }
    
    func testPrivacyPreservingWorkflow() async throws {
        // 1. Tokenize sensitive data
        let tokenizer = PrivacyTokenizer()
        let sensitiveText = "Contact john.doe@company.com for project details"
        
        let emailPattern = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        let regex = try NSRegularExpression(pattern: emailPattern)
        let range = NSRange(location: 0, length: sensitiveText.utf16.count)
        let matches = regex.matches(in: sensitiveText, range: range)
        
        var tokenizedText = sensitiveText
        for match in matches.reversed() {
            if let emailRange = Range(match.range, in: sensitiveText) {
                let email = String(sensitiveText[emailRange])
                
                let tokenizedEmail = try await tokenizer.formatPreservingTokenize(
                    email,
                    context: TokenizationContext(
                        purpose: .email,
                        dataClassification: .sensitive,
                        retentionPolicy: .shortTerm
                    )
                )
                
                tokenizedText = tokenizedText.replacingCharacters(in: emailRange, with: tokenizedEmail)
            }
        }
        
        // 2. Process tokenized text with NLP
        let nlpEngine = NLPEngine.shared
        let nlpResult = try await nlpEngine.analyzeText(
            tokenizedText,
            options: NLPAnalysisOptions(
                enableKeywords: true,
                enableLanguageDetection: true
            )
        )
        
        XCTAssertEqual(nlpResult.language, "en")
        XCTAssertGreaterThan(nlpResult.keywords.count, 0)
        
        // 3. Verify privacy preservation
        XCTAssertFalse(tokenizedText.contains("john.doe@company.com"))
        XCTAssertTrue(tokenizedText.contains("project"))
    }
    
    // MARK: - Performance Integration Tests
    
    func testConcurrentModuleProcessing() async throws {
        let testText = "SwiftIntelligence enables powerful AI applications"
        
        #if canImport(UIKit)
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        #endif
        
        let startTime = Date()
        
        // Run multiple modules concurrently
        async let nlpTask = processWithNLP(text: testText)
        async let speechTask = processWithSpeech(text: testText)
        #if canImport(UIKit)
        async let visionTask = processWithVision(image: testImage)
        #endif
        
        let nlpResult = try await nlpTask
        let speechResult = try await speechTask
        #if canImport(UIKit)
        let visionResult = try await visionTask
        #endif
        
        let totalTime = Date().timeIntervalSince(startTime)
        
        // Verify results
        XCTAssertNotNil(nlpResult.sentiment)
        XCTAssertGreaterThan(speechResult.duration, 0)
        #if canImport(UIKit)
        XCTAssertGreaterThanOrEqual(visionResult.detectedObjects.count, 0)
        #endif
        
        // Concurrent processing should be faster than sequential
        XCTAssertLessThan(totalTime, 5.0)
    }
    
    func testHighThroughputProcessing() async throws {
        let texts = Array(1...20).map { "Test text number \($0) for high throughput processing" }
        
        let startTime = Date()
        
        // Process multiple texts concurrently
        let results = await withTaskGroup(of: NLPAnalysisResult?.self, returning: [NLPAnalysisResult].self) { group in
            for text in texts {
                group.addTask {
                    do {
                        return try await self.processWithNLP(text: text)
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
        
        let totalTime = Date().timeIntervalSince(startTime)
        let throughput = Double(results.count) / totalTime
        
        XCTAssertEqual(results.count, texts.count)
        XCTAssertGreaterThan(throughput, 2.0) // Should process at least 2 texts per second
        
        for result in results {
            XCTAssertGreaterThan(result.keywords.count, 0)
        }
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testCascadingErrorHandling() async throws {
        let errorHandler = SwiftIntelligenceCore.shared.errorHandler
        
        // Clear any existing errors
        errorHandler.clearHistory()
        
        // Generate errors from different modules
        do {
            _ = try await NLPEngine.shared.analyzeText(
                "", // Empty text should cause error
                options: NLPAnalysisOptions.demo
            )
        } catch {
            // Expected error
        }
        
        #if canImport(UIKit)
        do {
            let tinyImage = createColoredImage(size: CGSize(width: 1, height: 1), color: .clear)!
            _ = try await VisionEngine.shared.detectObjects(
                in: tinyImage,
                options: ObjectDetectionOptions.demo
            )
        } catch {
            // Expected error for tiny image
        }
        #endif
        
        // Check error collection
        let errorHistory = errorHandler.errorHistory
        XCTAssertGreaterThan(errorHistory.count, 0)
        
        // Verify error categorization
        let nlpErrors = errorHandler.errors(fromModule: "NLP")
        let visionErrors = errorHandler.errors(fromModule: "Vision")
        
        XCTAssertGreaterThanOrEqual(nlpErrors.count, 0)
        XCTAssertGreaterThanOrEqual(visionErrors.count, 0)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryUsageUnderLoad() async throws {
        let initialMemory = SwiftIntelligenceCore.shared.memoryUsage()
        
        // Generate memory pressure
        var results: [Any] = []
        
        for i in 0..<50 {
            let text = String(repeating: "Memory test text \(i). ", count: 100)
            
            let nlpResult = try await NLPEngine.shared.analyzeText(
                text,
                options: NLPAnalysisOptions.demo
            )
            results.append(nlpResult)
            
            #if canImport(UIKit)
            if let image = createTestImage() {
                let visionResult = try await VisionEngine.shared.detectObjects(
                    in: image,
                    options: ObjectDetectionOptions.demo
                )
                results.append(visionResult)
            }
            #endif
        }
        
        let peakMemory = SwiftIntelligenceCore.shared.memoryUsage()
        
        // Clear results to allow garbage collection
        results.removeAll()
        
        // Force garbage collection (if possible)
        for _ in 0..<10 {
            autoreleasepool {
                _ = Array(0..<1000)
            }
        }
        
        let finalMemory = SwiftIntelligenceCore.shared.memoryUsage()
        
        // Memory should have increased during processing
        XCTAssertGreaterThan(peakMemory.used, initialMemory.used)
        
        // Memory should be reasonable (not excessive)
        let memoryIncreaseMB = (peakMemory.used - initialMemory.used) / (1024 * 1024)
        XCTAssertLessThan(memoryIncreaseMB, 200) // Should not increase by more than 200MB
    }
    
    // MARK: - Configuration Integration Tests
    
    func testConfigurationPropagation() async throws {
        // Test that configuration changes propagate to all modules
        let customConfig = IntelligenceConfiguration(
            debugMode: true,
            performanceMonitoring: true,
            verboseLogging: true,
            memoryLimit: 256,
            requestTimeout: 10,
            maxConcurrentOperations: 2
        )
        
        SwiftIntelligenceCore.shared.configure(with: customConfig)
        
        // Verify configuration is applied
        let appliedConfig = SwiftIntelligenceCore.shared.configuration
        XCTAssertTrue(appliedConfig.debugMode)
        XCTAssertTrue(appliedConfig.performanceMonitoring)
        XCTAssertTrue(appliedConfig.verboseLogging)
        XCTAssertEqual(appliedConfig.memoryLimit, 256)
        XCTAssertEqual(appliedConfig.maxConcurrentOperations, 2)
        
        // Test that modules respect the configuration
        let performanceMonitor = SwiftIntelligenceCore.shared.performanceMonitor
        XCTAssertTrue(performanceMonitor.isMonitoring)
    }
    
    // MARK: - Helper Methods
    
    private func processWithNLP(text: String) async throws -> NLPAnalysisResult {
        return try await NLPEngine.shared.analyzeText(
            text,
            options: NLPAnalysisOptions.demo
        )
    }
    
    private func processWithSpeech(text: String) async throws -> SpeechSynthesisResult {
        return try await SpeechEngine.shared.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions.default
        )
    }
    
    #if canImport(UIKit)
    private func processWithVision(image: UIImage) async throws -> ObjectDetectionResult {
        return try await VisionEngine.shared.detectObjects(
            in: image,
            options: ObjectDetectionOptions.demo
        )
    }
    
    private func createTestImage() -> UIImage? {
        let size = CGSize(width: 200, height: 150)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Blue background
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Red circle
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 50, width: 60, height: 60))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createTextImage(text: String) -> UIImage? {
        let size = CGSize(width: 400, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Black text
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createColoredImage(size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
}

// MARK: - Test Extensions

extension NLPAnalysisOptions {
    static let demo = NLPAnalysisOptions(
        enableSentiment: true,
        enableEntities: true,
        enableKeywords: true,
        enableLanguageDetection: true,
        maxKeywords: 5
    )
}

extension ObjectDetectionOptions {
    static let demo = ObjectDetectionOptions(
        confidenceThreshold: 0.5,
        enableClassification: true,
        maxObjects: 5
    )
}
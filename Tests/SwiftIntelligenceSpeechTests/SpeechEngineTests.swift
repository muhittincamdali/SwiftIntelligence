import XCTest
import Foundation
import AVFoundation
@testable import SwiftIntelligenceSpeech
@testable import SwiftIntelligenceCore

/// Comprehensive test suite for Speech Engine functionality
@MainActor
final class SpeechEngineTests: XCTestCase {
    
    var speechEngine: SpeechEngine!
    
    override func setUp() async throws {
        speechEngine = SpeechEngine.shared
        
        // Configure for testing
        let testConfig = IntelligenceConfiguration.testing
        SwiftIntelligenceCore.shared.configure(with: testConfig)
    }
    
    override func tearDown() async throws {
        SwiftIntelligenceCore.shared.cleanup()
    }
    
    // MARK: - Speech Synthesis Tests
    
    func testBasicSpeechSynthesis() async throws {
        let text = "Hello from SwiftIntelligence!"
        
        let result = try await speechEngine.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions.default
        )
        
        XCTAssertEqual(result.originalText, text)
        XCTAssertGreaterThan(result.duration, 0)
        XCTAssertGreaterThan(result.processingTime, 0)
        XCTAssertGreaterThan(result.synthesizedAudio.count, 0)
    }
    
    func testSpeechSynthesisWithCustomOptions() async throws {
        let text = "This is a test with custom speech synthesis options."
        let options = SpeechSynthesisOptions(
            speed: 0.8,
            pitch: 1.2,
            volume: 0.9,
            enableSSML: false
        )
        
        let result = try await speechEngine.synthesizeSpeech(
            from: text,
            options: options
        )
        
        XCTAssertEqual(result.originalText, text)
        XCTAssertGreaterThan(result.duration, 0)
        XCTAssertNotNil(result.voice)
    }
    
    func testLongTextSynthesis() async throws {
        let longText = String(repeating: "This is a longer text for testing speech synthesis with extended content. ", count: 10)
        
        let result = try await speechEngine.synthesizeSpeech(
            from: longText,
            options: SpeechSynthesisOptions.default
        )
        
        XCTAssertEqual(result.originalText, longText)
        XCTAssertGreaterThan(result.duration, 5.0) // Should be longer for more text
        XCTAssertGreaterThan(result.synthesizedAudio.count, 0)
    }
    
    // MARK: - Voice Management Tests
    
    func testGetAvailableVoices() {
        let englishVoices = speechEngine.getAvailableVoices(for: "en-US")
        let allVoices = speechEngine.getAvailableVoices()
        
        XCTAssertGreaterThan(englishVoices.count, 0)
        XCTAssertGreaterThanOrEqual(allVoices.count, englishVoices.count)
        
        for voice in englishVoices {
            XCTAssertTrue(voice.language.hasPrefix("en"))
            XCTAssertFalse(voice.identifier.isEmpty)
            XCTAssertFalse(voice.name.isEmpty)
        }
    }
    
    func testVoiceSelection() async throws {
        let voices = speechEngine.getAvailableVoices(for: "en-US")
        guard let firstVoice = voices.first else {
            XCTFail("No English voices available")
            return
        }
        
        let text = "Testing voice selection."
        let options = SpeechSynthesisOptions(
            speed: 1.0,
            pitch: 1.0,
            volume: 1.0,
            enableSSML: false
        )
        
        let result = try await speechEngine.synthesizeSpeech(
            from: text,
            voice: firstVoice,
            options: options
        )
        
        XCTAssertEqual(result.voice?.identifier, firstVoice.identifier)
        XCTAssertEqual(result.originalText, text)
    }
    
    // MARK: - Text-to-Speech Configuration Tests
    
    func testTextToSpeechOptions() async throws {
        let text = "Testing different speech rates and pitches."
        
        // Test slow speech
        let slowResult = try await speechEngine.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions(speed: 0.3, pitch: 1.0, volume: 1.0)
        )
        
        // Test fast speech
        let fastResult = try await speechEngine.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions(speed: 0.9, pitch: 1.0, volume: 1.0)
        )
        
        // Slow speech should generally take longer
        XCTAssertGreaterThan(slowResult.duration, fastResult.duration)
        XCTAssertEqual(slowResult.originalText, text)
        XCTAssertEqual(fastResult.originalText, text)
    }
    
    func testPitchVariation() async throws {
        let text = "Testing pitch variation in speech synthesis."
        
        let lowPitchResult = try await speechEngine.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions(speed: 1.0, pitch: 0.7, volume: 1.0)
        )
        
        let highPitchResult = try await speechEngine.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions(speed: 1.0, pitch: 1.5, volume: 1.0)
        )
        
        XCTAssertEqual(lowPitchResult.originalText, text)
        XCTAssertEqual(highPitchResult.originalText, text)
        XCTAssertGreaterThan(lowPitchResult.synthesizedAudio.count, 0)
        XCTAssertGreaterThan(highPitchResult.synthesizedAudio.count, 0)
    }
    
    // MARK: - Performance Tests
    
    func testSynthesisPerformance() async throws {
        let text = "Performance test for speech synthesis."
        let startTime = Date()
        
        let result = try await speechEngine.synthesizeSpeech(
            from: text,
            options: SpeechSynthesisOptions.default
        )
        
        let wallClockTime = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(wallClockTime, 3.0) // Should complete within 3 seconds
        XCTAssertLessThan(result.processingTime, wallClockTime)
        XCTAssertNotNil(result)
    }
    
    func testBatchSynthesisPerformance() async throws {
        let texts = [
            "First text for batch synthesis.",
            "Second text for performance testing.",
            "Third text to complete the batch.",
            "Fourth text for comprehensive testing.",
            "Fifth and final text for the batch."
        ]
        
        let startTime = Date()
        var results: [SpeechSynthesisResult] = []
        
        for text in texts {
            let result = try await speechEngine.synthesizeSpeech(
                from: text,
                options: SpeechSynthesisOptions.default
            )
            results.append(result)
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        let averageTime = totalTime / Double(texts.count)
        
        XCTAssertEqual(results.count, texts.count)
        XCTAssertLessThan(averageTime, 2.0) // Average should be under 2 seconds per text
        
        for result in results {
            XCTAssertGreaterThan(result.duration, 0)
            XCTAssertGreaterThan(result.synthesizedAudio.count, 0)
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyTextSynthesis() async throws {
        let emptyText = ""
        
        do {
            let result = try await speechEngine.synthesizeSpeech(
                from: emptyText,
                options: SpeechSynthesisOptions.default
            )
            
            // Should handle gracefully
            XCTAssertEqual(result.originalText, emptyText)
            XCTAssertEqual(result.duration, 0, accuracy: 0.1)
        } catch {
            // Error handling is also acceptable for empty text
            XCTAssertTrue(error is SpeechError)
        }
    }
    
    func testSpecialCharactersSynthesis() async throws {
        let specialText = "Hello! How are you? 123... @#$%^&*()"
        
        let result = try await speechEngine.synthesizeSpeech(
            from: specialText,
            options: SpeechSynthesisOptions.default
        )
        
        XCTAssertEqual(result.originalText, specialText)
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    func testNumbersAndSymbolsSynthesis() async throws {
        let numbersText = "The temperature is 25.5 degrees, and the time is 3:45 PM."
        
        let result = try await speechEngine.synthesizeSpeech(
            from: numbersText,
            options: SpeechSynthesisOptions.default
        )
        
        XCTAssertEqual(result.originalText, numbersText)
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    func testMultilingualText() async throws {
        let multilingualText = "Hello, Hola, Bonjour, Guten Tag"
        
        let result = try await speechEngine.synthesizeSpeech(
            from: multilingualText,
            options: SpeechSynthesisOptions.default
        )
        
        XCTAssertEqual(result.originalText, multilingualText)
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    // MARK: - Concurrent Processing Tests
    
    func testConcurrentSynthesis() async throws {
        let texts = [
            "First concurrent synthesis request.",
            "Second concurrent synthesis request.",
            "Third concurrent synthesis request."
        ]
        
        let results = await withTaskGroup(of: SpeechSynthesisResult?.self, returning: [SpeechSynthesisResult].self) { group in
            for text in texts {
                group.addTask {
                    do {
                        return try await self.speechEngine.synthesizeSpeech(
                            from: text,
                            options: SpeechSynthesisOptions.default
                        )
                    } catch {
                        return nil
                    }
                }
            }
            
            var collectedResults: [SpeechSynthesisResult] = []
            for await result in group {
                if let result = result {
                    collectedResults.append(result)
                }
            }
            return collectedResults
        }
        
        XCTAssertEqual(results.count, texts.count)
        
        for result in results {
            XCTAssertGreaterThan(result.duration, 0)
            XCTAssertGreaterThan(result.synthesizedAudio.count, 0)
        }
    }
    
    // MARK: - Language Support Tests
    
    func testLanguageSupport() {
        let supportedLanguages = SpeechLanguageSupport.supportedLanguages
        
        XCTAssertGreaterThan(supportedLanguages.count, 0)
        
        // Check for English support
        let englishSupport = supportedLanguages.first { $0.languageCode.hasPrefix("en") }
        XCTAssertNotNil(englishSupport)
        XCTAssertEqual(englishSupport?.synthesisSupport, .excellent)
        
        for language in supportedLanguages {
            XCTAssertFalse(language.languageCode.isEmpty)
            XCTAssertFalse(language.displayName.isEmpty)
            XCTAssertGreaterThanOrEqual(language.availableVoices, 0)
        }
    }
    
    // MARK: - Voice Quality Tests
    
    func testVoiceQualityLevels() {
        let voices = speechEngine.getAvailableVoices()
        
        let enhancedVoices = voices.filter { $0.quality == .enhanced }
        let premiumVoices = voices.filter { $0.quality == .premium }
        let standardVoices = voices.filter { $0.quality == .standard }
        
        // Should have voices of different quality levels
        XCTAssertGreaterThan(voices.count, 0)
        
        for voice in voices {
            XCTAssertNotNil(voice.quality)
            XCTAssertNotNil(voice.gender)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidVoiceHandling() async throws {
        let invalidVoice = SpeechVoice(
            identifier: "invalid-voice-id",
            name: "Invalid Voice",
            language: "xx-XX",
            quality: .standard,
            gender: .neutral
        )
        
        let text = "Testing with invalid voice."
        
        do {
            let result = try await speechEngine.synthesizeSpeech(
                from: text,
                voice: invalidVoice,
                options: SpeechSynthesisOptions.default
            )
            
            // Should handle gracefully or use fallback voice
            XCTAssertEqual(result.originalText, text)
        } catch {
            // Error handling is also acceptable
            XCTAssertTrue(error is SpeechError)
        }
    }
    
    func testExtremeParameterValues() async throws {
        let text = "Testing extreme parameter values."
        
        // Test with extreme but valid values
        let extremeOptions = SpeechSynthesisOptions(
            speed: 0.1,  // Very slow
            pitch: 2.0,  // Very high pitch
            volume: 0.1, // Very quiet
            enableSSML: false
        )
        
        do {
            let result = try await speechEngine.synthesizeSpeech(
                from: text,
                options: extremeOptions
            )
            
            XCTAssertEqual(result.originalText, text)
            XCTAssertGreaterThan(result.duration, 0)
        } catch {
            // Some extreme values might not be supported
            XCTAssertTrue(error is SpeechError)
        }
    }
}

// MARK: - Test Extensions

extension SpeechSynthesisOptions {
    static let testFast = SpeechSynthesisOptions(
        speed: 0.8,
        pitch: 1.0,
        volume: 0.8,
        enableSSML: false
    )
    
    static let testSlow = SpeechSynthesisOptions(
        speed: 0.3,
        pitch: 1.0,
        volume: 0.8,
        enableSSML: false
    )
    
    static let testHighPitch = SpeechSynthesisOptions(
        speed: 0.5,
        pitch: 1.5,
        volume: 0.8,
        enableSSML: false
    )
}
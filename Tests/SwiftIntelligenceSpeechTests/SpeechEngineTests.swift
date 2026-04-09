@preconcurrency import XCTest
@testable import SwiftIntelligenceSpeech

@MainActor
final class SpeechEngineTests: XCTestCase {
    func testSpeechSynthesisOptionsDefaults() {
        let options = SpeechSynthesisOptions.default

        XCTAssertEqual(options.language, "en-US")
        XCTAssertEqual(options.speed, 1.0)
        XCTAssertEqual(options.pitch, 1.0)
        XCTAssertEqual(options.volume, 1.0)
        XCTAssertFalse(options.enableSSML)
    }

    func testTextToSpeechOptionsClampValues() {
        let options = TextToSpeechOptions(
            rate: 5.0,
            pitch: 5.0,
            volume: -1.0,
            preUtteranceDelay: -2.0,
            postUtteranceDelay: -3.0
        )

        XCTAssertEqual(options.rate, 1.0)
        XCTAssertEqual(options.pitch, 2.0)
        XCTAssertEqual(options.volume, 0.0)
        XCTAssertEqual(options.preUtteranceDelay, 0.0)
        XCTAssertEqual(options.postUtteranceDelay, 0.0)
    }

    func testLanguageSupportCatalogIncludesEnglish() {
        let english = SpeechLanguageSupport.supportedLanguages.first { $0.languageCode == "en-US" }

        XCTAssertNotNil(english)
        XCTAssertEqual(english?.synthesisSupport, .excellent)
        XCTAssertGreaterThan(english?.availableVoices ?? 0, 0)
    }

    func testAvailableVoicesForEnglishContainMetadata() throws {
        let voices = SpeechEngine.availableVoices(for: "en-US")
        try XCTSkipIf(voices.isEmpty, "No English voices available in this environment")

        XCTAssertTrue(voices.allSatisfy { $0.language.hasPrefix("en") })
        XCTAssertTrue(voices.allSatisfy { !$0.identifier.isEmpty && !$0.name.isEmpty })
    }
}

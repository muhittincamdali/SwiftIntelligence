import XCTest
@testable import SwiftIntelligenceSpeech

final class SwiftIntelligenceSpeechTests: XCTestCase {
    func testSpeechRecognitionOptionsPresets() {
        XCTAssertTrue(SpeechRecognitionOptions.realtime.enablePartialResults)
        XCTAssertTrue(SpeechRecognitionOptions.realtime.requireOnDeviceRecognition)
        XCTAssertFalse(SpeechRecognitionOptions.realtime.addPunctuation)

        XCTAssertFalse(SpeechRecognitionOptions.accurate.enablePartialResults)
        XCTAssertTrue(SpeechRecognitionOptions.accurate.addPunctuation)
        XCTAssertTrue(SpeechRecognitionOptions.accurate.detectLanguage)
    }

    func testTextToSpeechPresetLanguages() {
        XCTAssertEqual(TextToSpeechOptions.default.language, "en-US")
        XCTAssertEqual(TextToSpeechOptions.turkish.language, "tr-TR")
        XCTAssertGreaterThan(TextToSpeechOptions.announcement.preUtteranceDelay, 0)
    }
}

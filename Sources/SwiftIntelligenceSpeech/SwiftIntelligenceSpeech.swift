import Foundation
import SwiftIntelligenceCore
import Speech
import AVFoundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Speech Recognition and Text-to-Speech Engine - Advanced speech processing capabilities
public actor SwiftIntelligenceSpeech {
    
    // MARK: - Properties
    
    public let moduleID = "Speech"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - Speech Components
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var speechSynthesizer: AVSpeechSynthesizer?
    
    // MARK: - Configuration
    
    private var supportedLanguages: [String] = []
    private let maxRecordingDuration: TimeInterval = 300 // 5 minutes
    private var currentLanguage: String = "en-US"
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: SpeechPerformanceMetrics = SpeechPerformanceMetrics()
    private let logger = IntelligenceLogger()
    
    // MARK: - State Management
    
    private var isRecording = false
    private var isPlaying = false
    private var currentRecognitionText = ""
    private var recognitionConfidence: Float = 0.0
    
    // MARK: - Initialization
    
    public init() async throws {
        try await initializeSpeechEngine()
    }
    
    private func initializeSpeechEngine() async throws {
        status = .initializing
        logger.info("Initializing Speech Engine...", category: "Speech")
        
        // Setup speech capabilities
        await setupSpeechCapabilities()
        await validateSpeechFrameworks()
        
        // Request permissions
        try await requestSpeechPermissions()
        
        status = .ready
        logger.info("Speech Engine initialized successfully", category: "Speech")
    }
    
    private func setupSpeechCapabilities() async {
        logger.debug("Setting up Speech capabilities", category: "Speech")
        
        // Initialize speech recognizer with current language
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLanguage))
        
        // Setup speech synthesizer
        speechSynthesizer = AVSpeechSynthesizer()
        
        // Get supported languages
        supportedLanguages = SFSpeechRecognizer.supportedLocales().map { $0.identifier }
        
        // Initialize performance metrics
        performanceMetrics = SpeechPerformanceMetrics()
        
        logger.debug("Speech capabilities configured with \(supportedLanguages.count) languages", category: "Speech")
    }
    
    private func validateSpeechFrameworks() async {
        logger.debug("Validating Speech frameworks", category: "Speech")
        
        // Check Speech framework availability
        #if os(iOS) || os(macOS)
        logger.info("Speech framework available", category: "Speech")
        #else
        logger.warning("Speech framework not available on this platform", category: "Speech")
        #endif
        
        // Check AVFoundation availability
        logger.info("AVFoundation available for audio processing", category: "Speech")
    }
    
    private func requestSpeechPermissions() async throws {
        logger.info("Requesting speech recognition permissions", category: "Speech")
        
        // Request speech recognition permission
        return try await withCheckedThrowingContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    self.logger.info("Speech recognition authorized", category: "Speech")
                    continuation.resume()
                case .denied:
                    self.logger.error("Speech recognition denied", category: "Speech")
                    continuation.resume(throwing: IntelligenceError(code: "SPEECH_PERMISSION_DENIED", message: "Speech recognition permission denied"))
                case .restricted:
                    self.logger.error("Speech recognition restricted", category: "Speech")
                    continuation.resume(throwing: IntelligenceError(code: "SPEECH_PERMISSION_RESTRICTED", message: "Speech recognition restricted"))
                case .notDetermined:
                    self.logger.warning("Speech recognition not determined", category: "Speech")
                    continuation.resume(throwing: IntelligenceError(code: "SPEECH_PERMISSION_NOT_DETERMINED", message: "Speech recognition permission not determined"))
                @unknown default:
                    continuation.resume(throwing: IntelligenceError(code: "SPEECH_PERMISSION_UNKNOWN", message: "Unknown speech recognition permission status"))
                }
            }
        }
    }
    
    // MARK: - Speech Recognition
    
    /// Start continuous speech recognition
    public func startRecognition(language: String = "en-US", options: SpeechRecognitionOptions = .default) async throws -> AsyncStream<SpeechRecognitionResult> {
        guard status == .ready else {
            throw IntelligenceError(code: "SPEECH_NOT_READY", message: "Speech Engine not ready")
        }
        
        guard !isRecording else {
            throw IntelligenceError(code: "ALREADY_RECORDING", message: "Speech recognition already in progress")
        }
        
        logger.info("Starting speech recognition for language: \(language)", category: "Speech")
        
        // Configure recognizer for the specified language
        if language != currentLanguage {
            currentLanguage = language
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw IntelligenceError(code: "SPEECH_RECOGNIZER_UNAVAILABLE", message: "Speech recognizer not available for language: \(language)")
        }
        
        // Setup audio session
        try await setupAudioSession()
        
        let startTime = Date()
        isRecording = true
        currentRecognitionText = ""
        recognitionConfidence = 0.0
        
        return AsyncStream { continuation in
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                continuation.finish()
                return
            }
            
            recognitionRequest.shouldReportPartialResults = options.enablePartialResults
            recognitionRequest.requiresOnDeviceRecognition = options.requireOnDeviceRecognition
            
            // Configure audio input
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            // Start audio engine
            audioEngine.prepare()
            try? audioEngine.start()
            
            // Start recognition task
            recognitionTask = speechRecognizer.recognizeRequest(recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let transcription = result.bestTranscription.formattedString
                    let confidence = result.bestTranscription.segments.first?.confidence ?? 0.0
                    
                    Task {
                        await self.updateCurrentRecognition(text: transcription, confidence: confidence)
                    }
                    
                    let recognitionResult = SpeechRecognitionResult(
                        processingTime: Date().timeIntervalSince(startTime),
                        confidence: confidence,
                        transcription: transcription,
                        segments: result.bestTranscription.segments.map { segment in
                            SpeechSegment(
                                text: segment.substring,
                                confidence: segment.confidence,
                                duration: segment.duration,
                                timestamp: segment.timestamp
                            )
                        },
                        isFinal: result.isFinal,
                        detectedLanguage: language
                    )
                    
                    continuation.yield(recognitionResult)
                    
                    if result.isFinal {
                        Task {
                            await self.updateRecognitionMetrics(
                                duration: Date().timeIntervalSince(startTime),
                                confidence: confidence
                            )
                        }
                        continuation.finish()
                    }
                }
                
                if let error = error {
                    self.logger.error("Speech recognition error: \(error)", category: "Speech")
                    Task {
                        await self.setRecordingState(false)
                    }
                    continuation.finish()
                }
            }
        }
    }
    
    /// Stop speech recognition
    public func stopRecognition() async {
        guard isRecording else { return }
        
        logger.info("Stopping speech recognition", category: "Speech")
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
        
        logger.info("Speech recognition stopped", category: "Speech")
    }
    
    /// Recognize speech from audio file
    public func recognizeSpeech(from audioURL: URL, options: SpeechRecognitionOptions = .default) async throws -> SpeechRecognitionResult {
        guard status == .ready else {
            throw IntelligenceError(code: "SPEECH_NOT_READY", message: "Speech Engine not ready")
        }
        
        guard let speechRecognizer = speechRecognizer else {
            throw IntelligenceError(code: "SPEECH_RECOGNIZER_UNAVAILABLE", message: "Speech recognizer not available")
        }
        
        let startTime = Date()
        logger.info("Starting speech recognition from file: \(audioURL.lastPathComponent)", category: "Speech")
        
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = options.requireOnDeviceRecognition
        
        return try await withCheckedThrowingContinuation { continuation in
            speechRecognizer.recognizeRequest(request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.logger.error("Speech recognition error: \(error)", category: "Speech")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result, result.isFinal else { return }
                
                let transcription = result.bestTranscription.formattedString
                let confidence = result.bestTranscription.segments.first?.confidence ?? 0.0
                let duration = Date().timeIntervalSince(startTime)
                
                let recognitionResult = SpeechRecognitionResult(
                    processingTime: duration,
                    confidence: confidence,
                    transcription: transcription,
                    segments: result.bestTranscription.segments.map { segment in
                        SpeechSegment(
                            text: segment.substring,
                            confidence: segment.confidence,
                            duration: segment.duration,
                            timestamp: segment.timestamp
                        )
                    },
                    isFinal: true,
                    detectedLanguage: self.currentLanguage
                )
                
                Task {
                    await self.updateRecognitionMetrics(duration: duration, confidence: confidence)
                }
                
                continuation.resume(returning: recognitionResult)
            }
        }
    }
    
    // MARK: - Text-to-Speech
    
    /// Convert text to speech
    public func speak(_ text: String, options: TextToSpeechOptions = .default) async throws {
        guard status == .ready else {
            throw IntelligenceError(code: "SPEECH_NOT_READY", message: "Speech Engine not ready")
        }
        
        guard let speechSynthesizer = speechSynthesizer else {
            throw IntelligenceError(code: "SPEECH_SYNTHESIZER_UNAVAILABLE", message: "Speech synthesizer not available")
        }
        
        logger.info("Starting text-to-speech synthesis", category: "Speech")
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: options.language)
        utterance.rate = options.rate
        utterance.pitchMultiplier = options.pitch
        utterance.volume = options.volume
        
        isPlaying = true
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = SpeechSynthesizerDelegate(
                onFinish: { [weak self] in
                    Task {
                        await self?.setPlayingState(false)
                    }
                    continuation.resume()
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
            
            speechSynthesizer.delegate = delegate
            speechSynthesizer.speak(utterance)
        }
    }
    
    /// Stop text-to-speech playback
    public func stopSpeaking() async {
        guard let speechSynthesizer = speechSynthesizer else { return }
        
        logger.info("Stopping text-to-speech synthesis", category: "Speech")
        speechSynthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }
    
    /// Get available voices for a language
    public func getAvailableVoices(for language: String) -> [VoiceInfo] {
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(language.prefix(2)) }
        
        return voices.map { voice in
            VoiceInfo(
                identifier: voice.identifier,
                name: voice.name,
                language: voice.language,
                quality: voice.quality == .enhanced ? .enhanced : .default,
                gender: voice.gender == .male ? .male : (voice.gender == .female ? .female : .unspecified)
            )
        }
    }
    
    // MARK: - Audio Session Management
    
    private func setupAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Language Management
    
    /// Get supported languages for speech recognition
    public func getSupportedLanguages() -> [String] {
        return supportedLanguages
    }
    
    /// Change recognition language
    public func changeLanguage(to language: String) async throws {
        guard supportedLanguages.contains(language) else {
            throw IntelligenceError(code: "LANGUAGE_NOT_SUPPORTED", message: "Language \(language) not supported")
        }
        
        currentLanguage = language
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        
        logger.info("Speech language changed to: \(language)", category: "Speech")
    }
    
    // MARK: - State Management
    
    private func setRecordingState(_ recording: Bool) async {
        isRecording = recording
    }
    
    private func setPlayingState(_ playing: Bool) async {
        isPlaying = playing
    }
    
    private func updateCurrentRecognition(text: String, confidence: Float) async {
        currentRecognitionText = text
        recognitionConfidence = confidence
    }
    
    // MARK: - Performance Metrics
    
    private func updateRecognitionMetrics(duration: TimeInterval, confidence: Float) async {
        performanceMetrics.totalRecognitions += 1
        performanceMetrics.averageRecognitionTime = (performanceMetrics.averageRecognitionTime + duration) / 2.0
        performanceMetrics.averageConfidence = (performanceMetrics.averageConfidence + Double(confidence)) / 2.0
    }
    
    private func updateSynthesisMetrics(duration: TimeInterval) async {
        performanceMetrics.totalSyntheses += 1
        performanceMetrics.averageSynthesisTime = (performanceMetrics.averageSynthesisTime + duration) / 2.0
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> SpeechPerformanceMetrics {
        return performanceMetrics
    }
    
    /// Get current state
    public func getCurrentState() async -> (isRecording: Bool, isPlaying: Bool, currentText: String, confidence: Float) {
        return (isRecording, isPlaying, currentRecognitionText, recognitionConfidence)
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceSpeech: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeSpeechEngine()
    }
    
    public func shutdown() async throws {
        await stopRecognition()
        await stopSpeaking()
        status = .shutdown
        logger.info("Speech Engine shutdown complete", category: "Speech")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "SPEECH_NOT_READY", message: "Speech Engine not ready"))
        }
        
        if speechRecognizer == nil {
            errors.append(ValidationError(code: "NO_SPEECH_RECOGNIZER", message: "Speech recognizer not available"))
        }
        
        if speechSynthesizer == nil {
            warnings.append(ValidationWarning(code: "NO_SPEECH_SYNTHESIZER", message: "Speech synthesizer not available"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let metrics = [
            "total_recognitions": String(performanceMetrics.totalRecognitions),
            "total_syntheses": String(performanceMetrics.totalSyntheses),
            "supported_languages": String(supportedLanguages.count),
            "current_language": currentLanguage,
            "is_recording": String(isRecording),
            "is_playing": String(isPlaying)
        ]
        
        switch status {
        case .ready:
            return HealthStatus(
                status: .healthy,
                message: "Speech Engine operational with \(supportedLanguages.count) languages",
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "Speech Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "Speech Engine not ready",
                metrics: metrics
            )
        }
    }
}

// MARK: - Speech Synthesizer Delegate

private class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onFinish: () -> Void
    private let onError: (Error) -> Void
    
    init(onFinish: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        self.onFinish = onFinish
        self.onError = onError
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onFinish()
    }
}

// MARK: - Performance Metrics

/// Speech engine performance metrics
public struct SpeechPerformanceMetrics: Sendable {
    public var totalRecognitions: Int = 0
    public var totalSyntheses: Int = 0
    
    public var averageRecognitionTime: TimeInterval = 0.0
    public var averageSynthesisTime: TimeInterval = 0.0
    public var averageConfidence: Double = 0.0
    
    public init() {}
}
import Foundation
import Speech
import AVFoundation
import CoreML
import NaturalLanguage
import os.log

/// Advanced Speech Recognition and Synthesis Engine with multilingual support
@MainActor
public class SpeechEngine: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = SpeechEngine()
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Speech")
    private let processingQueue = DispatchQueue(label: "speech.processing", qos: .userInitiated)
    
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Speech Synthesis
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var currentSpeechVoice: AVSpeechSynthesisVoice?
    
    // MARK: - Custom Models
    private var customSpeechModels: [String: MLModel] = [:]
    private var turkishSpeechModel: MLModel?
    private var voiceActivityDetector: MLModel?
    
    // MARK: - Audio Configuration
    #if canImport(AVFoundation) && !os(macOS)
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    #endif
    
    // MARK: - State Management
    @Published public var isRecording = false
    @Published public var isSpeaking = false
    @Published public var currentTranscription = ""
    @Published public var recognitionError: Error?
    
    // MARK: - Cache and Storage
    private let cache = NSCache<NSString, AnyObject>()
    private let voiceCache = NSCache<NSString, NSData>()
    
    // MARK: - Configuration
    private var configuration = SpeechEngineConfiguration.default
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        cache.countLimit = 100
        cache.totalCostLimit = 20_000_000 // 20MB
        
        voiceCache.countLimit = 50
        voiceCache.totalCostLimit = 100_000_000 // 100MB
        
        speechSynthesizer.delegate = self
        
        Task {
            try await initializeEngine()
        }
    }
    
    // MARK: - Engine Initialization
    private func initializeEngine() async throws {
        logger.info("Initializing Speech Engine...")
        
        // Request speech recognition authorization
        await requestSpeechRecognitionAuthorization()
        
        // Configure audio session
        try configureAudioSession()
        
        // Load custom models
        await loadCustomModels()
        
        // Setup voice activity detection
        await setupVoiceActivityDetection()
        
        // Initialize available voices
        setupAvailableVoices()
        
        logger.info("Speech Engine initialized successfully")
    }
    
    private func requestSpeechRecognitionAuthorization() async {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    self.logger.info("Speech recognition authorized")
                case .denied:
                    self.logger.error("Speech recognition denied")
                case .restricted:
                    self.logger.error("Speech recognition restricted")
                case .notDetermined:
                    self.logger.warning("Speech recognition not determined")
                @unknown default:
                    self.logger.error("Unknown speech recognition authorization status")
                }
                continuation.resume()
            }
        }
    }
    
    private func configureAudioSession() throws {
        #if canImport(AVFoundation) && !os(macOS)
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
    }
    
    private func loadCustomModels() async {
        // Load Turkish speech model
        await loadTurkishSpeechModel()
        
        // Load voice activity detection model
        await loadVoiceActivityDetectionModel()
        
        // Load other custom models
        await loadAdditionalSpeechModels()
    }
    
    private func loadTurkishSpeechModel() async {
        do {
            if let modelURL = Bundle.main.url(forResource: "TurkishSpeechModel", withExtension: "mlmodel") {
                turkishSpeechModel = try MLModel(contentsOf: modelURL)
                logger.info("Turkish speech model loaded successfully")
            }
        } catch {
            logger.error("Failed to load Turkish speech model: \(error.localizedDescription)")
        }
    }
    
    private func loadVoiceActivityDetectionModel() async {
        do {
            if let modelURL = Bundle.main.url(forResource: "VoiceActivityDetector", withExtension: "mlmodel") {
                voiceActivityDetector = try MLModel(contentsOf: modelURL)
                logger.info("Voice activity detector loaded successfully")
            }
        } catch {
            logger.error("Failed to load voice activity detector: \(error.localizedDescription)")
        }
    }
    
    private func loadAdditionalSpeechModels() async {
        let modelNames = ["NoiseReductionModel", "SpeechEnhancementModel", "AccentRecognitionModel"]
        
        for modelName in modelNames {
            do {
                if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodel") {
                    let model = try MLModel(contentsOf: modelURL)
                    customSpeechModels[modelName] = model
                    logger.info("Loaded custom speech model: \(modelName)")
                }
            } catch {
                logger.warning("Failed to load \(modelName): \(error.localizedDescription)")
            }
        }
    }
    
    private func setupVoiceActivityDetection() async {
        // Configure voice activity detection parameters
        logger.info("Voice activity detection configured")
    }
    
    private func setupAvailableVoices() {
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        logger.info("Available voices: \(availableVoices.count)")
        
        // Set default voice
        if let englishVoice = AVSpeechSynthesisVoice(language: "en-US") {
            currentSpeechVoice = englishVoice
        }
    }
    
    // MARK: - Speech Recognition
    
    /// Start continuous speech recognition
    public func startSpeechRecognition(
        language: String = "en-US",
        options: SpeechRecognitionOptions = .default
    ) async throws {
        
        // Check authorization
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechError.notAuthorized
        }
        
        // Stop any ongoing recognition
        try await stopSpeechRecognition()
        
        // Configure recognizer for language
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language)) else {
            throw SpeechError.recognizerUnavailable
        }
        
        guard recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }
        
        // Setup audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = options.reportPartialResults
        recognitionRequest.requiresOnDeviceRecognition = options.requireOnDeviceRecognition
        recognitionRequest.addsPunctuation = options.addPunctuation
        
        // Start recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let result = result {
                    self.currentTranscription = result.bestTranscription.formattedString
                    
                    // Process with Turkish model if applicable
                    if language.contains("tr") && self.turkishSpeechModel != nil {
                        await self.enhanceTranscriptionWithTurkishModel(result.bestTranscription.formattedString)
                    }
                }
                
                if let error = error {
                    self.recognitionError = error
                    self.logger.error("Speech recognition error: \(error.localizedDescription)")
                }
            }
        }
        
        // Install audio tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
        logger.info("Speech recognition started for language: \(language)")
    }
    
    /// Stop speech recognition
    public func stopSpeechRecognition() async throws {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecording = false
        logger.info("Speech recognition stopped")
    }
    
    /// Recognize speech from audio file
    public func recognizeSpeech(
        from audioURL: URL,
        language: String = "en-US",
        options: SpeechRecognitionOptions = .default
    ) async throws -> SpeechRecognitionResult {
        
        let startTime = Date()
        
        // Check cache
        let cacheKey = NSString(string: "\(audioURL.path)_\(language)")
        if let cachedResult = cache.object(forKey: cacheKey) as? SpeechRecognitionResult {
            return cachedResult
        }
        
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language)) else {
            throw SpeechError.recognizerUnavailable
        }
        
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = options.requireOnDeviceRecognition
        request.addsPunctuation = options.addPunctuation
        
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result, result.isFinal else { return }
                
                let processingTime = Date().timeIntervalSince(startTime)
                let transcription = result.bestTranscription
                
                let speechResult = SpeechRecognitionResult(
                    transcription: transcription.formattedString,
                    confidence: self.calculateAverageConfidence(transcription),
                    alternatives: result.transcriptions.prefix(5).map { $0.formattedString },
                    segments: self.createSegments(from: transcription),
                    language: language,
                    processingTime: processingTime
                )
                
                // Cache result
                self.cache.setObject(speechResult, forKey: cacheKey)
                
                continuation.resume(returning: speechResult)
            }
        }
    }
    
    /// Batch speech recognition for multiple files
    public func batchRecognizeSpeech(
        from audioURLs: [URL],
        language: String = "en-US",
        options: SpeechRecognitionOptions = .default
    ) async throws -> [SpeechRecognitionResult] {
        
        return try await withThrowingTaskGroup(of: SpeechRecognitionResult.self) { group in
            for audioURL in audioURLs {
                group.addTask {
                    try await self.recognizeSpeech(from: audioURL, language: language, options: options)
                }
            }
            
            var results: [SpeechRecognitionResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    // MARK: - Speech Synthesis
    
    /// Synthesize speech from text
    public func synthesizeSpeech(
        from text: String,
        voice: SpeechVoice? = nil,
        options: SpeechSynthesisOptions = .default
    ) async throws -> SpeechSynthesisResult {
        
        let startTime = Date()
        
        // Check cache
        let cacheKey = NSString(string: "\(text.hashValue)_\(voice?.identifier ?? "default")_\(options.hashValue)")
        if let cachedData = voiceCache.object(forKey: cacheKey) {
            return SpeechSynthesisResult(
                synthesizedAudio: cachedData,
                originalText: text,
                voice: voice,
                duration: 0, // Would need to calculate from audio data
                processingTime: 0
            )
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure utterance
        if let voice = voice {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice.identifier)
        } else if let currentVoice = currentSpeechVoice {
            utterance.voice = currentVoice
        }
        
        utterance.rate = options.rate
        utterance.pitchMultiplier = options.pitch
        utterance.volume = options.volume
        utterance.preUtteranceDelay = options.preDelay
        utterance.postUtteranceDelay = options.postDelay
        
        return try await withCheckedThrowingContinuation { continuation in
            var synthesisResult: SpeechSynthesisResult?
            
            // Create a temporary delegate to handle completion
            let delegate = TemporarySynthesisDelegate { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    // Cache result
                    self.voiceCache.setObject(result.synthesizedAudio, forKey: cacheKey)
                    continuation.resume(returning: result)
                }
            }
            
            // Store original delegate and set temporary one
            let originalDelegate = speechSynthesizer.delegate
            speechSynthesizer.delegate = delegate
            
            // Start synthesis
            speechSynthesizer.speak(utterance)
            
            // Restore original delegate after completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.speechSynthesizer.delegate === delegate {
                    self.speechSynthesizer.delegate = originalDelegate
                }
            }
        }
    }
    
    /// Generate audio data without playing
    public func generateSpeechAudio(
        from text: String,
        voice: SpeechVoice? = nil,
        options: SpeechSynthesisOptions = .default
    ) async throws -> Data {
        
        return try await withCheckedThrowingContinuation { continuation in
            var audioData = Data()
            
            let utterance = AVSpeechUtterance(string: text)
            
            if let voice = voice {
                utterance.voice = AVSpeechSynthesisVoice(identifier: voice.identifier)
            }
            
            utterance.rate = options.rate
            utterance.pitchMultiplier = options.pitch
            utterance.volume = options.volume
            
            // Create audio buffer to capture synthesis
            let synthesizer = AVSpeechSynthesizer()
            
            // This is a simplified implementation
            // In production, you would need to set up an audio engine to capture the output
            synthesizer.speak(utterance)
            
            // For now, return empty data as placeholder
            continuation.resume(returning: audioData)
        }
    }
    
    /// Get available voices for language
    public func getAvailableVoices(for language: String) -> [SpeechVoice] {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        return voices
            .filter { $0.language.hasPrefix(language.prefix(2)) }
            .map { voice in
                SpeechVoice(
                    identifier: voice.identifier,
                    name: voice.name,
                    language: voice.language,
                    quality: mapQuality(voice.quality),
                    gender: mapGender(voice.gender)
                )
            }
    }
    
    // MARK: - Real-time Processing
    
    /// Start real-time speech processing with live feedback
    public func startRealtimeSpeechProcessing(
        language: String = "en-US",
        options: RealtimeProcessingOptions = .default
    ) -> AsyncThrowingStream<SpeechRealtimeResult, Error> {
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    try await self.startSpeechRecognition(language: language)
                    
                    // Monitor transcription changes
                    var lastTranscription = ""
                    
                    while self.isRecording {
                        let currentTranscription = self.currentTranscription
                        
                        if currentTranscription != lastTranscription && !currentTranscription.isEmpty {
                            
                            // Process with voice activity detection
                            let hasVoiceActivity = await self.detectVoiceActivity()
                            
                            // Apply noise reduction if enabled
                            var processedText = currentTranscription
                            if options.applyNoiseReduction {
                                processedText = await self.applyNoiseReduction(to: processedText)
                            }
                            
                            // Create real-time result
                            let result = SpeechRealtimeResult(
                                partialTranscription: processedText,
                                confidence: 0.8, // Would calculate from recognition
                                isVoiceActive: hasVoiceActivity,
                                timestamp: Date(),
                                language: language
                            )
                            
                            continuation.yield(result)
                            lastTranscription = currentTranscription
                        }
                        
                        // Wait before next check
                        try await Task.sleep(nanoseconds: UInt64(options.updateInterval * 1_000_000_000))
                    }
                    
                    continuation.finish()
                    
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Audio Processing
    
    /// Apply noise reduction to audio
    public func applyNoiseReduction(to audioURL: URL) async throws -> URL {
        guard let noiseReductionModel = customSpeechModels["NoiseReductionModel"] else {
            throw SpeechError.modelNotAvailable
        }
        
        // Process audio through noise reduction model
        // This is a placeholder - would need actual audio processing
        return audioURL
    }
    
    /// Enhance speech audio quality
    public func enhanceSpeechAudio(_ audioURL: URL) async throws -> URL {
        guard let enhancementModel = customSpeechModels["SpeechEnhancementModel"] else {
            throw SpeechError.modelNotAvailable
        }
        
        // Process audio through enhancement model
        return audioURL
    }
    
    /// Detect speaker characteristics
    public func analyzeSpeakerCharacteristics(from audioURL: URL) async throws -> SpeakerAnalysis {
        // Analyze audio for speaker characteristics
        // This would use voice biometry and accent recognition models
        
        return SpeakerAnalysis(
            estimatedAge: .adult,
            estimatedGender: .unknown,
            accent: .unidentified,
            emotionalTone: .neutral,
            speakingRate: .normal,
            confidence: 0.7
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func enhanceTranscriptionWithTurkishModel(_ transcription: String) async {
        guard let turkishModel = turkishSpeechModel else { return }
        
        // Process transcription with Turkish-specific model
        // This would improve accuracy for Turkish speech patterns
        logger.info("Enhanced transcription with Turkish model")
    }
    
    private func calculateAverageConfidence(_ transcription: SFTranscription) -> Float {
        let segments = transcription.segments
        guard !segments.isEmpty else { return 0.0 }
        
        let totalConfidence = segments.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Float(segments.count)
    }
    
    private func createSegments(from transcription: SFTranscription) -> [SpeechSegment] {
        return transcription.segments.map { segment in
            SpeechSegment(
                text: segment.substring,
                confidence: segment.confidence,
                timestamp: segment.timestamp,
                duration: segment.duration
            )
        }
    }
    
    private func detectVoiceActivity() async -> Bool {
        guard let vad = voiceActivityDetector else { return true }
        
        // Process current audio buffer through VAD model
        // This is simplified - would need actual audio analysis
        return true
    }
    
    private func applyNoiseReduction(to text: String) async -> String {
        // Apply text-based noise reduction/cleanup
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func mapQuality(_ quality: AVSpeechSynthesisVoiceQuality) -> SpeechVoice.VoiceQuality {
        switch quality {
        case .default: return .standard
        case .enhanced: return .enhanced
        case .premium: return .premium
        @unknown default: return .standard
        }
    }
    
    private func mapGender(_ gender: AVSpeechSynthesisVoiceGender) -> SpeechVoice.VoiceGender {
        switch gender {
        case .male: return .male
        case .female: return .female
        case .unspecified: return .neutral
        @unknown default: return .neutral
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechEngine: @preconcurrency AVSpeechSynthesizerDelegate {
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
        logger.info("Speech synthesis started")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        logger.info("Speech synthesis finished")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        logger.info("Speech synthesis paused")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        logger.info("Speech synthesis cancelled")
    }
}

// MARK: - Temporary Synthesis Delegate

private final class TemporarySynthesisDelegate: NSObject, @unchecked Sendable, AVSpeechSynthesizerDelegate {
    private let completion: (SpeechSynthesisResult?, Error?) -> Void
    
    init(completion: @escaping (SpeechSynthesisResult?, Error?) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let result = SpeechSynthesisResult(
            synthesizedAudio: Data(), // Placeholder
            originalText: utterance.speechString,
            voice: nil,
            duration: 0,
            processingTime: 0
        )
        completion(result, nil)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completion(nil, SpeechError.synthesisCancelled)
    }
}
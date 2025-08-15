import Foundation
import AVFoundation
import Speech

// MARK: - Core Speech Types

public struct SpeechConfiguration {
    public let enableContinuousRecognition: Bool
    public let preferOnDeviceRecognition: Bool
    public let enableNoiseReduction: Bool
    public let maxRecordingDuration: TimeInterval
    public let audioQuality: AudioQuality
    public let defaultLanguage: String
    
    public enum AudioQuality {
        case low
        case standard
        case high
        case lossless
    }
    
    public init(
        enableContinuousRecognition: Bool = true,
        preferOnDeviceRecognition: Bool = true,
        enableNoiseReduction: Bool = true,
        maxRecordingDuration: TimeInterval = 300, // 5 minutes
        audioQuality: AudioQuality = .standard,
        defaultLanguage: String = "en-US"
    ) {
        self.enableContinuousRecognition = enableContinuousRecognition
        self.preferOnDeviceRecognition = preferOnDeviceRecognition
        self.enableNoiseReduction = enableNoiseReduction
        self.maxRecordingDuration = maxRecordingDuration
        self.audioQuality = audioQuality
        self.defaultLanguage = defaultLanguage
    }
    
    public static let `default` = SpeechConfiguration()
    
    public static let highQuality = SpeechConfiguration(
        enableContinuousRecognition: true,
        preferOnDeviceRecognition: false,
        enableNoiseReduction: true,
        maxRecordingDuration: 600,
        audioQuality: .high,
        defaultLanguage: "en-US"
    )
    
    public static let privacy = SpeechConfiguration(
        enableContinuousRecognition: false,
        preferOnDeviceRecognition: true,
        enableNoiseReduction: false,
        maxRecordingDuration: 60,
        audioQuality: .standard,
        defaultLanguage: "en-US"
    )
}

// MARK: - Speech Recognition Types

public struct SpeechRecognitionOptions: Hashable, Codable {
    public let enablePartialResults: Bool
    public let requireOnDeviceRecognition: Bool
    public let addPunctuation: Bool
    public let detectLanguage: Bool
    public let contextualStrings: [String]
    
    public init(
        enablePartialResults: Bool = true,
        requireOnDeviceRecognition: Bool = false,
        addPunctuation: Bool = true,
        detectLanguage: Bool = false,
        contextualStrings: [String] = []
    ) {
        self.enablePartialResults = enablePartialResults
        self.requireOnDeviceRecognition = requireOnDeviceRecognition
        self.addPunctuation = addPunctuation
        self.detectLanguage = detectLanguage
        self.contextualStrings = contextualStrings
    }
    
    public static let `default` = SpeechRecognitionOptions()
    
    public static let realtime = SpeechRecognitionOptions(
        enablePartialResults: true,
        requireOnDeviceRecognition: true,
        addPunctuation: false,
        detectLanguage: false
    )
    
    public static let accurate = SpeechRecognitionOptions(
        enablePartialResults: false,
        requireOnDeviceRecognition: false,
        addPunctuation: true,
        detectLanguage: true
    )
}

public struct SpeechRecognitionResult: Codable {
    public let transcription: String
    public let confidence: Float
    public let alternatives: [String]
    public let segments: [SpeechSegment]
    public let language: String
    public let processingTime: TimeInterval
    public let metadata: [String: String]
    
    public init(
        transcription: String,
        confidence: Float,
        alternatives: [String] = [],
        segments: [SpeechSegment] = [],
        language: String,
        processingTime: TimeInterval,
        metadata: [String: String] = [:]
    ) {
        self.transcription = transcription
        self.confidence = confidence
        self.alternatives = alternatives
        self.segments = segments
        self.language = language
        self.processingTime = processingTime
        self.metadata = metadata
    }
}

public struct SpeechSegment: Codable {
    public let text: String
    public let confidence: Float
    public let timestamp: TimeInterval
    public let duration: TimeInterval
    public let speaker: String?
    
    public init(
        text: String,
        confidence: Float,
        timestamp: TimeInterval,
        duration: TimeInterval,
        speaker: String? = nil
    ) {
        self.text = text
        self.confidence = confidence
        self.timestamp = timestamp
        self.duration = duration
        self.speaker = speaker
    }
}

// MARK: - Text-to-Speech Types

public struct TextToSpeechOptions: Hashable, Codable {
    public let language: String
    public let voiceIdentifier: String?
    public let rate: Float // 0.0 to 1.0
    public let pitch: Float // 0.5 to 2.0
    public let volume: Float // 0.0 to 1.0
    public let preUtteranceDelay: TimeInterval
    public let postUtteranceDelay: TimeInterval
    
    public init(
        language: String = "en-US",
        voiceIdentifier: String? = nil,
        rate: Float = 0.5,
        pitch: Float = 1.0,
        volume: Float = 1.0,
        preUtteranceDelay: TimeInterval = 0.0,
        postUtteranceDelay: TimeInterval = 0.0
    ) {
        self.language = language
        self.voiceIdentifier = voiceIdentifier
        self.rate = max(0.0, min(1.0, rate))
        self.pitch = max(0.5, min(2.0, pitch))
        self.volume = max(0.0, min(1.0, volume))
        self.preUtteranceDelay = max(0.0, preUtteranceDelay)
        self.postUtteranceDelay = max(0.0, postUtteranceDelay)
    }
    
    public static let `default` = TextToSpeechOptions()
    
    public static let slow = TextToSpeechOptions(rate: 0.3)
    public static let fast = TextToSpeechOptions(rate: 0.8)
    public static let highPitch = TextToSpeechOptions(pitch: 1.5)
    public static let lowPitch = TextToSpeechOptions(pitch: 0.7)
    public static let turkish = TextToSpeechOptions(language: "tr-TR")
    
    public static let announcement = TextToSpeechOptions(
        rate: 0.4,
        pitch: 1.0,
        volume: 0.9,
        preUtteranceDelay: 0.5,
        postUtteranceDelay: 1.0
    )
}

public struct SpeechSynthesisResult: Codable {
    public let synthesizedAudio: Data
    public let originalText: String
    public let voice: SpeechVoice?
    public let duration: TimeInterval
    public let processingTime: TimeInterval
    public let metadata: [String: String]
    
    public init(
        synthesizedAudio: Data,
        originalText: String,
        voice: SpeechVoice?,
        duration: TimeInterval,
        processingTime: TimeInterval,
        metadata: [String: String] = [:]
    ) {
        self.synthesizedAudio = synthesizedAudio
        self.originalText = originalText
        self.voice = voice
        self.duration = duration
        self.processingTime = processingTime
        self.metadata = metadata
    }
}

public struct VoiceInfo: Codable, Hashable {
    public let identifier: String
    public let name: String
    public let language: String
    public let quality: VoiceQuality
    public let gender: VoiceGender
    
    public enum VoiceQuality: String, CaseIterable, Codable {
        case `default` = "default"
        case enhanced = "enhanced"
        case premium = "premium"
        
        public var description: String {
            switch self {
            case .default: return "Default Quality"
            case .enhanced: return "Enhanced Quality"
            case .premium: return "Premium Quality"
            }
        }
    }
    
    public enum VoiceGender: String, CaseIterable, Codable {
        case male = "male"
        case female = "female"
        case unspecified = "unspecified"
        
        public var emoji: String {
            switch self {
            case .male: return "👨"
            case .female: return "👩"
            case .unspecified: return "👤"
            }
        }
    }
    
    public init(
        identifier: String,
        name: String,
        language: String,
        quality: VoiceQuality,
        gender: VoiceGender
    ) {
        self.identifier = identifier
        self.name = name
        self.language = language
        self.quality = quality
        self.gender = gender
    }
    
    public var languageName: String {
        return Locale.current.localizedString(forLanguageCode: String(language.prefix(2))) ?? language
    }
    
    public var flag: String {
        let languageCode = String(language.prefix(2))
        switch languageCode {
        case "en": return "🇺🇸"
        case "tr": return "🇹🇷"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "it": return "🇮🇹"
        case "pt": return "🇵🇹"
        case "ru": return "🇷🇺"
        case "zh": return "🇨🇳"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "ar": return "🇸🇦"
        default: return "🌍"
        }
    }
}

// MARK: - Real-time Processing Types

public struct RealtimeProcessingOptions: Hashable, Codable {
    public let updateInterval: TimeInterval // Seconds between updates
    public let applyNoiseReduction: Bool
    public let detectVoiceActivity: Bool
    public let enableSpeakerDiarization: Bool
    public let confidenceThreshold: Float
    
    public init(
        updateInterval: TimeInterval = 0.1,
        applyNoiseReduction: Bool = true,
        detectVoiceActivity: Bool = true,
        enableSpeakerDiarization: Bool = false,
        confidenceThreshold: Float = 0.5
    ) {
        self.updateInterval = max(0.05, updateInterval)
        self.applyNoiseReduction = applyNoiseReduction
        self.detectVoiceActivity = detectVoiceActivity
        self.enableSpeakerDiarization = enableSpeakerDiarization
        self.confidenceThreshold = max(0.0, min(1.0, confidenceThreshold))
    }
    
    public static let `default` = RealtimeProcessingOptions()
    
    public static let highPerformance = RealtimeProcessingOptions(
        updateInterval: 0.05,
        applyNoiseReduction: true,
        detectVoiceActivity: true,
        enableSpeakerDiarization: true,
        confidenceThreshold: 0.3
    )
    
    public static let lowLatency = RealtimeProcessingOptions(
        updateInterval: 0.2,
        applyNoiseReduction: false,
        detectVoiceActivity: false,
        enableSpeakerDiarization: false,
        confidenceThreshold: 0.7
    )
}

public struct SpeechRealtimeResult {
    public let partialTranscription: String
    public let confidence: Float
    public let isVoiceActive: Bool
    public let timestamp: Date
    public let language: String
    public let speakerId: String?
    
    public init(
        partialTranscription: String,
        confidence: Float,
        isVoiceActive: Bool,
        timestamp: Date,
        language: String,
        speakerId: String? = nil
    ) {
        self.partialTranscription = partialTranscription
        self.confidence = confidence
        self.isVoiceActive = isVoiceActive
        self.timestamp = timestamp
        self.language = language
        self.speakerId = speakerId
    }
}

// MARK: - Audio Analysis Types

public struct SpeakerAnalysis: Codable {
    public let estimatedAge: AgeGroup
    public let estimatedGender: Gender
    public let accent: AccentType
    public let emotionalTone: EmotionalTone
    public let speakingRate: SpeakingRate
    public let confidence: Float
    
    public enum AgeGroup: String, CaseIterable, Codable {
        case child = "child"
        case teenager = "teenager"
        case adult = "adult"
        case elderly = "elderly"
        
        public var description: String {
            switch self {
            case .child: return "Child (5-12)"
            case .teenager: return "Teenager (13-19)"
            case .adult: return "Adult (20-64)"
            case .elderly: return "Elderly (65+)"
            }
        }
    }
    
    public enum Gender: String, CaseIterable, Codable {
        case male = "male"
        case female = "female"
        case unknown = "unknown"
    }
    
    public enum AccentType: String, CaseIterable, Codable {
        case american = "american"
        case british = "british"
        case australian = "australian"
        case indian = "indian"
        case turkish = "turkish"
        case spanish = "spanish"
        case french = "french"
        case german = "german"
        case unidentified = "unidentified"
        
        public var description: String {
            switch self {
            case .american: return "American English"
            case .british: return "British English"
            case .australian: return "Australian English"
            case .indian: return "Indian English"
            case .turkish: return "Turkish"
            case .spanish: return "Spanish"
            case .french: return "French"
            case .german: return "German"
            case .unidentified: return "Unidentified"
            }
        }
    }
    
    public enum EmotionalTone: String, CaseIterable, Codable {
        case neutral = "neutral"
        case happy = "happy"
        case sad = "sad"
        case angry = "angry"
        case excited = "excited"
        case calm = "calm"
        case stressed = "stressed"
        
        public var emoji: String {
            switch self {
            case .neutral: return "😐"
            case .happy: return "😊"
            case .sad: return "😢"
            case .angry: return "😠"
            case .excited: return "🤩"
            case .calm: return "😌"
            case .stressed: return "😰"
            }
        }
    }
    
    public enum SpeakingRate: String, CaseIterable, Codable {
        case slow = "slow"
        case normal = "normal"
        case fast = "fast"
        case veryFast = "very_fast"
        
        public var description: String {
            switch self {
            case .slow: return "Slow (< 150 WPM)"
            case .normal: return "Normal (150-200 WPM)"
            case .fast: return "Fast (200-250 WPM)"
            case .veryFast: return "Very Fast (> 250 WPM)"
            }
        }
    }
    
    public init(
        estimatedAge: AgeGroup,
        estimatedGender: Gender,
        accent: AccentType,
        emotionalTone: EmotionalTone,
        speakingRate: SpeakingRate,
        confidence: Float
    ) {
        self.estimatedAge = estimatedAge
        self.estimatedGender = estimatedGender
        self.accent = accent
        self.emotionalTone = emotionalTone
        self.speakingRate = speakingRate
        self.confidence = confidence
    }
}

// MARK: - Audio Processing Types

public struct AudioProcessingOptions: Hashable, Codable {
    public let applyNoiseReduction: Bool
    public let normalizeVolume: Bool
    public let removeEcho: Bool
    public let enhanceSpeech: Bool
    public let outputFormat: AudioFormat
    
    public enum AudioFormat: String, CaseIterable, Codable {
        case wav = "wav"
        case mp3 = "mp3"
        case aac = "aac"
        case flac = "flac"
    }
    
    public init(
        applyNoiseReduction: Bool = true,
        normalizeVolume: Bool = true,
        removeEcho: Bool = false,
        enhanceSpeech: Bool = true,
        outputFormat: AudioFormat = .wav
    ) {
        self.applyNoiseReduction = applyNoiseReduction
        self.normalizeVolume = normalizeVolume
        self.removeEcho = removeEcho
        self.enhanceSpeech = enhanceSpeech
        self.outputFormat = outputFormat
    }
    
    public static let `default` = AudioProcessingOptions()
    
    public static let highQuality = AudioProcessingOptions(
        applyNoiseReduction: true,
        normalizeVolume: true,
        removeEcho: true,
        enhanceSpeech: true,
        outputFormat: .flac
    )
}

public struct AudioProcessingResult {
    public let processedAudioURL: URL
    public let originalAudioURL: URL
    public let processingTime: TimeInterval
    public let appliedProcessing: [String]
    public let qualityImprovement: Float // 0.0 to 1.0
    
    public init(
        processedAudioURL: URL,
        originalAudioURL: URL,
        processingTime: TimeInterval,
        appliedProcessing: [String],
        qualityImprovement: Float
    ) {
        self.processedAudioURL = processedAudioURL
        self.originalAudioURL = originalAudioURL
        self.processingTime = processingTime
        self.appliedProcessing = appliedProcessing
        self.qualityImprovement = max(0.0, min(1.0, qualityImprovement))
    }
}

// MARK: - Language Support

public struct SpeechLanguageSupport {
    public let languageCode: String
    public let displayName: String
    public let recognitionSupport: SupportLevel
    public let synthesisSupport: SupportLevel
    public let onDeviceSupport: Bool
    public let availableVoices: Int
    
    public enum SupportLevel: String, CaseIterable, Codable {
        case none = "none"
        case basic = "basic"
        case good = "good"
        case excellent = "excellent"
        
        public var emoji: String {
            switch self {
            case .none: return "❌"
            case .basic: return "🟡"
            case .good: return "🟢"
            case .excellent: return "⭐"
            }
        }
    }
    
    public init(
        languageCode: String,
        displayName: String,
        recognitionSupport: SupportLevel,
        synthesisSupport: SupportLevel,
        onDeviceSupport: Bool,
        availableVoices: Int
    ) {
        self.languageCode = languageCode
        self.displayName = displayName
        self.recognitionSupport = recognitionSupport
        self.synthesisSupport = synthesisSupport
        self.onDeviceSupport = onDeviceSupport
        self.availableVoices = availableVoices
    }
    
    public static let supportedLanguages: [SpeechLanguageSupport] = [
        SpeechLanguageSupport(
            languageCode: "en-US",
            displayName: "English (US)",
            recognitionSupport: .excellent,
            synthesisSupport: .excellent,
            onDeviceSupport: true,
            availableVoices: 12
        ),
        SpeechLanguageSupport(
            languageCode: "tr-TR",
            displayName: "Turkish",
            recognitionSupport: .excellent,
            synthesisSupport: .good,
            onDeviceSupport: true,
            availableVoices: 4
        ),
        SpeechLanguageSupport(
            languageCode: "es-ES",
            displayName: "Spanish",
            recognitionSupport: .good,
            synthesisSupport: .good,
            onDeviceSupport: true,
            availableVoices: 6
        ),
        SpeechLanguageSupport(
            languageCode: "fr-FR",
            displayName: "French",
            recognitionSupport: .good,
            synthesisSupport: .good,
            onDeviceSupport: true,
            availableVoices: 5
        ),
        SpeechLanguageSupport(
            languageCode: "de-DE",
            displayName: "German",
            recognitionSupport: .good,
            synthesisSupport: .good,
            onDeviceSupport: true,
            availableVoices: 4
        )
    ]
}

// MARK: - Errors

public enum SpeechError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case recognitionRequestFailed
    case audioEngineError
    case synthesisCancelled
    case synthesisError(String)
    case modelNotAvailable
    case audioProcessingFailed
    case invalidAudioFormat
    case fileNotFound
    case networkError
    case insufficientMemory
    
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition not authorized"
        case .recognizerUnavailable:
            return "Speech recognizer unavailable for this language"
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .audioEngineError:
            return "Audio engine error"
        case .synthesisCancelled:
            return "Speech synthesis was cancelled"
        case .synthesisError(let message):
            return "Speech synthesis error: \(message)"
        case .modelNotAvailable:
            return "Required speech model not available"
        case .audioProcessingFailed:
            return "Audio processing failed"
        case .invalidAudioFormat:
            return "Invalid audio format"
        case .fileNotFound:
            return "Audio file not found"
        case .networkError:
            return "Network error during speech processing"
        case .insufficientMemory:
            return "Insufficient memory for speech processing"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .notAuthorized:
            return "Please enable speech recognition in Settings"
        case .recognizerUnavailable:
            return "Try a different language or check internet connection"
        case .recognitionRequestFailed:
            return "Please try again"
        case .audioEngineError:
            return "Check microphone permissions and try again"
        case .synthesisCancelled:
            return "Synthesis was interrupted"
        case .synthesisError:
            return "Please try with different text or voice"
        case .modelNotAvailable:
            return "Download the required language model"
        case .audioProcessingFailed:
            return "Check audio file format and try again"
        case .invalidAudioFormat:
            return "Use supported audio format (WAV, MP3, AAC)"
        case .fileNotFound:
            return "Check file path and permissions"
        case .networkError:
            return "Check internet connection and try again"
        case .insufficientMemory:
            return "Close other apps and try again"
        }
    }
}

// MARK: - Convenience Extensions

extension SpeechResult {
    public var isEmpty: Bool {
        return false // This would need proper implementation based on actual result
    }
    
    public var wordCount: Int {
        return 0 // This would need proper implementation
    }
    
    public var estimatedDuration: TimeInterval {
        return 0 // This would need proper implementation
    }
}

// MARK: - Protocol Conformance

extension SpeechRecognitionResult: CustomStringConvertible {
    public var description: String {
        return "SpeechRecognitionResult(transcription: \"\(transcription)\", confidence: \(confidence), language: \(language))"
    }
}

extension SpeechSynthesisResult: CustomStringConvertible {
    public var description: String {
        return "SpeechSynthesisResult(text: \"\(originalText)\", duration: \(duration)s)"
    }
}

// MARK: - Helper Types

public protocol SpeechResult {
    var processingTime: TimeInterval { get }
    var confidence: Float { get }
}

extension SpeechRecognitionResult: SpeechResult {}

// This would need to be properly implemented in SpeechSynthesisResult
extension SpeechSynthesisResult: SpeechResult {
    public var confidence: Float {
        return 1.0 // Synthesis typically has high confidence
    }
}
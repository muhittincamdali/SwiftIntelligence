import Foundation
import AVFoundation
import Speech
import os.log

/// Advanced configuration system for Speech Recognition and Synthesis operations
public struct SpeechEngineConfiguration: Sendable {
    
    // MARK: - Recognition Settings
    public let recognitionSettings: RecognitionSettings
    public let synthesisSettings: SynthesisSettings
    public let audioSettings: AudioSettings
    public let performanceSettings: PerformanceSettings
    public let privacySettings: PrivacySettings
    
    public struct RecognitionSettings: Sendable {
        public let preferOnDevice: Bool
        public let enableContinuousRecognition: Bool
        public let reportPartialResults: Bool
        public let addPunctuation: Bool
        public let enableLanguageDetection: Bool
        public let maxRecordingDuration: TimeInterval
        public let contextualStrings: [String]
        public let confidenceThreshold: Float
        
        public init(
            preferOnDevice: Bool = true,
            enableContinuousRecognition: Bool = true,
            reportPartialResults: Bool = true,
            addPunctuation: Bool = true,
            enableLanguageDetection: Bool = false,
            maxRecordingDuration: TimeInterval = 300,
            contextualStrings: [String] = [],
            confidenceThreshold: Float = 0.5
        ) {
            self.preferOnDevice = preferOnDevice
            self.enableContinuousRecognition = enableContinuousRecognition
            self.reportPartialResults = reportPartialResults
            self.addPunctuation = addPunctuation
            self.enableLanguageDetection = enableLanguageDetection
            self.maxRecordingDuration = maxRecordingDuration
            self.contextualStrings = contextualStrings
            self.confidenceThreshold = max(0.0, min(1.0, confidenceThreshold))
        }
    }
    
    public struct SynthesisSettings: Sendable {
        public let preferHighQualityVoices: Bool
        public let enableVoiceEffects: Bool
        public let defaultRate: Float
        public let defaultPitch: Float
        public let defaultVolume: Float
        public let enableSSML: Bool
        public let maxTextLength: Int
        
        public init(
            preferHighQualityVoices: Bool = true,
            enableVoiceEffects: Bool = false,
            defaultRate: Float = 0.5,
            defaultPitch: Float = 1.0,
            defaultVolume: Float = 1.0,
            enableSSML: Bool = false,
            maxTextLength: Int = 10000
        ) {
            self.preferHighQualityVoices = preferHighQualityVoices
            self.enableVoiceEffects = enableVoiceEffects
            self.defaultRate = max(0.0, min(1.0, defaultRate))
            self.defaultPitch = max(0.5, min(2.0, defaultPitch))
            self.defaultVolume = max(0.0, min(1.0, defaultVolume))
            self.enableSSML = enableSSML
            self.maxTextLength = max(1, maxTextLength)
        }
    }
    
    public struct AudioSettings: Sendable {
        public let inputGain: Float
        public let outputGain: Float
        public let enableNoiseReduction: Bool
        public let enableEchoCancellation: Bool
        public let enableAutomaticGainControl: Bool
        public let sampleRate: Double
        public let bufferSize: Int
        public let audioFormat: AudioFormat
        
        public enum AudioFormat: String, CaseIterable, Sendable {
            case pcm16 = "pcm16"
            case pcm24 = "pcm24"
            case pcm32 = "pcm32"
            case float32 = "float32"
        }
        
        public init(
            inputGain: Float = 1.0,
            outputGain: Float = 1.0,
            enableNoiseReduction: Bool = true,
            enableEchoCancellation: Bool = true,
            enableAutomaticGainControl: Bool = true,
            sampleRate: Double = 44100.0,
            bufferSize: Int = 1024,
            audioFormat: AudioFormat = .pcm16
        ) {
            self.inputGain = max(0.0, min(2.0, inputGain))
            self.outputGain = max(0.0, min(2.0, outputGain))
            self.enableNoiseReduction = enableNoiseReduction
            self.enableEchoCancellation = enableEchoCancellation
            self.enableAutomaticGainControl = enableAutomaticGainControl
            self.sampleRate = sampleRate
            self.bufferSize = bufferSize
            self.audioFormat = audioFormat
        }
    }
    
    public struct PerformanceSettings: Sendable {
        public let maxConcurrentOperations: Int
        public let enableCaching: Bool
        public let cacheSize: Int
        public let enablePreloading: Bool
        public let processingQueue: ProcessingQueue
        public let memoryOptimization: Bool
        
        public enum ProcessingQueue: Sendable {
            case main
            case background
            case userInitiated
            case utility
        }
        
        public init(
            maxConcurrentOperations: Int = 3,
            enableCaching: Bool = true,
            cacheSize: Int = 100,
            enablePreloading: Bool = true,
            processingQueue: ProcessingQueue = .userInitiated,
            memoryOptimization: Bool = true
        ) {
            self.maxConcurrentOperations = max(1, min(10, maxConcurrentOperations))
            self.enableCaching = enableCaching
            self.cacheSize = max(10, cacheSize)
            self.enablePreloading = enablePreloading
            self.processingQueue = processingQueue
            self.memoryOptimization = memoryOptimization
        }
    }
    
    public struct PrivacySettings: Sendable {
        public let forceOnDeviceProcessing: Bool
        public let disableCloudSync: Bool
        public let enableDataEncryption: Bool
        public let autoDeleteRecordings: Bool
        public let maxDataRetention: TimeInterval
        public let anonymizeData: Bool
        
        public init(
            forceOnDeviceProcessing: Bool = false,
            disableCloudSync: Bool = false,
            enableDataEncryption: Bool = true,
            autoDeleteRecordings: Bool = true,
            maxDataRetention: TimeInterval = 86400, // 24 hours
            anonymizeData: Bool = true
        ) {
            self.forceOnDeviceProcessing = forceOnDeviceProcessing
            self.disableCloudSync = disableCloudSync
            self.enableDataEncryption = enableDataEncryption
            self.autoDeleteRecordings = autoDeleteRecordings
            self.maxDataRetention = max(3600, maxDataRetention) // Minimum 1 hour
            self.anonymizeData = anonymizeData
        }
    }
    
    public init(
        recognitionSettings: RecognitionSettings = RecognitionSettings(),
        synthesisSettings: SynthesisSettings = SynthesisSettings(),
        audioSettings: AudioSettings = AudioSettings(),
        performanceSettings: PerformanceSettings = PerformanceSettings(),
        privacySettings: PrivacySettings = PrivacySettings()
    ) {
        self.recognitionSettings = recognitionSettings
        self.synthesisSettings = synthesisSettings
        self.audioSettings = audioSettings
        self.performanceSettings = performanceSettings
        self.privacySettings = privacySettings
    }
}

// MARK: - Predefined Configurations

extension SpeechEngineConfiguration {
    
    /// Default balanced configuration
    public static let `default` = SpeechEngineConfiguration()
    
    /// High-performance configuration optimized for speed and accuracy
    public static let highPerformance = SpeechEngineConfiguration(
        recognitionSettings: RecognitionSettings(
            preferOnDevice: false,
            enableContinuousRecognition: true,
            reportPartialResults: true,
            addPunctuation: true,
            enableLanguageDetection: true,
            maxRecordingDuration: 600,
            confidenceThreshold: 0.3
        ),
        synthesisSettings: SynthesisSettings(
            preferHighQualityVoices: true,
            enableVoiceEffects: true,
            enableSSML: true,
            maxTextLength: 50000
        ),
        audioSettings: AudioSettings(
            enableNoiseReduction: true,
            enableEchoCancellation: true,
            enableAutomaticGainControl: true,
            sampleRate: 48000.0,
            audioFormat: .pcm24
        ),
        performanceSettings: PerformanceSettings(
            maxConcurrentOperations: 6,
            enableCaching: true,
            cacheSize: 500,
            enablePreloading: true,
            memoryOptimization: false
        )
    )
    
    /// Privacy-focused configuration with maximum on-device processing
    public static let privacyFocused = SpeechEngineConfiguration(
        recognitionSettings: RecognitionSettings(
            preferOnDevice: true,
            enableContinuousRecognition: false,
            reportPartialResults: false,
            enableLanguageDetection: false,
            maxRecordingDuration: 60
        ),
        synthesisSettings: SynthesisSettings(
            preferHighQualityVoices: false,
            enableVoiceEffects: false,
            maxTextLength: 1000
        ),
        performanceSettings: PerformanceSettings(
            enableCaching: false,
            enablePreloading: false,
            memoryOptimization: true
        ),
        privacySettings: PrivacySettings(
            forceOnDeviceProcessing: true,
            disableCloudSync: true,
            enableDataEncryption: true,
            autoDeleteRecordings: true,
            maxDataRetention: 3600, // 1 hour
            anonymizeData: true
        )
    )
    
    /// Real-time configuration optimized for live applications
    public static let realtime = SpeechEngineConfiguration(
        recognitionSettings: RecognitionSettings(
            preferOnDevice: true,
            enableContinuousRecognition: true,
            reportPartialResults: true,
            addPunctuation: false,
            maxRecordingDuration: 60,
            confidenceThreshold: 0.4
        ),
        synthesisSettings: SynthesisSettings(
            preferHighQualityVoices: false,
            defaultRate: 0.6,
            maxTextLength: 500
        ),
        audioSettings: AudioSettings(
            enableNoiseReduction: true,
            sampleRate: 16000.0,
            bufferSize: 512
        ),
        performanceSettings: PerformanceSettings(
            maxConcurrentOperations: 2,
            enableCaching: true,
            cacheSize: 50,
            processingQueue: .userInitiated,
            memoryOptimization: true
        )
    )
    
    /// Accessibility configuration for users with special needs
    public static let accessibility = SpeechEngineConfiguration(
        recognitionSettings: RecognitionSettings(
            preferOnDevice: false,
            enableContinuousRecognition: true,
            reportPartialResults: true,
            addPunctuation: true,
            enableLanguageDetection: true,
            maxRecordingDuration: 1800, // 30 minutes
            confidenceThreshold: 0.2
        ),
        synthesisSettings: SynthesisSettings(
            preferHighQualityVoices: true,
            defaultRate: 0.3, // Slower for clarity
            defaultPitch: 1.0,
            defaultVolume: 1.0,
            enableSSML: true,
            maxTextLength: 100000
        ),
        audioSettings: AudioSettings(
            inputGain: 1.5,
            outputGain: 1.2,
            enableNoiseReduction: true,
            enableEchoCancellation: true,
            enableAutomaticGainControl: true
        ),
        performanceSettings: PerformanceSettings(
            maxConcurrentOperations: 1,
            enableCaching: true,
            cacheSize: 200
        )
    )
    
    /// Enterprise configuration for business applications
    public static let enterprise = SpeechEngineConfiguration(
        recognitionSettings: RecognitionSettings(
            preferOnDevice: false,
            enableContinuousRecognition: true,
            reportPartialResults: true,
            addPunctuation: true,
            enableLanguageDetection: true,
            maxRecordingDuration: 3600, // 1 hour
            confidenceThreshold: 0.6
        ),
        synthesisSettings: SynthesisSettings(
            preferHighQualityVoices: true,
            enableVoiceEffects: false,
            enableSSML: true,
            maxTextLength: 100000
        ),
        audioSettings: AudioSettings(
            enableNoiseReduction: true,
            enableEchoCancellation: true,
            sampleRate: 44100.0,
            audioFormat: .pcm24
        ),
        performanceSettings: PerformanceSettings(
            maxConcurrentOperations: 8,
            enableCaching: true,
            cacheSize: 1000,
            enablePreloading: true,
            memoryOptimization: false
        ),
        privacySettings: PrivacySettings(
            enableDataEncryption: true,
            maxDataRetention: 604800, // 7 days
            anonymizeData: true
        )
    )
    
    /// Development configuration for testing and debugging
    public static let development = SpeechEngineConfiguration(
        recognitionSettings: RecognitionSettings(
            preferOnDevice: false,
            enableContinuousRecognition: true,
            reportPartialResults: true,
            addPunctuation: true,
            enableLanguageDetection: true,
            confidenceThreshold: 0.1
        ),
        synthesisSettings: SynthesisSettings(
            preferHighQualityVoices: false,
            enableVoiceEffects: true,
            enableSSML: true
        ),
        performanceSettings: PerformanceSettings(
            maxConcurrentOperations: 10,
            enableCaching: false, // Disable caching for testing
            enablePreloading: false
        ),
        privacySettings: PrivacySettings(
            autoDeleteRecordings: false, // Keep for debugging
            maxDataRetention: 259200 // 3 days
        )
    )
}

// MARK: - Configuration Builder

public class SpeechConfigurationBuilder {
    private var config = SpeechEngineConfiguration()
    
    public init() {}
    
    // MARK: - Recognition Settings
    
    public func setOnDeviceRecognition(_ enabled: Bool) -> Self {
        let settings = SpeechEngineConfiguration.RecognitionSettings(
            preferOnDevice: enabled,
            enableContinuousRecognition: config.recognitionSettings.enableContinuousRecognition,
            reportPartialResults: config.recognitionSettings.reportPartialResults,
            addPunctuation: config.recognitionSettings.addPunctuation,
            enableLanguageDetection: config.recognitionSettings.enableLanguageDetection,
            maxRecordingDuration: config.recognitionSettings.maxRecordingDuration,
            contextualStrings: config.recognitionSettings.contextualStrings,
            confidenceThreshold: config.recognitionSettings.confidenceThreshold
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: settings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    public func setMaxRecordingDuration(_ duration: TimeInterval) -> Self {
        let settings = SpeechEngineConfiguration.RecognitionSettings(
            preferOnDevice: config.recognitionSettings.preferOnDevice,
            enableContinuousRecognition: config.recognitionSettings.enableContinuousRecognition,
            reportPartialResults: config.recognitionSettings.reportPartialResults,
            addPunctuation: config.recognitionSettings.addPunctuation,
            enableLanguageDetection: config.recognitionSettings.enableLanguageDetection,
            maxRecordingDuration: duration,
            contextualStrings: config.recognitionSettings.contextualStrings,
            confidenceThreshold: config.recognitionSettings.confidenceThreshold
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: settings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    public func setContextualStrings(_ strings: [String]) -> Self {
        let settings = SpeechEngineConfiguration.RecognitionSettings(
            preferOnDevice: config.recognitionSettings.preferOnDevice,
            enableContinuousRecognition: config.recognitionSettings.enableContinuousRecognition,
            reportPartialResults: config.recognitionSettings.reportPartialResults,
            addPunctuation: config.recognitionSettings.addPunctuation,
            enableLanguageDetection: config.recognitionSettings.enableLanguageDetection,
            maxRecordingDuration: config.recognitionSettings.maxRecordingDuration,
            contextualStrings: strings,
            confidenceThreshold: config.recognitionSettings.confidenceThreshold
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: settings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    // MARK: - Synthesis Settings
    
    public func setDefaultSpeechRate(_ rate: Float) -> Self {
        let settings = SpeechEngineConfiguration.SynthesisSettings(
            preferHighQualityVoices: config.synthesisSettings.preferHighQualityVoices,
            enableVoiceEffects: config.synthesisSettings.enableVoiceEffects,
            defaultRate: rate,
            defaultPitch: config.synthesisSettings.defaultPitch,
            defaultVolume: config.synthesisSettings.defaultVolume,
            enableSSML: config.synthesisSettings.enableSSML,
            maxTextLength: config.synthesisSettings.maxTextLength
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: settings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    public func enableVoiceEffects(_ enabled: Bool) -> Self {
        let settings = SpeechEngineConfiguration.SynthesisSettings(
            preferHighQualityVoices: config.synthesisSettings.preferHighQualityVoices,
            enableVoiceEffects: enabled,
            defaultRate: config.synthesisSettings.defaultRate,
            defaultPitch: config.synthesisSettings.defaultPitch,
            defaultVolume: config.synthesisSettings.defaultVolume,
            enableSSML: config.synthesisSettings.enableSSML,
            maxTextLength: config.synthesisSettings.maxTextLength
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: settings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    // MARK: - Audio Settings
    
    public func setAudioFormat(_ format: SpeechEngineConfiguration.AudioSettings.AudioFormat) -> Self {
        let settings = SpeechEngineConfiguration.AudioSettings(
            inputGain: config.audioSettings.inputGain,
            outputGain: config.audioSettings.outputGain,
            enableNoiseReduction: config.audioSettings.enableNoiseReduction,
            enableEchoCancellation: config.audioSettings.enableEchoCancellation,
            enableAutomaticGainControl: config.audioSettings.enableAutomaticGainControl,
            sampleRate: config.audioSettings.sampleRate,
            bufferSize: config.audioSettings.bufferSize,
            audioFormat: format
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: settings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    public func enableNoiseReduction(_ enabled: Bool) -> Self {
        let settings = SpeechEngineConfiguration.AudioSettings(
            inputGain: config.audioSettings.inputGain,
            outputGain: config.audioSettings.outputGain,
            enableNoiseReduction: enabled,
            enableEchoCancellation: config.audioSettings.enableEchoCancellation,
            enableAutomaticGainControl: config.audioSettings.enableAutomaticGainControl,
            sampleRate: config.audioSettings.sampleRate,
            bufferSize: config.audioSettings.bufferSize,
            audioFormat: config.audioSettings.audioFormat
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: settings,
            performanceSettings: config.performanceSettings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    // MARK: - Performance Settings
    
    public func setMaxConcurrentOperations(_ count: Int) -> Self {
        let settings = SpeechEngineConfiguration.PerformanceSettings(
            maxConcurrentOperations: count,
            enableCaching: config.performanceSettings.enableCaching,
            cacheSize: config.performanceSettings.cacheSize,
            enablePreloading: config.performanceSettings.enablePreloading,
            processingQueue: config.performanceSettings.processingQueue,
            memoryOptimization: config.performanceSettings.memoryOptimization
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: settings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    public func enableCaching(_ enabled: Bool, size: Int? = nil) -> Self {
        let settings = SpeechEngineConfiguration.PerformanceSettings(
            maxConcurrentOperations: config.performanceSettings.maxConcurrentOperations,
            enableCaching: enabled,
            cacheSize: size ?? config.performanceSettings.cacheSize,
            enablePreloading: config.performanceSettings.enablePreloading,
            processingQueue: config.performanceSettings.processingQueue,
            memoryOptimization: config.performanceSettings.memoryOptimization
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: settings,
            privacySettings: config.privacySettings
        )
        
        return self
    }
    
    // MARK: - Privacy Settings
    
    public func forceOnDeviceProcessing(_ enabled: Bool) -> Self {
        let settings = SpeechEngineConfiguration.PrivacySettings(
            forceOnDeviceProcessing: enabled,
            disableCloudSync: config.privacySettings.disableCloudSync,
            enableDataEncryption: config.privacySettings.enableDataEncryption,
            autoDeleteRecordings: config.privacySettings.autoDeleteRecordings,
            maxDataRetention: config.privacySettings.maxDataRetention,
            anonymizeData: config.privacySettings.anonymizeData
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: settings
        )
        
        return self
    }
    
    public func setDataRetention(_ duration: TimeInterval) -> Self {
        let settings = SpeechEngineConfiguration.PrivacySettings(
            forceOnDeviceProcessing: config.privacySettings.forceOnDeviceProcessing,
            disableCloudSync: config.privacySettings.disableCloudSync,
            enableDataEncryption: config.privacySettings.enableDataEncryption,
            autoDeleteRecordings: config.privacySettings.autoDeleteRecordings,
            maxDataRetention: duration,
            anonymizeData: config.privacySettings.anonymizeData
        )
        
        config = SpeechEngineConfiguration(
            recognitionSettings: config.recognitionSettings,
            synthesisSettings: config.synthesisSettings,
            audioSettings: config.audioSettings,
            performanceSettings: config.performanceSettings,
            privacySettings: settings
        )
        
        return self
    }
    
    public func build() -> SpeechEngineConfiguration {
        return config
    }
}

// MARK: - Configuration Validation

extension SpeechEngineConfiguration {
    
    /// Validates the configuration and returns warnings
    public func validate() -> [ConfigurationWarning] {
        var warnings: [ConfigurationWarning] = []
        
        // Check recognition settings
        if recognitionSettings.maxRecordingDuration > 3600 {
            warnings.append(.longRecordingDuration(recognitionSettings.maxRecordingDuration))
        }
        
        if recognitionSettings.confidenceThreshold < 0.3 {
            warnings.append(.lowConfidenceThreshold(recognitionSettings.confidenceThreshold))
        }
        
        // Check audio settings
        if audioSettings.sampleRate < 16000 {
            warnings.append(.lowSampleRate(audioSettings.sampleRate))
        }
        
        // Check performance settings
        if performanceSettings.maxConcurrentOperations > 10 {
            warnings.append(.highConcurrency(performanceSettings.maxConcurrentOperations))
        }
        
        // Check privacy settings
        if !privacySettings.enableDataEncryption && !privacySettings.forceOnDeviceProcessing {
            warnings.append(.privacyRisk)
        }
        
        return warnings
    }
    
    /// Returns optimal configuration for current device
    public static func optimizedForDevice() -> SpeechEngineConfiguration {
        let processorCount = ProcessInfo.processInfo.processorCount
        let memorySize = ProcessInfo.processInfo.physicalMemory
        
        let maxConcurrency = max(2, min(6, processorCount))
        let cacheSize = memorySize > 4_000_000_000 ? 500 : 200
        let highQualityAudio = memorySize > 2_000_000_000
        
        return SpeechEngineConfiguration(
            audioSettings: AudioSettings(
                sampleRate: highQualityAudio ? 44100.0 : 22050.0,
                audioFormat: highQualityAudio ? .pcm24 : .pcm16
            ),
            performanceSettings: PerformanceSettings(
                maxConcurrentOperations: maxConcurrency,
                cacheSize: cacheSize,
                memoryOptimization: memorySize < 4_000_000_000
            )
        )
    }
}

public enum ConfigurationWarning {
    case longRecordingDuration(TimeInterval)
    case lowConfidenceThreshold(Float)
    case lowSampleRate(Double)
    case highConcurrency(Int)
    case privacyRisk
    
    public var message: String {
        switch self {
        case .longRecordingDuration(let duration):
            return "Recording duration (\(Int(duration))s) is very long and may impact performance"
        case .lowConfidenceThreshold(let threshold):
            return "Low confidence threshold (\(threshold)) may result in poor quality transcriptions"
        case .lowSampleRate(let rate):
            return "Low sample rate (\(Int(rate))Hz) may reduce audio quality"
        case .highConcurrency(let count):
            return "High concurrent operations (\(count)) may impact system performance"
        case .privacyRisk:
            return "Data encryption disabled with cloud processing - privacy risk"
        }
    }
}
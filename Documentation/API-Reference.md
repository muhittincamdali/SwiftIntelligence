# SwiftIntelligence API Reference

Complete API reference for the SwiftIntelligence framework - your comprehensive AI/ML toolkit for Apple platforms.

## 📚 Table of Contents

- [Core Module](#core-module)
- [NLP Module](#nlp-module)
- [Vision Module](#vision-module)
- [Speech Module](#speech-module)
- [Machine Learning Module](#ml-module)
- [Privacy Module](#privacy-module)
- [Network Module](#network-module)
- [Cache Module](#cache-module)
- [Metrics Module](#metrics-module)
- [Reasoning Module](#reasoning-module)
- [Image Generation Module](#image-generation-module)

---

## Core Module

The foundation module providing configuration, logging, performance monitoring, and error handling.

### SwiftIntelligenceCore

The main entry point for the framework.

```swift
public class SwiftIntelligenceCore {
    /// Shared singleton instance
    public static let shared = SwiftIntelligenceCore()
    
    /// Framework version
    public static let version = "1.0.0"
    
    /// Build number
    public static let buildNumber = "100"
    
    /// Current configuration
    public private(set) var configuration: IntelligenceConfiguration
    
    /// Logger instance
    public let logger: IntelligenceLogger
    
    /// Performance monitor
    public let performanceMonitor: PerformanceMonitor
    
    /// Error handler
    public let errorHandler: ErrorHandler
}
```

#### Methods

```swift
/// Configure the framework with custom settings
public func configure(with configuration: IntelligenceConfiguration)

/// Reset to default configuration
public func resetConfiguration()

/// Get current memory usage statistics
public func memoryUsage() -> MemoryUsage

/// Get current CPU usage statistics
public func cpuUsage() -> CPUUsage

/// Cleanup framework resources
public func cleanup()
```

### IntelligenceConfiguration

Framework configuration options.

```swift
public struct IntelligenceConfiguration: Sendable {
    public let debugMode: Bool
    public let performanceMonitoring: Bool
    public let verboseLogging: Bool
    public let memoryLimit: Int // MB
    public let requestTimeout: TimeInterval
    public let cacheDuration: TimeInterval
    public let maxConcurrentOperations: Int
    public let privacyMode: Bool
    public let telemetryEnabled: Bool
    
    // Predefined configurations
    public static let development: IntelligenceConfiguration
    public static let production: IntelligenceConfiguration
    public static let testing: IntelligenceConfiguration
}
```

## Core Intelligence Engine

### IntelligenceEngine

The central orchestrator for all AI operations.

```swift
public class IntelligenceEngine {
    public static let shared = IntelligenceEngine()
    
    public func initialize() async throws
    public func getVisionEngine() async throws -> VisionEngine
    public func getNaturalLanguageEngine() async throws -> NaturalLanguageEngine
    public func getSpeechEngine() async throws -> SpeechEngine
    public func getLLMEngine() async throws -> LLMEngine
    public func getPrivacyEngine() async throws -> PrivacyEngine
}
```

## Vision Engine

### VisionEngine

Computer vision processing capabilities.

```swift
public actor VisionEngine {
    public func processImage(_ image: CIImage, with request: VisionRequest) async throws -> VisionResult
    public func detectObjects(in image: CIImage) async throws -> [DetectedObject]
    public func classifyImage(_ image: CIImage) async throws -> [ImageClassification]
    public func recognizeFaces(in image: CIImage) async throws -> [FaceRecognition]
    public func extractText(from image: CIImage) async throws -> String
}
```

### VisionRequest

```swift
public enum VisionRequest {
    case objectDetection(threshold: Float, classes: [String]?)
    case imageClassification(maxResults: Int, threshold: Float)
    case faceDetection(landmarks: Bool, expressions: Bool)
    case textRecognition(language: String?)
}
```

### VisionResult

```swift
public enum VisionResult {
    case objectDetection([DetectedObject])
    case imageClassification([ImageClassification])
    case faceDetection([FaceDetection])
    case textRecognition(String)
}
```

## Natural Language Processing

### NaturalLanguageEngine

Text processing and analysis capabilities.

```swift
public actor NaturalLanguageEngine {
    public func processText(_ request: NLPRequest) async throws -> NLPResult
    public func analyzeSentiment(_ text: String) async throws -> SentimentAnalysis
    public func extractEntities(from text: String) async throws -> [NamedEntity]
    public func detectLanguage(of text: String) async throws -> NLPLanguage
    public func summarizeText(_ text: String) async throws -> String
}
```

### NLPRequest

```swift
public enum NLPRequest {
    case sentimentAnalysis(text: String, language: NLPLanguage?)
    case entityRecognition(text: String, types: [EntityType])
    case languageDetection(text: String)
    case textSummarization(text: String, maxLength: Int)
    case translation(text: String, from: NLPLanguage, to: NLPLanguage)
}
```

## Speech Engine

### SpeechEngine

Audio processing and speech capabilities.

```swift
public actor SpeechEngine {
    public func processAudio(_ data: Data, with request: SpeechRequest) async throws -> SpeechResult
    public func startRecognition() -> AsyncThrowingStream<SpeechRecognitionResult, Error>
    public func stopRecognition()
    public func synthesizeSpeech(_ request: SpeechSynthesisRequest) async throws -> Data
}
```

### SpeechRequest

```swift
public enum SpeechRequest {
    case recognition(language: SpeechLanguage, enablePunctuation: Bool, enableNoiseReduction: Bool)
    case synthesis(text: String, voice: VoiceType, language: SpeechLanguage, rate: Float)
}
```

## Privacy Engine

### PrivacyEngine

Data protection and privacy capabilities.

```swift
public class PrivacyEngine {
    public func protectSensitiveText(_ text: String, classification: DataClassification) async throws -> String
    public func anonymizeData<T>(_ data: T, level: AnonymizationLevel) async throws -> T
    public func encryptData<T>(_ data: T) async throws -> EncryptedData<T>
    public func classifyData(_ data: String) async throws -> DataClassification
}
```

## Configuration

### IntelligenceConfiguration

```swift
public struct IntelligenceConfiguration {
    public let enabledEngines: Set<EngineType>
    public let privacyLevel: PrivacyLevel
    public let performanceProfile: PerformanceProfile
    public let cachingPolicy: CachingPolicy
    public let loggingLevel: LogLevel
    
    public static let development: IntelligenceConfiguration
    public static let production: IntelligenceConfiguration
    public static let testing: IntelligenceConfiguration
}
```

## Error Handling

### IntelligenceError

```swift
public enum IntelligenceError: Error {
    case engineNotInitialized
    case engineNotFound(String)
    case configurationInvalid
    case resourceUnavailable
    case processingFailed(String)
}
```

### VisionError

```swift
public enum VisionError: Error {
    case invalidImage
    case modelNotAvailable(String)
    case processingFailed(String)
    case unsupportedRequest
}
```

### NLPError

```swift
public enum NLPError: Error {
    case languageNotSupported(NLPLanguage)
    case textTooLong
    case processingFailed(String)
    case modelNotAvailable
}
```

### SpeechError

```swift
public enum SpeechError: Error {
    case audioFormatUnsupported
    case recognitionFailed
    case synthesisFailed
    case permissionDenied
}
```

## Data Types

### Common Types

```swift
public struct DetectedObject {
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect
    public let id: UUID
}

public struct ImageClassification {
    public let label: String
    public let confidence: Float
    public let category: String?
}

public struct SentimentAnalysis {
    public let sentiment: Sentiment
    public let confidence: Float
    public let score: Float
}

public struct NamedEntity {
    public let text: String
    public let type: EntityType
    public let range: NSRange
    public let confidence: Float
}
```

### Enumerations

```swift
public enum EngineType: CaseIterable {
    case vision
    case nlp
    case speech
    case llm
    case imageGeneration
    case privacy
}

public enum PrivacyLevel {
    case standard
    case high
    case maximum
}

public enum PerformanceProfile {
    case battery
    case balanced
    case performance
}

public enum NLPLanguage: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case turkish = "tr"
    case japanese = "ja"
    case chinese = "zh"
}

public enum EntityType {
    case person
    case organization
    case location
    case date
    case email
    case phoneNumber
    case url
    case custom(String)
}

public enum Sentiment {
    case positive
    case negative
    case neutral
}
```

## Performance Monitoring

### MetricsCollector

```swift
public class MetricsCollector {
    public func startCollecting(_ metrics: [MetricType]) async
    public func stopCollecting() async
    public func getCurrentMetrics() async -> PerformanceMetrics
    public func getHistoricalMetrics(period: TimePeriod) async -> [PerformanceMetrics]
}

public struct PerformanceMetrics {
    public let averageInferenceTime: TimeInterval
    public let memoryUsage: Int64
    public let cpuUsage: Double
    public let batteryImpact: BatteryImpact
    public let modelAccuracy: Double?
    public let timestamp: Date
}
```

## Caching

### CacheManager

```swift
public class CacheManager {
    public func store<T>(_ value: T, for key: String, ttl: TimeInterval?) async
    public func retrieve<T>(_ type: T.Type, for key: String) async -> T?
    public func remove(for key: String) async
    public func clear() async
    public func getCacheStatistics() async -> CacheStatistics
}

public struct CacheStatistics {
    public let hitRate: Double
    public let missRate: Double
    public let totalSize: Int64
    public let itemCount: Int
    public let evictionCount: Int
}
```

## Extensions and Utilities

### SwiftUI Integration

```swift
extension IntelligenceEngine {
    @MainActor
    public func processImageAsync(_ image: UIImage, request: VisionRequest) async throws -> VisionResult
    
    @MainActor
    public func analyzeTextAsync(_ text: String) async throws -> NLPResult
}
```

### Combine Integration

```swift
extension IntelligenceEngine {
    public func visionPublisher(for request: VisionRequest) -> AnyPublisher<VisionResult, Error>
    public func nlpPublisher(for request: NLPRequest) -> AnyPublisher<NLPResult, Error>
    public func speechPublisher(for request: SpeechRequest) -> AnyPublisher<SpeechResult, Error>
}
```

## Platform-Specific APIs

### iOS Extensions

```swift
#if os(iOS)
extension VisionEngine {
    public func processLiveCamera() -> AsyncThrowingStream<VisionResult, Error>
    public func startLiveCameraProcessing(request: VisionRequest) async throws
    public func stopLiveCameraProcessing() async
}
#endif
```

### macOS Extensions

```swift
#if os(macOS)
extension IntelligenceEngine {
    public func batchProcessImages(_ images: [NSImage], request: VisionRequest) async throws -> [VisionResult]
    public func trainCustomModel(with data: TrainingData) async throws -> CustomModel
}
#endif
```

### visionOS Extensions

```swift
#if os(visionOS)
extension IntelligenceEngine {
    public func getVisionOSEngine() async throws -> VisionOSEngine
}

public class VisionOSEngine {
    public func getSpatialComputingManager() async throws -> SpatialComputingManager
    public func getImmersiveSpaceManager() async throws -> ImmersiveSpaceManager
    public func getRealityKitManager() async throws -> RealityKitManager
}
#endif
```

This API reference provides comprehensive documentation for all public interfaces in the SwiftIntelligence framework.
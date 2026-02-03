# SwiftIntelligence API Reference

Complete API documentation for SwiftIntelligence framework.

## Table of Contents

1. [Core Module](#core-module)
2. [ML Models](#ml-models)
3. [NLP Processing](#nlp-processing)
4. [Vision Analysis](#vision-analysis)
5. [Prediction Engine](#prediction-engine)
6. [Data Processing](#data-processing)

---

## Core Module

### IntelligenceEngine

The main entry point for SwiftIntelligence operations.

```swift
public final class IntelligenceEngine {
    /// Shared instance
    public static let shared: IntelligenceEngine
    
    /// Initialize with configuration
    public init(configuration: Configuration = .default)
    
    /// Start engine
    public func start() async throws
    
    /// Stop engine
    public func stop()
}
```

#### Configuration

```swift
public struct Configuration {
    /// Default configuration
    public static let `default`: Configuration
    
    /// Enable GPU acceleration
    public var useGPU: Bool
    
    /// Maximum concurrent operations
    public var maxConcurrency: Int
    
    /// Cache policy
    public var cachePolicy: CachePolicy
    
    /// Logging level
    public var logLevel: LogLevel
}
```

#### Usage

```swift
// Initialize engine
let engine = IntelligenceEngine(configuration: .default)
try await engine.start()

// Use modules
let nlpResult = try await engine.nlp.process("Hello world")
let visionResult = try await engine.vision.analyze(image)

// Stop when done
engine.stop()
```

---

## ML Models

### MLModelManager

Manages machine learning models.

```swift
public final class MLModelManager {
    /// Load model from URL
    public func loadModel(from url: URL) async throws -> MLModel
    
    /// Load model from bundle
    public func loadModel(named name: String, bundle: Bundle) async throws -> MLModel
    
    /// Unload model
    public func unloadModel(_ identifier: String)
    
    /// Get loaded models
    public var loadedModels: [String: MLModel] { get }
}
```

### MLPredictor

Performs ML predictions.

```swift
public protocol MLPredictor {
    associatedtype Input
    associatedtype Output
    
    /// Predict single input
    func predict(_ input: Input) async throws -> Output
    
    /// Batch prediction
    func predictBatch(_ inputs: [Input]) async throws -> [Output]
}
```

#### PredictionResult

```swift
public struct PredictionResult<T> {
    /// Predicted value
    public let value: T
    
    /// Confidence score (0-1)
    public let confidence: Float
    
    /// Processing time
    public let processingTime: TimeInterval
    
    /// Additional metadata
    public let metadata: [String: Any]
}
```

---

## NLP Processing

### NLPProcessor

Natural language processing operations.

```swift
public final class NLPProcessor {
    /// Full text analysis
    public func process(_ text: String) async throws -> NLPResult
    
    /// Sentiment analysis
    public func analyzeSentiment(_ text: String) -> SentimentScore
    
    /// Entity extraction
    public func extractEntities(_ text: String) -> [NamedEntity]
    
    /// Tokenization
    public func tokenize(_ text: String) -> [Token]
    
    /// Language detection
    public func detectLanguage(_ text: String) -> String?
    
    /// Key phrase extraction
    public func extractKeyPhrases(_ text: String) -> [String]
}
```

### NLPResult

```swift
public struct NLPResult {
    public let text: String
    public let language: String?
    public let sentiment: SentimentScore
    public let entities: [NamedEntity]
    public let tokens: [Token]
    public let keyPhrases: [String]
    public let processingTime: TimeInterval
}
```

### SentimentScore

```swift
public struct SentimentScore {
    /// Score (-1 to 1)
    public let score: Double
    
    /// Sentiment label
    public let label: SentimentLabel
    
    /// Confidence
    public let confidence: Double
    
    public enum SentimentLabel {
        case positive
        case negative
        case neutral
        case mixed
    }
}
```

### NamedEntity

```swift
public struct NamedEntity {
    public let text: String
    public let type: EntityType
    public let range: Range<String.Index>?
    
    public enum EntityType {
        case person
        case organization
        case location
        case date
        case money
        case percentage
        case other
    }
}
```

#### Usage

```swift
let processor = NLPProcessor()

// Full analysis
let result = try await processor.process("Apple announced new iPhone in California.")
print("Sentiment: \(result.sentiment.label)")
print("Entities: \(result.entities)")

// Quick sentiment
let sentiment = processor.analyzeSentiment("I love this!")
print("Score: \(sentiment.score)")
```

---

## Vision Analysis

### VisionAnalyzer

Computer vision operations.

```swift
public final class VisionAnalyzer {
    /// Initialize with options
    public init(
        minimumConfidence: Float = 0.5,
        textRecognitionLevel: VNRequestTextRecognitionLevel = .accurate
    )
    
    /// Full image analysis
    public func analyze(_ image: CGImage) async throws -> VisionAnalysisResult
    
    /// Object detection
    public func detectObjects(_ image: CGImage) async throws -> [DetectedObject]
    
    /// Text recognition
    public func recognizeText(_ image: CGImage) async throws -> [RecognizedText]
    
    /// Face detection
    public func detectFaces(_ image: CGImage) async throws -> [DetectedFace]
    
    /// Barcode detection
    public func detectBarcodes(_ image: CGImage) async throws -> [DetectedBarcode]
    
    /// Image classification
    public func classifyImage(_ image: CGImage) async throws -> [ImageClassification]
}
```

### VisionAnalysisResult

```swift
public struct VisionAnalysisResult {
    public let objects: [DetectedObject]
    public let texts: [RecognizedText]
    public let faces: [DetectedFace]
    public let barcodes: [DetectedBarcode]
    public let imageClassifications: [ImageClassification]
    public let processingTime: TimeInterval
}
```

### DetectedObject

```swift
public struct DetectedObject {
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect
}
```

### DetectedFace

```swift
public struct DetectedFace {
    public let boundingBox: CGRect
    public let landmarks: FaceLandmarks?
    public let roll: CGFloat?
    public let yaw: CGFloat?
    public let quality: Float?
}
```

#### Usage

```swift
let analyzer = VisionAnalyzer(minimumConfidence: 0.6)

// Full analysis
let result = try await analyzer.analyze(image)
print("Found \(result.faces.count) faces")
print("Texts: \(result.texts.map { $0.text })")

// Specific detection
let faces = try await analyzer.detectFaces(image)
let texts = try await analyzer.recognizeText(image)
```

---

## Prediction Engine

### PredictionEngine

Time series and pattern prediction.

```swift
public final class PredictionEngine {
    /// Predict next values
    public func predict(
        values: [Double],
        steps: Int
    ) async throws -> [PredictedValue]
    
    /// Detect anomalies
    public func detectAnomalies(
        values: [Double],
        sensitivity: Float
    ) -> [Anomaly]
    
    /// Find patterns
    public func findPatterns(
        values: [Double]
    ) -> [Pattern]
}
```

### PredictedValue

```swift
public struct PredictedValue {
    public let value: Double
    public let confidence: Float
    public let lowerBound: Double
    public let upperBound: Double
}
```

### Anomaly

```swift
public struct Anomaly {
    public let index: Int
    public let value: Double
    public let expectedRange: ClosedRange<Double>
    public let severity: Severity
    
    public enum Severity {
        case low
        case medium
        case high
        case critical
    }
}
```

---

## Data Processing

### DataPreprocessor

Data preparation utilities.

```swift
public final class DataPreprocessor {
    /// Normalize values
    public func normalize(_ values: [Double]) -> [Double]
    
    /// Standardize values
    public func standardize(_ values: [Double]) -> [Double]
    
    /// One-hot encode
    public func oneHotEncode(_ categories: [String]) -> [[Int]]
    
    /// Fill missing values
    public func fillMissing(
        _ values: [Double?],
        strategy: FillStrategy
    ) -> [Double]
    
    public enum FillStrategy {
        case mean
        case median
        case mode
        case constant(Double)
        case forward
        case backward
    }
}
```

### FeatureExtractor

```swift
public final class FeatureExtractor {
    /// Extract statistical features
    public func extractStatisticalFeatures(
        _ values: [Double]
    ) -> StatisticalFeatures
    
    /// Extract frequency features
    public func extractFrequencyFeatures(
        _ values: [Double]
    ) -> FrequencyFeatures
}
```

### StatisticalFeatures

```swift
public struct StatisticalFeatures {
    public let mean: Double
    public let median: Double
    public let standardDeviation: Double
    public let variance: Double
    public let min: Double
    public let max: Double
    public let range: Double
    public let skewness: Double
    public let kurtosis: Double
}
```

---

## Error Handling

### IntelligenceError

```swift
public enum IntelligenceError: Error {
    case modelNotFound(String)
    case modelLoadFailed(String, underlying: Error)
    case predictionFailed(String)
    case invalidInput(String)
    case processingTimeout
    case resourceUnavailable
    case configurationError(String)
}
```

---

## Performance Tips

1. **Batch Processing**: Use batch methods for multiple inputs
2. **Caching**: Enable caching for repeated operations
3. **GPU Acceleration**: Enable GPU when available
4. **Async Operations**: Use async/await for non-blocking execution

---

## Thread Safety

All public APIs are thread-safe and support concurrent access. Use actors internally for state management.

---

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS | 15.0+ |
| macOS | 12.0+ |
| tvOS | 15.0+ |
| watchOS | 8.0+ |
| visionOS | 1.0+ |

---

**Version**: 2.0.0  
**Last Updated**: 2025

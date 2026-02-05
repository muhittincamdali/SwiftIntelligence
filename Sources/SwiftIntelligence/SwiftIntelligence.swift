// SwiftIntelligence.swift
// The Ultimate AI/ML Framework for Apple Platforms
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import CoreML
import Vision
import NaturalLanguage
#if canImport(UIKit)
import UIKit
public typealias SIImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias SIImage = NSImage
#endif

// MARK: - SwiftIntelligence Main API

/// The unified entry point for all AI/ML operations on Apple platforms.
///
/// SwiftIntelligence provides world-class, on-device AI capabilities with
/// a simple, Swift-native API. Privacy-first, battery-optimized, production-ready.
///
/// ```swift
/// // One-liner predictions
/// let result = try await SwiftIntelligence.classify(image)
/// let sentiment = try await SwiftIntelligence.sentiment("I love this!")
/// let objects = try await SwiftIntelligence.detectObjects(in: image)
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum SwiftIntelligence {
    
    // MARK: - Version Info
    
    /// Current framework version
    public static let version = "2.0.0"
    
    /// Build information
    public static let build = "2024.02.05"
    
    // MARK: - Shared Engines
    
    /// Vision processing engine
    public static let vision = VisionEngine.shared
    
    /// Natural Language processing engine
    public static let nlp = NLPEngine.shared
    
    /// Speech processing engine
    public static let speech = SpeechEngine.shared
    
    /// Machine Learning engine
    public static let ml = MLEngine.shared
    
    /// Recommendation engine
    public static let recommendations = RecommendationEngine.shared
    
    /// Anomaly detection engine
    public static let anomaly = AnomalyEngine.shared
    
    /// Time series prediction engine
    public static let timeSeries = TimeSeriesEngine.shared
    
    // MARK: - 🖼️ Vision - One-Liner APIs
    
    /// Classify image contents with AI
    /// - Parameter image: The image to classify
    /// - Returns: Classification result with labels and confidence scores
    public static func classify(_ image: SIImage) async throws -> ClassificationResult {
        try await vision.classify(image)
    }
    
    /// Detect and locate objects in an image
    /// - Parameters:
    ///   - image: The image to analyze
    ///   - maxObjects: Maximum number of objects to detect (default: 20)
    /// - Returns: Array of detected objects with bounding boxes
    public static func detectObjects(
        in image: SIImage,
        maxObjects: Int = 20
    ) async throws -> [DetectedObject] {
        try await vision.detectObjects(in: image, maxObjects: maxObjects)
    }
    
    /// Detect faces in an image
    /// - Parameter image: The image to analyze
    /// - Returns: Array of detected faces with landmarks
    public static func detectFaces(in image: SIImage) async throws -> [Face] {
        try await vision.detectFaces(in: image)
    }
    
    /// Extract text from an image (OCR)
    /// - Parameters:
    ///   - image: The image containing text
    ///   - languages: Preferred languages for recognition
    /// - Returns: Recognized text and positions
    public static func extractText(
        from image: SIImage,
        languages: [String] = ["en-US"]
    ) async throws -> TextExtractionResult {
        try await vision.extractText(from: image, languages: languages)
    }
    
    /// Generate image description using AI
    /// - Parameter image: The image to describe
    /// - Returns: Natural language description of the image
    public static func describe(_ image: SIImage) async throws -> String {
        try await vision.describe(image)
    }
    
    /// Segment image into meaningful regions
    /// - Parameter image: The image to segment
    /// - Returns: Segmented regions with labels
    public static func segment(_ image: SIImage) async throws -> SegmentationResult {
        try await vision.segment(image)
    }
    
    /// Remove background from image
    /// - Parameter image: The image to process
    /// - Returns: Image with transparent background
    public static func removeBackground(from image: SIImage) async throws -> SIImage {
        try await vision.removeBackground(from: image)
    }
    
    /// Enhance image quality with AI upscaling
    /// - Parameters:
    ///   - image: The image to enhance
    ///   - scale: Upscale factor (1.0-4.0)
    /// - Returns: Enhanced high-resolution image
    public static func enhance(
        _ image: SIImage,
        scale: Float = 2.0
    ) async throws -> SIImage {
        try await vision.enhance(image, scale: scale)
    }
    
    // MARK: - 📝 Natural Language - One-Liner APIs
    
    /// Analyze sentiment of text
    /// - Parameter text: The text to analyze
    /// - Returns: Sentiment score (-1.0 to 1.0) and label
    public static func sentiment(_ text: String) async throws -> SentimentResult {
        try await nlp.analyzeSentiment(text)
    }
    
    /// Extract named entities from text
    /// - Parameter text: The text to analyze
    /// - Returns: Extracted entities (people, places, organizations, etc.)
    public static func extractEntities(from text: String) async throws -> [Entity] {
        try await nlp.extractEntities(from: text)
    }
    
    /// Detect language of text
    /// - Parameter text: The text to analyze
    /// - Returns: Detected language code and confidence
    public static func detectLanguage(_ text: String) async throws -> LanguageResult {
        try await nlp.detectLanguage(text)
    }
    
    /// Summarize text content
    /// - Parameters:
    ///   - text: The text to summarize
    ///   - maxLength: Maximum summary length in words
    /// - Returns: Summarized text
    public static func summarize(
        _ text: String,
        maxLength: Int = 100
    ) async throws -> String {
        try await nlp.summarize(text, maxLength: maxLength)
    }
    
    /// Extract keywords from text
    /// - Parameters:
    ///   - text: The text to analyze
    ///   - count: Number of keywords to extract
    /// - Returns: Array of keywords with relevance scores
    public static func extractKeywords(
        from text: String,
        count: Int = 10
    ) async throws -> [Keyword] {
        try await nlp.extractKeywords(from: text, count: count)
    }
    
    /// Calculate semantic similarity between texts
    /// - Parameters:
    ///   - text1: First text
    ///   - text2: Second text
    /// - Returns: Similarity score (0.0 to 1.0)
    public static func similarity(
        _ text1: String,
        _ text2: String
    ) async throws -> Float {
        try await nlp.similarity(text1, text2)
    }
    
    /// Classify text into categories
    /// - Parameters:
    ///   - text: The text to classify
    ///   - categories: Available categories
    /// - Returns: Category with confidence score
    public static func classifyText(
        _ text: String,
        categories: [String]
    ) async throws -> TextClassificationResult {
        try await nlp.classify(text, categories: categories)
    }
    
    // MARK: - 🎤 Speech - One-Liner APIs
    
    /// Convert speech to text
    /// - Parameters:
    ///   - audioURL: URL of audio file
    ///   - language: Speech language (default: en-US)
    /// - Returns: Transcribed text with timestamps
    public static func transcribe(
        _ audioURL: URL,
        language: String = "en-US"
    ) async throws -> TranscriptionResult {
        try await speech.transcribe(audioURL, language: language)
    }
    
    /// Convert text to speech
    /// - Parameters:
    ///   - text: Text to speak
    ///   - voice: Voice identifier (optional)
    /// - Returns: Audio data
    public static func synthesize(
        _ text: String,
        voice: String? = nil
    ) async throws -> Data {
        try await speech.synthesize(text, voice: voice)
    }
    
    // MARK: - 🤖 Machine Learning - One-Liner APIs
    
    /// Make prediction with a trained model
    /// - Parameters:
    ///   - modelName: Name of the registered model
    ///   - input: Input features dictionary
    /// - Returns: Prediction result
    public static func predict(
        model modelName: String,
        input: [String: Any]
    ) async throws -> PredictionResult {
        try await ml.predict(model: modelName, input: input)
    }
    
    /// Train a model on-device
    /// - Parameters:
    ///   - modelType: Type of model to train
    ///   - data: Training data
    /// - Returns: Trained model identifier
    public static func train(
        _ modelType: ModelType,
        with data: TrainingData
    ) async throws -> String {
        try await ml.train(modelType, with: data)
    }
    
    // MARK: - 📊 Recommendations - One-Liner APIs
    
    /// Get personalized recommendations
    /// - Parameters:
    ///   - userId: User identifier
    ///   - context: Optional context for recommendations
    /// - Returns: Recommended items with scores
    public static func recommend(
        for userId: String,
        context: [String: Any]? = nil
    ) async throws -> [Recommendation] {
        try await recommendations.recommend(for: userId, context: context)
    }
    
    /// Find similar items
    /// - Parameters:
    ///   - itemId: Reference item identifier
    ///   - count: Number of similar items to find
    /// - Returns: Similar items with similarity scores
    public static func findSimilar(
        to itemId: String,
        count: Int = 10
    ) async throws -> [SimilarItem] {
        try await recommendations.findSimilar(to: itemId, count: count)
    }
    
    // MARK: - 🔍 Anomaly Detection - One-Liner APIs
    
    /// Detect anomalies in data
    /// - Parameter data: Array of values to analyze
    /// - Returns: Detected anomalies with scores
    public static func detectAnomalies(
        in data: [Double]
    ) async throws -> [Anomaly] {
        try await anomaly.detect(in: data)
    }
    
    /// Check if a value is anomalous
    /// - Parameters:
    ///   - value: Value to check
    ///   - baseline: Baseline data for comparison
    /// - Returns: Whether the value is anomalous and confidence score
    public static func isAnomalous(
        _ value: Double,
        baseline: [Double]
    ) async throws -> (isAnomaly: Bool, score: Float) {
        try await anomaly.isAnomalous(value, baseline: baseline)
    }
    
    // MARK: - 📈 Time Series - One-Liner APIs
    
    /// Predict future values in a time series
    /// - Parameters:
    ///   - series: Historical data points
    ///   - steps: Number of future steps to predict
    /// - Returns: Predicted values with confidence intervals
    public static func forecast(
        _ series: [Double],
        steps: Int
    ) async throws -> ForecastResult {
        try await timeSeries.forecast(series, steps: steps)
    }
    
    /// Detect trends in time series data
    /// - Parameter series: Data points to analyze
    /// - Returns: Detected trends and patterns
    public static func detectTrends(
        in series: [Double]
    ) async throws -> TrendResult {
        try await timeSeries.detectTrends(in: series)
    }
    
    // MARK: - 🔧 Configuration
    
    /// Configure SwiftIntelligence settings
    /// - Parameter configuration: Configuration options
    public static func configure(_ configuration: Configuration) {
        ConfigurationManager.shared.apply(configuration)
    }
    
    /// Reset all engines to default state
    public static func reset() async {
        await vision.reset()
        await nlp.reset()
        await speech.reset()
        await ml.reset()
        await recommendations.reset()
        await anomaly.reset()
        await timeSeries.reset()
    }
    
    /// Get system information
    public static func systemInfo() -> SystemInfo {
        SystemInfo(
            version: version,
            build: build,
            platform: platformName,
            neuralEngineAvailable: hasNeuralEngine,
            availableMemory: availableMemory
        )
    }
    
    // MARK: - Private Helpers
    
    private static var platformName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }
    
    private static var hasNeuralEngine: Bool {
        MLModel.availableComputeDevices.contains { $0.description.contains("Neural") }
    }
    
    private static var availableMemory: UInt64 {
        ProcessInfo.processInfo.physicalMemory
    }
}

// MARK: - Result Types

/// Image classification result
public struct ClassificationResult: Sendable {
    public let labels: [LabelScore]
    public let processingTime: TimeInterval
    
    public var topLabel: String? { labels.first?.label }
    public var topConfidence: Float? { labels.first?.confidence }
    
    public struct LabelScore: Sendable {
        public let label: String
        public let confidence: Float
    }
}

/// Detected object in an image
public struct DetectedObject: Sendable {
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect
    public let category: String
}

/// Detected face in an image
public struct Face: Sendable {
    public let boundingBox: CGRect
    public let confidence: Float
    public let landmarks: FaceLandmarks?
    public let age: Int?
    public let emotion: String?
}

/// Face landmarks
public struct FaceLandmarks: Sendable {
    public let leftEye: CGPoint
    public let rightEye: CGPoint
    public let nose: CGPoint
    public let mouth: CGPoint
    public let jawline: [CGPoint]
}

/// Text extraction result
public struct TextExtractionResult: Sendable {
    public let text: String
    public let blocks: [TextBlock]
    public let confidence: Float
    
    public struct TextBlock: Sendable {
        public let text: String
        public let boundingBox: CGRect
        public let confidence: Float
    }
}

/// Image segmentation result
public struct SegmentationResult: Sendable {
    public let segments: [Segment]
    public let maskImage: SIImage?
    
    public struct Segment: Sendable {
        public let label: String
        public let confidence: Float
        public let mask: Data
    }
}

/// Sentiment analysis result
public struct SentimentResult: Sendable {
    public let score: Float  // -1.0 (negative) to 1.0 (positive)
    public let label: SentimentLabel
    public let confidence: Float
    
    public enum SentimentLabel: String, Sendable {
        case veryNegative = "very_negative"
        case negative = "negative"
        case neutral = "neutral"
        case positive = "positive"
        case veryPositive = "very_positive"
    }
}

/// Extracted entity
public struct Entity: Sendable {
    public let text: String
    public let type: EntityType
    public let range: Range<String.Index>
    public let confidence: Float
    
    public enum EntityType: String, Sendable {
        case person, organization, place, date, money, percentage, other
    }
}

/// Language detection result
public struct LanguageResult: Sendable {
    public let languageCode: String
    public let languageName: String
    public let confidence: Float
}

/// Extracted keyword
public struct Keyword: Sendable {
    public let text: String
    public let relevance: Float
}

/// Text classification result
public struct TextClassificationResult: Sendable {
    public let category: String
    public let confidence: Float
    public let allScores: [String: Float]
}

/// Speech transcription result
public struct TranscriptionResult: Sendable {
    public let text: String
    public let segments: [TranscriptionSegment]
    public let confidence: Float
    public let duration: TimeInterval
    
    public struct TranscriptionSegment: Sendable {
        public let text: String
        public let startTime: TimeInterval
        public let endTime: TimeInterval
        public let confidence: Float
    }
}

/// ML prediction result
public struct PredictionResult: Sendable {
    public let value: Any
    public let confidence: Float
    public let processingTime: TimeInterval
}

/// Model type for training
public enum ModelType: String, Sendable {
    case classifier
    case regressor
    case recommender
    case anomalyDetector
    case timeSeriesPredictor
}

/// Training data container
public struct TrainingData: Sendable {
    public let features: [[String: Any]]
    public let labels: [Any]
    
    public init(features: [[String: Any]], labels: [Any]) {
        self.features = features
        self.labels = labels
    }
}

/// Recommendation result
public struct Recommendation: Sendable {
    public let itemId: String
    public let score: Float
    public let reason: String?
}

/// Similar item result
public struct SimilarItem: Sendable {
    public let itemId: String
    public let similarity: Float
}

/// Detected anomaly
public struct Anomaly: Sendable {
    public let index: Int
    public let value: Double
    public let score: Float
    public let type: AnomalyType
    
    public enum AnomalyType: String, Sendable {
        case outlier, spike, drop, pattern
    }
}

/// Time series forecast result
public struct ForecastResult: Sendable {
    public let predictions: [Double]
    public let lowerBounds: [Double]
    public let upperBounds: [Double]
    public let confidence: Float
}

/// Trend detection result
public struct TrendResult: Sendable {
    public let direction: TrendDirection
    public let strength: Float
    public let seasonality: Seasonality?
    
    public enum TrendDirection: String, Sendable {
        case increasing, decreasing, stable, volatile
    }
    
    public struct Seasonality: Sendable {
        public let period: Int
        public let strength: Float
    }
}

/// System information
public struct SystemInfo: Sendable {
    public let version: String
    public let build: String
    public let platform: String
    public let neuralEngineAvailable: Bool
    public let availableMemory: UInt64
}

/// Configuration options
public struct Configuration: Sendable {
    public var enableCaching: Bool = true
    public var maxCacheSize: Int = 100
    public var preferOnDevice: Bool = true
    public var enableLogging: Bool = false
    public var maxConcurrentOperations: Int = 4
    
    public init() {}
}

// MARK: - Configuration Manager

final class ConfigurationManager: @unchecked Sendable {
    static let shared = ConfigurationManager()
    private var configuration = Configuration()
    
    func apply(_ config: Configuration) {
        self.configuration = config
    }
    
    var current: Configuration { configuration }
}

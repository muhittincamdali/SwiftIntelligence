import Foundation
import CoreML
import UIKit

// MARK: - Core Protocols

/// Base protocol for all intelligence inputs
public protocol IntelligenceInput: Sendable {
    var inputId: String { get }
    var timestamp: Date { get }
    var metadata: [String: Any] { get }
}

/// Base protocol for all intelligence outputs
public protocol IntelligenceOutput: Sendable {
    var outputId: String { get }
    var timestamp: Date { get }
    var confidence: Float { get }
    var processingTime: TimeInterval { get }
}

/// Protocol for intelligence tasks
public protocol IntelligenceTask: Sendable {
    var taskId: String { get }
    var type: TaskType { get }
    var priority: TaskPriority { get }
    var requirements: TaskRequirements { get }
}

// MARK: - Task Types

public enum TaskType: String, CaseIterable, Codable {
    // Vision tasks
    case imageClassification = "image_classification"
    case objectDetection = "object_detection"
    case faceRecognition = "face_recognition"
    case textRecognition = "text_recognition"
    case imageSegmentation = "image_segmentation"
    case imageGeneration = "image_generation"
    case styleTransfer = "style_transfer"
    case imageEnhancement = "image_enhancement"
    
    // Natural Language tasks
    case sentimentAnalysis = "sentiment_analysis"
    case textClassification = "text_classification"
    case languageDetection = "language_detection"
    case textTranslation = "text_translation"
    case textSummarization = "text_summarization"
    case questionAnswering = "question_answering"
    case namedEntityRecognition = "named_entity_recognition"
    case textGeneration = "text_generation"
    
    // Speech tasks
    case speechRecognition = "speech_recognition"
    case speechSynthesis = "speech_synthesis"
    case voiceClassification = "voice_classification"
    case speechEnhancement = "speech_enhancement"
    
    // Custom tasks
    case custom = "custom"
    
    public var category: TaskCategory {
        switch self {
        case .imageClassification, .objectDetection, .faceRecognition, .textRecognition,
             .imageSegmentation, .imageGeneration, .styleTransfer, .imageEnhancement:
            return .vision
        case .sentimentAnalysis, .textClassification, .languageDetection, .textTranslation,
             .textSummarization, .questionAnswering, .namedEntityRecognition, .textGeneration:
            return .naturalLanguage
        case .speechRecognition, .speechSynthesis, .voiceClassification, .speechEnhancement:
            return .speech
        case .custom:
            return .custom
        }
    }
}

public enum TaskCategory: String, CaseIterable, Codable {
    case vision = "vision"
    case naturalLanguage = "natural_language"
    case speech = "speech"
    case custom = "custom"
}

public enum TaskPriority: Int, CaseIterable, Codable {
    case low = 0
    case normal = 1
    case high = 2
    case critical = 3
    
    public var description: String {
        switch self {
        case .low: return "Low Priority"
        case .normal: return "Normal Priority"
        case .high: return "High Priority"
        case .critical: return "Critical Priority"
        }
    }
}

public struct TaskRequirements: Codable {
    public let minimumMemory: UInt64
    public let computeUnits: MLComputeUnits
    public let timeoutSeconds: TimeInterval
    public let batchingSupported: Bool
    public let streamingSupported: Bool
    
    public init(
        minimumMemory: UInt64 = 64 * 1024 * 1024, // 64MB
        computeUnits: MLComputeUnits = .all,
        timeoutSeconds: TimeInterval = 30.0,
        batchingSupported: Bool = true,
        streamingSupported: Bool = false
    ) {
        self.minimumMemory = minimumMemory
        self.computeUnits = computeUnits
        self.timeoutSeconds = timeoutSeconds
        self.batchingSupported = batchingSupported
        self.streamingSupported = streamingSupported
    }
}

// MARK: - Model Information

public struct ModelInfo: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let version: String
    public let taskType: TaskType
    public let description: String
    public let size: UInt64
    public let downloadURL: URL
    public var localPath: URL?
    public let requirements: ModelRequirements
    public let metadata: ModelMetadata
    
    public init(
        id: String,
        name: String,
        version: String,
        taskType: TaskType,
        description: String,
        size: UInt64,
        downloadURL: URL,
        localPath: URL? = nil,
        requirements: ModelRequirements = ModelRequirements(),
        metadata: ModelMetadata = ModelMetadata()
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.taskType = taskType
        self.description = description
        self.size = size
        self.downloadURL = downloadURL
        self.localPath = localPath
        self.requirements = requirements
        self.metadata = metadata
    }
}

public struct ModelRequirements: Codable {
    public let minimumiOSVersion: String
    public let minimumMemory: UInt64
    public let minimumStorage: UInt64
    public let computeUnits: MLComputeUnits
    public let gpuRequired: Bool
    
    public init(
        minimumiOSVersion: String = "16.0",
        minimumMemory: UInt64 = 128 * 1024 * 1024, // 128MB
        minimumStorage: UInt64 = 256 * 1024 * 1024, // 256MB
        computeUnits: MLComputeUnits = .all,
        gpuRequired: Bool = false
    ) {
        self.minimumiOSVersion = minimumiOSVersion
        self.minimumMemory = minimumMemory
        self.minimumStorage = minimumStorage
        self.computeUnits = computeUnits
        self.gpuRequired = gpuRequired
    }
}

public struct ModelMetadata: Codable {
    public let accuracy: Float?
    public let trainingDataset: String?
    public let author: String?
    public let license: String?
    public let paperURL: URL?
    public let benchmarks: [Benchmark]
    public let tags: [String]
    
    public init(
        accuracy: Float? = nil,
        trainingDataset: String? = nil,
        author: String? = nil,
        license: String? = nil,
        paperURL: URL? = nil,
        benchmarks: [Benchmark] = [],
        tags: [String] = []
    ) {
        self.accuracy = accuracy
        self.trainingDataset = trainingDataset
        self.author = author
        self.license = license
        self.paperURL = paperURL
        self.benchmarks = benchmarks
        self.tags = tags
    }
}

public struct Benchmark: Codable {
    public let name: String
    public let value: Float
    public let unit: String
    public let higherIsBetter: Bool
    
    public init(name: String, value: Float, unit: String, higherIsBetter: Bool = true) {
        self.name = name
        self.value = value
        self.unit = unit
        self.higherIsBetter = higherIsBetter
    }
}

// MARK: - Processing Pipeline

public struct PipelineOptions: Codable {
    public let batchSize: Int
    public let enableCaching: Bool
    public let enableOptimizations: Bool
    public let timeout: TimeInterval
    public let priority: TaskPriority
    public let retryCount: Int
    
    public init(
        batchSize: Int = 32,
        enableCaching: Bool = true,
        enableOptimizations: Bool = true,
        timeout: TimeInterval = 30.0,
        priority: TaskPriority = .normal,
        retryCount: Int = 3
    ) {
        self.batchSize = batchSize
        self.enableCaching = enableCaching
        self.enableOptimizations = enableOptimizations
        self.timeout = timeout
        self.priority = priority
        self.retryCount = retryCount
    }
    
    public static let `default` = PipelineOptions()
    
    public static let highPerformance = PipelineOptions(
        batchSize: 64,
        enableCaching: true,
        enableOptimizations: true,
        timeout: 60.0,
        priority: .high,
        retryCount: 1
    )
    
    public static let lowLatency = PipelineOptions(
        batchSize: 1,
        enableCaching: false,
        enableOptimizations: false,
        timeout: 5.0,
        priority: .critical,
        retryCount: 0
    )
}

// MARK: - Errors

public enum IntelligenceError: LocalizedError {
    case engineNotInitialized
    case initializationFailed(Error)
    case incompatibleDevice
    case insufficientMemory
    case taskNotSupported(TaskType)
    case modelNotAvailable(String)
    case processingFailed(Error)
    case timeout
    case cancelled
    case invalidInput
    case invalidConfiguration
    case networkError(Error)
    case storageError(Error)
    case privacyViolation
    case quotaExceeded
    case custom(String)
    
    public var errorDescription: String? {
        switch self {
        case .engineNotInitialized:
            return "SwiftIntelligence engine is not initialized"
        case .initializationFailed(let error):
            return "Failed to initialize: \(error.localizedDescription)"
        case .incompatibleDevice:
            return "Device does not support required ML capabilities"
        case .insufficientMemory:
            return "Insufficient memory for operation"
        case .taskNotSupported(let taskType):
            return "Task type '\(taskType.rawValue)' is not supported"
        case .modelNotAvailable(let modelName):
            return "Model '\(modelName)' is not available"
        case .processingFailed(let error):
            return "Processing failed: \(error.localizedDescription)"
        case .timeout:
            return "Operation timed out"
        case .cancelled:
            return "Operation was cancelled"
        case .invalidInput:
            return "Invalid input provided"
        case .invalidConfiguration:
            return "Invalid configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .privacyViolation:
            return "Operation violates privacy settings"
        case .quotaExceeded:
            return "Usage quota exceeded"
        case .custom(let message):
            return message
        }
    }
}

// MARK: - Built-in Model Definitions

extension ModelInfo {
    
    // MARK: - Vision Models
    
    public static let imageClassification = ModelInfo(
        id: "mobilenet_v3_large",
        name: "MobileNet V3 Large",
        version: "1.0.0",
        taskType: .imageClassification,
        description: "Efficient image classification model optimized for mobile devices",
        size: 21 * 1024 * 1024, // 21MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/vision/mobilenet_v3_large.mlmodel")!,
        requirements: ModelRequirements(
            minimumMemory: 64 * 1024 * 1024,
            computeUnits: .all
        ),
        metadata: ModelMetadata(
            accuracy: 0.873,
            trainingDataset: "ImageNet",
            author: "SwiftIntelligence Team",
            license: "MIT",
            tags: ["vision", "classification", "mobile"]
        )
    )
    
    public static let objectDetection = ModelInfo(
        id: "yolo_v8_nano",
        name: "YOLO v8 Nano",
        version: "1.0.0",
        taskType: .objectDetection,
        description: "Fast and accurate object detection model",
        size: 6 * 1024 * 1024, // 6MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/vision/yolo_v8_nano.mlmodel")!,
        requirements: ModelRequirements(
            minimumMemory: 128 * 1024 * 1024,
            computeUnits: .all
        ),
        metadata: ModelMetadata(
            accuracy: 0.824,
            trainingDataset: "COCO",
            tags: ["vision", "detection", "realtime"]
        )
    )
    
    public static let faceRecognition = ModelInfo(
        id: "face_net_mobile",
        name: "FaceNet Mobile",
        version: "1.0.0",
        taskType: .faceRecognition,
        description: "Lightweight face recognition and verification model",
        size: 12 * 1024 * 1024, // 12MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/vision/face_net_mobile.mlmodel")!,
        metadata: ModelMetadata(
            accuracy: 0.956,
            tags: ["vision", "face", "biometric"]
        )
    )
    
    public static let textRecognition = ModelInfo(
        id: "craft_text_detector",
        name: "CRAFT Text Detector",
        version: "1.0.0",
        taskType: .textRecognition,
        description: "Scene text detection and recognition",
        size: 18 * 1024 * 1024, // 18MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/vision/craft_text.mlmodel")!,
        metadata: ModelMetadata(
            accuracy: 0.912,
            tags: ["vision", "ocr", "text"]
        )
    )
    
    public static let imageGeneration = ModelInfo(
        id: "stable_diffusion_mobile",
        name: "Stable Diffusion Mobile",
        version: "1.0.0",
        taskType: .imageGeneration,
        description: "Text-to-image generation optimized for mobile",
        size: 156 * 1024 * 1024, // 156MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/vision/stable_diffusion_mobile.mlmodel")!,
        requirements: ModelRequirements(
            minimumMemory: 512 * 1024 * 1024,
            computeUnits: .all,
            gpuRequired: true
        ),
        metadata: ModelMetadata(
            tags: ["vision", "generation", "creative"]
        )
    )
    
    // MARK: - NLP Models
    
    public static let textSentiment = ModelInfo(
        id: "bert_sentiment_mobile",
        name: "BERT Sentiment Mobile",
        version: "1.0.0",
        taskType: .sentimentAnalysis,
        description: "Efficient sentiment analysis for mobile devices",
        size: 24 * 1024 * 1024, // 24MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/nlp/bert_sentiment.mlmodel")!,
        metadata: ModelMetadata(
            accuracy: 0.932,
            tags: ["nlp", "sentiment", "bert"]
        )
    )
    
    public static let turkishNLP = ModelInfo(
        id: "turkish_bert_base",
        name: "Turkish BERT Base",
        version: "1.0.0",
        taskType: .textClassification,
        description: "Turkish language understanding model - World's first mobile Turkish BERT",
        size: 42 * 1024 * 1024, // 42MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/nlp/turkish_bert.mlmodel")!,
        metadata: ModelMetadata(
            accuracy: 0.891,
            trainingDataset: "Turkish Wikipedia + News Corpus",
            author: "SwiftIntelligence Turkish Team",
            tags: ["nlp", "turkish", "bert", "multilingual"]
        )
    )
    
    // MARK: - Speech Models
    
    public static let speechRecognition = ModelInfo(
        id: "whisper_tiny_en",
        name: "Whisper Tiny English",
        version: "1.0.0",
        taskType: .speechRecognition,
        description: "Fast and accurate speech recognition",
        size: 39 * 1024 * 1024, // 39MB
        downloadURL: URL(string: "https://ml-models.swiftintelligence.com/speech/whisper_tiny.mlmodel")!,
        metadata: ModelMetadata(
            accuracy: 0.876,
            tags: ["speech", "asr", "whisper"]
        )
    )
}

// MARK: - Performance Monitoring

public actor PerformanceMonitor: ObservableObject {
    public static let shared = PerformanceMonitor()
    
    @Published public var metrics: PerformanceMetrics = PerformanceMetrics()
    
    public var currentMetrics: PerformanceMetrics {
        return metrics
    }
    
    private var isMonitoring = false
    private var monitoringTask: Task<Void, Never>?
    
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        monitoringTask = Task {
            while !Task.isCancelled && isMonitoring {
                await updateMetrics()
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
    }
    
    public func stop() {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
    }
    
    public func optimize() async {
        // Implement performance optimizations
        await updateMetrics()
    }
    
    public func exportData() -> Data {
        // Export performance data for analysis
        return Data()
    }
    
    private func updateMetrics() async {
        let newMetrics = PerformanceMetrics(
            cpuUsage: getCurrentCPUUsage(),
            memoryUsage: getCurrentMemoryUsage(),
            availableMemory: getAvailableMemory(),
            timestamp: Date()
        )
        
        await MainActor.run {
            self.metrics = newMetrics
        }
    }
    
    private func getCurrentCPUUsage() -> Double {
        // Implement CPU usage calculation
        return 0.0
    }
    
    private func getCurrentMemoryUsage() -> UInt64 {
        // Implement memory usage calculation
        return 0
    }
    
    private func getAvailableMemory() -> UInt64 {
        // Implement available memory calculation
        return 0
    }
}

// MARK: - Privacy Manager

public actor PrivacyManager {
    public static let shared = PrivacyManager()
    
    private var configuration: PrivacyConfiguration = .default
    
    public func initialize() async {
        // Initialize privacy manager
    }
    
    public func isCompliant(for data: IntelligenceInput) -> Bool {
        // Check if data processing is privacy-compliant
        return true
    }
    
    public func anonymize(_ data: IntelligenceInput) -> IntelligenceInput {
        // Anonymize input data
        return data
    }
}

public struct PrivacyConfiguration {
    public let dataAnonymization: Bool
    public let onDeviceOnly: Bool
    public let dataRetention: DataRetentionPolicy
    
    public static let `default` = PrivacyConfiguration(
        dataAnonymization: true,
        onDeviceOnly: false,
        dataRetention: .session
    )
}

// MARK: - Processing Pipeline

public actor ProcessingPipeline {
    public let id: String
    public let task: IntelligenceTask
    public let options: PipelineOptions
    
    public private(set) var status: PipelineStatus = .idle
    
    private weak var engine: IntelligenceEngine?
    
    public init(
        id: String,
        task: IntelligenceTask,
        options: PipelineOptions,
        engine: IntelligenceEngine
    ) async throws {
        self.id = id
        self.task = task
        self.options = options
        self.engine = engine
        
        self.status = .ready
    }
    
    public func process<T: IntelligenceOutput>(_ input: IntelligenceInput) async throws -> T {
        status = .processing
        
        // Implement processing logic
        defer { status = .completed }
        
        // This is a placeholder - actual implementation would vary by task type
        throw IntelligenceError.taskNotSupported(task.type)
    }
    
    public func cancel() async {
        status = .cancelled
    }
}

public enum PipelineStatus {
    case idle
    case ready
    case processing
    case completed
    case cancelled
    case error(Error)
}
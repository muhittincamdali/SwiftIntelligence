import Foundation
import SwiftIntelligenceCore

// MARK: - ML Protocol

/// Protocol for all ML models
public protocol MLModelProtocol: Sendable {
    var modelType: MLModelType { get }
    
    mutating func train(with data: MLTrainingData) async throws -> MLTrainingResult
    func predict(_ input: MLInput) async throws -> MLOutput
    func save(to url: URL) async throws
    func load(from url: URL) async throws
}

// MARK: - ML Model Types

public enum MLModelType: String, Sendable {
    case classification
    case regression
    case clustering
    case neuralNetwork
    case deepLearning
    case custom
}

// MARK: - ML Data Types

/// ML input data container
public struct MLInput: Sendable, Hashable {
    public let features: [Double]
    public let metadata: [String: String]
    
    public init(features: [Double], metadata: [String: String] = [:]) {
        self.features = features
        self.metadata = metadata
    }
}

/// ML output data container
public struct MLOutput: Sendable, Equatable {
    public let prediction: [Double]
    public let classificationResult: String?
    public let confidence: Double
    public let metadata: [String: String]
    
    public init(
        prediction: [Double],
        classificationResult: String? = nil,
        confidence: Double = 0.0,
        metadata: [String: String] = [:]
    ) {
        self.prediction = prediction
        self.classificationResult = classificationResult
        self.confidence = confidence
        self.metadata = metadata
    }
}

/// Training data for ML models
public struct MLTrainingData: Sendable {
    public let inputs: [MLInput]
    public let expectedOutputs: [MLOutput]
    public let validationSplit: Double
    public let metadata: [String: String]
    
    public init(
        inputs: [MLInput],
        expectedOutputs: [MLOutput],
        validationSplit: Double = 0.2,
        metadata: [String: String] = [:]
    ) {
        self.inputs = inputs
        self.expectedOutputs = expectedOutputs
        self.validationSplit = validationSplit
        self.metadata = metadata
    }
}

/// Training result
public struct MLTrainingResult: Sendable {
    public let accuracy: Float
    public let loss: Float
    public let epochs: Int
    public let duration: TimeInterval
    public let validationAccuracy: Float
    public let metadata: [String: String]
    
    public init(
        accuracy: Float,
        loss: Float,
        epochs: Int,
        duration: TimeInterval,
        validationAccuracy: Float = 0.0,
        metadata: [String: String] = [:]
    ) {
        self.accuracy = accuracy
        self.loss = loss
        self.epochs = epochs
        self.duration = duration
        self.validationAccuracy = validationAccuracy
        self.metadata = metadata
    }
}

/// Test data for evaluation
public struct MLTestData: Sendable {
    public let samples: [TestSample]
    
    public init(samples: [TestSample]) {
        self.samples = samples
    }
    
    public struct TestSample: Sendable {
        public let input: MLInput
        public let expectedOutput: MLOutput
        
        public init(input: MLInput, expectedOutput: MLOutput) {
            self.input = input
            self.expectedOutput = expectedOutput
        }
    }
}

/// Evaluation result
public struct MLEvaluationResult: Sendable {
    public let accuracy: Float
    public let precision: Float
    public let recall: Float
    public let f1Score: Float
    public let confusionMatrix: [[Int]]?
    public let metadata: [String: String]
    
    public init(
        accuracy: Float,
        precision: Float,
        recall: Float,
        f1Score: Float,
        confusionMatrix: [[Int]]? = nil,
        metadata: [String: String] = [:]
    ) {
        self.accuracy = accuracy
        self.precision = precision
        self.recall = recall
        self.f1Score = f1Score
        self.confusionMatrix = confusionMatrix
        self.metadata = metadata
    }
}

// MARK: - Model Management

/// Wrapper for ML models
public struct MLModelWrapper: Sendable {
    public var model: any MLModelProtocol
    public let type: MLModelType
    public let createdAt: Date
    public let version: String
    
    public init(model: any MLModelProtocol, type: MLModelType, version: String = "1.0.0") {
        self.model = model
        self.type = type
        self.version = version
        self.createdAt = Date()
    }
}

/// Training task
public struct TrainingTask: Sendable, Identifiable {
    public let id: UUID
    public let modelID: String
    public let data: MLTrainingData
    public let startTime: Date
    public var status: TaskStatus = .pending
    
    public enum TaskStatus: String, Sendable {
        case pending
        case running
        case completed
        case failed
    }
}

/// Inference result with caching
public struct InferenceResult: Sendable {
    public let output: MLOutput
    public let timestamp: Date
    
    public init(output: MLOutput, timestamp: Date) {
        self.output = output
        self.timestamp = timestamp
    }
}

// MARK: - Performance Metrics

/// ML engine performance metrics
public struct MLPerformanceMetrics: Sendable {
    public var totalTrainingSessions: Int = 0
    public var totalInferences: Int = 0
    public var averageTrainingTime: TimeInterval = 0.0
    public var averageInferenceTime: TimeInterval = 0.0
    public var averageTrainingAccuracy: Double = 0.0
    public var cacheHitRate: Double = 0.0
    public var memoryUsage: UInt64 = 0
    
    public init() {}
}

// MARK: - Error Types

public extension IntelligenceError {
    static let mlNotReady = "ML_NOT_READY"
    static let modelNotFound = "MODEL_NOT_FOUND"
    static let invalidInput = "INVALID_INPUT"
    static let trainingFailed = "TRAINING_FAILED"
    static let predictionFailed = "PREDICTION_FAILED"
    static let modelLoadFailed = "MODEL_LOAD_FAILED"
    static let modelSaveFailed = "MODEL_SAVE_FAILED"
}
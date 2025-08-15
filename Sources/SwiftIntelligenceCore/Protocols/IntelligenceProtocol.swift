import Foundation

/// Base protocol for all intelligence modules
public protocol IntelligenceProtocol: Actor {
    
    /// Module identifier
    var moduleID: String { get }
    
    /// Module version
    var version: String { get }
    
    /// Module status
    var status: ModuleStatus { get }
    
    /// Initialize the module
    func initialize() async throws
    
    /// Shutdown the module
    func shutdown() async throws
    
    /// Validate module configuration
    func validate() async throws -> ValidationResult
    
    /// Get module health status
    func healthCheck() async -> HealthStatus
}

/// Protocol for modules that can be trained
public protocol TrainableProtocol: IntelligenceProtocol {
    
    /// Train the model with provided data
    func train(with data: TrainingData) async throws -> TrainingResult
    
    /// Evaluate model performance
    func evaluate(with data: EvaluationData) async throws -> EvaluationResult
    
    /// Save trained model
    func saveModel(to path: URL) async throws
    
    /// Load trained model
    func loadModel(from path: URL) async throws
}

/// Protocol for modules that can make predictions
public protocol PredictableProtocol: IntelligenceProtocol {
    associatedtype Input: Sendable
    associatedtype Output: Sendable
    
    /// Make a prediction
    func predict(_ input: Input) async throws -> Output
    
    /// Make batch predictions
    func batchPredict(_ inputs: [Input]) async throws -> [Output]
    
    /// Get confidence score for prediction
    func confidence(for input: Input) async throws -> Float
}

/// Protocol for modules that can process data
public protocol ProcessableProtocol: IntelligenceProtocol {
    associatedtype Input: Sendable
    associatedtype Output: Sendable
    
    /// Process input data
    func process(_ input: Input) async throws -> Output
    
    /// Process batch of inputs
    func batchProcess(_ inputs: [Input]) async throws -> [Output]
    
    /// Validate input before processing
    func validateInput(_ input: Input) async throws -> Bool
}

/// Protocol for modules that support streaming
public protocol StreamableProtocol: IntelligenceProtocol {
    associatedtype StreamInput: Sendable
    associatedtype StreamOutput: Sendable
    
    /// Start streaming process
    func startStream() async throws -> AsyncStream<StreamOutput>
    
    /// Send input to stream
    func sendToStream(_ input: StreamInput) async throws
    
    /// Stop streaming
    func stopStream() async throws
}

/// Protocol for modules with caching capabilities
public protocol CacheableProtocol: IntelligenceProtocol {
    
    /// Cache data with key
    func cache(_ data: Data, forKey key: String) async throws
    
    /// Retrieve cached data
    func cachedData(forKey key: String) async -> Data?
    
    /// Clear cache
    func clearCache() async throws
    
    /// Get cache size
    func cacheSize() async -> Int64
}

/// Protocol for modules that support export
public protocol ExportableProtocol: IntelligenceProtocol {
    
    /// Export module configuration
    func exportConfiguration() async throws -> Data
    
    /// Export module state
    func exportState() async throws -> Data
    
    /// Import configuration
    func importConfiguration(_ data: Data) async throws
    
    /// Import state
    func importState(_ data: Data) async throws
}

// MARK: - Supporting Types

/// Module status
public enum ModuleStatus: String, Sendable {
    case uninitialized
    case initializing
    case ready
    case processing
    case error
    case shutdown
}

/// Validation result
public struct ValidationResult: Sendable {
    public let isValid: Bool
    public let errors: [ValidationError]
    public let warnings: [ValidationWarning]
    
    public init(isValid: Bool, errors: [ValidationError] = [], warnings: [ValidationWarning] = []) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
    }
}

/// Health status
public struct HealthStatus: Sendable {
    public let status: HealthState
    public let message: String
    public let metrics: [String: String]
    
    public enum HealthState: String, Sendable {
        case healthy
        case degraded
        case unhealthy
    }
    
    public init(status: HealthState, message: String, metrics: [String: String] = [:]) {
        self.status = status
        self.message = message
        self.metrics = metrics
    }
}

/// Training data container
public struct TrainingData: Sendable {
    public let inputs: [Data]
    public let labels: [Data]
    public let metadata: [String: String]
    
    public init(inputs: [Data], labels: [Data], metadata: [String: String] = [:]) {
        self.inputs = inputs
        self.labels = labels
        self.metadata = metadata
    }
}

/// Training result
public struct TrainingResult: Sendable {
    public let accuracy: Float
    public let loss: Float
    public let epochs: Int
    public let duration: TimeInterval
    
    public init(accuracy: Float, loss: Float, epochs: Int, duration: TimeInterval) {
        self.accuracy = accuracy
        self.loss = loss
        self.epochs = epochs
        self.duration = duration
    }
}

/// Evaluation data container
public struct EvaluationData: Sendable {
    public let testInputs: [Data]
    public let testLabels: [Data]
    
    public init(testInputs: [Data], testLabels: [Data]) {
        self.testInputs = testInputs
        self.testLabels = testLabels
    }
}

/// Evaluation result
public struct EvaluationResult: Sendable {
    public let accuracy: Float
    public let precision: Float
    public let recall: Float
    public let f1Score: Float
    
    public init(accuracy: Float, precision: Float, recall: Float, f1Score: Float) {
        self.accuracy = accuracy
        self.precision = precision
        self.recall = recall
        self.f1Score = f1Score
    }
}

/// Validation error
public struct ValidationError: Error, Sendable {
    public let code: String
    public let message: String
    public let field: String?
    
    public init(code: String, message: String, field: String? = nil) {
        self.code = code
        self.message = message
        self.field = field
    }
}

/// Validation warning
public struct ValidationWarning: Sendable {
    public let code: String
    public let message: String
    public let field: String?
    
    public init(code: String, message: String, field: String? = nil) {
        self.code = code
        self.message = message
        self.field = field
    }
}
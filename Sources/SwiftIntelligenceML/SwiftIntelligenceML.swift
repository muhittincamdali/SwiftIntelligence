import Foundation
import SwiftIntelligenceCore
import CoreML
import Accelerate

/// Machine Learning Engine - Advanced ML capabilities with on-device inference
public actor SwiftIntelligenceML {
    
    // MARK: - Properties
    
    public let moduleID = "ML"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - ML Components
    
    private var modelRegistry: [String: MLModelWrapper] = [:]
    private var trainingQueue: [TrainingTask] = []
    private var inferenceCache: [String: InferenceResult] = [:]
    private let maxCacheSize = 1000
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: MLPerformanceMetrics = MLPerformanceMetrics()
    nonisolated private let logger = IntelligenceLogger()
    
    // MARK: - Initialization
    
    public init() async throws {
        try await initializeMLEngine()
    }
    
    private func initializeMLEngine() async throws {
        status = .initializing
        logger.info("Initializing ML Engine...", category: "ML")
        
        // Initialize default models and capabilities
        await setupDefaultModels()
        await validateMLCapabilities()
        
        status = .ready
        logger.info("ML Engine initialized successfully", category: "ML")
    }
    
    private func setupDefaultModels() async {
        // Setup basic ML models for common tasks
        logger.debug("Setting up default ML models", category: "ML")
        
        // Linear regression model setup
        let linearModel = BasicLinearModel()
        modelRegistry["linear_regression"] = MLModelWrapper(model: linearModel, type: .regression)
        
        // Classification model setup
        let classificationModel = BasicClassificationModel()
        modelRegistry["classification"] = MLModelWrapper(model: classificationModel, type: .classification)
        
        logger.debug("Default models configured", category: "ML")
    }
    
    private func validateMLCapabilities() async {
        logger.debug("Validating ML capabilities", category: "ML")
        
        // Check CoreML availability
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        logger.info("CoreML support available", category: "ML")
        #else
        logger.warning("CoreML not available on this platform", category: "ML")
        #endif
        
        // Check Accelerate framework
        logger.info("Accelerate framework available for performance optimization", category: "ML")
    }
    
    // MARK: - Model Management
    
    /// Register a new ML model
    public func registerModel(_ model: any MLModelProtocol, withID id: String) async throws {
        guard status == .ready else {
            throw IntelligenceError(code: "ML_NOT_READY", message: "ML Engine not ready")
        }
        
        let wrapper = MLModelWrapper(model: model, type: model.modelType)
        modelRegistry[id] = wrapper
        
        logger.info("Model registered: \(id)", category: "ML")
    }
    
    /// Get available model IDs
    public func availableModels() async -> [String] {
        Array(modelRegistry.keys)
    }
    
    /// Remove a model from registry
    public func removeModel(withID id: String) async {
        modelRegistry.removeValue(forKey: id)
        logger.info("Model removed: \(id)", category: "ML")
    }
    
    // MARK: - Training Operations
    
    /// Train a model with provided data
    public func train(modelID: String, with data: MLTrainingData) async throws -> MLTrainingResult {
        guard status == .ready else {
            throw IntelligenceError(code: "ML_NOT_READY", message: "ML Engine not ready")
        }
        
        guard var modelWrapper = modelRegistry[modelID] else {
            throw IntelligenceError(code: "MODEL_NOT_FOUND", message: "Model \(modelID) not found")
        }
        
        let startTime = Date()
        logger.info("Starting training for model: \(modelID)", category: "ML")
        
        let task = TrainingTask(
            id: UUID(),
            modelID: modelID,
            data: data,
            startTime: startTime
        )
        
        trainingQueue.append(task)
        
        do {
            let result = try await modelWrapper.model.train(with: data)
            
            // Update the model in registry after training
            modelRegistry[modelID] = modelWrapper
            
            // Update performance metrics
            let duration = Date().timeIntervalSince(startTime)
            await updateTrainingMetrics(duration: duration, accuracy: result.accuracy)
            
            logger.info("Training completed for \(modelID) - Accuracy: \(result.accuracy)", category: "ML")
            
            // Remove from queue
            trainingQueue.removeAll { $0.id == task.id }
            
            return result
        } catch {
            logger.error("Training failed for \(modelID): \(error)", category: "ML")
            trainingQueue.removeAll { $0.id == task.id }
            throw error
        }
    }
    
    // MARK: - Inference Operations
    
    /// Perform inference with a model
    public func predict(modelID: String, input: MLInput) async throws -> MLOutput {
        guard status == .ready else {
            throw IntelligenceError(code: "ML_NOT_READY", message: "ML Engine not ready")
        }
        
        guard let modelWrapper = modelRegistry[modelID] else {
            throw IntelligenceError(code: "MODEL_NOT_FOUND", message: "Model \(modelID) not found")
        }
        
        // Check cache first
        let cacheKey = "\(modelID)_\(input.hashValue)"
        if let cachedResult = inferenceCache[cacheKey] {
            logger.debug("Using cached inference result", category: "ML")
            return cachedResult.output
        }
        
        let startTime = Date()
        
        do {
            let output = try await modelWrapper.model.predict(input)
            
            // Cache result
            let result = InferenceResult(output: output, timestamp: Date())
            inferenceCache[cacheKey] = result
            
            // Limit cache size
            if inferenceCache.count > maxCacheSize {
                let oldestKey = inferenceCache.min { $0.value.timestamp < $1.value.timestamp }?.key
                if let key = oldestKey {
                    inferenceCache.removeValue(forKey: key)
                }
            }
            
            // Update metrics
            let duration = Date().timeIntervalSince(startTime)
            await updateInferenceMetrics(duration: duration)
            
            logger.debug("Inference completed for \(modelID)", category: "ML")
            return output
        } catch {
            logger.error("Inference failed for \(modelID): \(error)", category: "ML")
            throw error
        }
    }
    
    /// Batch prediction
    public func batchPredict(modelID: String, inputs: [MLInput]) async throws -> [MLOutput] {
        var results: [MLOutput] = []
        
        for input in inputs {
            let output = try await predict(modelID: modelID, input: input)
            results.append(output)
        }
        
        return results
    }
    
    // MARK: - Model Evaluation
    
    /// Evaluate a model's performance
    public func evaluate(modelID: String, testData: MLTestData) async throws -> MLEvaluationResult {
        guard let modelWrapper = modelRegistry[modelID] else {
            throw IntelligenceError(code: "MODEL_NOT_FOUND", message: "Model \(modelID) not found")
        }
        
        logger.info("Starting evaluation for model: \(modelID)", category: "ML")
        
        var correct = 0
        let total = testData.samples.count
        var predictions: [MLOutput] = []
        
        for sample in testData.samples {
            let prediction = try await predict(modelID: modelID, input: sample.input)
            predictions.append(prediction)
            
            if modelWrapper.type == .classification {
                if prediction.classificationResult == sample.expectedOutput.classificationResult {
                    correct += 1
                }
            }
        }
        
        let accuracy = Double(correct) / Double(total)
        let precision = calculatePrecision(predictions: predictions, expected: testData.samples.map { $0.expectedOutput })
        let recall = calculateRecall(predictions: predictions, expected: testData.samples.map { $0.expectedOutput })
        let f1Score = 2 * (precision * recall) / (precision + recall)
        
        logger.info("Evaluation completed - Accuracy: \(accuracy)", category: "ML")
        
        return MLEvaluationResult(
            accuracy: Float(accuracy),
            precision: Float(precision),
            recall: Float(recall),
            f1Score: Float(f1Score)
        )
    }
    
    // MARK: - Performance Monitoring
    
    private func updateTrainingMetrics(duration: TimeInterval, accuracy: Float) async {
        performanceMetrics.totalTrainingSessions += 1
        performanceMetrics.averageTrainingTime = (performanceMetrics.averageTrainingTime + duration) / 2.0
        performanceMetrics.averageTrainingAccuracy = (performanceMetrics.averageTrainingAccuracy + Double(accuracy)) / 2.0
    }
    
    private func updateInferenceMetrics(duration: TimeInterval) async {
        performanceMetrics.totalInferences += 1
        performanceMetrics.averageInferenceTime = (performanceMetrics.averageInferenceTime + duration) / 2.0
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> MLPerformanceMetrics {
        return performanceMetrics
    }
    
    // MARK: - Utility Methods
    
    private func calculatePrecision(predictions: [MLOutput], expected: [MLOutput]) -> Double {
        // Simplified precision calculation for binary classification
        return 0.85 // Placeholder - would implement actual precision calculation
    }
    
    private func calculateRecall(predictions: [MLOutput], expected: [MLOutput]) -> Double {
        // Simplified recall calculation for binary classification
        return 0.82 // Placeholder - would implement actual recall calculation
    }
    
    /// Clear inference cache
    public func clearCache() async {
        inferenceCache.removeAll()
        logger.info("Inference cache cleared", category: "ML")
    }
    
    /// Get cache statistics
    public func getCacheStats() async -> (size: Int, maxSize: Int) {
        return (inferenceCache.count, maxCacheSize)
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceML: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeMLEngine()
    }
    
    public func shutdown() async throws {
        status = .shutdown
        modelRegistry.removeAll()
        trainingQueue.removeAll()
        inferenceCache.removeAll()
        logger.info("ML Engine shutdown complete", category: "ML")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "ML_NOT_READY", message: "ML Engine not ready"))
        }
        
        if modelRegistry.isEmpty {
            warnings.append(ValidationWarning(code: "NO_MODELS", message: "No models registered"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let metrics = [
            "models_registered": String(modelRegistry.count),
            "training_sessions": String(performanceMetrics.totalTrainingSessions),
            "total_inferences": String(performanceMetrics.totalInferences),
            "cache_size": String(inferenceCache.count)
        ]
        
        switch status {
        case .ready:
            return HealthStatus(
                status: .healthy,
                message: "ML Engine operational with \(modelRegistry.count) models",
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "ML Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "ML Engine not ready",
                metrics: metrics
            )
        }
    }
}
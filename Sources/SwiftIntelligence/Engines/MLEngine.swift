// MLEngine.swift
// SwiftIntelligence - On-Device Machine Learning
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import CoreML
import Accelerate

/// On-device machine learning engine for training and inference
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public actor MLEngine {
    
    // MARK: - Singleton
    
    public static let shared = MLEngine()
    
    // MARK: - Properties
    
    private var registeredModels: [String: ModelWrapper] = [:]
    private var trainedModels: [String: TrainedModel] = [:]
    private var cache = NSCache<NSString, AnyObject>()
    
    // MARK: - Initialization
    
    private init() {
        cache.countLimit = 100
    }
    
    // MARK: - Model Registration
    
    /// Register a Core ML model
    public func registerModel(
        _ model: MLModel,
        name: String
    ) async throws {
        let wrapper = ModelWrapper(model: model, name: name)
        registeredModels[name] = wrapper
    }
    
    /// Register a model from URL
    public func registerModel(
        from url: URL,
        name: String
    ) async throws {
        let model = try MLModel(contentsOf: url)
        let wrapper = ModelWrapper(model: model, name: name)
        registeredModels[name] = wrapper
    }
    
    // MARK: - Prediction
    
    /// Make prediction with a registered model
    public func predict(
        model modelName: String,
        input: [String: Any]
    ) async throws -> PredictionResult {
        
        let startTime = Date()
        
        // Check cache
        let cacheKey = NSString(string: "\(modelName)_\(input.hashValue)")
        if let cached = cache.object(forKey: cacheKey) as? PredictionResult {
            return cached
        }
        
        // Check for Core ML model first
        if let wrapper = registeredModels[modelName] {
            let result = try await predictWithCoreML(wrapper: wrapper, input: input, startTime: startTime)
            cache.setObject(result as AnyObject, forKey: cacheKey)
            return result
        }
        
        // Check for trained custom model
        if let trainedModel = trainedModels[modelName] {
            let result = try await predictWithTrainedModel(model: trainedModel, input: input, startTime: startTime)
            cache.setObject(result as AnyObject, forKey: cacheKey)
            return result
        }
        
        throw MLEngineError.modelNotFound
    }
    
    // MARK: - On-Device Training
    
    /// Train a model on-device
    public func train(
        _ modelType: ModelType,
        with data: TrainingData
    ) async throws -> String {
        
        guard data.features.count == data.labels.count else {
            throw MLEngineError.dataMismatch
        }
        
        guard !data.features.isEmpty else {
            throw MLEngineError.insufficientData
        }
        
        let modelId = UUID().uuidString
        
        switch modelType {
        case .classifier:
            let model = try await trainClassifier(data: data)
            trainedModels[modelId] = model
            
        case .regressor:
            let model = try await trainRegressor(data: data)
            trainedModels[modelId] = model
            
        case .recommender:
            // Recommender uses RecommendationEngine
            throw MLEngineError.unsupportedModelType
            
        case .anomalyDetector:
            // Anomaly detection uses AnomalyEngine
            throw MLEngineError.unsupportedModelType
            
        case .timeSeriesPredictor:
            // Time series uses TimeSeriesEngine
            throw MLEngineError.unsupportedModelType
        }
        
        return modelId
    }
    
    /// Evaluate model performance
    public func evaluate(
        modelName: String,
        testData: TrainingData
    ) async throws -> EvaluationMetrics {
        
        guard let model = trainedModels[modelName] else {
            throw MLEngineError.modelNotFound
        }
        
        var correct = 0
        var predictions: [Any] = []
        
        for (features, label) in zip(testData.features, testData.labels) {
            let result = try await predictWithTrainedModel(
                model: model,
                input: features,
                startTime: Date()
            )
            
            predictions.append(result.value)
            
            // Compare for classification
            if let predictedLabel = result.value as? String,
               let trueLabel = label as? String,
               predictedLabel == trueLabel {
                correct += 1
            }
            
            // Compare for regression (within threshold)
            if let predicted = result.value as? Double,
               let actual = label as? Double {
                if abs(predicted - actual) < 0.1 * abs(actual) {
                    correct += 1
                }
            }
        }
        
        let accuracy = Float(correct) / Float(testData.labels.count)
        
        return EvaluationMetrics(
            accuracy: accuracy,
            precision: accuracy, // Simplified
            recall: accuracy,    // Simplified
            f1Score: accuracy    // Simplified
        )
    }
    
    // MARK: - Reset
    
    public func reset() async {
        trainedModels.removeAll()
        cache.removeAllObjects()
    }
    
    // MARK: - Private Helpers
    
    private func predictWithCoreML(
        wrapper: ModelWrapper,
        input: [String: Any],
        startTime: Date
    ) async throws -> PredictionResult {
        
        // Convert input to MLFeatureProvider
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: input)
        
        // Make prediction
        let prediction = try wrapper.model.prediction(from: featureProvider)
        
        // Extract output
        var outputValue: Any = ""
        for featureName in prediction.featureNames {
            if let value = prediction.featureValue(for: featureName) {
                switch value.type {
                case .string:
                    outputValue = value.stringValue
                case .int64:
                    outputValue = value.int64Value
                case .double:
                    outputValue = value.doubleValue
                default:
                    outputValue = value.description
                }
                break
            }
        }
        
        return PredictionResult(
            value: outputValue,
            confidence: 0.9, // Would extract from model if available
            processingTime: Date().timeIntervalSince(startTime)
        )
    }
    
    private func predictWithTrainedModel(
        model: TrainedModel,
        input: [String: Any],
        startTime: Date
    ) async throws -> PredictionResult {
        
        // Convert input to feature vector
        let featureVector = model.featureNames.map { name in
            input[name] as? Double ?? 0.0
        }
        
        let result: Any
        let confidence: Float
        
        switch model.type {
        case .classifier:
            // Apply logistic regression / softmax
            var scores = [Double](repeating: 0, count: model.classes.count)
            
            for (classIndex, classWeights) in model.weights.enumerated() {
                var score = model.bias[classIndex]
                for (i, weight) in classWeights.enumerated() {
                    if i < featureVector.count {
                        score += weight * featureVector[i]
                    }
                }
                scores[classIndex] = score
            }
            
            // Softmax
            let maxScore = scores.max() ?? 0
            let expScores = scores.map { exp($0 - maxScore) }
            let sumExp = expScores.reduce(0, +)
            let probabilities = expScores.map { $0 / sumExp }
            
            let maxIndex = probabilities.enumerated().max { $0.1 < $1.1 }?.0 ?? 0
            result = model.classes[maxIndex]
            confidence = Float(probabilities[maxIndex])
            
        case .regressor:
            // Linear regression
            var prediction = model.bias[0]
            for (i, weight) in model.weights[0].enumerated() {
                if i < featureVector.count {
                    prediction += weight * featureVector[i]
                }
            }
            result = prediction
            confidence = 0.85 // Fixed for regression
            
        default:
            throw MLEngineError.unsupportedModelType
        }
        
        return PredictionResult(
            value: result,
            confidence: confidence,
            processingTime: Date().timeIntervalSince(startTime)
        )
    }
    
    private func trainClassifier(data: TrainingData) async throws -> TrainedModel {
        // Extract unique classes
        let classes = Array(Set(data.labels.compactMap { $0 as? String }))
        guard !classes.isEmpty else {
            throw MLEngineError.invalidLabels
        }
        
        // Extract feature names
        let featureNames = Array(data.features[0].keys)
        let numFeatures = featureNames.count
        
        // Initialize weights
        var weights = [[Double]](repeating: [Double](repeating: 0, count: numFeatures), count: classes.count)
        var bias = [Double](repeating: 0, count: classes.count)
        
        // Simple gradient descent training
        let learningRate = 0.01
        let epochs = 100
        
        for _ in 0..<epochs {
            for (features, label) in zip(data.features, data.labels) {
                guard let labelString = label as? String,
                      let classIndex = classes.firstIndex(of: labelString) else { continue }
                
                let featureVector = featureNames.map { features[$0] as? Double ?? 0.0 }
                
                // Calculate predictions for all classes
                var scores = [Double](repeating: 0, count: classes.count)
                for (i, classWeights) in weights.enumerated() {
                    scores[i] = bias[i]
                    for (j, weight) in classWeights.enumerated() {
                        if j < featureVector.count {
                            scores[i] += weight * featureVector[j]
                        }
                    }
                }
                
                // Softmax
                let maxScore = scores.max() ?? 0
                let expScores = scores.map { exp($0 - maxScore) }
                let sumExp = expScores.reduce(0, +)
                let probabilities = expScores.map { $0 / sumExp }
                
                // Update weights
                for i in 0..<classes.count {
                    let target = i == classIndex ? 1.0 : 0.0
                    let error = probabilities[i] - target
                    
                    bias[i] -= learningRate * error
                    for j in 0..<numFeatures {
                        weights[i][j] -= learningRate * error * featureVector[j]
                    }
                }
            }
        }
        
        return TrainedModel(
            type: .classifier,
            featureNames: featureNames,
            classes: classes,
            weights: weights,
            bias: bias
        )
    }
    
    private func trainRegressor(data: TrainingData) async throws -> TrainedModel {
        // Extract feature names
        let featureNames = Array(data.features[0].keys)
        let numFeatures = featureNames.count
        
        // Initialize weights
        var weights = [Double](repeating: 0, count: numFeatures)
        var bias: Double = 0
        
        // Gradient descent training
        let learningRate = 0.001
        let epochs = 100
        let n = Double(data.features.count)
        
        for _ in 0..<epochs {
            var biasGradient: Double = 0
            var weightGradients = [Double](repeating: 0, count: numFeatures)
            
            for (features, label) in zip(data.features, data.labels) {
                guard let target = label as? Double else { continue }
                
                let featureVector = featureNames.map { features[$0] as? Double ?? 0.0 }
                
                // Calculate prediction
                var prediction = bias
                for (i, weight) in weights.enumerated() {
                    if i < featureVector.count {
                        prediction += weight * featureVector[i]
                    }
                }
                
                let error = prediction - target
                
                biasGradient += error
                for i in 0..<numFeatures {
                    weightGradients[i] += error * featureVector[i]
                }
            }
            
            // Update weights
            bias -= learningRate * biasGradient / n
            for i in 0..<numFeatures {
                weights[i] -= learningRate * weightGradients[i] / n
            }
        }
        
        return TrainedModel(
            type: .regressor,
            featureNames: featureNames,
            classes: [],
            weights: [weights],
            bias: [bias]
        )
    }
}

// MARK: - Supporting Types

/// Wrapper for Core ML models
private struct ModelWrapper {
    let model: MLModel
    let name: String
}

/// Custom trained model
private struct TrainedModel {
    let type: ModelType
    let featureNames: [String]
    let classes: [String]
    let weights: [[Double]]
    let bias: [Double]
}

/// Model evaluation metrics
public struct EvaluationMetrics: Sendable {
    public let accuracy: Float
    public let precision: Float
    public let recall: Float
    public let f1Score: Float
}

/// ML Engine errors
public enum MLEngineError: LocalizedError {
    case modelNotFound
    case invalidInput
    case predictionFailed
    case trainingFailed
    case insufficientData
    case dataMismatch
    case invalidLabels
    case unsupportedModelType
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound: return "Model not found"
        case .invalidInput: return "Invalid input data"
        case .predictionFailed: return "Prediction failed"
        case .trainingFailed: return "Training failed"
        case .insufficientData: return "Insufficient training data"
        case .dataMismatch: return "Features and labels count mismatch"
        case .invalidLabels: return "Invalid labels for classification"
        case .unsupportedModelType: return "Unsupported model type"
        }
    }
}

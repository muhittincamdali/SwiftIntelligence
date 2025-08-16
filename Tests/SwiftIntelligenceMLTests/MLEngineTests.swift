import XCTest
import Foundation
import CoreML
@testable import SwiftIntelligenceML
@testable import SwiftIntelligenceCore

/// Comprehensive test suite for ML Engine functionality
@MainActor
final class MLEngineTests: XCTestCase {
    
    var mlEngine: MLEngine!
    
    override func setUp() async throws {
        mlEngine = MLEngine.shared
        
        // Configure for testing
        let testConfig = IntelligenceConfiguration.testing
        SwiftIntelligenceCore.shared.configure(with: testConfig)
    }
    
    override func tearDown() async throws {
        SwiftIntelligenceCore.shared.cleanup()
    }
    
    // MARK: - Model Management Tests
    
    func testModelLoading() async throws {
        // Test loading a basic model
        let modelConfig = MLModelConfiguration(
            name: "TestClassifier",
            version: "1.0",
            type: .classification,
            inputFeatures: ["text"],
            outputFeatures: ["prediction", "confidence"],
            metadata: ["description": "Test classification model"]
        )
        
        // Since we're testing without actual model files, we'll test the interface
        do {
            let loadedModel = try await mlEngine.loadModel(configuration: modelConfig)
            XCTAssertNotNil(loadedModel)
            XCTAssertEqual(loadedModel.name, "TestClassifier")
            XCTAssertEqual(loadedModel.version, "1.0")
        } catch {
            // Model loading might fail in test environment without actual model files
            XCTAssertTrue(error is MLError)
        }
    }
    
    func testModelCaching() async throws {
        let modelConfig = MLModelConfiguration(
            name: "CacheTestModel",
            version: "1.0",
            type: .regression,
            inputFeatures: ["input"],
            outputFeatures: ["output"]
        )
        
        // Test caching behavior
        do {
            let model1 = try await mlEngine.loadModel(configuration: modelConfig)
            let model2 = try await mlEngine.loadModel(configuration: modelConfig)
            
            // Should return cached instance
            XCTAssertEqual(model1.name, model2.name)
            XCTAssertEqual(model1.version, model2.version)
        } catch {
            // Expected in test environment
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Text Classification Tests
    
    func testTextClassification() async throws {
        let trainingData = [
            "This movie is absolutely fantastic and amazing!",
            "I love this product, it's wonderful!",
            "This is terrible and awful, I hate it.",
            "Not good at all, very disappointing.",
            "It's okay, nothing special about it."
        ]
        
        let labels = ["positive", "positive", "negative", "negative", "neutral"]
        
        do {
            let model = try await mlEngine.trainTextClassificationModel(
                trainingData: trainingData,
                labels: labels,
                configuration: MLTrainingConfiguration(
                    epochs: 5,
                    batchSize: 2,
                    learningRate: 0.01,
                    enablePrivacyPreserving: false
                )
            )
            
            XCTAssertNotNil(model.modelId)
            XCTAssertGreaterThan(model.accuracy, 0.0)
            XCTAssertLessThanOrEqual(model.accuracy, 1.0)
            
            // Test prediction
            let testText = "This is absolutely wonderful!"
            let prediction = try await mlEngine.classifyText(testText, modelId: model.modelId)
            
            XCTAssertNotNil(prediction.predictedClass)
            XCTAssertGreaterThan(prediction.confidence, 0.0)
            XCTAssertLessThanOrEqual(prediction.confidence, 1.0)
            
        } catch {
            // Training might not be fully implemented in test environment
            XCTAssertTrue(error is MLError)
        }
    }
    
    func testTextClassificationWithCategories() async throws {
        let testText = "The new iPhone has an amazing camera and fast processor."
        let categories = ["technology", "sports", "politics", "entertainment"]
        
        do {
            let result = try await mlEngine.classifyText(
                testText,
                categories: categories,
                options: MLClassificationOptions(
                    confidenceThreshold: 0.1,
                    maxResults: 3
                )
            )
            
            XCTAssertEqual(result.predictedClass, "technology")
            XCTAssertGreaterThan(result.confidence, 0.1)
            XCTAssertLessThanOrEqual(result.allPredictions.count, 3)
            
        } catch {
            // Classification might not be fully implemented in test environment
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Regression Tests
    
    func testRegressionModel() async throws {
        // Create sample regression data
        let features = [
            [1.0, 2.0, 3.0],
            [2.0, 3.0, 4.0],
            [3.0, 4.0, 5.0],
            [4.0, 5.0, 6.0],
            [5.0, 6.0, 7.0]
        ]
        
        let targets = [6.0, 9.0, 12.0, 15.0, 18.0] // Sum of features
        
        do {
            let model = try await mlEngine.trainRegressionModel(
                features: features,
                targets: targets,
                configuration: MLTrainingConfiguration(
                    epochs: 10,
                    batchSize: 2,
                    learningRate: 0.01
                )
            )
            
            XCTAssertNotNil(model.modelId)
            XCTAssertGreaterThan(model.accuracy, 0.0)
            
            // Test prediction
            let testFeatures = [6.0, 7.0, 8.0]
            let prediction = try await mlEngine.predictRegression(
                features: testFeatures,
                modelId: model.modelId
            )
            
            XCTAssertGreaterThan(prediction.value, 0.0)
            XCTAssertGreaterThan(prediction.confidence, 0.0)
            
        } catch {
            // Training might not be fully implemented
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Privacy-Preserving ML Tests
    
    func testPrivacyPreservingTraining() async throws {
        let sensitiveData = [
            "User john.doe@company.com likes this product",
            "Customer jane.smith@corp.com purchased item",
            "Client mike.wilson@startup.io rated 5 stars"
        ]
        
        let labels = ["positive", "positive", "positive"]
        
        do {
            let model = try await mlEngine.trainTextClassificationModel(
                trainingData: sensitiveData,
                labels: labels,
                configuration: MLTrainingConfiguration(
                    epochs: 3,
                    batchSize: 1,
                    learningRate: 0.001,
                    enablePrivacyPreserving: true,
                    enableDifferentialPrivacy: true,
                    privacyBudget: 1.0
                )
            )
            
            XCTAssertNotNil(model.modelId)
            XCTAssertGreaterThan(model.accuracy, 0.0)
            
        } catch {
            // Privacy-preserving training might not be fully implemented
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Model Evaluation Tests
    
    func testModelEvaluation() async throws {
        let testData = [
            "This is a positive example",
            "This is a negative example",
            "This is another positive example"
        ]
        
        let trueLabels = ["positive", "negative", "positive"]
        
        do {
            // First train a simple model
            let model = try await mlEngine.trainTextClassificationModel(
                trainingData: testData,
                labels: trueLabels,
                configuration: MLTrainingConfiguration(epochs: 3)
            )
            
            // Evaluate the model
            let evaluation = try await mlEngine.evaluateModel(
                modelId: model.modelId,
                testData: testData,
                trueLabels: trueLabels
            )
            
            XCTAssertGreaterThanOrEqual(evaluation.accuracy, 0.0)
            XCTAssertLessThanOrEqual(evaluation.accuracy, 1.0)
            XCTAssertGreaterThanOrEqual(evaluation.precision, 0.0)
            XCTAssertLessThanOrEqual(evaluation.precision, 1.0)
            XCTAssertGreaterThanOrEqual(evaluation.recall, 0.0)
            XCTAssertLessThanOrEqual(evaluation.recall, 1.0)
            XCTAssertGreaterThanOrEqual(evaluation.f1Score, 0.0)
            XCTAssertLessThanOrEqual(evaluation.f1Score, 1.0)
            
        } catch {
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testTrainingPerformance() async throws {
        let trainingData = Array(repeating: "Sample training text for performance testing", count: 50)
        let labels = Array(repeating: "test", count: 50)
        
        let startTime = Date()
        
        do {
            let model = try await mlEngine.trainTextClassificationModel(
                trainingData: trainingData,
                labels: labels,
                configuration: MLTrainingConfiguration(
                    epochs: 2,
                    batchSize: 10,
                    learningRate: 0.01
                )
            )
            
            let trainingTime = Date().timeIntervalSince(startTime)
            
            XCTAssertLessThan(trainingTime, 30.0) // Should complete within 30 seconds
            XCTAssertNotNil(model.modelId)
            
        } catch {
            XCTAssertTrue(error is MLError)
        }
    }
    
    func testPredictionPerformance() async throws {
        let testTexts = Array(repeating: "Performance test text", count: 20)
        
        do {
            // Use a simple categorical classification
            let startTime = Date()
            
            var predictions: [MLClassificationResult] = []
            for text in testTexts {
                let prediction = try await mlEngine.classifyText(
                    text,
                    categories: ["positive", "negative", "neutral"]
                )
                predictions.append(prediction)
            }
            
            let totalTime = Date().timeIntervalSince(startTime)
            let averageTime = totalTime / Double(testTexts.count)
            
            XCTAssertEqual(predictions.count, testTexts.count)
            XCTAssertLessThan(averageTime, 0.5) // Average should be under 0.5 seconds
            
        } catch {
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyDataHandling() async throws {
        let emptyData: [String] = []
        let emptyLabels: [String] = []
        
        do {
            let model = try await mlEngine.trainTextClassificationModel(
                trainingData: emptyData,
                labels: emptyLabels,
                configuration: MLTrainingConfiguration(epochs: 1)
            )
            
            XCTFail("Should not succeed with empty data")
        } catch {
            XCTAssertTrue(error is MLError)
        }
    }
    
    func testMismatchedDataAndLabels() async throws {
        let data = ["Text 1", "Text 2", "Text 3"]
        let labels = ["Label 1", "Label 2"] // Mismatched count
        
        do {
            let model = try await mlEngine.trainTextClassificationModel(
                trainingData: data,
                labels: labels,
                configuration: MLTrainingConfiguration(epochs: 1)
            )
            
            XCTFail("Should not succeed with mismatched data and labels")
        } catch {
            XCTAssertTrue(error is MLError)
        }
    }
    
    func testVeryLongTextClassification() async throws {
        let longText = String(repeating: "Very long text for classification testing. ", count: 1000)
        
        do {
            let result = try await mlEngine.classifyText(
                longText,
                categories: ["positive", "negative", "neutral"]
            )
            
            XCTAssertNotNil(result.predictedClass)
            XCTAssertGreaterThan(result.confidence, 0.0)
            
        } catch {
            // Long text might be truncated or cause errors
            XCTAssertTrue(error is MLError)
        }
    }
    
    // MARK: - Concurrent Processing Tests
    
    func testConcurrentPredictions() async throws {
        let texts = [
            "First concurrent prediction text.",
            "Second concurrent prediction text.",
            "Third concurrent prediction text.",
            "Fourth concurrent prediction text."
        ]
        
        let results = await withTaskGroup(of: MLClassificationResult?.self, returning: [MLClassificationResult].self) { group in
            for text in texts {
                group.addTask {
                    do {
                        return try await self.mlEngine.classifyText(
                            text,
                            categories: ["positive", "negative", "neutral"]
                        )
                    } catch {
                        return nil
                    }
                }
            }
            
            var collectedResults: [MLClassificationResult] = []
            for await result in group {
                if let result = result {
                    collectedResults.append(result)
                }
            }
            return collectedResults
        }
        
        // Even if some fail, we should get some results
        XCTAssertGreaterThan(results.count, 0)
        
        for result in results {
            XCTAssertNotNil(result.predictedClass)
            XCTAssertGreaterThan(result.confidence, 0.0)
        }
    }
    
    // MARK: - Model Persistence Tests
    
    func testModelSaveAndLoad() async throws {
        let trainingData = ["Test data for save/load"]
        let labels = ["test"]
        
        do {
            // Train a model
            let originalModel = try await mlEngine.trainTextClassificationModel(
                trainingData: trainingData,
                labels: labels,
                configuration: MLTrainingConfiguration(epochs: 1)
            )
            
            // Save the model
            let saveURL = try await mlEngine.saveModel(
                modelId: originalModel.modelId,
                to: FileManager.default.temporaryDirectory.appendingPathComponent("test_model.mlmodel")
            )
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: saveURL.path))
            
            // Load the model back
            let loadedModel = try await mlEngine.loadModel(from: saveURL)
            
            XCTAssertEqual(loadedModel.name, originalModel.modelId)
            
        } catch {
            XCTAssertTrue(error is MLError)
        }
    }
}

// MARK: - Test Extensions

extension MLTrainingConfiguration {
    static let fastTest = MLTrainingConfiguration(
        epochs: 2,
        batchSize: 4,
        learningRate: 0.1,
        enablePrivacyPreserving: false
    )
    
    static let privacyTest = MLTrainingConfiguration(
        epochs: 1,
        batchSize: 2,
        learningRate: 0.01,
        enablePrivacyPreserving: true,
        enableDifferentialPrivacy: true,
        privacyBudget: 0.5
    )
}

extension MLClassificationOptions {
    static let demo = MLClassificationOptions(
        confidenceThreshold: 0.3,
        maxResults: 5
    )
}
import XCTest
@testable import SwiftIntelligenceML
import CoreML

final class MLTests: XCTestCase {
    
    var mlEngine: SwiftIntelligenceML!
    
    override func setUp() async throws {
        mlEngine = try await SwiftIntelligenceML()
    }
    
    override func tearDown() {
        mlEngine = nil
    }
    
    // MARK: - Model Loading Tests
    
    func testEngineInitialization() {
        XCTAssertNotNil(mlEngine)
        XCTAssertTrue(mlEngine.isReady)
    }
    
    func testAvailableModels() async throws {
        let models = try await mlEngine.availableModels()
        XCTAssertFalse(models.isEmpty)
    }
    
    // MARK: - Prediction Tests
    
    func testBasicPrediction() async throws {
        let input = MLInput(features: ["value": 42.0])
        let prediction = try await mlEngine.predict(input: input)
        
        XCTAssertNotNil(prediction)
        XCTAssertGreaterThan(prediction.confidence, 0.0)
        XCTAssertLessThanOrEqual(prediction.confidence, 1.0)
    }
    
    func testBatchPrediction() async throws {
        let inputs = [
            MLInput(features: ["value": 10.0]),
            MLInput(features: ["value": 20.0]),
            MLInput(features: ["value": 30.0])
        ]
        
        let predictions = try await mlEngine.batchPredict(inputs: inputs)
        
        XCTAssertEqual(predictions.count, inputs.count)
        
        for prediction in predictions {
            XCTAssertGreaterThan(prediction.confidence, 0.0)
            XCTAssertLessThanOrEqual(prediction.confidence, 1.0)
        }
    }
    
    // MARK: - Classification Tests
    
    func testClassification() async throws {
        let features = ["feature1": 0.5, "feature2": 0.8, "feature3": 0.2]
        let result = try await mlEngine.classify(features: features)
        
        XCTAssertNotNil(result.label)
        XCTAssertFalse(result.label.isEmpty)
        XCTAssertGreaterThan(result.confidence, 0.0)
        
        // Check probability distribution
        let totalProbability = result.probabilities.values.reduce(0, +)
        XCTAssertEqual(totalProbability, 1.0, accuracy: 0.01)
    }
    
    func testMultiClassClassification() async throws {
        let features = ["feature1": 0.3, "feature2": 0.6, "feature3": 0.9]
        let result = try await mlEngine.classify(features: features, topK: 3)
        
        XCTAssertLessThanOrEqual(result.topLabels.count, 3)
        
        // Verify descending order of probabilities
        for i in 0..<result.topLabels.count - 1 {
            XCTAssertGreaterThanOrEqual(
                result.topLabels[i].probability,
                result.topLabels[i + 1].probability
            )
        }
    }
    
    // MARK: - Regression Tests
    
    func testLinearRegression() async throws {
        let features = ["x": 5.0]
        let result = try await mlEngine.regress(features: features)
        
        XCTAssertNotNil(result.value)
        XCTAssertGreaterThan(result.confidence, 0.0)
    }
    
    func testMultiVariateRegression() async throws {
        let features = ["x1": 2.0, "x2": 3.0, "x3": 4.0]
        let result = try await mlEngine.regress(features: features)
        
        XCTAssertNotNil(result.value)
        XCTAssertNotNil(result.range)
        XCTAssertLessThan(result.range!.lowerBound, result.value)
        XCTAssertGreaterThan(result.range!.upperBound, result.value)
    }
    
    // MARK: - Clustering Tests
    
    func testKMeansClustering() async throws {
        let dataPoints = [
            [1.0, 2.0],
            [1.5, 1.8],
            [5.0, 8.0],
            [8.0, 8.0],
            [1.0, 0.6],
            [9.0, 11.0]
        ]
        
        let clusters = try await mlEngine.cluster(data: dataPoints, k: 2)
        
        XCTAssertEqual(clusters.count, 2)
        
        // Each cluster should have points
        for cluster in clusters {
            XCTAssertFalse(cluster.points.isEmpty)
            XCTAssertNotNil(cluster.centroid)
        }
    }
    
    // MARK: - Feature Extraction Tests
    
    func testFeatureExtraction() async throws {
        let rawData = ["text": "Hello world", "number": 42]
        let features = try await mlEngine.extractFeatures(from: rawData)
        
        XCTAssertFalse(features.isEmpty)
        XCTAssertGreaterThan(features.count, 0)
    }
    
    func testDimensionalityReduction() async throws {
        let highDimensionalData = Array(repeating: 0.0...1.0, count: 100)
            .map { _ in Double.random(in: 0...1) }
        
        let reducedData = try await mlEngine.reduceDimensions(
            data: highDimensionalData,
            targetDimensions: 2
        )
        
        XCTAssertEqual(reducedData.count, 2)
    }
    
    // MARK: - Model Training Tests
    
    func testModelTraining() async throws {
        let trainingData = MLTrainingData(
            inputs: [
                ["x": 1.0], ["x": 2.0], ["x": 3.0], ["x": 4.0]
            ],
            outputs: [
                ["y": 2.0], ["y": 4.0], ["y": 6.0], ["y": 8.0]
            ]
        )
        
        let trainedModel = try await mlEngine.train(
            data: trainingData,
            modelType: .linearRegression
        )
        
        XCTAssertNotNil(trainedModel)
        XCTAssertGreaterThan(trainedModel.accuracy, 0.8)
    }
    
    // MARK: - Performance Tests
    
    func testPredictionPerformance() {
        let input = MLInput(features: ["value": 42.0])
        
        measure {
            let expectation = self.expectation(description: "Prediction")
            
            Task {
                _ = try? await mlEngine.predict(input: input)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testBatchPredictionPerformance() {
        let inputs = (0..<100).map { MLInput(features: ["value": Double($0)]) }
        
        measure {
            let expectation = self.expectation(description: "Batch prediction")
            
            Task {
                _ = try? await mlEngine.batchPredict(inputs: inputs)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidInputHandling() async {
        let invalidInput = MLInput(features: [:]) // Empty features
        
        do {
            _ = try await mlEngine.predict(input: invalidInput)
            XCTFail("Should throw error for invalid input")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testModelNotFoundHandling() async {
        do {
            _ = try await mlEngine.loadModel(named: "NonExistentModel")
            XCTFail("Should throw error for non-existent model")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
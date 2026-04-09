@preconcurrency import XCTest
@testable import SwiftIntelligenceML
@testable import SwiftIntelligenceCore

final class MLEngineTests: XCTestCase {
    private var mlEngine: SwiftIntelligenceML!

    @MainActor
    override func setUp() async throws {
        mlEngine = try await SwiftIntelligenceML()
        SwiftIntelligenceCore.shared.configure(with: .testing)
    }

    @MainActor
    override func tearDown() async throws {
        try await mlEngine.shutdown()
        SwiftIntelligenceCore.shared.cleanup()
        mlEngine = nil
    }

    func testAvailableModelsIncludesDefaults() async {
        let models = await mlEngine.availableModels()

        XCTAssertTrue(models.contains("classification"))
        XCTAssertTrue(models.contains("linear_regression"))
    }

    func testClassificationTrainingAndPrediction() async throws {
        let trainingData = makeClassificationTrainingData()

        let result = try await mlEngine.train(modelID: "classification", with: trainingData)
        let prediction = try await mlEngine.predict(
            modelID: "classification",
            input: MLInput(features: [0.05, 0.05])
        )

        XCTAssertGreaterThanOrEqual(result.accuracy, 0)
        XCTAssertLessThanOrEqual(result.accuracy, 1)
        XCTAssertEqual(prediction.classificationResult, "class_0")
        XCTAssertGreaterThan(prediction.confidence, 0)
    }

    func testRegressionTrainingAndPrediction() async throws {
        let trainingData = makeRegressionTrainingData()

        let result = try await mlEngine.train(modelID: "linear_regression", with: trainingData)
        let prediction = try await mlEngine.predict(
            modelID: "linear_regression",
            input: MLInput(features: [4.0])
        )

        XCTAssertGreaterThanOrEqual(result.accuracy, 0)
        XCTAssertFalse(prediction.prediction.isEmpty)
        XCTAssertEqual(prediction.classificationResult, nil)
        XCTAssertEqual(prediction.prediction[0], 8.0, accuracy: 2.0)
    }

    func testModelEvaluationReturnsBoundedMetrics() async throws {
        _ = try await mlEngine.train(modelID: "classification", with: makeClassificationTrainingData())

        let evaluation = try await mlEngine.evaluate(
            modelID: "classification",
            testData: MLTestData(
                samples: [
                    .init(
                        input: MLInput(features: [0.0, 0.1]),
                        expectedOutput: MLOutput(prediction: [0], classificationResult: "class_0", confidence: 1.0)
                    ),
                    .init(
                        input: MLInput(features: [1.0, 1.1]),
                        expectedOutput: MLOutput(prediction: [0], classificationResult: "class_1", confidence: 1.0)
                    )
                ]
            )
        )

        XCTAssertGreaterThanOrEqual(evaluation.accuracy, 0)
        XCTAssertLessThanOrEqual(evaluation.accuracy, 1)
        XCTAssertGreaterThanOrEqual(evaluation.precision, 0)
        XCTAssertLessThanOrEqual(evaluation.precision, 1)
        XCTAssertGreaterThanOrEqual(evaluation.recall, 0)
        XCTAssertLessThanOrEqual(evaluation.recall, 1)
        XCTAssertGreaterThanOrEqual(evaluation.f1Score, 0)
        XCTAssertLessThanOrEqual(evaluation.f1Score, 1)
    }

    func testPredictionCacheCanBeCleared() async throws {
        _ = try await mlEngine.train(modelID: "classification", with: makeClassificationTrainingData())

        _ = try await mlEngine.predict(
            modelID: "classification",
            input: MLInput(features: [0.05, 0.05])
        )

        let populatedStats = await mlEngine.getCacheStats()
        XCTAssertGreaterThan(populatedStats.size, 0)

        await mlEngine.clearCache()

        let clearedStats = await mlEngine.getCacheStats()
        XCTAssertEqual(clearedStats.size, 0)
        XCTAssertEqual(clearedStats.maxSize, populatedStats.maxSize)
    }

    private func makeClassificationTrainingData() -> MLTrainingData {
        MLTrainingData(
            inputs: [
                MLInput(features: [0.0, 0.0]),
                MLInput(features: [0.1, 0.1]),
                MLInput(features: [1.0, 1.0]),
                MLInput(features: [1.1, 1.1])
            ],
            expectedOutputs: [
                MLOutput(prediction: [0], classificationResult: "class_0", confidence: 1.0),
                MLOutput(prediction: [0], classificationResult: "class_0", confidence: 1.0),
                MLOutput(prediction: [0], classificationResult: "class_1", confidence: 1.0),
                MLOutput(prediction: [0], classificationResult: "class_1", confidence: 1.0)
            ]
        )
    }

    private func makeRegressionTrainingData() -> MLTrainingData {
        MLTrainingData(
            inputs: [
                MLInput(features: [1.0]),
                MLInput(features: [2.0]),
                MLInput(features: [3.0])
            ],
            expectedOutputs: [
                MLOutput(prediction: [2.0], confidence: 1.0),
                MLOutput(prediction: [4.0], confidence: 1.0),
                MLOutput(prediction: [6.0], confidence: 1.0)
            ]
        )
    }
}

import XCTest
@testable import SwiftIntelligence
@testable import SwiftIntelligenceCore

/// Comprehensive test suite for SwiftIntelligence framework
@MainActor
final class SwiftIntelligenceTests: XCTestCase {
    
    var swiftIntelligence: SwiftIntelligence!
    
    override func setUp() async throws {
        swiftIntelligence = SwiftIntelligence.shared
        try await swiftIntelligence.initialize(with: .testing)
    }
    
    override func tearDown() async throws {
        try await swiftIntelligence.shutdown()
    }
    
    // MARK: - Framework Tests
    
    func testFrameworkInitialization() async throws {
        // Given
        let framework = SwiftIntelligence.shared
        
        // Then
        XCTAssertTrue(framework.isInitialized)
        XCTAssertEqual(SwiftIntelligence.version, "1.0.0")
        XCTAssertEqual(SwiftIntelligence.build, "100")
    }
    
    func testFrameworkConfiguration() async throws {
        // Given
        let customConfig = IntelligenceConfiguration.development
        
        // When
        try await swiftIntelligence.initialize(with: customConfig)
        
        // Then
        XCTAssertTrue(swiftIntelligence.core.configuration.debugMode)
        XCTAssertTrue(swiftIntelligence.core.configuration.verboseLogging)
    }
    
    func testModuleLoading() async throws {
        // When
        try await swiftIntelligence.loadModule(.ml)
        
        // Then
        XCTAssertNotNil(swiftIntelligence.ml)
        XCTAssertTrue(swiftIntelligence.activeModules.contains("MachineLearning"))
    }
    
    func testModuleUnloading() async throws {
        // Given
        try await swiftIntelligence.loadModule(.ml)
        XCTAssertNotNil(swiftIntelligence.ml)
        
        // When
        try await swiftIntelligence.unloadModule(.ml)
        
        // Then
        XCTAssertNil(swiftIntelligence.ml)
        XCTAssertFalse(swiftIntelligence.activeModules.contains("MachineLearning"))
    }
    
    func testMultipleModuleLoading() async throws {
        // When
        try await swiftIntelligence.loadModules([.ml, .nlp, .vision])
        
        // Then
        XCTAssertNotNil(swiftIntelligence.ml)
        XCTAssertNotNil(swiftIntelligence.nlp)
        XCTAssertNotNil(swiftIntelligence.vision)
        XCTAssertEqual(swiftIntelligence.activeModules.count, 3)
    }
    
    func testAllModulesLoading() async throws {
        // When
        try await swiftIntelligence.loadAllModules()
        
        // Then
        XCTAssertNotNil(swiftIntelligence.ml)
        XCTAssertNotNil(swiftIntelligence.nlp)
        XCTAssertNotNil(swiftIntelligence.vision)
        XCTAssertNotNil(swiftIntelligence.speech)
        XCTAssertNotNil(swiftIntelligence.reasoning)
        XCTAssertNotNil(swiftIntelligence.imageGeneration)
        XCTAssertNotNil(swiftIntelligence.privacy)
        XCTAssertNotNil(swiftIntelligence.network)
        XCTAssertNotNil(swiftIntelligence.cache)
        XCTAssertNotNil(swiftIntelligence.metrics)
        XCTAssertEqual(swiftIntelligence.activeModules.count, Module.allCases.count)
    }
    
    func testHealthCheck() async throws {
        // Given
        try await swiftIntelligence.loadModules([.ml, .nlp])
        
        // When
        let healthReport = await swiftIntelligence.healthCheck()
        
        // Then
        XCTAssertEqual(healthReport.frameworkVersion, "1.0.0")
        XCTAssertTrue(healthReport.isInitialized)
        XCTAssertEqual(healthReport.activeModules.count, 2)
        XCTAssertTrue(healthReport.activeModules.contains("MachineLearning"))
        XCTAssertTrue(healthReport.activeModules.contains("NaturalLanguageProcessing"))
    }
    
    func testErrorHandling() async throws {
        // Given
        let errorHandler = swiftIntelligence.core.errorHandler
        var receivedError: IntelligenceError?
        
        errorHandler.registerCallback { error in
            receivedError = error
        }
        
        // When
        let testError = IntelligenceError(
            code: "TEST_ERROR",
            message: "Test error message",
            severity: .medium
        )
        errorHandler.handle(testError)
        
        // Then
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.code, "TEST_ERROR")
        XCTAssertEqual(receivedError?.message, "Test error message")
    }
    
    func testPerformanceMonitoring() async throws {
        // Given
        let monitor = swiftIntelligence.core.performanceMonitor
        monitor.startMonitoring()
        
        // When
        let operationID = monitor.beginOperation("Test Operation")
        
        // Simulate some work
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        monitor.endOperation(operationID)
        
        // Then
        let summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
        XCTAssertEqual(summary.activeOperations, 0)
        XCTAssertGreaterThan(summary.averageDuration, 0)
    }
    
    func testMemoryUsage() async throws {
        // When
        let memoryUsage = swiftIntelligence.core.memoryUsage()
        
        // Then
        XCTAssertGreaterThan(memoryUsage.used, 0)
        XCTAssertGreaterThan(memoryUsage.total, 0)
        XCTAssertGreaterThan(memoryUsage.usedMB, 0)
        XCTAssertGreaterThan(memoryUsage.totalMB, 0)
        XCTAssertGreaterThanOrEqual(memoryUsage.percentage, 0)
        XCTAssertLessThanOrEqual(memoryUsage.percentage, 100)
    }
    
    func testLogging() async throws {
        // Given
        let logger = swiftIntelligence.core.logger
        
        // When
        logger.info("Test info message")
        logger.warning("Test warning message")
        logger.error("Test error message")
        
        // Then - In a real app, you'd check log output
        // For now, we just verify the logger exists and doesn't crash
        XCTAssertNotNil(logger)
    }
    
    // MARK: - Configuration Tests
    
    func testDevelopmentConfiguration() {
        // Given
        let config = IntelligenceConfiguration.development
        
        // Then
        XCTAssertTrue(config.debugMode)
        XCTAssertTrue(config.performanceMonitoring)
        XCTAssertTrue(config.verboseLogging)
        XCTAssertFalse(config.privacyMode)
        XCTAssertFalse(config.telemetryEnabled)
        XCTAssertEqual(config.memoryLimit, 1024)
    }
    
    func testProductionConfiguration() {
        // Given
        let config = IntelligenceConfiguration.production
        
        // Then
        XCTAssertFalse(config.debugMode)
        XCTAssertFalse(config.performanceMonitoring)
        XCTAssertFalse(config.verboseLogging)
        XCTAssertTrue(config.privacyMode)
        XCTAssertTrue(config.telemetryEnabled)
        XCTAssertEqual(config.memoryLimit, 256)
    }
    
    func testTestingConfiguration() {
        // Given
        let config = IntelligenceConfiguration.testing
        
        // Then
        XCTAssertTrue(config.debugMode)
        XCTAssertFalse(config.performanceMonitoring)
        XCTAssertFalse(config.verboseLogging)
        XCTAssertFalse(config.privacyMode)
        XCTAssertFalse(config.telemetryEnabled)
        XCTAssertEqual(config.memoryLimit, 128)
        XCTAssertEqual(config.requestTimeout, 5)
        XCTAssertEqual(config.cacheDuration, 0)
        XCTAssertEqual(config.maxConcurrentOperations, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testValidationError() {
        // Given
        let error = ValidationError(
            code: "INVALID_INPUT",
            message: "Input validation failed",
            field: "email"
        )
        
        // Then
        XCTAssertEqual(error.code, "INVALID_INPUT")
        XCTAssertEqual(error.message, "Input validation failed")
        XCTAssertEqual(error.field, "email")
    }
    
    func testValidationResult() {
        // Given
        let errors = [ValidationError(code: "ERR1", message: "Error 1")]
        let warnings = [ValidationWarning(code: "WARN1", message: "Warning 1")]
        
        // When
        let result = ValidationResult(isValid: false, errors: errors, warnings: warnings)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertEqual(result.warnings.count, 1)
        XCTAssertEqual(result.errors.first?.code, "ERR1")
        XCTAssertEqual(result.warnings.first?.code, "WARN1")
    }
    
    func testHealthStatus() {
        // Given
        let metrics = ["cpu": 50.0, "memory": 75.0]
        
        // When
        let status = HealthStatus(
            status: .healthy,
            message: "All systems operational",
            metrics: metrics
        )
        
        // Then
        XCTAssertEqual(status.status, .healthy)
        XCTAssertEqual(status.message, "All systems operational")
        XCTAssertEqual(status.metrics.count, 2)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceMeasurement() async throws {
        // Given
        let monitor = swiftIntelligence.core.performanceMonitor
        monitor.startMonitoring()
        
        // When
        let result = monitor.measure("Test Operation") {
            return "Test Result"
        }
        
        // Then
        XCTAssertEqual(result, "Test Result")
        
        let summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
    }
    
    func testAsyncPerformanceMeasurement() async throws {
        // Given
        let monitor = swiftIntelligence.core.performanceMonitor
        monitor.startMonitoring()
        
        // When
        let result = await monitor.measureAsync("Async Test Operation") {
            try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
            return "Async Test Result"
        }
        
        // Then
        XCTAssertEqual(result, "Async Test Result")
        
        let summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
        XCTAssertGreaterThan(summary.averageDuration, 0.009) // Should be at least 0.01 seconds
    }
}

// MARK: - Module-Specific Tests

extension SwiftIntelligenceTests {
    
    func testMLEngineInitialization() async throws {
        // When
        try await swiftIntelligence.loadModule(.ml)
        
        // Then
        guard let mlEngine = swiftIntelligence.ml else {
            XCTFail("ML Engine should be loaded")
            return
        }
        
        XCTAssertEqual(await mlEngine.moduleID, "ML")
        XCTAssertEqual(await mlEngine.version, "1.0.0")
        XCTAssertEqual(await mlEngine.status, .ready)
        
        let healthStatus = await mlEngine.healthCheck()
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertEqual(healthStatus.message, "ML Engine is operational")
    }
    
    func testNLPEngineInitialization() async throws {
        // When
        try await swiftIntelligence.loadModule(.nlp)
        
        // Then
        guard let nlpEngine = swiftIntelligence.nlp else {
            XCTFail("NLP Engine should be loaded")
            return
        }
        
        XCTAssertEqual(await nlpEngine.moduleID, "NLP")
        XCTAssertEqual(await nlpEngine.version, "1.0.0")
        XCTAssertEqual(await nlpEngine.status, .ready)
        
        let healthStatus = await nlpEngine.healthCheck()
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertEqual(healthStatus.message, "NLP Engine is operational")
    }
    
    func testVisionEngineInitialization() async throws {
        // When
        try await swiftIntelligence.loadModule(.vision)
        
        // Then
        guard let visionEngine = swiftIntelligence.vision else {
            XCTFail("Vision Engine should be loaded")
            return
        }
        
        XCTAssertEqual(await visionEngine.moduleID, "Vision")
        XCTAssertEqual(await visionEngine.version, "1.0.0")
        XCTAssertEqual(await visionEngine.status, .ready)
        
        let healthStatus = await visionEngine.healthCheck()
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertEqual(healthStatus.message, "Vision Engine is operational")
    }
}

// MARK: - Integration Tests

extension SwiftIntelligenceTests {
    
    func testFrameworkIntegration() async throws {
        // Given
        let configuration = IntelligenceConfiguration.development
        
        // When
        try await swiftIntelligence.initialize(with: configuration)
        try await swiftIntelligence.loadAllModules()
        
        // Then
        XCTAssertTrue(swiftIntelligence.isInitialized)
        XCTAssertEqual(swiftIntelligence.activeModules.count, Module.allCases.count)
        
        let healthReport = await swiftIntelligence.healthCheck()
        XCTAssertTrue(healthReport.isInitialized)
        XCTAssertEqual(healthReport.activeModules.count, Module.allCases.count)
        
        // Cleanup
        try await swiftIntelligence.shutdown()
        XCTAssertFalse(swiftIntelligence.isInitialized)
        XCTAssertTrue(swiftIntelligence.activeModules.isEmpty)
    }
}

// MARK: - Performance Tests

extension SwiftIntelligenceTests {
    
    func testModuleLoadingPerformance() async throws {
        // Measure module loading time
        measure {
            Task {
                try await swiftIntelligence.loadModule(.ml)
                try await swiftIntelligence.unloadModule(.ml)
            }
        }
    }
    
    func testAllModulesLoadingPerformance() async throws {
        // Measure all modules loading time
        measure {
            Task {
                try await swiftIntelligence.loadAllModules()
                for module in Module.allCases {
                    try await swiftIntelligence.unloadModule(module)
                }
            }
        }
    }
}
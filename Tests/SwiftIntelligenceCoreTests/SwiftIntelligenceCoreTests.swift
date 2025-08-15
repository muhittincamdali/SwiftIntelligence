import XCTest
@testable import SwiftIntelligenceCore

/// Test suite for SwiftIntelligenceCore module
@MainActor
final class SwiftIntelligenceCoreTests: XCTestCase {
    
    var core: SwiftIntelligenceCore!
    
    override func setUp() async throws {
        core = SwiftIntelligenceCore.shared
    }
    
    override func tearDown() async throws {
        core.cleanup()
    }
    
    // MARK: - Core Tests
    
    func testCoreInitialization() {
        XCTAssertNotNil(core)
        XCTAssertEqual(SwiftIntelligenceCore.version, "1.0.0")
        XCTAssertEqual(SwiftIntelligenceCore.buildNumber, "100")
    }
    
    func testConfiguration() {
        // Given
        let customConfig = IntelligenceConfiguration(
            debugMode: true,
            performanceMonitoring: false,
            verboseLogging: true
        )
        
        // When
        core.configure(with: customConfig)
        
        // Then
        XCTAssertTrue(core.configuration.debugMode)
        XCTAssertFalse(core.configuration.performanceMonitoring)
        XCTAssertTrue(core.configuration.verboseLogging)
    }
    
    func testConfigurationReset() {
        // Given
        let customConfig = IntelligenceConfiguration(debugMode: true)
        core.configure(with: customConfig)
        XCTAssertTrue(core.configuration.debugMode)
        
        // When
        core.resetConfiguration()
        
        // Then
        XCTAssertFalse(core.configuration.debugMode) // Default is false
    }
    
    func testMemoryUsage() {
        // When
        let memoryUsage = core.memoryUsage()
        
        // Then
        XCTAssertGreaterThan(memoryUsage.used, 0)
        XCTAssertGreaterThan(memoryUsage.total, 0)
        XCTAssertGreaterThan(memoryUsage.usedMB, 0)
        XCTAssertGreaterThan(memoryUsage.totalMB, 0)
        XCTAssertGreaterThanOrEqual(memoryUsage.percentage, 0)
        XCTAssertLessThanOrEqual(memoryUsage.percentage, 100)
    }
    
    func testCPUUsage() {
        // When
        let cpuUsage = core.cpuUsage()
        
        // Then
        XCTAssertGreaterThanOrEqual(cpuUsage.user, 0)
        XCTAssertGreaterThanOrEqual(cpuUsage.system, 0)
        XCTAssertGreaterThanOrEqual(cpuUsage.total, 0)
        XCTAssertGreaterThanOrEqual(cpuUsage.percentage, 0)
    }
    
    // MARK: - Logger Tests
    
    func testLogger() {
        let logger = core.logger
        
        // Test different log levels
        logger.verbose("Verbose message")
        logger.debug("Debug message")
        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")
        
        // Test custom category
        logger.log("Custom category message", level: .info, category: "TestCategory")
        
        // These should not crash
        XCTAssertNotNil(logger)
    }
    
    func testLoggerLevels() {
        let logger = core.logger
        
        // Test log level comparison
        XCTAssertTrue(LogLevel.verbose < LogLevel.debug)
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.warning)
        XCTAssertTrue(LogLevel.warning < LogLevel.error)
        XCTAssertTrue(LogLevel.error < LogLevel.critical)
        
        // Test log level filtering
        logger.logLevel = .warning
        
        // These should be filtered out (but we can't easily test that)
        logger.verbose("Should be filtered")
        logger.debug("Should be filtered")
        logger.info("Should be filtered")
        
        // These should pass through
        logger.warning("Should pass")
        logger.error("Should pass")
        logger.critical("Should pass")
    }
    
    func testLoggerErrorHandling() {
        let logger = core.logger
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        logger.logError(testError, message: "Test error occurred")
        logger.logError(testError) // Without custom message
        
        XCTAssertNotNil(logger)
    }
    
    func testLoggerPerformance() {
        let logger = core.logger
        
        logger.logPerformance(operation: "Test Operation", duration: 1.234)
        
        XCTAssertNotNil(logger)
    }
    
    // MARK: - Performance Monitor Tests
    
    func testPerformanceMonitor() {
        let monitor = core.performanceMonitor
        
        monitor.startMonitoring()
        XCTAssertTrue(monitor.isMonitoring)
        
        monitor.stopMonitoring()
        XCTAssertFalse(monitor.isMonitoring)
    }
    
    func testOperationTracking() async throws {
        let monitor = core.performanceMonitor
        monitor.startMonitoring()
        
        // Test operation tracking
        let operationID = monitor.beginOperation("Test Operation", category: "Test")
        
        // Simulate some work
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        monitor.endOperation(operationID)
        
        let summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
        XCTAssertEqual(summary.activeOperations, 0)
        XCTAssertGreaterThan(summary.averageDuration, 0)
    }
    
    func testMeasureBlock() {
        let monitor = core.performanceMonitor
        monitor.startMonitoring()
        
        let result = monitor.measure("Test Block") {
            return "Test Result"
        }
        
        XCTAssertEqual(result, "Test Result")
        
        let summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
    }
    
    func testMeasureAsyncBlock() async throws {
        let monitor = core.performanceMonitor
        monitor.startMonitoring()
        
        let result = await monitor.measureAsync("Async Test Block") {
            try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
            return "Async Test Result"
        }
        
        XCTAssertEqual(result, "Async Test Result")
        
        let summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
        XCTAssertGreaterThan(summary.averageDuration, 0.009)
    }
    
    func testOperationsByCategory() {
        let monitor = core.performanceMonitor
        monitor.startMonitoring()
        
        let op1 = monitor.beginOperation("Op1", category: "Category1")
        let op2 = monitor.beginOperation("Op2", category: "Category2")
        let op3 = monitor.beginOperation("Op3", category: "Category1")
        
        monitor.endOperation(op1)
        monitor.endOperation(op2)
        monitor.endOperation(op3)
        
        let category1Ops = monitor.operations(forCategory: "Category1")
        let category2Ops = monitor.operations(forCategory: "Category2")
        
        XCTAssertEqual(category1Ops.count, 2)
        XCTAssertEqual(category2Ops.count, 1)
    }
    
    func testClearMetrics() {
        let monitor = core.performanceMonitor
        monitor.startMonitoring()
        
        let operationID = monitor.beginOperation("Test Operation")
        monitor.endOperation(operationID)
        
        var summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 1)
        
        monitor.clearMetrics()
        
        summary = monitor.performanceSummary()
        XCTAssertEqual(summary.totalOperations, 0)
        XCTAssertEqual(summary.activeOperations, 0)
    }
    
    // MARK: - Error Handler Tests
    
    func testErrorHandler() {
        let errorHandler = core.errorHandler
        let testError = IntelligenceError(
            code: "TEST_ERROR",
            message: "Test error message",
            severity: .medium
        )
        
        errorHandler.handle(testError)
        
        XCTAssertEqual(errorHandler.errorHistory.count, 1)
        XCTAssertEqual(errorHandler.errorHistory.first?.error.code, "TEST_ERROR")
        XCTAssertFalse(errorHandler.errorHistory.first?.recovered ?? true)
    }
    
    func testErrorCallback() {
        let errorHandler = core.errorHandler
        var receivedError: IntelligenceError?
        
        errorHandler.registerCallback { error in
            receivedError = error
        }
        
        let testError = IntelligenceError(
            code: "CALLBACK_TEST",
            message: "Callback test error",
            severity: .high
        )
        
        errorHandler.handle(testError)
        
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.code, "CALLBACK_TEST")
        XCTAssertEqual(receivedError?.severity, .high)
    }
    
    func testErrorFiltering() {
        let errorHandler = core.errorHandler
        
        let lowError = IntelligenceError(code: "LOW", message: "Low severity", severity: .low)
        let highError = IntelligenceError(code: "HIGH", message: "High severity", severity: .high)
        
        errorHandler.handle(lowError)
        errorHandler.handle(highError)
        
        let lowErrors = errorHandler.errors(withSeverity: .low)
        let highErrors = errorHandler.errors(withSeverity: .high)
        
        XCTAssertEqual(lowErrors.count, 1)
        XCTAssertEqual(highErrors.count, 1)
        XCTAssertEqual(lowErrors.first?.error.code, "LOW")
        XCTAssertEqual(highErrors.first?.error.code, "HIGH")
    }
    
    func testErrorsByModule() {
        let errorHandler = core.errorHandler
        
        let context1 = ErrorContext(module: "Module1", operation: "Operation1")
        let context2 = ErrorContext(module: "Module2", operation: "Operation2")
        
        let error1 = IntelligenceError(code: "ERR1", message: "Error 1", context: context1)
        let error2 = IntelligenceError(code: "ERR2", message: "Error 2", context: context2)
        
        errorHandler.handle(error1)
        errorHandler.handle(error2)
        
        let module1Errors = errorHandler.errors(fromModule: "Module1")
        let module2Errors = errorHandler.errors(fromModule: "Module2")
        
        XCTAssertEqual(module1Errors.count, 1)
        XCTAssertEqual(module2Errors.count, 1)
        XCTAssertEqual(module1Errors.first?.error.code, "ERR1")
        XCTAssertEqual(module2Errors.first?.error.code, "ERR2")
    }
    
    func testClearErrorHistory() {
        let errorHandler = core.errorHandler
        
        let testError = IntelligenceError(code: "TEST", message: "Test")
        errorHandler.handle(testError)
        
        XCTAssertEqual(errorHandler.errorHistory.count, 1)
        
        errorHandler.clearHistory()
        
        XCTAssertEqual(errorHandler.errorHistory.count, 0)
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationDefaults() {
        let config = IntelligenceConfiguration()
        
        XCTAssertFalse(config.debugMode)
        XCTAssertTrue(config.performanceMonitoring)
        XCTAssertFalse(config.verboseLogging)
        XCTAssertEqual(config.memoryLimit, 512)
        XCTAssertEqual(config.requestTimeout, 30)
        XCTAssertEqual(config.cacheDuration, 3600)
        XCTAssertEqual(config.maxConcurrentOperations, 4)
        XCTAssertTrue(config.privacyMode)
        XCTAssertFalse(config.telemetryEnabled)
    }
    
    func testConfigurationPresets() {
        let devConfig = IntelligenceConfiguration.development
        let prodConfig = IntelligenceConfiguration.production
        let testConfig = IntelligenceConfiguration.testing
        
        // Development config
        XCTAssertTrue(devConfig.debugMode)
        XCTAssertTrue(devConfig.verboseLogging)
        XCTAssertFalse(devConfig.privacyMode)
        
        // Production config
        XCTAssertFalse(prodConfig.debugMode)
        XCTAssertFalse(prodConfig.verboseLogging)
        XCTAssertTrue(prodConfig.privacyMode)
        XCTAssertTrue(prodConfig.telemetryEnabled)
        
        // Testing config
        XCTAssertTrue(testConfig.debugMode)
        XCTAssertFalse(testConfig.performanceMonitoring)
        XCTAssertEqual(testConfig.requestTimeout, 5)
        XCTAssertEqual(testConfig.cacheDuration, 0)
        XCTAssertEqual(testConfig.maxConcurrentOperations, 1)
    }
    
    func testEndpointsConfiguration() {
        let endpoints = EndpointsConfiguration(
            baseURL: "https://test.example.com",
            apiVersion: "v2",
            customEndpoints: ["test": "https://test.endpoint.com"]
        )
        
        XCTAssertEqual(endpoints.baseURL, "https://test.example.com")
        XCTAssertEqual(endpoints.apiVersion, "v2")
        XCTAssertEqual(endpoints.customEndpoints["test"], "https://test.endpoint.com")
    }
    
    func testModelPathsConfiguration() {
        let modelPaths = ModelPathsConfiguration(
            basePath: "CustomModels",
            customPaths: ["nlp": "CustomNLP"]
        )
        
        XCTAssertEqual(modelPaths.basePath, "CustomModels")
        XCTAssertEqual(modelPaths.customPaths["nlp"], "CustomNLP")
    }
}

// MARK: - Validation Tests

extension SwiftIntelligenceCoreTests {
    
    func testValidationResult() {
        let error = ValidationError(code: "E001", message: "Test error", field: "test")
        let warning = ValidationWarning(code: "W001", message: "Test warning", field: "test")
        
        let result = ValidationResult(
            isValid: false,
            errors: [error],
            warnings: [warning]
        )
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertEqual(result.warnings.count, 1)
        XCTAssertEqual(result.errors.first?.code, "E001")
        XCTAssertEqual(result.warnings.first?.code, "W001")
    }
    
    func testHealthStatus() {
        let metrics = ["metric1": "value1", "metric2": "value2"]
        let status = HealthStatus(
            status: .healthy,
            message: "All good",
            metrics: metrics
        )
        
        XCTAssertEqual(status.status, .healthy)
        XCTAssertEqual(status.message, "All good")
        XCTAssertEqual(status.metrics.count, 2)
    }
    
    func testTrainingData() {
        let inputs = [Data("input1".utf8), Data("input2".utf8)]
        let labels = [Data("label1".utf8), Data("label2".utf8)]
        let metadata = ["key": "value"]
        
        let trainingData = TrainingData(
            inputs: inputs,
            labels: labels,
            metadata: metadata
        )
        
        XCTAssertEqual(trainingData.inputs.count, 2)
        XCTAssertEqual(trainingData.labels.count, 2)
        XCTAssertEqual(trainingData.metadata.count, 1)
    }
    
    func testTrainingResult() {
        let result = TrainingResult(
            accuracy: 0.95,
            loss: 0.05,
            epochs: 100,
            duration: 60.0
        )
        
        XCTAssertEqual(result.accuracy, 0.95, accuracy: 0.001)
        XCTAssertEqual(result.loss, 0.05, accuracy: 0.001)
        XCTAssertEqual(result.epochs, 100)
        XCTAssertEqual(result.duration, 60.0, accuracy: 0.001)
    }
    
    func testEvaluationResult() {
        let result = EvaluationResult(
            accuracy: 0.92,
            precision: 0.89,
            recall: 0.94,
            f1Score: 0.915
        )
        
        XCTAssertEqual(result.accuracy, 0.92, accuracy: 0.001)
        XCTAssertEqual(result.precision, 0.89, accuracy: 0.001)
        XCTAssertEqual(result.recall, 0.94, accuracy: 0.001)
        XCTAssertEqual(result.f1Score, 0.915, accuracy: 0.001)
    }
}
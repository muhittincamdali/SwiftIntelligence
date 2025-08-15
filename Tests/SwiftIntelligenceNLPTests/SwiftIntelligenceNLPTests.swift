import XCTest
@testable import SwiftIntelligenceNLP
@testable import SwiftIntelligenceCore

final class SwiftIntelligenceNLPTests: XCTestCase {
    
    func testNLPModuleInitialization() async throws {
        let nlpModule = await SwiftIntelligenceNLP()
        
        let moduleID = await nlpModule.moduleID
        let version = await nlpModule.version
        let status = await nlpModule.status
        
        XCTAssertEqual(moduleID, "NLP")
        XCTAssertEqual(version, "1.0.0")
        XCTAssertEqual(status, .ready)
    }
    
    func testNLPModuleHealthCheck() async throws {
        let nlpModule = await SwiftIntelligenceNLP()
        let healthStatus = await nlpModule.healthCheck()
        
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertEqual(healthStatus.message, "NLP module is operational")
    }
    
    func testNLPModuleValidation() async throws {
        let nlpModule = await SwiftIntelligenceNLP()
        let validationResult = try await nlpModule.validate()
        
        XCTAssertTrue(validationResult.isValid)
    }
    
    func testNLPModuleShutdown() async throws {
        let nlpModule = await SwiftIntelligenceNLP()
        try await nlpModule.shutdown()
        
        let status = await nlpModule.status
        XCTAssertEqual(status, .shutdown)
    }
}
import XCTest
@testable import SwiftIntelligenceML
@testable import SwiftIntelligenceCore

final class SwiftIntelligenceMLTests: XCTestCase {
    
    func testMLModuleInitialization() async throws {
        let mlModule = try await SwiftIntelligenceML()
        
        let moduleID = await mlModule.moduleID
        let version = await mlModule.version
        let status = await mlModule.status
        
        XCTAssertEqual(moduleID, "ML")
        XCTAssertEqual(version, "1.2.2")
        XCTAssertEqual(status, .ready)
    }
    
    func testMLModuleHealthCheck() async throws {
        let mlModule = try await SwiftIntelligenceML()
        let healthStatus = await mlModule.healthCheck()
        
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertTrue(healthStatus.message.contains("ML Engine operational"))
        XCTAssertFalse(healthStatus.metrics.isEmpty)
    }
    
    func testMLModuleValidation() async throws {
        let mlModule = try await SwiftIntelligenceML()
        let validationResult = try await mlModule.validate()
        
        XCTAssertTrue(validationResult.isValid)
    }
    
    func testMLModuleShutdown() async throws {
        let mlModule = try await SwiftIntelligenceML()
        try await mlModule.shutdown()
        
        let status = await mlModule.status
        XCTAssertEqual(status, .shutdown)
    }
}

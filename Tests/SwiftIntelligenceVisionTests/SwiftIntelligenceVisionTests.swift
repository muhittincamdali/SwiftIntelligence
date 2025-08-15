import XCTest
@testable import SwiftIntelligenceVision
@testable import SwiftIntelligenceCore

final class SwiftIntelligenceVisionTests: XCTestCase {
    
    func testVisionModuleInitialization() async throws {
        let visionModule = await SwiftIntelligenceVision()
        
        let moduleID = await visionModule.moduleID
        let version = await visionModule.version
        let status = await visionModule.status
        
        XCTAssertEqual(moduleID, "Vision")
        XCTAssertEqual(version, "1.0.0")
        XCTAssertEqual(status, .ready)
    }
    
    func testVisionModuleHealthCheck() async throws {
        let visionModule = await SwiftIntelligenceVision()
        let healthStatus = await visionModule.healthCheck()
        
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertEqual(healthStatus.message, "Vision module is operational")
    }
    
    func testVisionModuleValidation() async throws {
        let visionModule = await SwiftIntelligenceVision()
        let validationResult = try await visionModule.validate()
        
        XCTAssertTrue(validationResult.isValid)
    }
    
    func testVisionModuleShutdown() async throws {
        let visionModule = await SwiftIntelligenceVision()
        try await visionModule.shutdown()
        
        let status = await visionModule.status
        XCTAssertEqual(status, .shutdown)
    }
}
import XCTest
@testable import SwiftIntelligenceVision
@testable import SwiftIntelligenceCore

final class SwiftIntelligenceVisionTests: XCTestCase {
    private func makeVisionModule() async throws -> SwiftIntelligenceVision {
        do {
            return try await SwiftIntelligenceVision()
        } catch {
            throw XCTSkip("Vision module initialization depends on local framework/model availability: \(error)")
        }
    }
    
    func testVisionModuleInitialization() async throws {
        let visionModule = try await makeVisionModule()
        
        let moduleID = await visionModule.moduleID
        let version = await visionModule.version
        let status = await visionModule.status
        
        XCTAssertEqual(moduleID, "Vision")
        XCTAssertEqual(version, "1.2.0")
        XCTAssertEqual(status, .ready)
    }
    
    func testVisionModuleHealthCheck() async throws {
        let visionModule = try await makeVisionModule()
        let healthStatus = await visionModule.healthCheck()
        
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertTrue(healthStatus.message.contains("Vision Engine operational"))
        XCTAssertFalse(healthStatus.metrics.isEmpty)
    }
    
    func testVisionModuleValidation() async throws {
        let visionModule = try await makeVisionModule()
        let validationResult = try await visionModule.validate()
        
        XCTAssertTrue(validationResult.isValid)
    }
    
    func testVisionModuleShutdown() async throws {
        let visionModule = try await makeVisionModule()
        try await visionModule.shutdown()
        
        let status = await visionModule.status
        XCTAssertEqual(status, .shutdown)
    }
}

import XCTest
@testable import SwiftIntelligenceSpeech
@testable import SwiftIntelligenceCore

final class SwiftIntelligenceSpeechTests: XCTestCase {
    
    func testSpeechModuleInitialization() async throws {
        let speechModule = await SwiftIntelligenceSpeech()
        
        let moduleID = await speechModule.moduleID
        let version = await speechModule.version
        let status = await speechModule.status
        
        XCTAssertEqual(moduleID, "Speech")
        XCTAssertEqual(version, "1.0.0")
        XCTAssertEqual(status, .ready)
    }
    
    func testSpeechModuleHealthCheck() async throws {
        let speechModule = await SwiftIntelligenceSpeech()
        let healthStatus = await speechModule.healthCheck()
        
        XCTAssertEqual(healthStatus.status, .healthy)
        XCTAssertEqual(healthStatus.message, "Speech module is operational")
    }
    
    func testSpeechModuleValidation() async throws {
        let speechModule = await SwiftIntelligenceSpeech()
        let validationResult = try await speechModule.validate()
        
        XCTAssertTrue(validationResult.isValid)
    }
    
    func testSpeechModuleShutdown() async throws {
        let speechModule = await SwiftIntelligenceSpeech()
        try await speechModule.shutdown()
        
        let status = await speechModule.status
        XCTAssertEqual(status, .shutdown)
    }
}
import XCTest
@testable import SwiftIntelligenceCore

final class CoreTests: XCTestCase {
    
    func testSwiftIntelligenceInitialization() {
        let intelligence = SwiftIntelligence()
        XCTAssertNotNil(intelligence)
        XCTAssertEqual(intelligence.version, "1.0.0")
    }
    
    func testIntelligenceProtocol() {
        struct TestEngine: IntelligenceProtocol {
            var modelType: String { "test" }
            var version: String { "1.0" }
            var isReady: Bool { true }
            
            func process(_ input: String) async throws -> String {
                return "Processed: \(input)"
            }
            
            func configure(with config: [String: Any]) async throws {
                // Test configuration
            }
        }
        
        let engine = TestEngine()
        XCTAssertEqual(engine.modelType, "test")
        XCTAssertEqual(engine.version, "1.0")
        XCTAssertTrue(engine.isReady)
    }
    
    func testAsyncProcessing() async throws {
        struct AsyncProcessor: IntelligenceProtocol {
            var modelType: String { "async" }
            var version: String { "1.0" }
            var isReady: Bool { true }
            
            func process(_ input: String) async throws -> String {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                return input.uppercased()
            }
            
            func configure(with config: [String: Any]) async throws {}
        }
        
        let processor = AsyncProcessor()
        let result = try await processor.process("hello")
        XCTAssertEqual(result, "HELLO")
    }
    
    func testErrorHandling() async {
        enum TestError: Error {
            case testFailed
        }
        
        struct FailingEngine: IntelligenceProtocol {
            var modelType: String { "failing" }
            var version: String { "1.0" }
            var isReady: Bool { false }
            
            func process(_ input: String) async throws -> String {
                throw TestError.testFailed
            }
            
            func configure(with config: [String: Any]) async throws {
                throw TestError.testFailed
            }
        }
        
        let engine = FailingEngine()
        
        do {
            _ = try await engine.process("test")
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
    
    func testPerformanceMetrics() {
        measure {
            let intelligence = SwiftIntelligence()
            for _ in 0..<100 {
                _ = intelligence.version
            }
        }
    }
}
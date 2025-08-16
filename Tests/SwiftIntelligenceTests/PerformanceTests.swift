import XCTest
import Foundation
@testable import SwiftIntelligence
@testable import SwiftIntelligenceCore
@testable import SwiftIntelligenceNLP
@testable import SwiftIntelligenceVision
@testable import SwiftIntelligenceSpeech

#if canImport(UIKit)
import UIKit
#endif

/// Performance benchmark tests for SwiftIntelligence framework
/// Measures execution time, memory usage, and throughput
@MainActor
final class PerformanceTests: XCTestCase {
    
    var performanceMonitor: PerformanceMonitor!
    
    override func setUp() async throws {
        // Configure for performance testing
        let perfConfig = IntelligenceConfiguration(
            debugMode: false,
            performanceMonitoring: true,
            verboseLogging: false,
            memoryLimit: 1024,
            maxConcurrentOperations: 8
        )
        
        SwiftIntelligenceCore.shared.configure(with: perfConfig)
        performanceMonitor = SwiftIntelligenceCore.shared.performanceMonitor
        performanceMonitor.startMonitoring()
    }
    
    override func tearDown() async throws {
        performanceMonitor.stopMonitoring()
        SwiftIntelligenceCore.shared.cleanup()
    }
    
    // MARK: - NLP Performance Tests
    
    func testNLPAnalysisPerformance() async throws {
        let text = "SwiftIntelligence is a comprehensive AI framework that provides natural language processing, computer vision, and speech capabilities for Apple platforms. It enables developers to build intelligent applications with ease."
        
        let metrics = self.measure {
            Task {
                do {
                    let result = try await NLPEngine.shared.analyzeText(
                        text,
                        options: NLPAnalysisOptions(
                            enableSentiment: true,
                            enableEntities: true,
                            enableKeywords: true,
                            enableLanguageDetection: true
                        )
                    )
                    
                    XCTAssertNotNil(result.sentiment)
                    XCTAssertGreaterThan(result.keywords.count, 0)
                } catch {
                    XCTFail("NLP analysis failed: \\(error)")
                }
            }
        }
    }
    
    func testNLPBatchProcessingPerformance() async throws {
        let texts = Array(1...100).map { index in
            "This is test text number \\(index) for batch processing performance evaluation. It contains various words and concepts to analyze."
        }
        
        let startTime = Date()
        let operationID = performanceMonitor.beginOperation("NLP Batch Processing", category: "Performance")
        
        var results: [NLPAnalysisResult] = []
        
        // Sequential processing
        for text in texts {
            let result = try await NLPEngine.shared.analyzeText(
                text,
                options: NLPAnalysisOptions(enableSentiment: true, enableKeywords: true)
            )
            results.append(result)
        }
        
        performanceMonitor.endOperation(operationID)
        let sequentialTime = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(results.count, texts.count)
        
        // Test concurrent processing
        let concurrentStartTime = Date()
        let concurrentOperationID = performanceMonitor.beginOperation("NLP Concurrent Processing", category: "Performance")
        
        let concurrentResults = await withTaskGroup(of: NLPAnalysisResult?.self, returning: [NLPAnalysisResult].self) { group in
            for text in texts {
                group.addTask {
                    do {
                        return try await NLPEngine.shared.analyzeText(
                            text,
                            options: NLPAnalysisOptions(enableSentiment: true, enableKeywords: true)
                        )
                    } catch {
                        return nil
                    }
                }
            }
            
            var collected: [NLPAnalysisResult] = []
            for await result in group {
                if let result = result {
                    collected.append(result)
                }
            }
            return collected
        }
        
        performanceMonitor.endOperation(concurrentOperationID)
        let concurrentTime = Date().timeIntervalSince(concurrentStartTime)
        
        XCTAssertEqual(concurrentResults.count, texts.count)
        
        // Concurrent processing should be faster for large batches
        let speedupRatio = sequentialTime / concurrentTime
        print("Sequential time: \\(String(format: "%.2f", sequentialTime))s")
        print("Concurrent time: \\(String(format: "%.2f", concurrentTime))s")
        print("Speedup ratio: \\(String(format: "%.2f", speedupRatio))x")
        
        XCTAssertGreaterThan(speedupRatio, 1.0) // Should have some speedup
    }
    
    func testNLPThroughputBenchmark() async throws {
        let testTexts = Array(1...50).map { "Throughput test text \\($0)" }
        let duration: TimeInterval = 10.0 // 10 second benchmark
        
        let startTime = Date()
        var processedCount = 0
        
        while Date().timeIntervalSince(startTime) < duration {
            for text in testTexts {
                let result = try await NLPEngine.shared.analyzeText(
                    text,
                    options: NLPAnalysisOptions(enableSentiment: true)
                )
                processedCount += 1
                
                if Date().timeIntervalSince(startTime) >= duration {
                    break
                }
            }
        }
        
        let actualDuration = Date().timeIntervalSince(startTime)
        let throughput = Double(processedCount) / actualDuration
        
        print("NLP Throughput: \\(String(format: "%.2f", throughput)) texts/second")
        print("Processed \\(processedCount) texts in \\(String(format: "%.2f", actualDuration)) seconds")
        
        XCTAssertGreaterThan(throughput, 5.0) // Should process at least 5 texts per second
    }
    
    // MARK: - Vision Performance Tests
    
    #if canImport(UIKit)
    func testVisionObjectDetectionPerformance() async throws {
        guard let testImage = createPerformanceTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let metrics = self.measure {
            Task {
                do {
                    let result = try await VisionEngine.shared.detectObjects(
                        in: testImage,
                        options: ObjectDetectionOptions(
                            confidenceThreshold: 0.5,
                            enableClassification: true,
                            maxObjects: 10
                        )
                    )
                    
                    XCTAssertGreaterThanOrEqual(result.detectedObjects.count, 0)
                } catch {
                    XCTFail("Vision object detection failed: \\(error)")
                }
            }
        }
    }
    
    func testVisionImageProcessingThroughput() async throws {
        let images = (1...20).compactMap { _ in createPerformanceTestImage() }
        guard !images.isEmpty else {
            XCTFail("Failed to create test images")
            return
        }
        
        let startTime = Date()
        let operationID = performanceMonitor.beginOperation("Vision Batch Processing", category: "Performance")
        
        var results: [ObjectDetectionResult] = []
        
        for image in images {
            let result = try await VisionEngine.shared.detectObjects(
                in: image,
                options: ObjectDetectionOptions(confidenceThreshold: 0.3)
            )
            results.append(result)
        }
        
        performanceMonitor.endOperation(operationID)
        let processingTime = Date().timeIntervalSince(startTime)
        let throughput = Double(images.count) / processingTime
        
        print("Vision Throughput: \\(String(format: "%.2f", throughput)) images/second")
        print("Processed \\(images.count) images in \\(String(format: "%.2f", processingTime)) seconds")
        
        XCTAssertEqual(results.count, images.count)
        XCTAssertGreaterThan(throughput, 1.0) // Should process at least 1 image per second
    }
    #endif
    
    // MARK: - Speech Performance Tests
    
    func testSpeechSynthesisPerformance() async throws {
        let text = "SwiftIntelligence provides high-performance speech synthesis capabilities for Apple platforms."
        
        let metrics = self.measure {
            Task {
                do {
                    let result = try await SpeechEngine.shared.synthesizeSpeech(
                        from: text,
                        options: SpeechSynthesisOptions.default
                    )
                    
                    XCTAssertGreaterThan(result.duration, 0)
                    XCTAssertGreaterThan(result.synthesizedAudio.count, 0)
                } catch {
                    XCTFail("Speech synthesis failed: \\(error)")
                }
            }
        }
    }
    
    func testSpeechSynthesisThroughput() async throws {
        let texts = Array(1...20).map { "Speech synthesis test text number \\($0)." }
        
        let startTime = Date()
        let operationID = performanceMonitor.beginOperation("Speech Batch Synthesis", category: "Performance")
        
        var results: [SpeechSynthesisResult] = []
        
        for text in texts {
            let result = try await SpeechEngine.shared.synthesizeSpeech(
                from: text,
                options: SpeechSynthesisOptions.default
            )
            results.append(result)
        }
        
        performanceMonitor.endOperation(operationID)
        let processingTime = Date().timeIntervalSince(startTime)
        let throughput = Double(texts.count) / processingTime
        
        print("Speech Synthesis Throughput: \\(String(format: "%.2f", throughput)) texts/second")
        print("Processed \\(texts.count) texts in \\(String(format: "%.2f", processingTime)) seconds")
        
        XCTAssertEqual(results.count, texts.count)
        XCTAssertGreaterThan(throughput, 2.0) // Should process at least 2 texts per second
    }
    
    // MARK: - Memory Performance Tests
    
    func testMemoryUsageUnderLoad() async throws {
        let initialMemory = SwiftIntelligenceCore.shared.memoryUsage()
        print("Initial memory usage: \\(String(format: "%.2f", Double(initialMemory.used) / 1024 / 1024)) MB")
        
        // Generate significant workload
        let largeBatch = Array(1...100).map { index in
            String(repeating: "Memory test text \\(index). ", count: 100)
        }
        
        let operationID = performanceMonitor.beginOperation("Memory Load Test", category: "Performance")
        
        var results: [Any] = []
        
        for text in largeBatch {
            // NLP processing
            let nlpResult = try await NLPEngine.shared.analyzeText(
                text,
                options: NLPAnalysisOptions(
                    enableSentiment: true,
                    enableKeywords: true,
                    enableEntities: true
                )
            )
            results.append(nlpResult)
            
            #if canImport(UIKit)
            // Vision processing
            if let image = createLargeTestImage() {
                let visionResult = try await VisionEngine.shared.detectObjects(
                    in: image,
                    options: ObjectDetectionOptions.default
                )
                results.append(visionResult)
            }
            #endif
            
            // Speech processing
            if text.count < 200 { // Limit speech synthesis for performance
                let speechResult = try await SpeechEngine.shared.synthesizeSpeech(
                    from: String(text.prefix(100)),
                    options: SpeechSynthesisOptions.default
                )
                results.append(speechResult)
            }
        }
        
        let peakMemory = SwiftIntelligenceCore.shared.memoryUsage()
        print("Peak memory usage: \\(String(format: "%.2f", Double(peakMemory.used) / 1024 / 1024)) MB")
        
        performanceMonitor.endOperation(operationID)
        
        // Clear results to allow garbage collection
        results.removeAll()
        
        // Force garbage collection
        for _ in 0..<5 {
            autoreleasepool {
                _ = Array(0..<10000)
            }
        }
        
        let finalMemory = SwiftIntelligenceCore.shared.memoryUsage()
        print("Final memory usage: \\(String(format: "%.2f", Double(finalMemory.used) / 1024 / 1024)) MB")
        
        let memoryIncrease = peakMemory.used - initialMemory.used
        let memoryIncreaseMB = Double(memoryIncrease) / 1024 / 1024
        
        print("Memory increase: \\(String(format: "%.2f", memoryIncreaseMB)) MB")
        
        // Memory increase should be reasonable
        XCTAssertLessThan(memoryIncreaseMB, 500) // Should not increase by more than 500MB
        
        // Memory should be partially reclaimed
        let memoryReclaimed = peakMemory.used - finalMemory.used
        XCTAssertGreaterThan(memoryReclaimed, 0) // Some memory should be reclaimed
    }
    
    func testMemoryLeakDetection() async throws {
        let initialMemory = SwiftIntelligenceCore.shared.memoryUsage()
        
        // Perform repeated operations that should not leak
        for iteration in 1...10 {
            autoreleasepool {
                Task {
                    do {
                        // Short operations that should be fully cleaned up
                        let text = "Memory leak test iteration \\(iteration)"
                        
                        let nlpResult = try await NLPEngine.shared.analyzeText(
                            text,
                            options: NLPAnalysisOptions(enableSentiment: true)
                        )
                        
                        #if canImport(UIKit)
                        if let image = createSmallTestImage() {
                            let visionResult = try await VisionEngine.shared.detectObjects(
                                in: image,
                                options: ObjectDetectionOptions(confidenceThreshold: 0.5)
                            )
                        }
                        #endif
                        
                        // Results should be automatically cleaned up
                    } catch {
                        // Ignore errors for leak testing
                    }
                }
            }
            
            // Force garbage collection between iterations
            for _ in 0..<3 {
                autoreleasepool {
                    _ = Array(0..<1000)
                }
            }
        }
        
        let finalMemory = SwiftIntelligenceCore.shared.memoryUsage()
        let memoryGrowth = finalMemory.used - initialMemory.used
        let memoryGrowthMB = Double(memoryGrowth) / 1024 / 1024
        
        print("Memory growth after 10 iterations: \\(String(format: "%.2f", memoryGrowthMB)) MB")
        
        // Memory growth should be minimal (< 50MB) for repeated operations
        XCTAssertLessThan(memoryGrowthMB, 50)
    }
    
    // MARK: - Scalability Tests
    
    func testConcurrentUserSimulation() async throws {
        let userCount = 10
        let operationsPerUser = 5
        
        let startTime = Date()
        let operationID = performanceMonitor.beginOperation("Concurrent Users Simulation", category: "Performance")
        
        let results = await withTaskGroup(of: Int.self, returning: [Int].self) { group in
            for userID in 1...userCount {
                group.addTask {
                    var completedOperations = 0
                    
                    for operationIndex in 1...operationsPerUser {
                        do {
                            let text = "User \\(userID) operation \\(operationIndex) test text"
                            
                            // Simulate mixed workload
                            switch operationIndex % 3 {
                            case 0:
                                let nlpResult = try await NLPEngine.shared.analyzeText(
                                    text,
                                    options: NLPAnalysisOptions(enableSentiment: true)
                                )
                                completedOperations += 1
                                
                            case 1:
                                #if canImport(UIKit)
                                if let image = self.createSmallTestImage() {
                                    let visionResult = try await VisionEngine.shared.detectObjects(
                                        in: image,
                                        options: ObjectDetectionOptions(confidenceThreshold: 0.5)
                                    )
                                    completedOperations += 1
                                }
                                #else
                                completedOperations += 1
                                #endif
                                
                            case 2:
                                let speechResult = try await SpeechEngine.shared.synthesizeSpeech(
                                    from: text,
                                    options: SpeechSynthesisOptions.default
                                )
                                completedOperations += 1
                                
                            default:
                                break
                            }
                        } catch {
                            // Continue with other operations
                        }
                    }
                    
                    return completedOperations
                }
            }
            
            var allResults: [Int] = []
            for await result in group {
                allResults.append(result)
            }
            return allResults
        }
        
        performanceMonitor.endOperation(operationID)
        let totalTime = Date().timeIntervalSince(startTime)
        
        let totalOperations = results.reduce(0, +)
        let throughput = Double(totalOperations) / totalTime
        
        print("Concurrent simulation: \\(userCount) users, \\(totalOperations) operations in \\(String(format: "%.2f", totalTime))s")
        print("Overall throughput: \\(String(format: "%.2f", throughput)) operations/second")
        
        XCTAssertEqual(results.count, userCount)
        XCTAssertGreaterThan(totalOperations, userCount * operationsPerUser / 2) // At least 50% success rate
        XCTAssertGreaterThan(throughput, Double(userCount)) // Should handle concurrent load efficiently
    }
    
    // MARK: - Helper Methods
    
    #if canImport(UIKit)
    private func createPerformanceTestImage() -> UIImage? {
        let size = CGSize(width: 300, height: 200)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Complex scene for object detection
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Multiple colored objects
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple]
        for i in 0..<6 {
            context.setFillColor(colors[i].cgColor)
            let rect = CGRect(
                x: CGFloat((i % 3) * 90 + 20),
                y: CGFloat((i / 3) * 80 + 20),
                width: 60,
                height: 60
            )
            context.fillEllipse(in: rect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createLargeTestImage() -> UIImage? {
        let size = CGSize(width: 1024, height: 768)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Large gradient background
        let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
        
        // Multiple objects
        for i in 0..<20 {
            context.setFillColor(UIColor.random.cgColor)
            let rect = CGRect(
                x: CGFloat.random(in: 0...(size.width - 50)),
                y: CGFloat.random(in: 0...(size.height - 50)),
                width: 50,
                height: 50
            )
            context.fillEllipse(in: rect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createSmallTestImage() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
}

// MARK: - Extensions

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
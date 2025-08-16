import XCTest
import Foundation
@testable import SwiftIntelligenceVision
@testable import SwiftIntelligenceCore

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Comprehensive test suite for Vision Engine functionality
@MainActor
final class VisionEngineTests: XCTestCase {
    
    var visionEngine: VisionEngine!
    
    override func setUp() async throws {
        visionEngine = VisionEngine.shared
        
        // Configure for testing
        let testConfig = IntelligenceConfiguration.testing
        SwiftIntelligenceCore.shared.configure(with: testConfig)
    }
    
    override func tearDown() async throws {
        SwiftIntelligenceCore.shared.cleanup()
    }
    
    // MARK: - Object Detection Tests
    
    #if canImport(UIKit)
    func testBasicObjectDetection() async throws {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let result = try await visionEngine.detectObjects(
            in: testImage,
            options: ObjectDetectionOptions(
                confidenceThreshold: 0.5,
                enableClassification: true,
                maxObjects: 10
            )
        )
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result.detectedObjects.count, 0)
        XCTAssertGreaterThan(result.processingTime, 0)
        
        for object in result.detectedObjects {
            XCTAssertGreaterThanOrEqual(object.confidence, 0.5)
            XCTAssertNotNil(object.classification)
            XCTAssertTrue(object.boundingBox.width > 0)
            XCTAssertTrue(object.boundingBox.height > 0)
        }
    }
    #endif
    
    #if canImport(UIKit)
    func testObjectDetectionWithHighConfidence() async throws {
        guard let testImage = createComplexTestImage() else {
            XCTFail("Failed to create complex test image")
            return
        }
        
        let result = try await visionEngine.detectObjects(
            in: testImage,
            options: ObjectDetectionOptions(
                confidenceThreshold: 0.8,
                enableClassification: true,
                maxObjects: 5
            )
        )
        
        XCTAssertLessThanOrEqual(result.detectedObjects.count, 5)
        
        for object in result.detectedObjects {
            XCTAssertGreaterThanOrEqual(object.confidence, 0.8)
        }
    }
    #endif
    
    // MARK: - Text Recognition Tests
    
    #if canImport(UIKit)
    func testBasicTextRecognition() async throws {
        guard let textImage = createTextImage(text: "SAMPLE TEXT") else {
            XCTFail("Failed to create text image")
            return
        }
        
        let result = try await visionEngine.recognizeText(
            in: textImage,
            options: TextRecognitionOptions.default
        )
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result.recognizedText.isEmpty)
        XCTAssertGreaterThan(result.confidence, 0.5)
        XCTAssertGreaterThan(result.textBlocks.count, 0)
        
        let foundText = result.recognizedText.uppercased()
        XCTAssertTrue(foundText.contains("SAMPLE") || foundText.contains("TEXT"))
    }
    #endif
    
    #if canImport(UIKit)
    func testTextRecognitionWithMultipleLines() async throws {
        let multilineText = "First Line\nSecond Line\nThird Line"
        guard let textImage = createTextImage(text: multilineText) else {
            XCTFail("Failed to create multiline text image")
            return
        }
        
        let result = try await visionEngine.recognizeText(
            in: textImage,
            options: TextRecognitionOptions(
                enablePartialResults: false,
                requireOnDeviceRecognition: true,
                addPunctuation: true,
                detectLanguage: true
            )
        )
        
        XCTAssertGreaterThan(result.textBlocks.count, 1)
        XCTAssertEqual(result.language, "en")
        
        let recognizedLines = result.recognizedText.components(separatedBy: .newlines)
        XCTAssertGreaterThan(recognizedLines.count, 1)
    }
    #endif
    
    // MARK: - Face Detection Tests
    
    #if canImport(UIKit)
    func testFaceDetection() async throws {
        guard let faceImage = createFaceTestImage() else {
            XCTFail("Failed to create face test image")
            return
        }
        
        let result = try await visionEngine.detectFaces(
            in: faceImage,
            options: FaceDetectionOptions.default
        )
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result.detectedFaces.count, 0)
        XCTAssertGreaterThan(result.processingTime, 0)
        
        for face in result.detectedFaces {
            XCTAssertGreaterThan(face.confidence, 0.3)
            XCTAssertTrue(face.boundingBox.width > 0)
            XCTAssertTrue(face.boundingBox.height > 0)
        }
    }
    #endif
    
    // MARK: - Image Classification Tests
    
    #if canImport(UIKit)
    func testImageClassification() async throws {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let result = try await visionEngine.classifyImage(
            testImage,
            options: ImageClassificationOptions.default
        )
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.classifications.count, 0)
        XCTAssertGreaterThan(result.processingTime, 0)
        
        let topClassification = result.classifications.first!
        XCTAssertGreaterThan(topClassification.confidence, 0.1)
        XCTAssertFalse(topClassification.identifier.isEmpty)
    }
    #endif
    
    // MARK: - Performance Tests
    
    #if canImport(UIKit)
    func testObjectDetectionPerformance() async throws {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let startTime = Date()
        
        let result = try await visionEngine.detectObjects(
            in: testImage,
            options: ObjectDetectionOptions.demo
        )
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(processingTime, 2.0) // Should complete within 2 seconds
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.processingTime, 0)
    }
    #endif
    
    #if canImport(UIKit)
    func testBatchImageProcessing() async throws {
        let images = [
            createTestImage(),
            createTextImage(text: "TEST"),
            createComplexTestImage()
        ].compactMap { $0 }
        
        guard !images.isEmpty else {
            XCTFail("Failed to create test images")
            return
        }
        
        let startTime = Date()
        var results: [ObjectDetectionResult] = []
        
        for image in images {
            let result = try await visionEngine.detectObjects(
                in: image,
                options: ObjectDetectionOptions(confidenceThreshold: 0.3)
            )
            results.append(result)
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        let averageTime = totalTime / Double(images.count)
        
        XCTAssertEqual(results.count, images.count)
        XCTAssertLessThan(averageTime, 1.0) // Average should be under 1 second per image
        
        for result in results {
            XCTAssertGreaterThan(result.processingTime, 0)
        }
    }
    #endif
    
    // MARK: - Edge Cases Tests
    
    #if canImport(UIKit)
    func testVerySmallImageHandling() async throws {
        let smallSize = CGSize(width: 10, height: 10)
        guard let smallImage = createColoredImage(size: smallSize, color: .blue) else {
            XCTFail("Failed to create small image")
            return
        }
        
        do {
            let result = try await visionEngine.detectObjects(
                in: smallImage,
                options: ObjectDetectionOptions.default
            )
            
            // Should handle gracefully
            XCTAssertNotNil(result)
        } catch {
            // Error handling is also acceptable for very small images
            XCTAssertTrue(error is VisionError)
        }
    }
    #endif
    
    #if canImport(UIKit)
    func testVeryLargeImageHandling() async throws {
        let largeSize = CGSize(width: 4000, height: 3000)
        guard let largeImage = createColoredImage(size: largeSize, color: .green) else {
            XCTFail("Failed to create large image")
            return
        }
        
        let result = try await visionEngine.detectObjects(
            in: largeImage,
            options: ObjectDetectionOptions(confidenceThreshold: 0.5, maxObjects: 3)
        )
        
        XCTAssertNotNil(result)
        XCTAssertLessThanOrEqual(result.detectedObjects.count, 3)
    }
    #endif
    
    // MARK: - Concurrent Processing Tests
    
    #if canImport(UIKit)
    func testConcurrentImageProcessing() async throws {
        let images = [
            createTestImage(),
            createTextImage(text: "CONCURRENT"),
            createComplexTestImage()
        ].compactMap { $0 }
        
        guard images.count >= 2 else {
            XCTFail("Need at least 2 test images")
            return
        }
        
        let results = await withTaskGroup(of: ObjectDetectionResult?.self, returning: [ObjectDetectionResult].self) { group in
            for image in images {
                group.addTask {
                    do {
                        return try await self.visionEngine.detectObjects(
                            in: image,
                            options: ObjectDetectionOptions.demo
                        )
                    } catch {
                        return nil
                    }
                }
            }
            
            var collectedResults: [ObjectDetectionResult] = []
            for await result in group {
                if let result = result {
                    collectedResults.append(result)
                }
            }
            return collectedResults
        }
        
        XCTAssertEqual(results.count, images.count)
        
        for result in results {
            XCTAssertGreaterThan(result.processingTime, 0)
        }
    }
    #endif
    
    // MARK: - Helper Methods
    
    #if canImport(UIKit)
    private func createTestImage() -> UIImage? {
        let size = CGSize(width: 200, height: 150)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Create gradient background
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add a red circle
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 50, width: 60, height: 60))
        
        // Add a yellow rectangle
        context.setFillColor(UIColor.yellow.cgColor)
        context.fill(CGRect(x: 120, y: 80, width: 40, height: 30))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createComplexTestImage() -> UIImage? {
        let size = CGSize(width: 300, height: 200)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Complex scene with multiple objects
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Multiple colored shapes
        let colors: [UIColor] = [.red, .green, .blue, .orange, .purple]
        for i in 0..<5 {
            context.setFillColor(colors[i].cgColor)
            let rect = CGRect(x: CGFloat(i * 50), y: CGFloat(i * 30), width: 40, height: 40)
            context.fillEllipse(in: rect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createTextImage(text: String) -> UIImage? {
        let size = CGSize(width: 300, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Black text
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 24)
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createFaceTestImage() -> UIImage? {
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Simplified face-like shape for testing
        context.setFillColor(UIColor.systemYellow.cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 50, width: 100, height: 120))
        
        // Eyes
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: CGRect(x: 70, y: 80, width: 15, height: 15))
        context.fillEllipse(in: CGRect(x: 115, y: 80, width: 15, height: 15))
        
        // Mouth
        context.fillEllipse(in: CGRect(x: 90, y: 130, width: 20, height: 10))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func createColoredImage(size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
}

// MARK: - Test Extensions

extension ObjectDetectionOptions {
    static let demo = ObjectDetectionOptions(
        confidenceThreshold: 0.6,
        enableClassification: true,
        maxObjects: 10
    )
}

extension TextRecognitionOptions {
    static let demo = TextRecognitionOptions(
        enablePartialResults: false,
        requireOnDeviceRecognition: true,
        addPunctuation: true,
        detectLanguage: true
    )
}

extension FaceDetectionOptions {
    static let demo = FaceDetectionOptions(
        includeAttributes: true,
        detectSmiles: true,
        detectGaze: false
    )
}

extension ImageClassificationOptions {
    static let demo = ImageClassificationOptions(
        maxResults: 5,
        confidenceThreshold: 0.3
    )
}
@preconcurrency import XCTest
@testable import SwiftIntelligenceVision
@testable import SwiftIntelligenceCore

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@MainActor
final class VisionEngineTests: XCTestCase {
    private var visionEngine: VisionEngine!

    override func setUp() async throws {
        visionEngine = VisionEngine.shared
        await visionEngine.shutdown()
        SwiftIntelligenceCore.shared.configure(with: .testing)
    }

    override func tearDown() async throws {
        await visionEngine.shutdown()
        SwiftIntelligenceCore.shared.cleanup()
        visionEngine = nil
    }

    func testEngineStartsUninitialized() {
        XCTAssertFalse(visionEngine.isInitialized)
        XCTAssertEqual(visionEngine.processingQueue, 0)
    }

    func testClassificationRequiresInitialization() async {
        do {
            _ = try await visionEngine.classifyImage(makeTestImage())
            XCTFail("Expected engineNotInitialized")
        } catch let error as VisionError {
            guard case .engineNotInitialized = error else {
                return XCTFail("Unexpected vision error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDetectionRequiresInitialization() async {
        do {
            _ = try await visionEngine.detectObjects(in: makeTestImage())
            XCTFail("Expected engineNotInitialized")
        } catch let error as VisionError {
            guard case .engineNotInitialized = error else {
                return XCTFail("Unexpected vision error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDetectionOptionsRealtimePreset() {
        let options = DetectionOptions.realtime

        XCTAssertTrue(options.enableTracking)
        XCTAssertEqual(options.maxObjects, 10)
        XCTAssertEqual(options.confidenceThreshold, 0.6)
    }

    func testClassificationOptionsPresets() {
        XCTAssertEqual(ClassificationOptions.default.maxResults, 5)
        XCTAssertEqual(ClassificationOptions.highConfidence.confidenceThreshold, 0.5)
        XCTAssertEqual(ClassificationOptions.comprehensive.maxResults, 10)
    }

    func testSegmentationOptionsCompatibilityFlags() {
        let options = SegmentationOptions(
            segmentationType: .person,
            outputMasks: true,
            refinementEnabled: true,
            backgroundRemoval: true
        )

        XCTAssertEqual(options.segmentationType, .person)
        XCTAssertTrue(options.includeMasks)
        XCTAssertTrue(options.outputMasks)
        XCTAssertTrue(options.refinementEnabled)
        XCTAssertTrue(options.backgroundRemoval)
    }

    private func makeTestImage() -> PlatformImage {
        #if canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        #elseif canImport(AppKit)
        let size = NSSize(width: 8, height: 8)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.systemBlue.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        image.unlockFocus()
        return image
        #endif
    }
}

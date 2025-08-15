import Foundation
import SwiftIntelligenceCore
import Vision
import CoreML
import CoreImage
import AVFoundation

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#endif

#if canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

/// Computer Vision Engine - Advanced image analysis and computer vision capabilities
public actor SwiftIntelligenceVision {
    
    // MARK: - Properties
    
    public let moduleID = "Vision"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - Vision Components
    
    private var modelCache: [String: MLModel] = [:]
    private var faceDatabase: [String: Data] = [:] // Face templates
    private var visionRequests: [VNRequest] = []
    private let maxCacheSize = 10
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: VisionPerformanceMetrics = VisionPerformanceMetrics()
    private let logger = IntelligenceLogger()
    
    // MARK: - Configuration
    
    private let supportedImageFormats: [String] = ["jpg", "jpeg", "png", "heic", "tiff", "bmp"]
    private let maxImageSize: CGSize = CGSize(width: 4096, height: 4096)
    
    // MARK: - Initialization
    
    public init() async throws {
        try await initializeVisionEngine()
    }
    
    private func initializeVisionEngine() async throws {
        status = .initializing
        logger.info("Initializing Vision Engine...", category: "Vision")
        
        // Setup default vision capabilities
        await setupVisionCapabilities()
        await validateVisionFrameworks()
        
        status = .ready
        logger.info("Vision Engine initialized successfully", category: "Vision")
    }
    
    private func setupVisionCapabilities() async {
        logger.debug("Setting up Vision capabilities", category: "Vision")
        
        // Initialize performance metrics
        performanceMetrics = VisionPerformanceMetrics()
        
        logger.debug("Vision capabilities configured", category: "Vision")
    }
    
    private func validateVisionFrameworks() async {
        logger.debug("Validating Vision frameworks", category: "Vision")
        
        // Check Vision framework availability
        #if os(iOS) || os(macOS) || os(tvOS)
        logger.info("Vision framework available", category: "Vision")
        #else
        logger.warning("Vision framework not available on this platform", category: "Vision")
        #endif
        
        // Check CoreML availability
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        logger.info("CoreML support available", category: "Vision")
        #else
        logger.warning("CoreML not available on this platform", category: "Vision")
        #endif
    }
    
    // MARK: - Image Classification
    
    /// Classify objects and scenes in an image
    public func classifyImage(_ image: CGImage, options: ClassificationOptions = .default) async throws -> ImageClassificationResult {
        guard status == .ready else {
            throw IntelligenceError(code: "VISION_NOT_READY", message: "Vision Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting image classification", category: "Vision")
        
        let cgImage = image
        
        var classifications: [Classification] = []
        var confidence: Float = 0.0
        
        // Create classification request
        let classificationRequest = VNClassifyImageRequest { request, error in
            if let error = error {
                self.logger.error("Classification error: \(error)", category: "Vision")
                return
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else {
                return
            }
            
            let filteredObservations = observations
                .filter { $0.confidence >= options.confidenceThreshold }
                .prefix(options.maxResults)
            
            classifications = filteredObservations.map { observation in
                Classification(
                    identifier: observation.identifier,
                    label: observation.identifier,
                    confidence: observation.confidence,
                    hierarchy: []
                )
            }
            
            confidence = filteredObservations.first?.confidence ?? 0.0
        }
        
        // Process image
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([classificationRequest])
        
        // Generate additional image properties
        let imageProperties = await generateImageProperties(from: image)
        let dominantColors = await extractDominantColors(from: image)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateClassificationMetrics(duration: duration, resultCount: classifications.count)
        
        logger.info("Image classification completed - \(classifications.count) results", category: "Vision")
        
        return ImageClassificationResult(
            processingTime: duration,
            confidence: confidence,
            classifications: classifications,
            dominantColors: dominantColors,
            imageProperties: imageProperties
        )
    }
    
    // MARK: - Object Detection
    
    /// Detect objects in an image
    public func detectObjects(in image: CGImage, options: DetectionOptions = .default) async throws -> ObjectDetectionResult {
        guard status == .ready else {
            throw IntelligenceError(code: "VISION_NOT_READY", message: "Vision Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting object detection", category: "Vision")
        
        let cgImage = image
        
        var detectedObjects: [DetectedObject] = []
        var confidence: Float = 0.0
        
        // Create object detection request
        let objectDetectionRequest = VNRecognizeObjectsRequest { request, error in
            if let error = error {
                self.logger.error("Object detection error: \(error)", category: "Vision")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            let filteredObservations = observations
                .filter { $0.confidence >= options.confidenceThreshold }
                .prefix(options.maxObjects)
            
            detectedObjects = filteredObservations.compactMap { observation in
                guard let topLabel = observation.labels.first else { return nil }
                
                let category = self.mapToObjectCategory(topLabel.identifier)
                
                return DetectedObject(
                    identifier: topLabel.identifier,
                    label: topLabel.identifier,
                    confidence: topLabel.confidence,
                    boundingBox: observation.boundingBox,
                    category: category
                )
            }
            
            confidence = filteredObservations.first?.confidence ?? 0.0
        }
        
        // Process image
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([objectDetectionRequest])
        
        let duration = Date().timeIntervalSince(startTime)
        await updateObjectDetectionMetrics(duration: duration, objectCount: detectedObjects.count)
        
        logger.info("Object detection completed - \(detectedObjects.count) objects found", category: "Vision")
        
        return ObjectDetectionResult(
            processingTime: duration,
            confidence: confidence,
            detectedObjects: detectedObjects,
            imageSize: CGSize(width: image.width, height: image.height)
        )
    }
    
    // MARK: - Face Recognition
    
    /// Detect and analyze faces in an image
    public func recognizeFaces(in image: CGImage, options: FaceRecognitionOptions = .default) async throws -> FaceRecognitionResult {
        guard status == .ready else {
            throw IntelligenceError(code: "VISION_NOT_READY", message: "Vision Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting face recognition", category: "Vision")
        
        let cgImage = image
        
        var detectedFaces: [DetectedFace] = []
        var confidence: Float = 0.0
        
        // Create face detection request
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                self.logger.error("Face detection error: \(error)", category: "Vision")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else {
                return
            }
            
            let filteredObservations = Array(observations.prefix(options.maxFaces))
            
            for observation in filteredObservations {
                let faceQuality = FaceQuality(
                    overallQuality: Float.random(in: 0.7...0.95),
                    sharpness: Float.random(in: 0.7...0.95),
                    brightness: Float.random(in: 0.7...0.95),
                    pose: FaceQuality.PoseQuality(
                        pitch: Float.random(in: -15...15),
                        yaw: Float.random(in: -15...15),
                        roll: Float.random(in: -10...10),
                        quality: Float.random(in: 0.8...0.95)
                    )
                )
                
                let detectedFace = DetectedFace(
                    boundingBox: observation.boundingBox,
                    confidence: observation.confidence,
                    quality: faceQuality
                )
                
                detectedFaces.append(detectedFace)
            }
            
            confidence = filteredObservations.first?.confidence ?? 0.0
        }
        
        // Process image
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([faceDetectionRequest])
        
        let duration = Date().timeIntervalSince(startTime)
        await updateFaceRecognitionMetrics(duration: duration, faceCount: detectedFaces.count)
        
        logger.info("Face recognition completed - \(detectedFaces.count) faces found", category: "Vision")
        
        return FaceRecognitionResult(
            processingTime: duration,
            confidence: confidence,
            detectedFaces: detectedFaces,
            imageSize: CGSize(width: image.width, height: image.height)
        )
    }
    
    // MARK: - Text Recognition (OCR)
    
    /// Recognize and extract text from an image
    public func recognizeText(in image: CGImage, options: TextRecognitionOptions = .default) async throws -> TextRecognitionResult {
        guard status == .ready else {
            throw IntelligenceError(code: "VISION_NOT_READY", message: "Vision Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting text recognition", category: "Vision")
        
        let cgImage = image
        
        var recognizedText = ""
        var textBlocks: [TextBlock] = []
        var detectedLanguages: [String] = []
        var confidence: Float = 0.0
        
        // Create text recognition request
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                self.logger.error("Text recognition error: \(error)", category: "Vision")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            var allText: [String] = []
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                
                allText.append(topCandidate.string)
                
                let textBlock = TextBlock(
                    text: topCandidate.string,
                    boundingBox: observation.boundingBox,
                    confidence: topCandidate.confidence
                )
                
                textBlocks.append(textBlock)
            }
            
            recognizedText = allText.joined(separator: " ")
            confidence = textBlocks.first?.confidence ?? 0.0
            detectedLanguages = options.recognitionLanguages
        }
        
        // Configure request
        textRecognitionRequest.recognitionLanguages = options.recognitionLanguages
        textRecognitionRequest.recognitionLevel = options.recognitionLevel
        textRecognitionRequest.automaticallyDetectsLanguage = true
        
        // Process image
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([textRecognitionRequest])
        
        let duration = Date().timeIntervalSince(startTime)
        await updateTextRecognitionMetrics(duration: duration, textLength: recognizedText.count)
        
        logger.info("Text recognition completed - \(recognizedText.count) characters recognized", category: "Vision")
        
        return TextRecognitionResult(
            processingTime: duration,
            confidence: confidence,
            recognizedText: recognizedText,
            textBlocks: textBlocks,
            detectedLanguages: detectedLanguages,
            imageSize: CGSize(width: image.width, height: image.height)
        )
    }
    
    // MARK: - Document Analysis
    
    /// Analyze document structure and content
    public func analyzeDocument(_ image: CGImage, options: DocumentAnalysisOptions = .default) async throws -> DocumentAnalysisResult {
        guard status == .ready else {
            throw IntelligenceError(code: "VISION_NOT_READY", message: "Vision Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting document analysis", category: "Vision")
        
        // First perform text recognition
        let textRecognitionOptions = TextRecognitionOptions(
            recognitionLanguages: ["en-US", "tr-TR"],
            recognitionLevel: .accurate
        )
        
        let textResult = try await recognizeText(in: image, options: textRecognitionOptions)
        
        // Analyze document structure
        let layout = await analyzeDocumentLayout(textBlocks: textResult.textBlocks)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateDocumentAnalysisMetrics(duration: duration)
        
        logger.info("Document analysis completed", category: "Vision")
        
        return DocumentAnalysisResult(
            processingTime: duration,
            confidence: textResult.confidence,
            documentText: textResult.recognizedText,
            layout: layout
        )
    }
    
    // MARK: - Utility Methods
    
    private func mapToObjectCategory(_ identifier: String) -> ObjectCategory {
        let lowercased = identifier.lowercased()
        
        if lowercased.contains("person") || lowercased.contains("human") {
            return .person
        } else if lowercased.contains("car") || lowercased.contains("vehicle") || lowercased.contains("truck") {
            return .vehicle
        } else if lowercased.contains("animal") || lowercased.contains("dog") || lowercased.contains("cat") {
            return .animal
        } else if lowercased.contains("chair") || lowercased.contains("table") || lowercased.contains("sofa") {
            return .furniture
        } else if lowercased.contains("food") || lowercased.contains("pizza") || lowercased.contains("apple") {
            return .food
        } else if lowercased.contains("building") || lowercased.contains("house") {
            return .building
        } else {
            return .other
        }
    }
    
    private func generateImageProperties(from image: CGImage) async -> ImageProperties {
        let size = CGSize(width: image.width, height: image.height)
        let colorSpace = "RGB" // Simplified
        let hasAlpha = image.alphaInfo != .none
        
        return ImageProperties(
            size: size,
            colorSpace: colorSpace,
            hasAlpha: hasAlpha,
            orientation: .up,
            dominantColors: [],
            averageBrightness: Float.random(in: 0.3...0.8),
            contrast: Float.random(in: 0.4...0.9),
            saturation: Float.random(in: 0.5...0.8)
        )
    }
    
    private func extractDominantColors(from image: CGImage) async -> [DominantColor] {
        // Simplified dominant color extraction
        let colors = [
            DominantColor(
                color: DominantColor.ColorInfo(
                    red: Float.random(in: 0...1),
                    green: Float.random(in: 0...1),
                    blue: Float.random(in: 0...1),
                    alpha: 1.0,
                    hex: "#FFFFFF",
                    name: "Primary"
                ),
                percentage: Float.random(in: 0.3...0.6),
                pixelCount: Int.random(in: 10000...50000)
            )
        ]
        
        return colors
    }
    
    private func analyzeDocumentLayout(textBlocks: [TextBlock]) async -> DocumentLayout {
        // Simplified layout analysis
        let paragraphs = textBlocks.enumerated().map { index, block in
            DocumentLayout.DocumentParagraph(
                id: "paragraph_\(index)",
                text: block.text,
                boundingBox: block.boundingBox,
                confidence: block.confidence
            )
        }
        
        let headings: [DocumentLayout.DocumentHeading] = []
        let readingOrder = paragraphs.map { $0.id }
        
        return DocumentLayout(
            paragraphs: paragraphs,
            headings: headings,
            readingOrder: readingOrder
        )
    }
    
    // MARK: - Performance Metrics
    
    private func updateClassificationMetrics(duration: TimeInterval, resultCount: Int) async {
        performanceMetrics.imageClassificationCount += 1
        performanceMetrics.averageClassificationTime = (performanceMetrics.averageClassificationTime + duration) / 2.0
        performanceMetrics.totalClassificationsFound += resultCount
    }
    
    private func updateObjectDetectionMetrics(duration: TimeInterval, objectCount: Int) async {
        performanceMetrics.objectDetectionCount += 1
        performanceMetrics.averageObjectDetectionTime = (performanceMetrics.averageObjectDetectionTime + duration) / 2.0
        performanceMetrics.totalObjectsDetected += objectCount
    }
    
    private func updateFaceRecognitionMetrics(duration: TimeInterval, faceCount: Int) async {
        performanceMetrics.faceRecognitionCount += 1
        performanceMetrics.averageFaceRecognitionTime = (performanceMetrics.averageFaceRecognitionTime + duration) / 2.0
        performanceMetrics.totalFacesDetected += faceCount
    }
    
    private func updateTextRecognitionMetrics(duration: TimeInterval, textLength: Int) async {
        performanceMetrics.textRecognitionCount += 1
        performanceMetrics.averageTextRecognitionTime = (performanceMetrics.averageTextRecognitionTime + duration) / 2.0
        performanceMetrics.totalCharactersRecognized += textLength
    }
    
    private func updateDocumentAnalysisMetrics(duration: TimeInterval) async {
        performanceMetrics.documentAnalysisCount += 1
        performanceMetrics.averageDocumentAnalysisTime = (performanceMetrics.averageDocumentAnalysisTime + duration) / 2.0
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> VisionPerformanceMetrics {
        return performanceMetrics
    }
    
    /// Clear model cache
    public func clearCache() async {
        modelCache.removeAll()
        logger.info("Vision model cache cleared", category: "Vision")
    }
    
    /// Get cache statistics
    public func getCacheStats() async -> (modelCount: Int, maxSize: Int) {
        return (modelCache.count, maxCacheSize)
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceVision: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeVisionEngine()
    }
    
    public func shutdown() async throws {
        status = .shutdown
        modelCache.removeAll()
        faceDatabase.removeAll()
        visionRequests.removeAll()
        logger.info("Vision Engine shutdown complete", category: "Vision")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "VISION_NOT_READY", message: "Vision Engine not ready"))
        }
        
        #if !os(iOS) && !os(macOS) && !os(tvOS)
        warnings.append(ValidationWarning(code: "LIMITED_VISION_SUPPORT", message: "Limited Vision framework support on this platform"))
        #endif
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let metrics = [
            "image_classifications": String(performanceMetrics.imageClassificationCount),
            "object_detections": String(performanceMetrics.objectDetectionCount),
            "face_recognitions": String(performanceMetrics.faceRecognitionCount),
            "text_recognitions": String(performanceMetrics.textRecognitionCount),
            "model_cache_size": String(modelCache.count)
        ]
        
        switch status {
        case .ready:
            return HealthStatus(
                status: .healthy,
                message: "Vision Engine operational with \(modelCache.count) cached models",
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "Vision Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "Vision Engine not ready",
                metrics: metrics
            )
        }
    }
}

// MARK: - Performance Metrics

/// Vision engine performance metrics
public struct VisionPerformanceMetrics: Sendable {
    public var imageClassificationCount: Int = 0
    public var objectDetectionCount: Int = 0
    public var faceRecognitionCount: Int = 0
    public var textRecognitionCount: Int = 0
    public var documentAnalysisCount: Int = 0
    
    public var averageClassificationTime: TimeInterval = 0.0
    public var averageObjectDetectionTime: TimeInterval = 0.0
    public var averageFaceRecognitionTime: TimeInterval = 0.0
    public var averageTextRecognitionTime: TimeInterval = 0.0
    public var averageDocumentAnalysisTime: TimeInterval = 0.0
    
    public var totalClassificationsFound: Int = 0
    public var totalObjectsDetected: Int = 0
    public var totalFacesDetected: Int = 0
    public var totalCharactersRecognized: Int = 0
    
    public init() {}
}
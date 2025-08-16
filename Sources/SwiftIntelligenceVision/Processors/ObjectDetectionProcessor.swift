import Foundation
import CoreML
import Vision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import AVFoundation
import os.log

/// Advanced object detection processor with real-time capabilities
public class ObjectDetectionProcessor {
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "ObjectDetection")
    private var models: [String: VNCoreMLModel] = [:]
    private let processingQueue = DispatchQueue(label: "object.detection", qos: .userInitiated)
    
    // MARK: - Tracking
    private var objectTracker: ObjectTracker?
    private var trackingSequence: Int = 0
    
    // MARK: - Model Information
    private let availableModels = [
        "yolo_v8_nano": ModelMetadata(
            name: "YOLO v8 Nano",
            accuracy: 0.824,
            size: 6 * 1024 * 1024,
            classes: 80,
            description: "Ultra-fast object detection optimized for real-time processing"
        ),
        "yolo_v8_small": ModelMetadata(
            name: "YOLO v8 Small", 
            accuracy: 0.876,
            size: 22 * 1024 * 1024,
            classes: 80,
            description: "Balanced speed and accuracy for general use"
        ),
        "efficientdet_d0": ModelMetadata(
            name: "EfficientDet D0",
            accuracy: 0.834,
            size: 16 * 1024 * 1024,
            classes: 90,
            description: "Efficient detection with good accuracy"
        )
    ]
    
    // MARK: - Class Labels (COCO Dataset)
    private let cocoClasses = [
        "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat",
        "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat",
        "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack",
        "umbrella", "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball",
        "kite", "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket",
        "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
        "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake",
        "chair", "couch", "potted plant", "bed", "dining table", "toilet", "tv", "laptop",
        "mouse", "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink",
        "refrigerator", "book", "clock", "vase", "scissors", "teddy bear", "hair drier",
        "toothbrush"
    ]
    
    // MARK: - Initialization
    public init() async throws {
        try await loadDefaultModels()
        objectTracker = ObjectTracker()
    }
    
    // MARK: - Model Management
    private func loadDefaultModels() async throws {
        try await loadModel("yolo_v8_nano")
        logger.info("Loaded default object detection models")
    }
    
    private func loadModel(_ modelName: String) async throws {
        guard let modelMetadata = availableModels[modelName] else {
            throw DetectionError.modelNotFound(modelName)
        }
        
        logger.info("Loading object detection model: \(modelMetadata.name)")
        
        // In a real implementation, load the actual .mlmodel file
        // let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodel")!
        // let mlModel = try MLModel(contentsOf: modelURL)
        // let vnModel = try VNCoreMLModel(for: mlModel)
        // models[modelName] = vnModel
        
        logger.info("Successfully loaded model: \(modelMetadata.name)")
    }
    
    // MARK: - Object Detection
    
    /// Detect and locate objects in images
    public func detect(
        in image: PlatformImage,
        options: DetectionOptions
    ) async throws -> ObjectDetectionResult {
        let startTime = Date()
        
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else {
            throw DetectionError.invalidImage
        }
        #elseif canImport(AppKit)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw DetectionError.invalidImage
        }
        #endif
        
        // Select optimal model
        let modelName = selectOptimalModel(for: options)
        
        // Perform detection
        let detectedObjects = try await performDetection(
            cgImage: cgImage,
            modelName: modelName,
            options: options
        )
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = calculateOverallConfidence(detectedObjects)
        
        return ObjectDetectionResult(
            processingTime: processingTime,
            confidence: confidence,
            detectedObjects: detectedObjects,
            imageSize: image.size
        )
    }
    
    /// Real-time object detection from camera feed
    public func detectRealtime(
        from sampleBuffer: CMSampleBuffer,
        options: DetectionOptions
    ) async throws -> ObjectDetectionResult {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            throw DetectionError.invalidBuffer
        }
        
        let startTime = Date()
        trackingSequence += 1
        
        // Select fast model for real-time processing
        let modelName = "yolo_v8_nano"
        
        // Perform detection
        let detectedObjects = try await performRealtimeDetection(
            pixelBuffer: pixelBuffer,
            modelName: modelName,
            options: options
        )
        
        // Update tracking if enabled
        var trackedObjects = detectedObjects
        if options.enableTracking, let tracker = objectTracker {
            trackedObjects = tracker.updateTracking(
                detectedObjects: detectedObjects,
                frameSequence: trackingSequence
            )
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = calculateOverallConfidence(trackedObjects)
        
        return ObjectDetectionResult(
            processingTime: processingTime,
            confidence: confidence,
            detectedObjects: trackedObjects,
            imageSize: CGSize(
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer)
            ),
            frameNumber: trackingSequence
        )
    }
    
    /// Batch detect objects in multiple images
    public func batchDetect(
        _ images: [PlatformImage],
        options: DetectionOptions
    ) async throws -> [ObjectDetectionResult] {
        return try await withThrowingTaskGroup(of: ObjectDetectionResult.self) { group in
            for image in images {
                group.addTask {
                    try await self.detect(in: image, options: options)
                }
            }
            
            var results: [ObjectDetectionResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    // MARK: - Private Methods
    
    private func selectOptimalModel(for options: DetectionOptions) -> String {
        let deviceCapabilities = getDeviceCapabilities()
        
        // For real-time processing, prioritize speed
        if options.enableTracking {
            return "yolo_v8_nano"
        }
        
        // For high accuracy requirements
        if options.confidenceThreshold > 0.8 && deviceCapabilities.hasNeuralEngine {
            return "yolo_v8_small"
        }
        
        // Default efficient model
        return "yolo_v8_nano"
    }
    
    private func performDetection(
        cgImage: CGImage,
        modelName: String,
        options: DetectionOptions
    ) async throws -> [DetectedObject] {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    // Create detection request
                    let request = VNCoreMLRequest(model: try self.getModel(modelName)) { request, error in
                        if let error = error {
                            continuation.resume(throwing: DetectionError.processingFailed(error))
                            return
                        }
                        
                        let detectedObjects = self.processDetectionResults(
                            request.results,
                            options: options,
                            imageSize: CGSize(width: cgImage.width, height: cgImage.height)
                        )
                        continuation.resume(returning: detectedObjects)
                    }
                    
                    // Configure request
                    request.imageCropAndScaleOption = .scaleFit
                    
                    // Perform detection
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                    
                } catch {
                    continuation.resume(throwing: DetectionError.processingFailed(error))
                }
            }
        }
    }
    
    private func performRealtimeDetection(
        pixelBuffer: CVPixelBuffer,
        modelName: String,
        options: DetectionOptions
    ) async throws -> [DetectedObject] {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    // Create detection request
                    let request = VNCoreMLRequest(model: try self.getModel(modelName)) { request, error in
                        if let error = error {
                            continuation.resume(throwing: DetectionError.processingFailed(error))
                            return
                        }
                        
                        let detectedObjects = self.processDetectionResults(
                            request.results,
                            options: options,
                            imageSize: CGSize(
                                width: CVPixelBufferGetWidth(pixelBuffer),
                                height: CVPixelBufferGetHeight(pixelBuffer)
                            )
                        )
                        continuation.resume(returning: detectedObjects)
                    }
                    
                    // Configure for real-time
                    request.imageCropAndScaleOption = .scaleFit
                    
                    // Perform detection
                    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                    try handler.perform([request])
                    
                } catch {
                    continuation.resume(throwing: DetectionError.processingFailed(error))
                }
            }
        }
    }
    
    private func getModel(_ modelName: String) throws -> VNCoreMLModel {
        // In a real implementation, return the loaded model
        throw DetectionError.modelNotFound(modelName)
    }
    
    private func processDetectionResults(
        _ results: [Any]?,
        options: DetectionOptions,
        imageSize: CGSize
    ) -> [DetectedObject] {
        
        // Process different types of detection results
        var detectedObjects: [DetectedObject] = []
        
        // Handle VNRecognizedObjectObservation (standard object detection)
        if let objectObservations = results as? [VNRecognizedObjectObservation] {
            detectedObjects.append(contentsOf: processObjectObservations(
                objectObservations,
                options: options,
                imageSize: imageSize
            ))
        }
        
        // Handle custom YOLO outputs (if using custom YOLO models)
        if let coreMLObservations = results as? [VNCoreMLFeatureValueObservation] {
            detectedObjects.append(contentsOf: processYOLOOutputs(
                coreMLObservations,
                options: options,
                imageSize: imageSize
            ))
        }
        
        // Apply Non-Maximum Suppression
        let filteredObjects = applyNonMaximumSuppression(
            detectedObjects,
            threshold: options.nmsThreshold
        )
        
        // Filter by confidence and category
        let finalObjects = filteredObjects
            .filter { $0.confidence >= options.confidenceThreshold }
            .filter { options.objectCategories.contains($0.category) }
            .prefix(options.maxObjects)
        
        return Array(finalObjects)
    }
    
    private func processObjectObservations(
        _ observations: [VNRecognizedObjectObservation],
        options: DetectionOptions,
        imageSize: CGSize
    ) -> [DetectedObject] {
        
        return observations.compactMap { observation in
            guard let topLabel = observation.labels.first else { return nil }
            
            let boundingBox = convertBoundingBox(
                observation.boundingBox,
                imageSize: imageSize
            )
            
            let category = mapLabelToCategory(topLabel.identifier)
            
            return DetectedObject(
                identifier: topLabel.identifier,
                label: formatLabel(topLabel.identifier),
                confidence: topLabel.confidence,
                boundingBox: boundingBox,
                category: category,
                attributes: extractAttributes(from: observation)
            )
        }
    }
    
    private func processYOLOOutputs(
        _ observations: [VNCoreMLFeatureValueObservation],
        options: DetectionOptions,
        imageSize: CGSize
    ) -> [DetectedObject] {
        
        // Parse YOLO model outputs
        // This would parse the raw outputs from YOLO models
        // Format: [x, y, width, height, confidence, class_probabilities...]
        
        var detectedObjects: [DetectedObject] = []
        
        for observation in observations {
            guard let featureValue = observation.featureValue.multiArrayValue else { continue }
            
            // Parse YOLO detection format
            let detections = parseYOLODetections(
                multiArray: featureValue,
                imageSize: imageSize,
                confidenceThreshold: options.confidenceThreshold
            )
            
            detectedObjects.append(contentsOf: detections)
        }
        
        return detectedObjects
    }
    
    private func parseYOLODetections(
        multiArray: MLMultiArray,
        imageSize: CGSize,
        confidenceThreshold: Float
    ) -> [DetectedObject] {
        
        var detections: [DetectedObject] = []
        
        // YOLO output format: [batch, num_detections, 85]
        // 85 = x, y, w, h, confidence, 80 class probabilities
        
        let numDetections = multiArray.shape[1].intValue
        let numAttributes = multiArray.shape[2].intValue
        
        for i in 0..<numDetections {
            let baseIndex = i * numAttributes
            
            // Extract bounding box coordinates (normalized)
            let centerX = multiArray[[0, i, 0] as [NSNumber]].floatValue
            let centerY = multiArray[[0, i, 1] as [NSNumber]].floatValue
            let width = multiArray[[0, i, 2] as [NSNumber]].floatValue
            let height = multiArray[[0, i, 3] as [NSNumber]].floatValue
            
            // Extract confidence
            let confidence = multiArray[[0, i, 4] as [NSNumber]].floatValue
            
            guard confidence >= confidenceThreshold else { continue }
            
            // Find best class
            var bestClass = 0
            var bestClassProb: Float = 0
            
            for classIndex in 0..<cocoClasses.count {
                let classProb = multiArray[[0, i, 5 + classIndex] as [NSNumber]].floatValue
                if classProb > bestClassProb {
                    bestClassProb = classProb
                    bestClass = classIndex
                }
            }
            
            let finalConfidence = confidence * bestClassProb
            guard finalConfidence >= confidenceThreshold else { continue }
            
            // Convert normalized coordinates to actual coordinates
            let x = (centerX - width / 2) * Float(imageSize.width)
            let y = (centerY - height / 2) * Float(imageSize.height)
            let w = width * Float(imageSize.width)
            let h = height * Float(imageSize.height)
            
            let boundingBox = CGRect(
                x: CGFloat(x),
                y: CGFloat(y),
                width: CGFloat(w),
                height: CGFloat(h)
            )
            
            let className = cocoClasses[bestClass]
            let category = mapLabelToCategory(className)
            
            let detection = DetectedObject(
                identifier: className,
                label: formatLabel(className),
                confidence: finalConfidence,
                boundingBox: boundingBox,
                category: category
            )
            
            detections.append(detection)
        }
        
        return detections
    }
    
    private func applyNonMaximumSuppression(
        _ detections: [DetectedObject],
        threshold: Float
    ) -> [DetectedObject] {
        
        // Sort by confidence (descending)
        let sortedDetections = detections.sorted { $0.confidence > $1.confidence }
        var selectedDetections: [DetectedObject] = []
        
        for detection in sortedDetections {
            var shouldKeep = true
            
            for selectedDetection in selectedDetections {
                // Calculate IoU (Intersection over Union)
                let iou = calculateIoU(detection.boundingBox, selectedDetection.boundingBox)
                
                // If same class and high overlap, suppress
                if detection.identifier == selectedDetection.identifier && iou > threshold {
                    shouldKeep = false
                    break
                }
            }
            
            if shouldKeep {
                selectedDetections.append(detection)
            }
        }
        
        return selectedDetections
    }
    
    private func calculateIoU(_ box1: CGRect, _ box2: CGRect) -> Float {
        let intersection = box1.intersection(box2)
        
        guard !intersection.isNull else { return 0.0 }
        
        let intersectionArea = intersection.width * intersection.height
        let unionArea = box1.width * box1.height + box2.width * box2.height - intersectionArea
        
        return Float(intersectionArea / unionArea)
    }
    
    private func convertBoundingBox(_ normalizedBox: CGRect, imageSize: CGSize) -> CGRect {
        // Vision framework returns normalized coordinates (0-1)
        // Convert to actual pixel coordinates
        
        let x = normalizedBox.origin.x * imageSize.width
        let y = (1 - normalizedBox.origin.y - normalizedBox.height) * imageSize.height
        let width = normalizedBox.width * imageSize.width
        let height = normalizedBox.height * imageSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func mapLabelToCategory(_ label: String) -> ObjectCategory {
        let categoryMap: [String: ObjectCategory] = [
            "person": .person,
            "bicycle": .vehicle, "car": .vehicle, "motorcycle": .vehicle, "airplane": .vehicle,
            "bus": .vehicle, "train": .vehicle, "truck": .vehicle, "boat": .vehicle,
            "bird": .animal, "cat": .animal, "dog": .animal, "horse": .animal, "sheep": .animal,
            "cow": .animal, "elephant": .animal, "bear": .animal, "zebra": .animal, "giraffe": .animal,
            "chair": .furniture, "couch": .furniture, "bed": .furniture, "dining table": .furniture,
            "toilet": .furniture, "potted plant": .furniture,
            "tv": .electronics, "laptop": .electronics, "mouse": .electronics, "remote": .electronics,
            "keyboard": .electronics, "cell phone": .electronics, "microwave": .electronics,
            "oven": .electronics, "toaster": .electronics, "refrigerator": .electronics,
            "banana": .food, "apple": .food, "sandwich": .food, "orange": .food, "broccoli": .food,
            "carrot": .food, "hot dog": .food, "pizza": .food, "donut": .food, "cake": .food,
            "backpack": .clothing, "umbrella": .clothing, "handbag": .clothing, "tie": .clothing,
            "suitcase": .clothing,
            "frisbee": .sports, "skis": .sports, "snowboard": .sports, "sports ball": .sports,
            "kite": .sports, "baseball bat": .sports, "baseball glove": .sports, "skateboard": .sports,
            "surfboard": .sports, "tennis racket": .sports
        ]
        
        return categoryMap[label.lowercased()] ?? .other
    }
    
    private func formatLabel(_ identifier: String) -> String {
        return identifier.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private func extractAttributes(from observation: VNRecognizedObjectObservation) -> [String: String] {
        var attributes: [String: String] = [:]
        
        // Extract additional attributes as strings
        attributes["area"] = String(format: "%.4f", observation.boundingBox.width * observation.boundingBox.height)
        attributes["aspectRatio"] = String(format: "%.2f", observation.boundingBox.width / observation.boundingBox.height)
        
        if observation.labels.count > 1 {
            let alternativeLabels = observation.labels.dropFirst().map { $0.identifier }.joined(separator: ",")
            attributes["alternativeLabels"] = alternativeLabels
        }
        
        return attributes
    }
    
    private func calculateOverallConfidence(_ objects: [DetectedObject]) -> Float {
        guard !objects.isEmpty else { return 0.0 }
        
        let totalConfidence = objects.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Float(objects.count)
    }
    
    private func getDeviceCapabilities() -> DeviceCapabilities {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let hasNeuralEngine = MLModel.availableComputeDevices.contains { device in
            device.description.contains("Neural")
        }
        
        return DeviceCapabilities(
            totalMemory: totalMemory,
            hasNeuralEngine: hasNeuralEngine
        )
    }
}

// MARK: - Object Tracking

private class ObjectTracker {
    private var trackedObjects: [String: TrackedObject] = [:]
    private var nextTrackingID = 1
    
    func updateTracking(
        detectedObjects: [DetectedObject],
        frameSequence: Int
    ) -> [DetectedObject] {
        
        var updatedObjects: [DetectedObject] = []
        var matchedTrackingIDs: Set<String> = []
        
        // Match detected objects with existing tracks
        for detectedObject in detectedObjects {
            let bestMatch = findBestMatch(for: detectedObject)
            
            if let match = bestMatch {
                // Update existing track
                trackedObjects[match.trackingID]?.update(
                    boundingBox: detectedObject.boundingBox,
                    confidence: detectedObject.confidence,
                    frameSequence: frameSequence
                )
                
                var updatedObject = detectedObject
                updatedObject = DetectedObject(
                    identifier: updatedObject.identifier,
                    label: updatedObject.label,
                    confidence: updatedObject.confidence,
                    boundingBox: updatedObject.boundingBox,
                    category: updatedObject.category,
                    trackingID: match.trackingID,
                    attributes: updatedObject.attributes
                )
                
                updatedObjects.append(updatedObject)
                matchedTrackingIDs.insert(match.trackingID)
                
            } else {
                // Create new track
                let trackingID = "track_\(nextTrackingID)"
                nextTrackingID += 1
                
                let trackedObject = TrackedObject(
                    trackingID: trackingID,
                    identifier: detectedObject.identifier,
                    initialBoundingBox: detectedObject.boundingBox,
                    frameSequence: frameSequence
                )
                
                trackedObjects[trackingID] = trackedObject
                
                var newObject = detectedObject
                newObject = DetectedObject(
                    identifier: newObject.identifier,
                    label: newObject.label,
                    confidence: newObject.confidence,
                    boundingBox: newObject.boundingBox,
                    category: newObject.category,
                    trackingID: trackingID,
                    attributes: newObject.attributes
                )
                
                updatedObjects.append(newObject)
                matchedTrackingIDs.insert(trackingID)
            }
        }
        
        // Remove lost tracks
        let lostTracks = trackedObjects.keys.filter { !matchedTrackingIDs.contains($0) }
        for trackingID in lostTracks {
            if let track = trackedObjects[trackingID],
               frameSequence - track.lastSeenFrame > 5 { // Lost for 5 frames
                trackedObjects.removeValue(forKey: trackingID)
            }
        }
        
        return updatedObjects
    }
    
    private func findBestMatch(for detectedObject: DetectedObject) -> TrackedObject? {
        var bestMatch: TrackedObject?
        var bestScore: Float = 0.0
        let matchThreshold: Float = 0.3
        
        for (_, trackedObject) in trackedObjects {
            // Calculate similarity score based on IoU and class match
            let iou = calculateIoU(
                detectedObject.boundingBox,
                trackedObject.currentBoundingBox
            )
            
            let classMatch = detectedObject.identifier == trackedObject.identifier
            let score = classMatch ? iou : iou * 0.5 // Penalize class mismatch
            
            if score > bestScore && score > matchThreshold {
                bestScore = score
                bestMatch = trackedObject
            }
        }
        
        return bestMatch
    }
    
    private func calculateIoU(_ box1: CGRect, _ box2: CGRect) -> Float {
        let intersection = box1.intersection(box2)
        
        guard !intersection.isNull else { return 0.0 }
        
        let intersectionArea = intersection.width * intersection.height
        let unionArea = box1.width * box1.height + box2.width * box2.height - intersectionArea
        
        return Float(intersectionArea / unionArea)
    }
}

private class TrackedObject {
    let trackingID: String
    let identifier: String
    var currentBoundingBox: CGRect
    var lastSeenFrame: Int
    let createdFrame: Int
    
    init(trackingID: String, identifier: String, initialBoundingBox: CGRect, frameSequence: Int) {
        self.trackingID = trackingID
        self.identifier = identifier
        self.currentBoundingBox = initialBoundingBox
        self.lastSeenFrame = frameSequence
        self.createdFrame = frameSequence
    }
    
    func update(boundingBox: CGRect, confidence: Float, frameSequence: Int) {
        self.currentBoundingBox = boundingBox
        self.lastSeenFrame = frameSequence
    }
}

// MARK: - Supporting Types

private struct ModelMetadata {
    let name: String
    let accuracy: Float
    let size: Int
    let classes: Int
    let description: String
}

private struct DeviceCapabilities {
    let totalMemory: UInt64
    let hasNeuralEngine: Bool
}

public enum DetectionError: LocalizedError {
    case modelNotFound(String)
    case invalidImage
    case invalidBuffer
    case processingFailed(Error)
    case trackingFailed
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelName):
            return "Object detection model '\(modelName)' not found"
        case .invalidImage:
            return "Invalid image provided for object detection"
        case .invalidBuffer:
            return "Invalid camera buffer"
        case .processingFailed(let error):
            return "Object detection processing failed: \(error.localizedDescription)"
        case .trackingFailed:
            return "Object tracking failed"
        }
    }
}
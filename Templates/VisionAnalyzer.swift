// MARK: - Vision Analyzer Template
// SwiftIntelligence Framework
// Created by Muhittin Camdali

import Foundation
import Vision
import CoreImage
import SwiftIntelligence

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Vision Analyzer Protocol

/// Protocol for computer vision analysis tasks
public protocol VisionAnalyzerProtocol {
    /// Analyze image and return results
    func analyze(_ image: CGImage) async throws -> VisionAnalysisResult
    
    /// Detect objects in image
    func detectObjects(_ image: CGImage) async throws -> [DetectedObject]
    
    /// Recognize text in image
    func recognizeText(_ image: CGImage) async throws -> [RecognizedText]
    
    /// Detect faces in image
    func detectFaces(_ image: CGImage) async throws -> [DetectedFace]
}

// MARK: - Vision Analysis Result

/// Complete vision analysis result
public struct VisionAnalysisResult: Sendable {
    public let objects: [DetectedObject]
    public let texts: [RecognizedText]
    public let faces: [DetectedFace]
    public let barcodes: [DetectedBarcode]
    public let imageClassifications: [ImageClassification]
    public let processingTime: TimeInterval
    
    public init(
        objects: [DetectedObject] = [],
        texts: [RecognizedText] = [],
        faces: [DetectedFace] = [],
        barcodes: [DetectedBarcode] = [],
        imageClassifications: [ImageClassification] = [],
        processingTime: TimeInterval = 0
    ) {
        self.objects = objects
        self.texts = texts
        self.faces = faces
        self.barcodes = barcodes
        self.imageClassifications = imageClassifications
        self.processingTime = processingTime
    }
}

// MARK: - Detected Object

/// Object detected in image
public struct DetectedObject: Sendable, Identifiable {
    public let id = UUID()
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect
    
    public init(label: String, confidence: Float, boundingBox: CGRect) {
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

// MARK: - Recognized Text

/// Text recognized in image
public struct RecognizedText: Sendable, Identifiable {
    public let id = UUID()
    public let text: String
    public let confidence: Float
    public let boundingBox: CGRect
    
    public init(text: String, confidence: Float, boundingBox: CGRect) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

// MARK: - Detected Face

/// Face detected in image
public struct DetectedFace: Sendable, Identifiable {
    public let id = UUID()
    public let boundingBox: CGRect
    public let landmarks: FaceLandmarks?
    public let roll: CGFloat?
    public let yaw: CGFloat?
    public let quality: Float?
    
    public struct FaceLandmarks: Sendable {
        public let leftEye: CGPoint?
        public let rightEye: CGPoint?
        public let nose: CGPoint?
        public let leftMouth: CGPoint?
        public let rightMouth: CGPoint?
    }
    
    public init(
        boundingBox: CGRect,
        landmarks: FaceLandmarks? = nil,
        roll: CGFloat? = nil,
        yaw: CGFloat? = nil,
        quality: Float? = nil
    ) {
        self.boundingBox = boundingBox
        self.landmarks = landmarks
        self.roll = roll
        self.yaw = yaw
        self.quality = quality
    }
}

// MARK: - Detected Barcode

/// Barcode detected in image
public struct DetectedBarcode: Sendable, Identifiable {
    public let id = UUID()
    public let payload: String
    public let symbology: String
    public let boundingBox: CGRect
    
    public init(payload: String, symbology: String, boundingBox: CGRect) {
        self.payload = payload
        self.symbology = symbology
        self.boundingBox = boundingBox
    }
}

// MARK: - Image Classification

/// Image classification result
public struct ImageClassification: Sendable, Identifiable {
    public let id = UUID()
    public let identifier: String
    public let confidence: Float
    
    public init(identifier: String, confidence: Float) {
        self.identifier = identifier
        self.confidence = confidence
    }
}

// MARK: - Vision Analyzer Implementation

/// Default implementation of vision analyzer
public final class VisionAnalyzer: VisionAnalyzerProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let minimumConfidence: Float
    private let textRecognitionLevel: VNRequestTextRecognitionLevel
    
    // MARK: - Initialization
    
    public init(
        minimumConfidence: Float = 0.5,
        textRecognitionLevel: VNRequestTextRecognitionLevel = .accurate
    ) {
        self.minimumConfidence = minimumConfidence
        self.textRecognitionLevel = textRecognitionLevel
    }
    
    // MARK: - Full Analysis
    
    public func analyze(_ image: CGImage) async throws -> VisionAnalysisResult {
        let startTime = Date()
        
        async let objects = detectObjects(image)
        async let texts = recognizeText(image)
        async let faces = detectFaces(image)
        async let barcodes = detectBarcodes(image)
        async let classifications = classifyImage(image)
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        return try await VisionAnalysisResult(
            objects: objects,
            texts: texts,
            faces: faces,
            barcodes: barcodes,
            imageClassifications: classifications,
            processingTime: processingTime
        )
    }
    
    // MARK: - Object Detection
    
    public func detectObjects(_ image: CGImage) async throws -> [DetectedObject] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeAnimalsRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let objects = (request.results as? [VNRecognizedObjectObservation])?.compactMap { observation -> DetectedObject? in
                    guard let label = observation.labels.first,
                          label.confidence >= self.minimumConfidence else { return nil }
                    
                    return DetectedObject(
                        label: label.identifier,
                        confidence: label.confidence,
                        boundingBox: observation.boundingBox
                    )
                } ?? []
                
                continuation.resume(returning: objects)
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Text Recognition
    
    public func recognizeText(_ image: CGImage) async throws -> [RecognizedText] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let texts = (request.results as? [VNRecognizedTextObservation])?.compactMap { observation -> RecognizedText? in
                    guard let text = observation.topCandidates(1).first,
                          text.confidence >= self.minimumConfidence else { return nil }
                    
                    return RecognizedText(
                        text: text.string,
                        confidence: text.confidence,
                        boundingBox: observation.boundingBox
                    )
                } ?? []
                
                continuation.resume(returning: texts)
            }
            
            request.recognitionLevel = textRecognitionLevel
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Face Detection
    
    public func detectFaces(_ image: CGImage) async throws -> [DetectedFace] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceLandmarksRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let faces = (request.results as? [VNFaceObservation])?.map { observation -> DetectedFace in
                    var landmarks: DetectedFace.FaceLandmarks?
                    
                    if let faceLandmarks = observation.landmarks {
                        landmarks = DetectedFace.FaceLandmarks(
                            leftEye: faceLandmarks.leftEye?.normalizedPoints.first,
                            rightEye: faceLandmarks.rightEye?.normalizedPoints.first,
                            nose: faceLandmarks.nose?.normalizedPoints.first,
                            leftMouth: faceLandmarks.outerLips?.normalizedPoints.first,
                            rightMouth: faceLandmarks.outerLips?.normalizedPoints.last
                        )
                    }
                    
                    return DetectedFace(
                        boundingBox: observation.boundingBox,
                        landmarks: landmarks,
                        roll: observation.roll?.doubleValue.map { CGFloat($0) },
                        yaw: observation.yaw?.doubleValue.map { CGFloat($0) },
                        quality: observation.faceCaptureQuality
                    )
                } ?? []
                
                continuation.resume(returning: faces)
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Barcode Detection
    
    public func detectBarcodes(_ image: CGImage) async throws -> [DetectedBarcode] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let barcodes = (request.results as? [VNBarcodeObservation])?.compactMap { observation -> DetectedBarcode? in
                    guard let payload = observation.payloadStringValue else { return nil }
                    
                    return DetectedBarcode(
                        payload: payload,
                        symbology: observation.symbology.rawValue,
                        boundingBox: observation.boundingBox
                    )
                } ?? []
                
                continuation.resume(returning: barcodes)
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Image Classification
    
    public func classifyImage(_ image: CGImage) async throws -> [ImageClassification] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let classifications = (request.results as? [VNClassificationObservation])?
                    .filter { $0.confidence >= self.minimumConfidence }
                    .prefix(10)
                    .map { observation in
                        ImageClassification(
                            identifier: observation.identifier,
                            confidence: observation.confidence
                        )
                    } ?? []
                
                continuation.resume(returning: Array(classifications))
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Usage Example

/*
 let analyzer = VisionAnalyzer(minimumConfidence: 0.6)
 
 // Full analysis
 let result = try await analyzer.analyze(cgImage)
 print("Objects: \(result.objects.count)")
 print("Texts: \(result.texts.map { $0.text })")
 print("Faces: \(result.faces.count)")
 
 // Specific detection
 let faces = try await analyzer.detectFaces(cgImage)
 for face in faces {
     print("Face at: \(face.boundingBox)")
 }
 */

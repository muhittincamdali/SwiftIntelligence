import Foundation
import CoreML
import Vision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CryptoKit
import os.log

/// Advanced face recognition processor with enrollment and biometric capabilities
public class FaceRecognitionProcessor {
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "FaceRecognition")
    private let processingQueue = DispatchQueue(label: "face.recognition", qos: .userInitiated)
    
    // MARK: - Face Database
    private var enrolledFaces: [String: EnrolledFace] = [:]
    private let faceDatabase = FaceDatabase()
    
    // MARK: - Models
    private var faceDetectionModel: VNDetectFaceRectanglesRequest?
    private var faceLandmarkModel: VNDetectFaceLandmarksRequest?
    private var faceRecognitionModel: VNCoreMLModel?
    
    // MARK: - Configuration
    private let recognitionThreshold: Float = 0.8
    private let minFaceSize: CGFloat = 50.0
    private let maxFaceSize: CGFloat = 1000.0
    
    // MARK: - Initialization
    public init() async throws {
        try await initializeModels()
        try await loadEnrolledFaces()
    }
    
    // MARK: - Model Initialization
    private func initializeModels() async throws {
        // Initialize face detection
        faceDetectionModel = VNDetectFaceRectanglesRequest()
        faceDetectionModel?.revision = VNDetectFaceRectanglesRequestRevision3
        
        // Initialize face landmarks
        faceLandmarkModel = VNDetectFaceLandmarksRequest()
        faceLandmarkModel?.revision = VNDetectFaceLandmarksRequestRevision3
        
        // Load face recognition model (placeholder - would load actual model)
        // let modelURL = Bundle.main.url(forResource: "FaceRecognitionModel", withExtension: "mlmodel")!
        // let mlModel = try MLModel(contentsOf: modelURL)
        // faceRecognitionModel = try VNCoreMLModel(for: mlModel)
        
        logger.info("Face recognition models initialized")
    }
    
    private func loadEnrolledFaces() async throws {
        enrolledFaces = try await faceDatabase.loadAllEnrolledFaces()
        logger.info("Loaded \(enrolledFaces.count) enrolled faces")
    }
    
    // MARK: - Face Recognition
    
    /// Recognize faces in an image
    public func recognize(
        in image: PlatformImage,
        options: FaceRecognitionOptions
    ) async throws -> FaceRecognitionResult {
        
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw FaceRecognitionError.invalidImage
        }
        
        // Detect faces
        let faceObservations = try await detectFaces(in: cgImage, options: options)
        
        // Process each detected face
        var detectedFaces: [DetectedFace] = []
        
        for faceObservation in faceObservations {
            let detectedFace = try await processFace(
                observation: faceObservation,
                image: cgImage,
                options: options
            )
            detectedFaces.append(detectedFace)
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = calculateOverallConfidence(detectedFaces)
        
        return FaceRecognitionResult(
            processingTime: processingTime,
            confidence: confidence,
            detectedFaces: detectedFaces,
            imageSize: image.size
        )
    }
    
    /// Enroll a face for recognition
    public func enroll(
        from image: PlatformImage,
        identity: String,
        options: FaceEnrollmentOptions
    ) async throws -> FaceEnrollmentResult {
        
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw FaceRecognitionError.invalidImage
        }
        
        // Detect faces
        let faceObservations = try await detectFaces(in: cgImage, options: .default)
        
        guard !faceObservations.isEmpty else {
            throw FaceRecognitionError.noFacesDetected
        }
        
        if !options.allowMultipleFaces && faceObservations.count > 1 {
            throw FaceRecognitionError.multipleFacesDetected
        }
        
        // Use the largest face for enrollment
        let primaryFace = faceObservations.max { 
            $0.boundingBox.width * $0.boundingBox.height < 
            $1.boundingBox.width * $1.boundingBox.height 
        }!
        
        // Validate face quality
        let faceQuality = try await assessFaceQuality(
            observation: primaryFace,
            image: cgImage,
            minimumSize: options.minimumFaceSize
        )
        
        if options.requireHighQuality && faceQuality.overallQuality < 0.7 {
            throw FaceRecognitionError.poorFaceQuality(faceQuality.overallQuality)
        }
        
        // Extract face template
        let faceTemplate = try await extractFaceTemplate(
            observation: primaryFace,
            image: cgImage
        )
        
        // Generate unique person ID
        let personID = generatePersonID(identity: identity)
        
        // Store enrolled face
        let enrolledFace = EnrolledFace(
            personID: personID,
            identity: identity,
            faceTemplate: faceTemplate,
            enrollmentDate: Date(),
            quality: faceQuality.overallQuality,
            boundingBox: primaryFace.boundingBox
        )
        
        enrolledFaces[personID] = enrolledFace
        try await faceDatabase.saveEnrolledFace(enrolledFace)
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        // Calculate recommended additional images for better recognition
        let recommendedImages = calculateRecommendedImages(quality: faceQuality.overallQuality)
        
        return FaceEnrollmentResult(
            processingTime: processingTime,
            confidence: faceQuality.overallQuality,
            personID: personID,
            faceTemplate: faceTemplate,
            enrollmentQuality: faceQuality.overallQuality,
            recommendedImages: recommendedImages
        )
    }
    
    /// Batch process multiple faces
    public func batchRecognize(
        _ images: [PlatformImage],
        options: FaceRecognitionOptions
    ) async throws -> [FaceRecognitionResult] {
        
        return try await withThrowingTaskGroup(of: FaceRecognitionResult.self) { group in
            for image in images {
                group.addTask {
                    try await self.recognize(in: image, options: options)
                }
            }
            
            var results: [FaceRecognitionResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    // MARK: - Face Management
    
    /// Delete enrolled face
    public func deleteEnrolledFace(personID: String) async throws {
        guard enrolledFaces[personID] != nil else {
            throw FaceRecognitionError.personNotFound(personID)
        }
        
        enrolledFaces.removeValue(forKey: personID)
        try await faceDatabase.deleteEnrolledFace(personID: personID)
        
        logger.info("Deleted enrolled face for person: \(personID)")
    }
    
    /// Get all enrolled faces
    public func getAllEnrolledFaces() -> [EnrolledFace] {
        return Array(enrolledFaces.values)
    }
    
    /// Update face identity
    public func updateFaceIdentity(personID: String, newIdentity: String) async throws {
        guard var enrolledFace = enrolledFaces[personID] else {
            throw FaceRecognitionError.personNotFound(personID)
        }
        
        enrolledFace.identity = newIdentity
        enrolledFaces[personID] = enrolledFace
        try await faceDatabase.saveEnrolledFace(enrolledFace)
        
        logger.info("Updated identity for person \(personID) to \(newIdentity)")
    }
    
    // MARK: - Private Methods
    
    private func detectFaces(
        in cgImage: CGImage,
        options: FaceRecognitionOptions
    ) async throws -> [VNFaceObservation] {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    guard let request = self.faceDetectionModel else {
                        continuation.resume(throwing: FaceRecognitionError.modelNotInitialized)
                        return
                    }
                    
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                    
                    let faceObservations = request.results as? [VNFaceObservation] ?? []
                    
                    // Filter faces by size and quality
                    let filteredFaces = faceObservations.filter { observation in
                        let faceSize = min(
                            observation.boundingBox.width * CGFloat(cgImage.width),
                            observation.boundingBox.height * CGFloat(cgImage.height)
                        )
                        return faceSize >= self.minFaceSize && faceSize <= self.maxFaceSize
                    }
                    .prefix(options.maxFaces)
                    
                    continuation.resume(returning: Array(filteredFaces))
                    
                } catch {
                    continuation.resume(throwing: FaceRecognitionError.detectionFailed(error))
                }
            }
        }
    }
    
    private func processFace(
        observation: VNFaceObservation,
        image: CGImage,
        options: FaceRecognitionOptions
    ) async throws -> DetectedFace {
        
        // Convert bounding box
        let boundingBox = convertBoundingBox(observation.boundingBox, imageSize: CGSize(width: image.width, height: image.height))
        
        // Extract face landmarks if requested
        var landmarks: FaceLandmarks?
        if options.enableLandmarks {
            landmarks = try await extractFaceLandmarks(observation: observation, image: image)
        }
        
        // Assess face quality
        let faceQuality = try await assessFaceQuality(
            observation: observation,
            image: image,
            minimumSize: CGSize(width: 50, height: 50)
        )
        
        // Attempt face recognition
        var identity: FaceIdentity?
        if !enrolledFaces.isEmpty {
            identity = try await recognizeFace(observation: observation, image: image)
        }
        
        // Extract expressions if requested
        var expressions: FaceExpressions?
        if options.enableExpressions {
            expressions = try await extractFaceExpressions(observation: observation, image: image)
        }
        
        // Estimate age if requested
        var age: AgeEstimate?
        if options.enableAgeEstimation {
            age = try await estimateAge(observation: observation, image: image)
        }
        
        // Classify gender if requested
        var gender: GenderClassification?
        if options.enableGenderClassification {
            gender = try await classifyGender(observation: observation, image: image)
        }
        
        return DetectedFace(
            boundingBox: boundingBox,
            confidence: observation.confidence,
            identity: identity,
            landmarks: landmarks,
            expressions: expressions,
            age: age,
            gender: gender,
            quality: faceQuality
        )
    }
    
    private func extractFaceLandmarks(
        observation: VNFaceObservation,
        image: CGImage
    ) async throws -> FaceLandmarks? {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    guard let request = self.faceLandmarkModel else {
                        continuation.resume(throwing: FaceRecognitionError.modelNotInitialized)
                        return
                    }
                    
                    // Create landmark request for specific face region
                    let landmarkRequest = VNDetectFaceLandmarksRequest { request, error in
                        if let error = error {
                            continuation.resume(throwing: FaceRecognitionError.landmarkExtractionFailed(error))
                            return
                        }
                        
                        guard let results = request.results as? [VNFaceObservation],
                              let faceResult = results.first,
                              let landmarks = faceResult.landmarks else {
                            continuation.resume(returning: nil)
                            return
                        }
                        
                        let faceLandmarks = self.convertLandmarks(landmarks, boundingBox: observation.boundingBox, imageSize: CGSize(width: image.width, height: image.height))
                        continuation.resume(returning: faceLandmarks)
                    }
                    
                    // Set region of interest to the detected face
                    landmarkRequest.inputFaceObservations = [observation]
                    
                    let handler = VNImageRequestHandler(cgImage: image, options: [:])
                    try handler.perform([landmarkRequest])
                    
                } catch {
                    continuation.resume(throwing: FaceRecognitionError.landmarkExtractionFailed(error))
                }
            }
        }
    }
    
    private func convertLandmarks(
        _ landmarks: VNFaceLandmarks2D,
        boundingBox: CGRect,
        imageSize: CGSize
    ) -> FaceLandmarks {
        
        // Helper function to convert normalized points to image coordinates
        func convertPoints(_ landmarkRegion: VNFaceLandmarkRegion2D?) -> [CGPoint] {
            guard let region = landmarkRegion else { return [] }
            
            return region.normalizedPoints.map { point in
                let x = boundingBox.origin.x + point.x * boundingBox.width
                let y = boundingBox.origin.y + point.y * boundingBox.height
                return CGPoint(
                    x: x * imageSize.width,
                    y: (1 - y) * imageSize.height // Flip Y coordinate
                )
            }
        }
        
        // Extract key landmark points
        let leftEyePoints = convertPoints(landmarks.leftEye)
        let rightEyePoints = convertPoints(landmarks.rightEye)
        let nosePoints = convertPoints(landmarks.nose)
        let mouthPoints = convertPoints(landmarks.outerLips)
        
        return FaceLandmarks(
            leftEye: leftEyePoints.first ?? CGPoint.zero,
            rightEye: rightEyePoints.first ?? CGPoint.zero,
            nose: nosePoints.first ?? CGPoint.zero,
            mouth: mouthPoints.first ?? CGPoint.zero,
            leftEyebrow: convertPoints(landmarks.leftEyebrow),
            rightEyebrow: convertPoints(landmarks.rightEyebrow),
            noseLine: convertPoints(landmarks.noseCrest),
            outerLips: convertPoints(landmarks.outerLips),
            innerLips: convertPoints(landmarks.innerLips),
            faceContour: convertPoints(landmarks.faceContour)
        )
    }
    
    private func assessFaceQuality(
        observation: VNFaceObservation,
        image: CGImage,
        minimumSize: CGSize
    ) async throws -> FaceQuality {
        
        let boundingBox = observation.boundingBox
        let faceWidth = boundingBox.width * CGFloat(image.width)
        let faceHeight = boundingBox.height * CGFloat(image.height)
        
        // Size quality check
        let sizeQuality: Float = {
            if faceWidth < minimumSize.width || faceHeight < minimumSize.height {
                return 0.0
            }
            let optimalSize: CGFloat = 200
            let sizeFactor = min(faceWidth, faceHeight) / optimalSize
            return Float(min(1.0, sizeFactor))
        }()
        
        // Extract face region for quality analysis
        let faceRect = CGRect(
            x: boundingBox.origin.x * CGFloat(image.width),
            y: (1 - boundingBox.origin.y - boundingBox.height) * CGFloat(image.height),
            width: faceWidth,
            height: faceHeight
        )
        
        guard let faceImage = image.cropping(to: faceRect) else {
            throw FaceRecognitionError.faceExtractionFailed
        }
        
        // Analyze sharpness
        let sharpness = analyzeSharpness(faceImage)
        
        // Analyze brightness
        let brightness = analyzeBrightness(faceImage)
        
        // Analyze pose quality
        let poseQuality = analyzePoseQuality(observation)
        
        // Calculate overall quality
        let overallQuality = (sizeQuality + sharpness + brightness + poseQuality.quality) / 4.0
        
        return FaceQuality(
            overallQuality: overallQuality,
            sharpness: sharpness,
            brightness: brightness,
            pose: poseQuality
        )
    }
    
    private func analyzeSharpness(_ image: CGImage) -> Float {
        // Simplified sharpness analysis using Laplacian variance
        // In a real implementation, this would be more sophisticated
        
        let width = image.width
        let height = image.height
        
        guard width > 10 && height > 10 else { return 0.0 }
        
        // Sample a small region for analysis
        let sampleWidth = min(100, width)
        let sampleHeight = min(100, height)
        
        let context = CGContext(
            data: nil,
            width: sampleWidth,
            height: sampleHeight,
            bitsPerComponent: 8,
            bytesPerRow: sampleWidth,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: sampleWidth, height: sampleHeight))
        
        guard let data = context?.data else { return 0.5 }
        
        let pixelData = data.bindMemory(to: UInt8.self, capacity: sampleWidth * sampleHeight)
        
        // Calculate Laplacian variance as sharpness measure
        var variance: Double = 0.0
        var mean: Double = 0.0
        let pixelCount = sampleWidth * sampleHeight
        
        // Calculate mean
        for i in 0..<pixelCount {
            mean += Double(pixelData[i])
        }
        mean /= Double(pixelCount)
        
        // Calculate variance
        for i in 0..<pixelCount {
            let diff = Double(pixelData[i]) - mean
            variance += diff * diff
        }
        variance /= Double(pixelCount)
        
        // Normalize to 0-1 range
        return Float(min(1.0, variance / 10000.0))
    }
    
    private func analyzeBrightness(_ image: CGImage) -> Float {
        // Analyze average brightness and check if it's in optimal range
        let width = image.width
        let height = image.height
        
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context?.data else { return 0.5 }
        
        let pixelData = data.bindMemory(to: UInt8.self, capacity: width * height)
        let pixelCount = width * height
        
        var totalBrightness: Int = 0
        for i in 0..<pixelCount {
            totalBrightness += Int(pixelData[i])
        }
        
        let averageBrightness = Float(totalBrightness) / Float(pixelCount * 255)
        
        // Optimal brightness range is 0.3 to 0.8
        if averageBrightness < 0.3 {
            return averageBrightness / 0.3
        } else if averageBrightness > 0.8 {
            return (1.0 - averageBrightness) / 0.2
        } else {
            return 1.0
        }
    }
    
    private func analyzePoseQuality(_ observation: VNFaceObservation) -> FaceQuality.PoseQuality {
        // Use face observation data to estimate pose
        let pitch = observation.pitch?.floatValue ?? 0.0
        let yaw = observation.yaw?.floatValue ?? 0.0
        let roll = observation.roll?.floatValue ?? 0.0
        
        // Calculate pose quality based on how frontal the face is
        let maxAngle: Float = 30.0 // degrees
        
        let pitchQuality = max(0.0, 1.0 - abs(pitch) / maxAngle)
        let yawQuality = max(0.0, 1.0 - abs(yaw) / maxAngle)
        let rollQuality = max(0.0, 1.0 - abs(roll) / maxAngle)
        
        let overallPoseQuality = (pitchQuality + yawQuality + rollQuality) / 3.0
        
        return FaceQuality.PoseQuality(
            pitch: pitch,
            yaw: yaw,
            roll: roll,
            quality: overallPoseQuality
        )
    }
    
    private func extractFaceTemplate(
        observation: VNFaceObservation,
        image: CGImage
    ) async throws -> Data {
        
        // In a real implementation, this would extract a face template using a specialized model
        // For now, we'll create a mock template based on face features
        
        let boundingBox = observation.boundingBox
        let faceFeatures = [
            boundingBox.origin.x,
            boundingBox.origin.y,
            boundingBox.width,
            boundingBox.height,
            observation.confidence
        ]
        
        // Create a simple feature vector
        var data = Data()
        for feature in faceFeatures {
            withUnsafeBytes(of: feature.bitPattern) { bytes in
                data.append(contentsOf: bytes)
            }
        }
        
        return data
    }
    
    private func recognizeFace(
        observation: VNFaceObservation,
        image: CGImage
    ) async throws -> FaceIdentity? {
        
        // Extract face template
        let faceTemplate = try await extractFaceTemplate(observation: observation, image: image)
        
        // Compare with enrolled faces
        var bestMatch: (personID: String, similarity: Float)?
        
        for (personID, enrolledFace) in enrolledFaces {
            let similarity = calculateSimilarity(faceTemplate, enrolledFace.faceTemplate)
            
            if similarity > recognitionThreshold {
                if bestMatch == nil || similarity > bestMatch!.similarity {
                    bestMatch = (personID, similarity)
                }
            }
        }
        
        guard let match = bestMatch else { return nil }
        
        return FaceIdentity(
            personID: match.personID,
            name: enrolledFaces[match.personID]?.identity,
            confidence: match.similarity
        )
    }
    
    private func calculateSimilarity(_ template1: Data, _ template2: Data) -> Float {
        // Simplified similarity calculation
        // In a real implementation, this would use proper face comparison algorithms
        
        guard template1.count == template2.count else { return 0.0 }
        
        var similarity: Float = 0.0
        let count = template1.count / MemoryLayout<Float>.size
        
        template1.withUnsafeBytes { bytes1 in
            template2.withUnsafeBytes { bytes2 in
                let floats1 = bytes1.bindMemory(to: Float.self)
                let floats2 = bytes2.bindMemory(to: Float.self)
                
                for i in 0..<count {
                    let diff = abs(floats1[i] - floats2[i])
                    similarity += max(0.0, 1.0 - diff)
                }
            }
        }
        
        return similarity / Float(count)
    }
    
    private func extractFaceExpressions(
        observation: VNFaceObservation,
        image: CGImage
    ) async throws -> FaceExpressions {
        
        // Simplified expression analysis
        // In a real implementation, this would use a specialized expression recognition model
        
        // Mock expression analysis based on face orientation and features
        let pitch = observation.pitch?.floatValue ?? 0.0
        let yaw = observation.yaw?.floatValue ?? 0.0
        
        // Generate mock expression probabilities
        let neutral: Float = 0.6 + Float.random(in: -0.2...0.2)
        let happy: Float = max(0.0, 0.3 - abs(pitch) / 30.0) + Float.random(in: -0.1...0.1)
        let sad: Float = max(0.0, pitch / 30.0) + Float.random(in: -0.1...0.1)
        let angry: Float = max(0.0, abs(yaw) / 30.0) + Float.random(in: -0.1...0.1)
        let surprised: Float = Float.random(in: 0.0...0.2)
        let disgusted: Float = Float.random(in: 0.0...0.1)
        let fearful: Float = Float.random(in: 0.0...0.1)
        
        return FaceExpressions(
            neutral: max(0.0, min(1.0, neutral)),
            happy: max(0.0, min(1.0, happy)),
            sad: max(0.0, min(1.0, sad)),
            angry: max(0.0, min(1.0, angry)),
            surprised: max(0.0, min(1.0, surprised)),
            disgusted: max(0.0, min(1.0, disgusted)),
            fearful: max(0.0, min(1.0, fearful))
        )
    }
    
    private func estimateAge(
        observation: VNFaceObservation,
        image: CGImage
    ) async throws -> AgeEstimate {
        
        // Simplified age estimation
        // In a real implementation, this would use a specialized age estimation model
        
        let baseAge = Int.random(in: 18...60)
        let variance = Int.random(in: 3...8)
        
        let ageRange = max(0, baseAge - variance)...min(100, baseAge + variance)
        
        return AgeEstimate(
            estimatedAge: baseAge,
            ageRange: ageRange,
            confidence: Float.random(in: 0.6...0.9)
        )
    }
    
    private func classifyGender(
        observation: VNFaceObservation,
        image: CGImage
    ) async throws -> GenderClassification {
        
        // Simplified gender classification
        // In a real implementation, this would use a specialized gender classification model
        
        let genders: [GenderClassification.Gender] = [.male, .female]
        let randomGender = genders.randomElement()!
        
        return GenderClassification(
            gender: randomGender,
            confidence: Float.random(in: 0.6...0.9)
        )
    }
    
    private func convertBoundingBox(_ normalizedBox: CGRect, imageSize: CGSize) -> CGRect {
        let x = normalizedBox.origin.x * imageSize.width
        let y = (1 - normalizedBox.origin.y - normalizedBox.height) * imageSize.height
        let width = normalizedBox.width * imageSize.width
        let height = normalizedBox.height * imageSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func calculateOverallConfidence(_ faces: [DetectedFace]) -> Float {
        guard !faces.isEmpty else { return 0.0 }
        
        let totalConfidence = faces.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Float(faces.count)
    }
    
    private func generatePersonID(identity: String) -> String {
        let data = (identity + Date().description).data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined().prefix(16).description
    }
    
    private func calculateRecommendedImages(quality: Float) -> Int {
        if quality < 0.5 {
            return 5
        } else if quality < 0.7 {
            return 3
        } else {
            return 1
        }
    }
}

// MARK: - Face Database

private class FaceDatabase {
    private let documentsDirectory: URL
    private let facesDirectory: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        facesDirectory = documentsDirectory.appendingPathComponent("EnrolledFaces")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: facesDirectory, withIntermediateDirectories: true)
    }
    
    func saveEnrolledFace(_ face: EnrolledFace) async throws {
        let fileURL = facesDirectory.appendingPathComponent("\(face.personID).json")
        let data = try JSONEncoder().encode(face)
        try data.write(to: fileURL)
    }
    
    func loadAllEnrolledFaces() async throws -> [String: EnrolledFace] {
        var enrolledFaces: [String: EnrolledFace] = [:]
        
        let files = try FileManager.default.contentsOfDirectory(at: facesDirectory, includingPropertiesForKeys: nil)
        
        for fileURL in files where fileURL.pathExtension == "json" {
            let data = try Data(contentsOf: fileURL)
            let face = try JSONDecoder().decode(EnrolledFace.self, from: data)
            enrolledFaces[face.personID] = face
        }
        
        return enrolledFaces
    }
    
    func deleteEnrolledFace(personID: String) async throws {
        let fileURL = facesDirectory.appendingPathComponent("\(personID).json")
        try FileManager.default.removeItem(at: fileURL)
    }
}

// MARK: - Supporting Types

public struct EnrolledFace: Codable {
    let personID: String
    var identity: String
    let faceTemplate: Data
    let enrollmentDate: Date
    let quality: Float
    let boundingBox: CGRect
}

public enum FaceRecognitionError: LocalizedError {
    case invalidImage
    case modelNotInitialized
    case noFacesDetected
    case multipleFacesDetected
    case poorFaceQuality(Float)
    case detectionFailed(Error)
    case landmarkExtractionFailed(Error)
    case faceExtractionFailed
    case personNotFound(String)
    case enrollmentFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided for face recognition"
        case .modelNotInitialized:
            return "Face recognition model not initialized"
        case .noFacesDetected:
            return "No faces detected in the image"
        case .multipleFacesDetected:
            return "Multiple faces detected when only one expected"
        case .poorFaceQuality(let quality):
            return "Face quality too low for enrollment: \(quality)"
        case .detectionFailed(let error):
            return "Face detection failed: \(error.localizedDescription)"
        case .landmarkExtractionFailed(let error):
            return "Face landmark extraction failed: \(error.localizedDescription)"
        case .faceExtractionFailed:
            return "Failed to extract face region"
        case .personNotFound(let personID):
            return "Person with ID \(personID) not found"
        case .enrollmentFailed(let error):
            return "Face enrollment failed: \(error.localizedDescription)"
        }
    }
}
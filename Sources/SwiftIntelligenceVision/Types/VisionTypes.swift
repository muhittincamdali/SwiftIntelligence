import Foundation
import SwiftIntelligenceCore
import CoreML
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Vision Operations

public enum VisionOperation {
    case classify(UIImage, ClassificationOptions)
    case detect(UIImage, DetectionOptions)
    case recognizeFaces(UIImage, FaceRecognitionOptions)
    case recognizeText(UIImage, TextRecognitionOptions)
    case segment(UIImage, SegmentationOptions)
    case generate(String, ImageGenerationOptions)
    case enhance(UIImage, EnhancementOptions)
    case styleTransfer(UIImage, ArtisticStyle, StyleTransferOptions)
}

// MARK: - Vision Results Base Protocol

public protocol VisionResult: Codable {
    var id: String { get }
    var timestamp: Date { get }
    var processingTime: TimeInterval { get }
    var confidence: Float { get }
    var metadata: [String: Any] { get }
}

// MARK: - Image Classification

public struct ClassificationOptions: Hashable, Codable {
    public let maxResults: Int
    public let confidenceThreshold: Float
    public let useCustomModel: Bool
    public let customModelPath: URL?
    
    public init(
        maxResults: Int = 5,
        confidenceThreshold: Float = 0.1,
        useCustomModel: Bool = false,
        customModelPath: URL? = nil
    ) {
        self.maxResults = maxResults
        self.confidenceThreshold = confidenceThreshold
        self.useCustomModel = useCustomModel
        self.customModelPath = customModelPath
    }
    
    public static let `default` = ClassificationOptions()
    
    public static let highConfidence = ClassificationOptions(
        maxResults: 3,
        confidenceThreshold: 0.5
    )
    
    public static let comprehensive = ClassificationOptions(
        maxResults: 10,
        confidenceThreshold: 0.05
    )
}

public struct ImageClassificationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let classifications: [Classification]
    public let dominantColors: [DominantColor]
    public let imageProperties: ImageProperties
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        classifications: [Classification],
        dominantColors: [DominantColor] = [],
        imageProperties: ImageProperties
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.classifications = classifications
        self.dominantColors = dominantColors
        self.imageProperties = imageProperties
    }
}

public struct Classification: Codable {
    public let identifier: String
    public let label: String
    public let confidence: Float
    public let hierarchy: [String]
    
    public init(identifier: String, label: String, confidence: Float, hierarchy: [String] = []) {
        self.identifier = identifier
        self.label = label
        self.confidence = confidence
        self.hierarchy = hierarchy
    }
}

// MARK: - Object Detection

public struct DetectionOptions: Hashable, Codable {
    public let confidenceThreshold: Float
    public let maxObjects: Int
    public let enableTracking: Bool
    public let nmsThreshold: Float
    public let objectCategories: [ObjectCategory]
    
    public init(
        confidenceThreshold: Float = 0.5,
        maxObjects: Int = 50,
        enableTracking: Bool = false,
        nmsThreshold: Float = 0.4,
        objectCategories: [ObjectCategory] = ObjectCategory.allCases
    ) {
        self.confidenceThreshold = confidenceThreshold
        self.maxObjects = maxObjects
        self.enableTracking = enableTracking
        self.nmsThreshold = nmsThreshold
        self.objectCategories = objectCategories
    }
    
    public static let `default` = DetectionOptions()
    
    public static let highPrecision = DetectionOptions(
        confidenceThreshold: 0.8,
        maxObjects: 20,
        nmsThreshold: 0.3
    )
    
    public static let realtime = DetectionOptions(
        confidenceThreshold: 0.6,
        maxObjects: 10,
        enableTracking: true
    )
}

public struct ObjectDetectionResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let detectedObjects: [DetectedObject]
    public let imageSize: CGSize
    public let frameNumber: Int?
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        detectedObjects: [DetectedObject],
        imageSize: CGSize,
        frameNumber: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.detectedObjects = detectedObjects
        self.imageSize = imageSize
        self.frameNumber = frameNumber
    }
}

public struct DetectedObject: Codable {
    public let identifier: String
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect
    public let category: ObjectCategory
    public let trackingID: String?
    public let attributes: [String: Any]
    
    public init(
        identifier: String,
        label: String,
        confidence: Float,
        boundingBox: CGRect,
        category: ObjectCategory,
        trackingID: String? = nil,
        attributes: [String: Any] = [:]
    ) {
        self.identifier = identifier
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.category = category
        self.trackingID = trackingID
        self.attributes = attributes
    }
}

public enum ObjectCategory: String, CaseIterable, Codable {
    case person = "person"
    case animal = "animal"
    case vehicle = "vehicle"
    case furniture = "furniture"
    case electronics = "electronics"
    case food = "food"
    case clothing = "clothing"
    case nature = "nature"
    case building = "building"
    case sports = "sports"
    case other = "other"
}

// MARK: - Face Recognition

public struct FaceRecognitionOptions: Hashable, Codable {
    public let enableLandmarks: Bool
    public let enableExpressions: Bool
    public let enableAgeEstimation: Bool
    public let enableGenderClassification: Bool
    public let recognitionThreshold: Float
    public let maxFaces: Int
    
    public init(
        enableLandmarks: Bool = true,
        enableExpressions: Bool = false,
        enableAgeEstimation: Bool = false,
        enableGenderClassification: Bool = false,
        recognitionThreshold: Float = 0.8,
        maxFaces: Int = 10
    ) {
        self.enableLandmarks = enableLandmarks
        self.enableExpressions = enableExpressions
        self.enableAgeEstimation = enableAgeEstimation
        self.enableGenderClassification = enableGenderClassification
        self.recognitionThreshold = recognitionThreshold
        self.maxFaces = maxFaces
    }
    
    public static let `default` = FaceRecognitionOptions()
    
    public static let detailed = FaceRecognitionOptions(
        enableLandmarks: true,
        enableExpressions: true,
        enableAgeEstimation: true,
        enableGenderClassification: true
    )
    
    public static let minimal = FaceRecognitionOptions(
        enableLandmarks: false,
        enableExpressions: false,
        enableAgeEstimation: false,
        enableGenderClassification: false
    )
}

public struct FaceRecognitionResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let detectedFaces: [DetectedFace]
    public let imageSize: CGSize
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        detectedFaces: [DetectedFace],
        imageSize: CGSize
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.detectedFaces = detectedFaces
        self.imageSize = imageSize
    }
}

public struct DetectedFace: Codable {
    public let boundingBox: CGRect
    public let confidence: Float
    public let identity: FaceIdentity?
    public let landmarks: FaceLandmarks?
    public let expressions: FaceExpressions?
    public let age: AgeEstimate?
    public let gender: GenderClassification?
    public let quality: FaceQuality
    
    public init(
        boundingBox: CGRect,
        confidence: Float,
        identity: FaceIdentity? = nil,
        landmarks: FaceLandmarks? = nil,
        expressions: FaceExpressions? = nil,
        age: AgeEstimate? = nil,
        gender: GenderClassification? = nil,
        quality: FaceQuality
    ) {
        self.boundingBox = boundingBox
        self.confidence = confidence
        self.identity = identity
        self.landmarks = landmarks
        self.expressions = expressions
        self.age = age
        self.gender = gender
        self.quality = quality
    }
}

public struct FaceIdentity: Codable {
    public let personID: String
    public let name: String?
    public let confidence: Float
    
    public init(personID: String, name: String? = nil, confidence: Float) {
        self.personID = personID
        self.name = name
        self.confidence = confidence
    }
}

public struct FaceLandmarks: Codable {
    public let leftEye: CGPoint
    public let rightEye: CGPoint
    public let nose: CGPoint
    public let mouth: CGPoint
    public let leftEyebrow: [CGPoint]
    public let rightEyebrow: [CGPoint]
    public let noseLine: [CGPoint]
    public let outerLips: [CGPoint]
    public let innerLips: [CGPoint]
    public let faceContour: [CGPoint]
}

public struct FaceExpressions: Codable {
    public let neutral: Float
    public let happy: Float
    public let sad: Float
    public let angry: Float
    public let surprised: Float
    public let disgusted: Float
    public let fearful: Float
    
    public var dominantExpression: (expression: String, confidence: Float) {
        let expressions = [
            ("neutral", neutral),
            ("happy", happy),
            ("sad", sad),
            ("angry", angry),
            ("surprised", surprised),
            ("disgusted", disgusted),
            ("fearful", fearful)
        ]
        
        let dominant = expressions.max { $0.1 < $1.1 } ?? ("neutral", 0.0)
        return dominant
    }
}

public struct AgeEstimate: Codable {
    public let estimatedAge: Int
    public let ageRange: ClosedRange<Int>
    public let confidence: Float
    
    public init(estimatedAge: Int, ageRange: ClosedRange<Int>, confidence: Float) {
        self.estimatedAge = estimatedAge
        self.ageRange = ageRange
        self.confidence = confidence
    }
}

public struct GenderClassification: Codable {
    public let gender: Gender
    public let confidence: Float
    
    public enum Gender: String, Codable {
        case male = "male"
        case female = "female"
        case unknown = "unknown"
    }
}

public struct FaceQuality: Codable {
    public let overallQuality: Float
    public let sharpness: Float
    public let brightness: Float
    public let pose: PoseQuality
    
    public struct PoseQuality: Codable {
        public let pitch: Float
        public let yaw: Float
        public let roll: Float
        public let quality: Float
    }
}

// MARK: - Face Enrollment

public struct FaceEnrollmentOptions: Hashable, Codable {
    public let requireHighQuality: Bool
    public let minimumFaceSize: CGSize
    public let allowMultipleFaces: Bool
    
    public init(
        requireHighQuality: Bool = true,
        minimumFaceSize: CGSize = CGSize(width: 80, height: 80),
        allowMultipleFaces: Bool = false
    ) {
        self.requireHighQuality = requireHighQuality
        self.minimumFaceSize = minimumFaceSize
        self.allowMultipleFaces = allowMultipleFaces
    }
    
    public static let `default` = FaceEnrollmentOptions()
}

public struct FaceEnrollmentResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let personID: String
    public let faceTemplate: Data
    public let enrollmentQuality: Float
    public let recommendedImages: Int
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        personID: String,
        faceTemplate: Data,
        enrollmentQuality: Float,
        recommendedImages: Int
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.personID = personID
        self.faceTemplate = faceTemplate
        self.enrollmentQuality = enrollmentQuality
        self.recommendedImages = recommendedImages
    }
}

// MARK: - Text Recognition

public struct TextRecognitionOptions: Hashable, Codable {
    public let recognitionLanguages: [String]
    public let recognitionLevel: VNRequestTextRecognitionLevel
    public let enableAutomaticTextNormalization: Bool
    public let customWordsToRecognize: [String]
    public let minimumTextHeight: Float
    
    public init(
        recognitionLanguages: [String] = ["en-US"],
        recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
        enableAutomaticTextNormalization: Bool = true,
        customWordsToRecognize: [String] = [],
        minimumTextHeight: Float = 0.03
    ) {
        self.recognitionLanguages = recognitionLanguages
        self.recognitionLevel = recognitionLevel
        self.enableAutomaticTextNormalization = enableAutomaticTextNormalization
        self.customWordsToRecognize = customWordsToRecognize
        self.minimumTextHeight = minimumTextHeight
    }
    
    public static let `default` = TextRecognitionOptions()
    
    public static let turkish = TextRecognitionOptions(
        recognitionLanguages: ["tr-TR"],
        recognitionLevel: .accurate
    )
    
    public static let multilingual = TextRecognitionOptions(
        recognitionLanguages: ["en-US", "tr-TR", "de-DE", "fr-FR", "es-ES"]
    )
    
    public static let fast = TextRecognitionOptions(
        recognitionLevel: .fast,
        minimumTextHeight: 0.05
    )
}

public struct TextRecognitionResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let recognizedText: String
    public let textBlocks: [TextBlock]
    public let detectedLanguages: [String]
    public let imageSize: CGSize
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        recognizedText: String,
        textBlocks: [TextBlock],
        detectedLanguages: [String],
        imageSize: CGSize
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.recognizedText = recognizedText
        self.textBlocks = textBlocks
        self.detectedLanguages = detectedLanguages
        self.imageSize = imageSize
    }
}

public struct TextBlock: Codable {
    public let text: String
    public let boundingBox: CGRect
    public let confidence: Float
    public let language: String?
    public let characterBoxes: [CharacterBox]
    
    public init(
        text: String,
        boundingBox: CGRect,
        confidence: Float,
        language: String? = nil,
        characterBoxes: [CharacterBox] = []
    ) {
        self.text = text
        self.boundingBox = boundingBox
        self.confidence = confidence
        self.language = language
        self.characterBoxes = characterBoxes
    }
}

public struct CharacterBox: Codable {
    public let character: String
    public let boundingBox: CGRect
    public let confidence: Float
}

// MARK: - Document Analysis

public struct DocumentAnalysisOptions: Hashable, Codable {
    public let enableLayoutAnalysis: Bool
    public let enableTableDetection: Bool
    public let enableFormFieldDetection: Bool
    public let outputFormat: DocumentOutputFormat
    
    public init(
        enableLayoutAnalysis: Bool = true,
        enableTableDetection: Bool = false,
        enableFormFieldDetection: Bool = false,
        outputFormat: DocumentOutputFormat = .structured
    ) {
        self.enableLayoutAnalysis = enableLayoutAnalysis
        self.enableTableDetection = enableTableDetection
        self.enableFormFieldDetection = enableFormFieldDetection
        self.outputFormat = outputFormat
    }
    
    public static let `default` = DocumentAnalysisOptions()
}

public enum DocumentOutputFormat: String, CaseIterable, Codable {
    case plainText = "plain_text"
    case structured = "structured"
    case markdown = "markdown"
    case json = "json"
}

public struct DocumentAnalysisResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let documentText: String
    public let layout: DocumentLayout
    public let tables: [DocumentTable]
    public let formFields: [FormField]
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        documentText: String,
        layout: DocumentLayout,
        tables: [DocumentTable] = [],
        formFields: [FormField] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.documentText = documentText
        self.layout = layout
        self.tables = tables
        self.formFields = formFields
    }
}

public struct DocumentLayout: Codable {
    public let paragraphs: [DocumentParagraph]
    public let headings: [DocumentHeading]
    public let readingOrder: [String]
    
    public struct DocumentParagraph: Codable {
        public let id: String
        public let text: String
        public let boundingBox: CGRect
        public let confidence: Float
    }
    
    public struct DocumentHeading: Codable {
        public let id: String
        public let text: String
        public let level: Int
        public let boundingBox: CGRect
        public let confidence: Float
    }
}

public struct DocumentTable: Codable {
    public let boundingBox: CGRect
    public let rows: [[TableCell]]
    public let confidence: Float
    
    public struct TableCell: Codable {
        public let text: String
        public let boundingBox: CGRect
        public let rowSpan: Int
        public let columnSpan: Int
    }
}

public struct FormField: Codable {
    public let fieldType: FieldType
    public let label: String?
    public let value: String?
    public let boundingBox: CGRect
    public let confidence: Float
    
    public enum FieldType: String, Codable {
        case textField = "text_field"
        case checkbox = "checkbox"
        case radioButton = "radio_button"
        case dropdown = "dropdown"
        case signature = "signature"
        case date = "date"
        case email = "email"
        case phone = "phone"
        case other = "other"
    }
}

// MARK: - Image Properties

public struct ImageProperties: Codable {
    public let size: CGSize
    public let colorSpace: String
    public let hasAlpha: Bool
    public let orientation: ImageOrientation
    public let dominantColors: [DominantColor]
    public let averageBrightness: Float
    public let contrast: Float
    public let saturation: Float
    
    public enum ImageOrientation: String, Codable {
        case up = "up"
        case down = "down"
        case left = "left"
        case right = "right"
        case upMirrored = "up_mirrored"
        case downMirrored = "down_mirrored"
        case leftMirrored = "left_mirrored"
        case rightMirrored = "right_mirrored"
    }
}

public struct DominantColor: Codable {
    public let color: ColorInfo
    public let percentage: Float
    public let pixelCount: Int
    
    public struct ColorInfo: Codable {
        public let red: Float
        public let green: Float
        public let blue: Float
        public let alpha: Float
        public let hex: String
        public let name: String?
        
        #if canImport(UIKit)
        public var uiColor: UIColor {
            return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        }
        #endif
        
        #if canImport(AppKit)
        public var nsColor: NSColor {
            return NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        }
        #endif
    }
}

// MARK: - Custom Extensions for Codable

extension CGRect: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(x: x, y: y, width: width, height: height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .x)
        try container.encode(origin.y, forKey: .y)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
    
    private enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }
}

extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
    
    private enum CodingKeys: String, CodingKey {
        case x, y
    }
}

extension CGSize: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
    
    private enum CodingKeys: String, CodingKey {
        case width, height
    }
}
import Foundation
import SwiftIntelligenceCore
import CoreML
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

// MARK: - Vision Operations

public enum VisionOperation {
    case classify(PlatformImage, ClassificationOptions)
    case detect(PlatformImage, DetectionOptions)
    case recognizeFaces(PlatformImage, FaceRecognitionOptions)
    case recognizeText(PlatformImage, TextRecognitionOptions)
    case segment(PlatformImage, SegmentationOptions)
    case generate(String, ImageGenerationOptions)
    case enhance(PlatformImage, EnhancementOptions)
    case styleTransfer(PlatformImage, ArtisticStyle, StyleTransferOptions)
}

// MARK: - Vision Results Base Protocol

public protocol VisionResult: Codable, Sendable {
    var id: String { get }
    var timestamp: Date { get }
    var processingTime: TimeInterval { get }
    var confidence: Float { get }
    var metadata: [String: String] { get }
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
    public let metadata: [String: String]
    
    public let classifications: [Classification]
    public let dominantColors: [DominantColor]
    public let imageProperties: ImageProperties
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
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

public struct DetectionOptions: Hashable, Codable, Sendable {
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
    public let metadata: [String: String]
    
    public let detectedObjects: [DetectedObject]
    public let imageSize: CGSize
    public let frameNumber: Int?
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
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
    public let attributes: [String: String]
    
    public init(
        identifier: String,
        label: String,
        confidence: Float,
        boundingBox: CGRect,
        category: ObjectCategory,
        trackingID: String? = nil,
        attributes: [String: String] = [:]
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
    public let metadata: [String: String]
    
    public let detectedFaces: [DetectedFace]
    public let imageSize: CGSize
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
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
    public let metadata: [String: String]
    
    public let personID: String
    public let faceTemplate: Data
    public let enrollmentQuality: Float
    public let recommendedImages: Int
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
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

public enum TextRecognitionLevel: String, Codable {
    case accurate = "accurate"
    case fast = "fast"
    
    public var vnLevel: VNRequestTextRecognitionLevel {
        switch self {
        case .accurate:
            return .accurate
        case .fast:
            return .fast
        }
    }
}

public struct TextRecognitionOptions: Hashable, Codable {
    public let recognitionLanguages: [String]
    public let recognitionLevel: TextRecognitionLevel
    public let enableAutomaticTextNormalization: Bool
    public let customWordsToRecognize: [String]
    public let minimumTextHeight: Float
    
    public init(
        recognitionLanguages: [String] = ["en-US"],
        recognitionLevel: TextRecognitionLevel = .accurate,
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
    public let metadata: [String: String]
    
    public let recognizedText: String
    public let textBlocks: [TextBlock]
    public let detectedLanguages: [String]
    public let imageSize: CGSize
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
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

public struct TextBlock: Codable, Sendable {
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
    public let metadata: [String: String]
    
    public let documentText: String
    public let layout: DocumentLayout
    public let tables: [DocumentTable]
    public let formFields: [FormField]
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
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

// MARK: - Cutout Mask Types

public enum SegmentationSubject: String, CaseIterable, Codable {
    case foreground = "foreground"
    case background = "background"
    case person = "person"
    case object = "object"
    case automatic = "automatic"
}

public struct CutoutMaskResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let maskData: Data
    public let subject: SegmentationSubject
    public let imageSize: CGSize
    public let maskFormat: MaskFormat
    
    public enum MaskFormat: String, CaseIterable, Codable {
        case png = "png"
        case alpha = "alpha"
        case binary = "binary"
    }
    
    public enum MaskQuality: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case excellent = "excellent"
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        maskData: Data,
        subject: SegmentationSubject,
        imageSize: CGSize,
        maskFormat: MaskFormat = .png
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.maskData = maskData
        self.subject = subject
        self.imageSize = imageSize
        self.maskFormat = maskFormat
    }
}

// MARK: - Image Generation Types

public struct ImageGenerationOptions: Hashable, Codable {
    public let prompt: String
    public let style: GenerationStyle
    public let size: GenerationSize
    public let quality: GenerationQuality
    public let count: Int
    
    public enum GenerationStyle: String, CaseIterable, Codable {
        case photorealistic = "photorealistic"
        case artistic = "artistic"
        case cartoon = "cartoon"
        case sketch = "sketch"
        case oil_painting = "oil_painting"
        case watercolor = "watercolor"
    }
    
    public enum GenerationSize: String, CaseIterable, Codable {
        case small = "256x256"
        case medium = "512x512"
        case large = "1024x1024"
        case extra_large = "1792x1024"
        case portrait = "1024x1792"
    }
    
    public enum GenerationQuality: String, CaseIterable, Codable {
        case standard = "standard"
        case high = "high"
        case ultra = "ultra"
    }
    
    public init(
        prompt: String,
        style: GenerationStyle = .photorealistic,
        size: GenerationSize = .medium,
        quality: GenerationQuality = .standard,
        count: Int = 1
    ) {
        self.prompt = prompt
        self.style = style
        self.size = size
        self.quality = quality
        self.count = count
    }
    
    public static let `default` = ImageGenerationOptions(prompt: "")
}

public struct ImageGenerationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let generatedImages: [GeneratedImage]
    public let prompt: String
    public let options: ImageGenerationOptions
    
    public struct GeneratedImage: Codable {
        public let imageData: Data
        public let format: String
        public let size: CGSize
        public let quality: Float
        
        public init(
            imageData: Data,
            format: String = "PNG",
            size: CGSize,
            quality: Float = 1.0
        ) {
            self.imageData = imageData
            self.format = format
            self.size = size
            self.quality = quality
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        generatedImages: [GeneratedImage],
        prompt: String,
        options: ImageGenerationOptions
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.generatedImages = generatedImages
        self.prompt = prompt
        self.options = options
    }
}

public struct ImageVariationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let variations: [ImageVariation]
    public let originalImageSize: CGSize
    
    public struct ImageVariation: Codable {
        public let imageData: Data
        public let variationType: VariationType
        public let similarity: Float
        public let format: String
        
        public enum VariationType: String, CaseIterable, Codable {
            case style_transfer = "style_transfer"
            case color_variation = "color_variation"
            case composition_change = "composition_change"
            case detail_enhancement = "detail_enhancement"
        }
        
        public init(
            imageData: Data,
            variationType: VariationType,
            similarity: Float,
            format: String = "PNG"
        ) {
            self.imageData = imageData
            self.variationType = variationType
            self.similarity = similarity
            self.format = format
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        variations: [ImageVariation],
        originalImageSize: CGSize
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.variations = variations
        self.originalImageSize = originalImageSize
    }
}

// MARK: - Image Variation Types

public struct VariationOptions: Hashable, Codable {
    public let count: Int
    public let variationType: ImageVariationResult.ImageVariation.VariationType
    public let similarity: Float
    public let enhanceQuality: Bool
    
    public init(
        count: Int = 1,
        variationType: ImageVariationResult.ImageVariation.VariationType = .style_transfer,
        similarity: Float = 0.8,
        enhanceQuality: Bool = true
    ) {
        self.count = count
        self.variationType = variationType
        self.similarity = similarity
        self.enhanceQuality = enhanceQuality
    }
    
    public static let `default` = VariationOptions()
}

// MARK: - Image Enhancement Types

public struct EnhancementOptions: Hashable, Codable {
    public let enhancementType: EnhancementType
    public let intensity: Float
    public let preserveOriginalColors: Bool
    public let upscaleFactor: Float
    
    public enum EnhancementType: String, CaseIterable, Codable {
        case sharpen = "sharpen"
        case denoise = "denoise"
        case upscale = "upscale"
        case colorCorrection = "color_correction"
        case contrastEnhancement = "contrast_enhancement"
        case saturationBoost = "saturation_boost"
        case brightnessAdjustment = "brightness_adjustment"
    }
    
    public init(
        enhancementType: EnhancementType = .sharpen,
        intensity: Float = 0.5,
        preserveOriginalColors: Bool = true,
        upscaleFactor: Float = 1.0
    ) {
        self.enhancementType = enhancementType
        self.intensity = intensity
        self.preserveOriginalColors = preserveOriginalColors
        self.upscaleFactor = upscaleFactor
    }
    
    public static let `default` = EnhancementOptions()
}

public struct ImageEnhancementResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let enhancedImageData: Data
    public let originalImageSize: CGSize
    public let enhancedImageSize: CGSize
    public let enhancementType: EnhancementType
    public let improvementMetrics: ImprovementMetrics
    
    public struct ImprovementMetrics: Codable {
        public let sharpnessImprovement: Float
        public let noiseReduction: Float
        public let colorAccuracy: Float
        public let overallQuality: Float
        
        public init(
            sharpnessImprovement: Float,
            noiseReduction: Float,
            colorAccuracy: Float,
            overallQuality: Float
        ) {
            self.sharpnessImprovement = sharpnessImprovement
            self.noiseReduction = noiseReduction
            self.colorAccuracy = colorAccuracy
            self.overallQuality = overallQuality
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        enhancedImageData: Data,
        originalImageSize: CGSize,
        enhancedImageSize: CGSize,
        enhancementType: EnhancementOptions.EnhancementType,
        improvementMetrics: ImprovementMetrics
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.enhancedImageData = enhancedImageData
        self.originalImageSize = originalImageSize
        self.enhancedImageSize = enhancedImageSize
        self.enhancementType = enhancementType
        self.improvementMetrics = improvementMetrics
    }
}

// MARK: - Style Transfer Types

public struct StyleTransferOptions: Hashable, Codable {
    public let style: ArtisticStyle
    public let intensity: Float
    public let preserveContent: Bool
    public let outputResolution: StyleResolution
    
    public enum StyleResolution: String, CaseIterable, Codable {
        case low = "512x512"
        case medium = "1024x1024"
        case high = "2048x2048"
    }
    
    public init(
        style: ArtisticStyle = .impressionist,
        intensity: Float = 0.7,
        preserveContent: Bool = true,
        outputResolution: StyleResolution = .medium
    ) {
        self.style = style
        self.intensity = intensity
        self.preserveContent = preserveContent
        self.outputResolution = outputResolution
    }
    
    public static let `default` = StyleTransferOptions()
}

public enum ArtisticStyle: String, CaseIterable, Codable {
    case impressionist = "impressionist"
    case cubist = "cubist"
    case abstract = "abstract"
    case realism = "realism"
    case surrealism = "surrealism"
    case pop_art = "pop_art"
    case minimalism = "minimalism"
    case expressionism = "expressionism"
    case baroque = "baroque"
    case renaissance = "renaissance"
}

public struct StyleTransferResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let styledImageData: Data
    public let originalImageSize: CGSize
    public let styledImageSize: CGSize
    public let appliedStyle: ArtisticStyle
    public let styleIntensity: Float
    public let qualityMetrics: StyleQualityMetrics
    
    public struct StyleQualityMetrics: Codable {
        public let contentPreservation: Float
        public let styleAdherence: Float
        public let artisticQuality: Float
        public let overallSatisfaction: Float
        
        public init(
            contentPreservation: Float,
            styleAdherence: Float,
            artisticQuality: Float,
            overallSatisfaction: Float
        ) {
            self.contentPreservation = contentPreservation
            self.styleAdherence = styleAdherence
            self.artisticQuality = artisticQuality
            self.overallSatisfaction = overallSatisfaction
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        styledImageData: Data,
        originalImageSize: CGSize,
        styledImageSize: CGSize,
        appliedStyle: ArtisticStyle,
        styleIntensity: Float,
        qualityMetrics: StyleQualityMetrics
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.styledImageData = styledImageData
        self.originalImageSize = originalImageSize
        self.styledImageSize = styledImageSize
        self.appliedStyle = appliedStyle
        self.styleIntensity = styleIntensity
        self.qualityMetrics = qualityMetrics
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

// MARK: - Image Segmentation Types

public struct SegmentationOptions: Hashable, Codable {
    public let segmentationType: SegmentationType
    public let minimumConfidence: Float
    public let includeMasks: Bool
    public let includeEdges: Bool
    
    public enum SegmentationType: String, CaseIterable, Codable {
        case semantic = "semantic"
        case instance = "instance"
        case panoptic = "panoptic"
    }
    
    public init(
        segmentationType: SegmentationType = .semantic,
        minimumConfidence: Float = 0.5,
        includeMasks: Bool = true,
        includeEdges: Bool = false
    ) {
        self.segmentationType = segmentationType
        self.minimumConfidence = minimumConfidence
        self.includeMasks = includeMasks
        self.includeEdges = includeEdges
    }
    
    public static let `default` = SegmentationOptions()
}

public struct ImageSegmentationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: String]
    
    public let segments: [ImageSegment]
    public let masks: [SegmentationMask]
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: String] = [:],
        segments: [ImageSegment],
        masks: [SegmentationMask] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.segments = segments
        self.masks = masks
    }
}

public struct ImageSegment: Codable {
    public let id: String
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect
    public let pixelCount: Int
    
    public init(
        id: String,
        label: String,
        confidence: Float,
        boundingBox: CGRect,
        pixelCount: Int
    ) {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.pixelCount = pixelCount
    }
}

public struct SegmentationMask: Codable {
    public let segmentId: String
    public let maskData: Data
    public let width: Int
    public let height: Int
    
    public init(
        segmentId: String,
        maskData: Data,
        width: Int,
        height: Int
    ) {
        self.segmentId = segmentId
        self.maskData = maskData
        self.width = width
        self.height = height
    }
}

// MARK: - Enhanced Image Types (Removed duplicate - using EnhancementOptions.EnhancementType instead)

// Typealias for backwards compatibility
public typealias EnhancementType = EnhancementOptions.EnhancementType

public struct EnhancementMetrics: Codable, Sendable {
    public let sharpnessImprovement: Float
    public let noiseReduction: Float
    public let colorAccuracy: Float
    public let detailPreservation: Float
    public let overallImprovement: Float
    public let upscaleQuality: Float?
    
    public init(
        sharpnessImprovement: Float,
        noiseReduction: Float,
        colorAccuracy: Float,
        detailPreservation: Float,
        overallImprovement: Float,
        upscaleQuality: Float? = nil
    ) {
        self.sharpnessImprovement = sharpnessImprovement
        self.noiseReduction = noiseReduction
        self.colorAccuracy = colorAccuracy
        self.detailPreservation = detailPreservation
        self.overallImprovement = overallImprovement
        self.upscaleQuality = upscaleQuality
    }
}

// MARK: - Missing Image Generation Types

public struct ImageSize: Hashable, Codable {
    public let width: Int
    public let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public static let small = ImageSize(width: 512, height: 512)
    public static let medium = ImageSize(width: 768, height: 768)
    public static let large = ImageSize(width: 1024, height: 1024)
    public static let ultraHD = ImageSize(width: 2048, height: 2048)
}

public enum GenerationStyle: String, CaseIterable, Codable {
    case realistic = "realistic"
    case artistic = "artistic"
    case cartoon = "cartoon"
    case anime = "anime"
    case abstract = "abstract"
    case photographic = "photographic"
    case illustration = "illustration"
    case digital_art = "digital_art"
    case oil_painting = "oil_painting"
    case watercolor = "watercolor"
    case pencil_sketch = "pencil_sketch"
    case cyberpunk = "cyberpunk"
    case fantasy = "fantasy"
    case minimalist = "minimalist"
    case vintage = "vintage"
}

public struct GenerationQualityMetrics: Codable {
    public let aestheticScore: Float
    public let technicalQuality: Float
    public let promptAdherence: Float
    public let creativity: Float
    public let composition: Float
    public let colorHarmony: Float
    public let detail: Float
    public let overallQuality: Float
    
    public init(
        aestheticScore: Float,
        technicalQuality: Float,
        promptAdherence: Float,
        creativity: Float,
        composition: Float,
        colorHarmony: Float,
        detail: Float,
        overallQuality: Float
    ) {
        self.aestheticScore = aestheticScore
        self.technicalQuality = technicalQuality
        self.promptAdherence = promptAdherence
        self.creativity = creativity
        self.composition = composition
        self.colorHarmony = colorHarmony
        self.detail = detail
        self.overallQuality = overallQuality
    }
}

// MARK: - Platform Color Support

#if canImport(UIKit)
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
public typealias PlatformColor = NSColor
#endif

// MARK: - Generation Parameters

public struct GenerationParameters: Codable {
    public let style: GenerationStyle
    public let size: ImageSize
    public let guidance: Float
    public let steps: Int
    public let seed: Int
    public let model: String
    
    public init(
        style: GenerationStyle,
        size: ImageSize,
        guidance: Float,
        steps: Int,
        seed: Int,
        model: String
    ) {
        self.style = style
        self.size = size
        self.guidance = guidance
        self.steps = steps
        self.seed = seed
        self.model = model
    }
}
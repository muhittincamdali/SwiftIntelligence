import Foundation
import CoreML
import Vision
import UIKit
import CoreImage

// MARK: - Image Segmentation Types

public struct SegmentationOptions: Hashable, Codable {
    public let segmentationType: SegmentationType
    public let outputMasks: Bool
    public let refinementEnabled: Bool
    public let backgroundRemoval: Bool
    
    public init(
        segmentationType: SegmentationType = .semantic,
        outputMasks: Bool = true,
        refinementEnabled: Bool = true,
        backgroundRemoval: Bool = false
    ) {
        self.segmentationType = segmentationType
        self.outputMasks = outputMasks
        self.refinementEnabled = refinementEnabled
        self.backgroundRemoval = backgroundRemoval
    }
    
    public static let `default` = SegmentationOptions()
    
    public static let portraitMode = SegmentationOptions(
        segmentationType: .person,
        outputMasks: true,
        refinementEnabled: true,
        backgroundRemoval: true
    )
}

public enum SegmentationType: String, CaseIterable, Codable {
    case semantic = "semantic"
    case instance = "instance"
    case person = "person"
    case object = "object"
    case scene = "scene"
}

public enum SegmentationSubject: String, CaseIterable, Codable {
    case foreground = "foreground"
    case background = "background"
    case person = "person"
    case animal = "animal"
    case vehicle = "vehicle"
    case custom = "custom"
}

public struct ImageSegmentationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let segmentedImage: UIImage?
    public let maskImage: UIImage?
    public let segments: [ImageSegment]
    public let backgroundRemoved: UIImage?
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        segmentedImage: UIImage? = nil,
        maskImage: UIImage? = nil,
        segments: [ImageSegment] = [],
        backgroundRemoved: UIImage? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.segmentedImage = segmentedImage
        self.maskImage = maskImage
        self.segments = segments
        self.backgroundRemoved = backgroundRemoved
    }
}

public struct ImageSegment: Codable {
    public let label: String
    public let confidence: Float
    public let mask: Data
    public let boundingBox: CGRect
    public let pixelCount: Int
    public let color: SegmentColor
    
    public struct SegmentColor: Codable {
        public let red: Float
        public let green: Float
        public let blue: Float
        public let alpha: Float
        
        public var uiColor: UIColor {
            return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        }
    }
}

public struct CutoutMaskResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let maskImage: UIImage
    public let cutoutImage: UIImage
    public let subjectBounds: CGRect
    public let quality: MaskQuality
    
    public struct MaskQuality: Codable {
        public let edgeSharpness: Float
        public let coverage: Float
        public let accuracy: Float
        public let overallQuality: Float
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        maskImage: UIImage,
        cutoutImage: UIImage,
        subjectBounds: CGRect,
        quality: MaskQuality
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.maskImage = maskImage
        self.cutoutImage = cutoutImage
        self.subjectBounds = subjectBounds
        self.quality = quality
    }
}

// MARK: - Image Enhancement Types

public struct EnhancementOptions: Hashable, Codable {
    public let enhancementType: EnhancementType
    public let upscaleFactor: Float
    public let denoiseStrength: Float
    public let sharpenAmount: Float
    public let colorEnhancement: Bool
    public let preserveDetails: Bool
    
    public init(
        enhancementType: EnhancementType = .general,
        upscaleFactor: Float = 2.0,
        denoiseStrength: Float = 0.5,
        sharpenAmount: Float = 0.3,
        colorEnhancement: Bool = true,
        preserveDetails: Bool = true
    ) {
        self.enhancementType = enhancementType
        self.upscaleFactor = upscaleFactor
        self.denoiseStrength = denoiseStrength
        self.sharpenAmount = sharpenAmount
        self.colorEnhancement = colorEnhancement
        self.preserveDetails = preserveDetails
    }
    
    public static let `default` = EnhancementOptions()
    
    public static let photo = EnhancementOptions(
        enhancementType: .photo,
        upscaleFactor: 2.0,
        colorEnhancement: true,
        preserveDetails: true
    )
    
    public static let lowLight = EnhancementOptions(
        enhancementType: .lowLight,
        denoiseStrength: 0.8,
        colorEnhancement: true
    )
}

public enum EnhancementType: String, CaseIterable, Codable {
    case general = "general"
    case photo = "photo"
    case lowLight = "low_light"
    case document = "document"
    case artwork = "artwork"
    case face = "face"
}

public struct ImageEnhancementResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let enhancedImage: UIImage
    public let originalImage: UIImage
    public let enhancementMetrics: EnhancementMetrics
    public let appliedFilters: [String]
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        enhancedImage: UIImage,
        originalImage: UIImage,
        enhancementMetrics: EnhancementMetrics,
        appliedFilters: [String] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.enhancedImage = enhancedImage
        self.originalImage = originalImage
        self.enhancementMetrics = enhancementMetrics
        self.appliedFilters = appliedFilters
    }
}

public struct EnhancementMetrics: Codable {
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

// MARK: - Image Generation Types

public struct ImageGenerationOptions: Hashable, Codable {
    public let style: GenerationStyle
    public let size: ImageSize
    public let quality: GenerationQuality
    public let guidance: Float
    public let steps: Int
    public let seed: Int?
    
    public init(
        style: GenerationStyle = .realistic,
        size: ImageSize = .medium,
        quality: GenerationQuality = .standard,
        guidance: Float = 7.5,
        steps: Int = 20,
        seed: Int? = nil
    ) {
        self.style = style
        self.size = size
        self.quality = quality
        self.guidance = guidance
        self.steps = steps
        self.seed = seed
    }
    
    public static let `default` = ImageGenerationOptions()
    
    public static let artistic = ImageGenerationOptions(
        style: .artistic,
        quality: .high,
        guidance: 12.0,
        steps: 50
    )
}

public enum GenerationStyle: String, CaseIterable, Codable {
    case realistic = "realistic"
    case artistic = "artistic"
    case cartoon = "cartoon"
    case anime = "anime"
    case painting = "painting"
    case sketch = "sketch"
    case photographic = "photographic"
}

public enum ImageSize: String, CaseIterable, Codable {
    case small = "small"      // 512x512
    case medium = "medium"    // 768x768
    case large = "large"      // 1024x1024
    case ultraWide = "ultra_wide" // 1024x512
    case portrait = "portrait"    // 512x768
    case landscape = "landscape"  // 768x512
    
    public var dimensions: CGSize {
        switch self {
        case .small: return CGSize(width: 512, height: 512)
        case .medium: return CGSize(width: 768, height: 768)
        case .large: return CGSize(width: 1024, height: 1024)
        case .ultraWide: return CGSize(width: 1024, height: 512)
        case .portrait: return CGSize(width: 512, height: 768)
        case .landscape: return CGSize(width: 768, height: 512)
        }
    }
}

public enum GenerationQuality: String, CaseIterable, Codable {
    case draft = "draft"
    case standard = "standard"
    case high = "high"
    case ultra = "ultra"
}

public struct ImageGenerationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let generatedImage: UIImage
    public let prompt: String
    public let generationParams: GenerationParameters
    public let qualityMetrics: GenerationQualityMetrics
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        generatedImage: UIImage,
        prompt: String,
        generationParams: GenerationParameters,
        qualityMetrics: GenerationQualityMetrics
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.generatedImage = generatedImage
        self.prompt = prompt
        self.generationParams = generationParams
        self.qualityMetrics = qualityMetrics
    }
}

public struct GenerationParameters: Codable {
    public let style: GenerationStyle
    public let size: ImageSize
    public let guidance: Float
    public let steps: Int
    public let seed: Int
    public let model: String
    
    public init(style: GenerationStyle, size: ImageSize, guidance: Float, steps: Int, seed: Int, model: String) {
        self.style = style
        self.size = size
        self.guidance = guidance
        self.steps = steps
        self.seed = seed
        self.model = model
    }
}

public struct GenerationQualityMetrics: Codable {
    public let aestheticScore: Float
    public let promptAdherence: Float
    public let technicalQuality: Float
    public let creativity: Float
    public let overallRating: Float
    
    public init(aestheticScore: Float, promptAdherence: Float, technicalQuality: Float, creativity: Float, overallRating: Float) {
        self.aestheticScore = aestheticScore
        self.promptAdherence = promptAdherence
        self.technicalQuality = technicalQuality
        self.creativity = creativity
        self.overallRating = overallRating
    }
}

public struct VariationOptions: Hashable, Codable {
    public let strength: Float
    public let preserveComposition: Bool
    public let preserveColors: Bool
    public let creativityLevel: Float
    
    public init(
        strength: Float = 0.5,
        preserveComposition: Bool = true,
        preserveColors: Bool = false,
        creativityLevel: Float = 0.7
    ) {
        self.strength = strength
        self.preserveComposition = preserveComposition
        self.preserveColors = preserveColors
        self.creativityLevel = creativityLevel
    }
    
    public static let `default` = VariationOptions()
}

public struct ImageVariationResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let originalImage: UIImage
    public let variations: [UIImage]
    public let variationScores: [Float]
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        originalImage: UIImage,
        variations: [UIImage],
        variationScores: [Float]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.originalImage = originalImage
        self.variations = variations
        self.variationScores = variationScores
    }
}

// MARK: - Style Transfer Types

public enum ArtisticStyle: String, CaseIterable, Codable {
    case vanGogh = "van_gogh"
    case picasso = "picasso"
    case monet = "monet"
    case kandinsky = "kandinsky"
    case ukiyoe = "ukiyoe"
    case abstractExpressionism = "abstract_expressionism"
    case cubism = "cubism"
    case impressionism = "impressionism"
    case surrealism = "surrealism"
    case popArt = "pop_art"
    case minimalism = "minimalism"
    case renaissance = "renaissance"
    
    public var description: String {
        switch self {
        case .vanGogh: return "Van Gogh - Post-Impressionist style with swirling brushstrokes"
        case .picasso: return "Picasso - Cubist style with geometric forms"
        case .monet: return "Monet - Impressionist style with light and color focus"
        case .kandinsky: return "Kandinsky - Abstract style with vibrant colors"
        case .ukiyoe: return "Ukiyo-e - Traditional Japanese woodblock print style"
        case .abstractExpressionism: return "Abstract Expressionism - Bold, emotional brushwork"
        case .cubism: return "Cubism - Geometric, fragmented representation"
        case .impressionism: return "Impressionism - Light and momentary effects"
        case .surrealism: return "Surrealism - Dreamlike, fantastical imagery"
        case .popArt: return "Pop Art - Bold colors and commercial imagery"
        case .minimalism: return "Minimalism - Simple forms and limited colors"
        case .renaissance: return "Renaissance - Classical realism and perspective"
        }
    }
}

public struct StyleTransferOptions: Hashable, Codable {
    public let strength: Float
    public let preserveColors: Bool
    public let preserveContent: Bool
    public let enhanceDetails: Bool
    
    public init(
        strength: Float = 0.8,
        preserveColors: Bool = false,
        preserveContent: Bool = true,
        enhanceDetails: Bool = false
    ) {
        self.strength = strength
        self.preserveColors = preserveColors
        self.preserveContent = preserveContent
        self.enhanceDetails = enhanceDetails
    }
    
    public static let `default` = StyleTransferOptions()
    
    public static let subtle = StyleTransferOptions(
        strength: 0.4,
        preserveColors: true,
        preserveContent: true
    )
    
    public static let dramatic = StyleTransferOptions(
        strength: 1.0,
        preserveColors: false,
        preserveContent: false,
        enhanceDetails: true
    )
}

public struct StyleTransferResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let styledImage: UIImage
    public let originalImage: UIImage
    public let appliedStyle: ArtisticStyle
    public let styleStrength: Float
    public let qualityMetrics: StyleQualityMetrics
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval,
        confidence: Float,
        metadata: [String: Any] = [:],
        styledImage: UIImage,
        originalImage: UIImage,
        appliedStyle: ArtisticStyle,
        styleStrength: Float,
        qualityMetrics: StyleQualityMetrics
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = metadata
        self.styledImage = styledImage
        self.originalImage = originalImage
        self.appliedStyle = appliedStyle
        self.styleStrength = styleStrength
        self.qualityMetrics = qualityMetrics
    }
}

public struct StyleQualityMetrics: Codable {
    public let styleTransferQuality: Float
    public let contentPreservation: Float
    public let artisticFidelity: Float
    public let visualCoherence: Float
    public let overallQuality: Float
    
    public init(
        styleTransferQuality: Float,
        contentPreservation: Float,
        artisticFidelity: Float,
        visualCoherence: Float,
        overallQuality: Float
    ) {
        self.styleTransferQuality = styleTransferQuality
        self.contentPreservation = contentPreservation
        self.artisticFidelity = artisticFidelity
        self.visualCoherence = visualCoherence
        self.overallQuality = overallQuality
    }
}
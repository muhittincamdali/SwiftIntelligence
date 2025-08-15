import Foundation
import UIKit
import SwiftUI

// MARK: - Core Image Generation Types

public struct ImageGenerationConfiguration {
    public let openAI: OpenAIImageConfig
    public let midjourney: MidjourneyConfig
    public let stabilityAI: StabilityAIConfig
    public let defaultProvider: String
    public let rateLimiting: RateLimitingConfig
    public let enableCaching: Bool
    public let timeout: TimeInterval
    public let retryAttempts: Int
    public let qualitySettings: ImageQualitySettings
    
    public struct OpenAIImageConfig {
        public let apiKey: String
        public let baseURL: String
        public let defaultModel: String
        
        public init(apiKey: String, baseURL: String = "https://api.openai.com/v1", defaultModel: String = "dall-e-3") {
            self.apiKey = apiKey
            self.baseURL = baseURL
            self.defaultModel = defaultModel
        }
    }
    
    public struct MidjourneyConfig {
        public let apiKey: String
        public let baseURL: String
        public let defaultVersion: String
        
        public init(apiKey: String, baseURL: String = "https://api.midjourney.com/v1", defaultVersion: String = "6") {
            self.apiKey = apiKey
            self.baseURL = baseURL
            self.defaultVersion = defaultVersion
        }
    }
    
    public struct StabilityAIConfig {
        public let apiKey: String
        public let baseURL: String
        public let defaultEngine: String
        
        public init(apiKey: String, baseURL: String = "https://api.stability.ai/v1", defaultEngine: String = "stable-diffusion-xl-1024-v1-0") {
            self.apiKey = apiKey
            self.baseURL = baseURL
            self.defaultEngine = defaultEngine
        }
    }
    
    public struct RateLimitingConfig {
        public let maxRequests: Int
        public let timeWindow: TimeInterval
        
        public init(maxRequests: Int = 20, timeWindow: TimeInterval = 60) {
            self.maxRequests = maxRequests
            self.timeWindow = timeWindow
        }
    }
    
    public struct ImageQualitySettings {
        public let defaultResolution: ImageResolution
        public let defaultQuality: ImageQuality
        public let enableUpscaling: Bool
        public let maxFileSize: Int
        
        public init(
            defaultResolution: ImageResolution = .large,
            defaultQuality: ImageQuality = .high,
            enableUpscaling: Bool = true,
            maxFileSize: Int = 10_000_000 // 10MB
        ) {
            self.defaultResolution = defaultResolution
            self.defaultQuality = defaultQuality
            self.enableUpscaling = enableUpscaling
            self.maxFileSize = maxFileSize
        }
    }
    
    public init(
        openAI: OpenAIImageConfig,
        midjourney: MidjourneyConfig,
        stabilityAI: StabilityAIConfig,
        defaultProvider: String = "openai",
        rateLimiting: RateLimitingConfig = RateLimitingConfig(),
        enableCaching: Bool = true,
        timeout: TimeInterval = 120,
        retryAttempts: Int = 3,
        qualitySettings: ImageQualitySettings = ImageQualitySettings()
    ) {
        self.openAI = openAI
        self.midjourney = midjourney
        self.stabilityAI = stabilityAI
        self.defaultProvider = defaultProvider
        self.rateLimiting = rateLimiting
        self.enableCaching = enableCaching
        self.timeout = timeout
        self.retryAttempts = retryAttempts
        self.qualitySettings = qualitySettings
    }
    
    public static let `default` = ImageGenerationConfiguration(
        openAI: OpenAIImageConfig(apiKey: ""),
        midjourney: MidjourneyConfig(apiKey: ""),
        stabilityAI: StabilityAIConfig(apiKey: "")
    )
}

// MARK: - Request Types

public struct ImageGenerationRequest {
    public let prompt: String
    public let options: ImageGenerationOptions
    public let requestId: String
    public let timestamp: Date
    
    public init(prompt: String, options: ImageGenerationOptions) {
        self.prompt = prompt
        self.options = options
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
    
    public var cacheKey: String {
        return "\(prompt.hashValue)_\(options.hashValue)_\(options.size.rawValue)_\(options.style.rawValue)".data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
    }
}

public struct ImageVariationRequest {
    public let sourceImage: UIImage
    public let options: ImageVariationOptions
    public let requestId: String
    public let timestamp: Date
    
    public init(sourceImage: UIImage, options: ImageVariationOptions) {
        self.sourceImage = sourceImage
        self.options = options
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
}

public struct ImageEditRequest {
    public let sourceImage: UIImage
    public let maskImage: UIImage
    public let prompt: String
    public let options: ImageEditOptions
    public let requestId: String
    public let timestamp: Date
    
    public init(sourceImage: UIImage, maskImage: UIImage, prompt: String, options: ImageEditOptions) {
        self.sourceImage = sourceImage
        self.maskImage = maskImage
        self.prompt = prompt
        self.options = options
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
}

// MARK: - Options Types

public struct ImageGenerationOptions: Hashable, Codable {
    public let size: ImageResolution
    public let quality: ImageQuality
    public let style: ImageStyle
    public let count: Int
    public let guidance: Double
    public let steps: Int
    public let seed: Int?
    public let negativePrompt: String?
    public let aspectRatio: AspectRatio
    
    public init(
        size: ImageResolution = .large,
        quality: ImageQuality = .standard,
        style: ImageStyle = .natural,
        count: Int = 1,
        guidance: Double = 7.5,
        steps: Int = 30,
        seed: Int? = nil,
        negativePrompt: String? = nil,
        aspectRatio: AspectRatio = .square
    ) {
        self.size = size
        self.quality = quality
        self.style = style
        self.count = max(1, min(10, count))
        self.guidance = max(1.0, min(20.0, guidance))
        self.steps = max(10, min(150, steps))
        self.seed = seed
        self.negativePrompt = negativePrompt
        self.aspectRatio = aspectRatio
    }
    
    public static let `default` = ImageGenerationOptions()
    
    public static let creative = ImageGenerationOptions(
        style: .vivid,
        guidance: 15.0,
        steps: 50
    )
    
    public static let photorealistic = ImageGenerationOptions(
        style: .natural,
        quality: .hd,
        guidance: 5.0,
        steps: 80
    )
    
    public static let artistic = ImageGenerationOptions(
        style: .vivid,
        guidance: 12.0,
        steps: 60
    )
    
    public static let quick = ImageGenerationOptions(
        size: .medium,
        quality: .standard,
        steps: 20
    )
}

public struct ImageVariationOptions: Hashable, Codable {
    public let count: Int
    public let similarityStrength: Double
    public let size: ImageResolution
    public let quality: ImageQuality
    
    public init(
        count: Int = 3,
        similarityStrength: Double = 0.8,
        size: ImageResolution = .large,
        quality: ImageQuality = .standard
    ) {
        self.count = max(1, min(10, count))
        self.similarityStrength = max(0.1, min(1.0, similarityStrength))
        self.size = size
        self.quality = quality
    }
    
    public static let `default` = ImageVariationOptions()
}

public struct ImageEditOptions: Hashable, Codable {
    public let size: ImageResolution
    public let quality: ImageQuality
    public let guidance: Double
    public let steps: Int
    public let strength: Double
    
    public init(
        size: ImageResolution = .large,
        quality: ImageQuality = .standard,
        guidance: Double = 7.5,
        steps: Int = 30,
        strength: Double = 0.8
    ) {
        self.size = size
        self.quality = quality
        self.guidance = max(1.0, min(20.0, guidance))
        self.steps = max(10, min(150, steps))
        self.strength = max(0.1, min(1.0, strength))
    }
    
    public static let `default` = ImageEditOptions()
}

// MARK: - Enum Types

public enum ImageResolution: String, CaseIterable, Codable {
    case small = "256x256"
    case medium = "512x512"
    case large = "1024x1024"
    case xlarge = "1536x1536"
    case xxlarge = "2048x2048"
    
    public var size: CGSize {
        switch self {
        case .small: return CGSize(width: 256, height: 256)
        case .medium: return CGSize(width: 512, height: 512)
        case .large: return CGSize(width: 1024, height: 1024)
        case .xlarge: return CGSize(width: 1536, height: 1536)
        case .xxlarge: return CGSize(width: 2048, height: 2048)
        }
    }
    
    public var description: String {
        switch self {
        case .small: return "Small (256×256)"
        case .medium: return "Medium (512×512)"
        case .large: return "Large (1024×1024)"
        case .xlarge: return "Extra Large (1536×1536)"
        case .xxlarge: return "XXL (2048×2048)"
        }
    }
}

public enum ImageQuality: String, CaseIterable, Codable {
    case standard = "standard"
    case hd = "hd"
    case ultra = "ultra"
    
    public var description: String {
        switch self {
        case .standard: return "Standard Quality"
        case .hd: return "High Definition"
        case .ultra: return "Ultra HD"
        }
    }
}

public enum ImageStyle: String, CaseIterable, Codable {
    case natural = "natural"
    case vivid = "vivid"
    case artistic = "artistic"
    case photorealistic = "photorealistic"
    case cartoon = "cartoon"
    case anime = "anime"
    case abstract = "abstract"
    case minimalist = "minimalist"
    
    public var description: String {
        switch self {
        case .natural: return "Natural"
        case .vivid: return "Vivid"
        case .artistic: return "Artistic"
        case .photorealistic: return "Photorealistic"
        case .cartoon: return "Cartoon"
        case .anime: return "Anime"
        case .abstract: return "Abstract"
        case .minimalist: return "Minimalist"
        }
    }
}

public enum AspectRatio: String, CaseIterable, Codable {
    case square = "1:1"
    case portrait = "3:4"
    case landscape = "4:3"
    case widescreen = "16:9"
    case ultrawide = "21:9"
    
    public var ratio: Double {
        switch self {
        case .square: return 1.0
        case .portrait: return 3.0/4.0
        case .landscape: return 4.0/3.0
        case .widescreen: return 16.0/9.0
        case .ultrawide: return 21.0/9.0
        }
    }
    
    public var description: String {
        switch self {
        case .square: return "Square (1:1)"
        case .portrait: return "Portrait (3:4)"
        case .landscape: return "Landscape (4:3)"
        case .widescreen: return "Widescreen (16:9)"
        case .ultrawide: return "Ultrawide (21:9)"
        }
    }
}

public enum StyleTransferStyle: String, CaseIterable, Codable {
    case abstract = "abstract"
    case impressionist = "impressionist"
    case cubist = "cubist"
    case anime = "anime"
    case photorealistic = "photorealistic"
    case watercolor = "watercolor"
    case oilPainting = "oil_painting"
    case pencilSketch = "pencil_sketch"
    
    public var description: String {
        switch self {
        case .abstract: return "Abstract"
        case .impressionist: return "Impressionist"
        case .cubist: return "Cubist"
        case .anime: return "Anime"
        case .photorealistic: return "Photorealistic"
        case .watercolor: return "Watercolor"
        case .oilPainting: return "Oil Painting"
        case .pencilSketch: return "Pencil Sketch"
        }
    }
}

// MARK: - Response Types

public struct ImageGenerationResult: Codable {
    public let images: [GeneratedImage]
    public let usage: ImageGenerationTokenUsage
    public let processingTime: TimeInterval
    public let metadata: ImageGenerationMetadata
    public let timestamp: Date
    
    public init(
        images: [GeneratedImage],
        usage: ImageGenerationTokenUsage,
        processingTime: TimeInterval,
        metadata: ImageGenerationMetadata
    ) {
        self.images = images
        self.usage = usage
        self.processingTime = processingTime
        self.metadata = metadata
        self.timestamp = Date()
    }
}

public struct GeneratedImage: Codable {
    public let imageData: Data?
    public let imageURL: String?
    public let size: CGSize
    public let format: ImageFormat
    public let quality: ImageQuality
    public let prompt: String?
    public let revisedPrompt: String?
    public let seed: Int?
    
    public init(
        imageData: Data? = nil,
        imageURL: String? = nil,
        size: CGSize,
        format: ImageFormat,
        quality: ImageQuality,
        prompt: String? = nil,
        revisedPrompt: String? = nil,
        seed: Int? = nil
    ) {
        self.imageData = imageData
        self.imageURL = imageURL
        self.size = size
        self.format = format
        self.quality = quality
        self.prompt = prompt
        self.revisedPrompt = revisedPrompt
        self.seed = seed
    }
    
    public var image: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        } else if let urlString = imageURL, let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}

public enum ImageFormat: String, CaseIterable, Codable {
    case png = "png"
    case jpeg = "jpeg"
    case webp = "webp"
    case heif = "heif"
    
    public var mimeType: String {
        switch self {
        case .png: return "image/png"
        case .jpeg: return "image/jpeg"
        case .webp: return "image/webp"
        case .heif: return "image/heif"
        }
    }
}

public struct ImageGenerationTokenUsage: Codable {
    public let imagesGenerated: Int
    public let processingTime: TimeInterval
    public let providerCost: Double?
    
    public init(imagesGenerated: Int, processingTime: TimeInterval, providerCost: Double? = nil) {
        self.imagesGenerated = imagesGenerated
        self.processingTime = processingTime
        self.providerCost = providerCost
    }
}

public struct ImageGenerationMetadata: Codable {
    public let provider: String
    public let model: String
    public let version: String?
    public let parameters: [String: String]
    
    public init(provider: String, model: String, version: String? = nil, parameters: [String: String] = [:]) {
        self.provider = provider
        self.model = model
        self.version = version
        self.parameters = parameters
    }
}

// MARK: - Analysis Types

public struct ImageAnalysisResult {
    public let classifications: [ImageClassification]
    public let dominantColors: [UIColor]
    public let imageSize: CGSize
    public let aspectRatio: Double
    public let timestamp: Date
    
    public init(
        classifications: [ImageClassification],
        dominantColors: [UIColor],
        imageSize: CGSize,
        aspectRatio: Double
    ) {
        self.classifications = classifications
        self.dominantColors = dominantColors
        self.imageSize = imageSize
        self.aspectRatio = aspectRatio
        self.timestamp = Date()
    }
}

public struct ImageClassification {
    public let label: String
    public let confidence: Float
    
    public init(label: String, confidence: Float) {
        self.label = label
        self.confidence = confidence
    }
}

// MARK: - Provider Types

public struct ImageProviderInfo {
    public let name: String
    public let supportedFormats: [ImageFormat]
    public let maxImageSize: CGSize
    public let features: ImageProviderFeatures
    
    public init(name: String, supportedFormats: [ImageFormat], maxImageSize: CGSize, features: ImageProviderFeatures) {
        self.name = name
        self.supportedFormats = supportedFormats
        self.maxImageSize = maxImageSize
        self.features = features
    }
}

public struct ImageProviderFeatures {
    public let textToImage: Bool
    public let imageVariations: Bool
    public let imageEditing: Bool
    public let styleTransfer: Bool
    public let upscaling: Bool
    public let isLocal: Bool
    
    public init(
        textToImage: Bool,
        imageVariations: Bool,
        imageEditing: Bool,
        styleTransfer: Bool,
        upscaling: Bool,
        isLocal: Bool
    ) {
        self.textToImage = textToImage
        self.imageVariations = imageVariations
        self.imageEditing = imageEditing
        self.styleTransfer = styleTransfer
        self.upscaling = upscaling
        self.isLocal = isLocal
    }
}

// MARK: - Usage and Monitoring

public struct ImageGenerationUsage {
    public var totalRequests: Int
    public var totalImages: Int
    public var estimatedCost: Double
    public var startDate: Date
    
    public init() {
        self.totalRequests = 0
        self.totalImages = 0
        self.estimatedCost = 0.0
        self.startDate = Date()
    }
}

public struct RateLimitStatus {
    public let remainingRequests: Int
    public let resetTime: Date
    public let totalLimit: Int
    
    public init(remainingRequests: Int, resetTime: Date, totalLimit: Int) {
        self.remainingRequests = remainingRequests
        self.resetTime = resetTime
        self.totalLimit = totalLimit
    }
}

public struct CacheInfo {
    public let count: Int
    public let size: Int
    public let currentCount: Int
    public let estimatedSize: Int
    
    public init(count: Int, size: Int, currentCount: Int, estimatedSize: Int) {
        self.count = count
        self.size = size
        self.currentCount = currentCount
        self.estimatedSize = estimatedSize
    }
}

// MARK: - Error Types

public enum ImageGenerationError: LocalizedError {
    case invalidConfiguration
    case noActiveProvider
    case providerNotFound(String)
    case modelNotAvailable(String)
    case networkUnavailable
    case requestTimeout
    case rateLimitExceeded
    case unauthorizedAccess
    case insufficientQuota
    case invalidPrompt(String)
    case imageTooLarge
    case unsupportedFormat
    case imageProcessingFailed(String)
    case networkError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid image generation configuration"
        case .noActiveProvider:
            return "No active image generation provider configured"
        case .providerNotFound(let provider):
            return "Provider '\(provider)' not found"
        case .modelNotAvailable(let model):
            return "Model '\(model)' not available"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .requestTimeout:
            return "Request timed out"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .unauthorizedAccess:
            return "Unauthorized access - check API key"
        case .insufficientQuota:
            return "Insufficient API quota"
        case .invalidPrompt(let message):
            return "Invalid prompt: \(message)"
        case .imageTooLarge:
            return "Image exceeds maximum size limit"
        case .unsupportedFormat:
            return "Unsupported image format"
        case .imageProcessingFailed(let message):
            return "Image processing failed: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidConfiguration:
            return "Check your API keys and provider configuration"
        case .noActiveProvider:
            return "Configure at least one image generation provider"
        case .providerNotFound:
            return "Verify the provider name and availability"
        case .modelNotAvailable:
            return "Check if the model is loaded or download it"
        case .networkUnavailable:
            return "Check your internet connection"
        case .requestTimeout:
            return "Try again or increase timeout duration"
        case .rateLimitExceeded:
            return "Wait before making more requests"
        case .unauthorizedAccess:
            return "Verify your API key is correct and has proper permissions"
        case .insufficientQuota:
            return "Check your API usage limits and billing"
        case .invalidPrompt:
            return "Use a more descriptive and appropriate prompt"
        case .imageTooLarge:
            return "Reduce image size or use a smaller resolution"
        case .unsupportedFormat:
            return "Use a supported image format (PNG, JPEG, WebP)"
        case .imageProcessingFailed, .networkError, .unknownError:
            return "Try again later"
        }
    }
}

// MARK: - Protocol Definitions

public protocol ImageGenerationProvider {
    var name: String { get }
    var supportedFormats: [ImageFormat] { get }
    var maxImageSize: CGSize { get }
    var supportsTextToImage: Bool { get }
    var supportsImageVariations: Bool { get }
    var supportsImageEditing: Bool { get }
    var supportsStyleTransfer: Bool { get }
    var supportsUpscaling: Bool { get }
    var isLocal: Bool { get }
    
    func generateImages(request: ImageGenerationRequest) async throws -> ImageGenerationResult
    func generateVariations(request: ImageVariationRequest) async throws -> ImageGenerationResult
    func editImage(request: ImageEditRequest) async throws -> ImageGenerationResult
}

// MARK: - Extensions

extension ImageGenerationOptions {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(quality)
        hasher.combine(style)
        hasher.combine(count)
        hasher.combine(guidance)
        hasher.combine(steps)
        hasher.combine(seed)
        hasher.combine(negativePrompt)
        hasher.combine(aspectRatio)
    }
}

extension GeneratedImage: CustomStringConvertible {
    public var description: String {
        return "GeneratedImage(size: \(size), format: \(format.rawValue), quality: \(quality.rawValue))"
    }
}

extension ImageGenerationResult: CustomStringConvertible {
    public var description: String {
        return "ImageGenerationResult(images: \(images.count), processingTime: \(processingTime)s)"
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)
extension GeneratedImage {
    @ViewBuilder
    public var swiftUIImage: some View {
        if let uiImage = image {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
        }
    }
}
#endif

// MARK: - Convenience Initializers

extension ImageGenerationOptions {
    public static func forPortrait(quality: ImageQuality = .standard) -> ImageGenerationOptions {
        return ImageGenerationOptions(
            size: .large,
            quality: quality,
            aspectRatio: .portrait
        )
    }
    
    public static func forLandscape(quality: ImageQuality = .standard) -> ImageGenerationOptions {
        return ImageGenerationOptions(
            size: .large,
            quality: quality,
            aspectRatio: .landscape
        )
    }
    
    public static func forArtwork(style: ImageStyle = .artistic) -> ImageGenerationOptions {
        return ImageGenerationOptions(
            size: .xlarge,
            quality: .hd,
            style: style,
            guidance: 12.0,
            steps: 60
        )
    }
}
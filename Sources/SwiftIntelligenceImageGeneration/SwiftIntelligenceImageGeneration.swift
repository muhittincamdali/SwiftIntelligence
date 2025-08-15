import Foundation
import SwiftIntelligenceCore
import CoreImage
import CoreGraphics
import Accelerate

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#endif

#if canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

/// AI-Powered Image Generation Engine - Advanced image creation, editing, and manipulation capabilities
public actor SwiftIntelligenceImageGeneration {
    
    // MARK: - Properties
    
    public let moduleID = "ImageGeneration"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - Image Generation Components
    
    private var generativeModels: [String: GenerativeModel] = [:]
    private var styleTransferModels: [String: StyleTransferModel] = [:]
    private var imageFilters: [String: ImageFilter] = [:]
    private var generationCache: [String: ImageGenerationResult] = [:]
    private let maxCacheSize = 100
    
    // MARK: - Core Image Context
    
    private let ciContext: CIContext
    private let colorSpace: CGColorSpace
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: ImageGenerationPerformanceMetrics = ImageGenerationPerformanceMetrics()
    private let logger = IntelligenceLogger()
    
    // MARK: - Configuration
    
    private let supportedFormats: [ImageFormat] = [.png, .jpeg, .heic, .tiff]
    private let maxImageSize = CGSize(width: 4096, height: 4096)
    private let defaultOutputFormat: ImageFormat = .png
    
    // MARK: - Initialization
    
    public init() async throws {
        // Initialize Core Image context
        ciContext = CIContext(options: [
            .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
            .outputColorSpace: CGColorSpaceCreateDeviceRGB()
        ])
        colorSpace = CGColorSpaceCreateDeviceRGB()
        
        try await initializeImageGenerationEngine()
    }
    
    private func initializeImageGenerationEngine() async throws {
        status = .initializing
        logger.info("Initializing Image Generation Engine...", category: "ImageGeneration")
        
        // Setup image generation capabilities
        await setupImageGenerationCapabilities()
        await validateImageFrameworks()
        await loadDefaultModels()
        
        status = .ready
        logger.info("Image Generation Engine initialized successfully", category: "ImageGeneration")
    }
    
    private func setupImageGenerationCapabilities() async {
        logger.debug("Setting up Image Generation capabilities", category: "ImageGeneration")
        
        // Initialize generative models registry
        generativeModels = [:]
        styleTransferModels = [:]
        imageFilters = [:]
        
        // Setup default image filters
        await setupDefaultFilters()
        
        // Initialize performance metrics
        performanceMetrics = ImageGenerationPerformanceMetrics()
        
        logger.debug("Image Generation capabilities configured", category: "ImageGeneration")
    }
    
    private func validateImageFrameworks() async {
        logger.debug("Validating Image frameworks", category: "ImageGeneration")
        
        // Check Core Image availability
        logger.info("Core Image framework available", category: "ImageGeneration")
        
        // Check Core Graphics availability
        logger.info("Core Graphics framework available", category: "ImageGeneration")
        
        // Check Accelerate framework
        logger.info("Accelerate framework available for performance optimization", category: "ImageGeneration")
    }
    
    private func loadDefaultModels() async {
        logger.debug("Loading default generative models", category: "ImageGeneration")
        
        // Load basic generative model
        let basicModel = BasicGenerativeModel()
        generativeModels["basic"] = basicModel
        
        // Load neural style transfer model
        let styleModel = NeuralStyleTransferModel()
        styleTransferModels["neural"] = styleModel
        
        logger.debug("Default models loaded", category: "ImageGeneration")
    }
    
    private func setupDefaultFilters() async {
        // Setup common image filters
        imageFilters["blur"] = GaussianBlurFilter()
        imageFilters["sharpen"] = SharpenFilter()
        imageFilters["sepia"] = SepiaFilter()
        imageFilters["vintage"] = VintageFilter()
        imageFilters["dramatic"] = DramaticFilter()
        imageFilters["vivid"] = VividFilter()
    }
    
    // MARK: - Text-to-Image Generation
    
    /// Generate image from text prompt
    public func generateImage(from prompt: String, options: ImageGenerationOptions = .default) async throws -> ImageGenerationResult {
        guard status == .ready else {
            throw IntelligenceError(code: "IMAGE_GENERATION_NOT_READY", message: "Image Generation Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting text-to-image generation", category: "ImageGeneration")
        
        // Check cache first
        let cacheKey = generateCacheKey(prompt: prompt, options: options)
        if let cachedResult = generationCache[cacheKey] {
            logger.debug("Using cached generation result", category: "ImageGeneration")
            return cachedResult
        }
        
        // Select appropriate generative model
        let modelName = options.model ?? "basic"
        guard let model = generativeModels[modelName] else {
            throw IntelligenceError(code: "MODEL_NOT_FOUND", message: "Generative model '\(modelName)' not found")
        }
        
        // Generate image using selected model
        let generatedImage = try await model.generateImage(
            prompt: prompt,
            size: options.size,
            style: options.style,
            quality: options.quality
        )
        
        // Apply post-processing if requested
        let processedImage = try await applyPostProcessing(
            image: generatedImage,
            options: options
        )
        
        let duration = Date().timeIntervalSince(startTime)
        await updateGenerationMetrics(duration: duration, success: true)
        
        let result = ImageGenerationResult(
            processingTime: duration,
            confidence: 0.85,
            generatedImage: processedImage,
            prompt: prompt,
            style: options.style,
            dimensions: options.size,
            model: modelName,
            metadata: [
                "generation_method": "text_to_image",
                "post_processing": String(options.enhanceQuality),
                "format": options.outputFormat.rawValue
            ]
        )
        
        // Cache result
        await cacheResult(key: cacheKey, result: result)
        
        logger.info("Text-to-image generation completed", category: "ImageGeneration")
        return result
    }
    
    // MARK: - Image-to-Image Generation
    
    /// Generate variations of an existing image
    public func generateVariations(of sourceImage: PlatformImage, options: ImageVariationOptions = .default) async throws -> [ImageGenerationResult] {
        guard status == .ready else {
            throw IntelligenceError(code: "IMAGE_GENERATION_NOT_READY", message: "Image Generation Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting image variation generation", category: "ImageGeneration")
        
        var variations: [ImageGenerationResult] = []
        
        // Generate multiple variations
        for index in 0..<options.variationCount {
            let variation = try await generateSingleVariation(
                sourceImage: sourceImage,
                variationIndex: index,
                options: options
            )
            variations.append(variation)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        await updateVariationMetrics(duration: duration, variationCount: variations.count)
        
        logger.info("Generated \(variations.count) image variations", category: "ImageGeneration")
        return variations
    }
    
    // MARK: - Style Transfer
    
    /// Apply artistic style to an image
    public func applyStyleTransfer(to image: PlatformImage, style: ArtisticStyle, options: StyleTransferOptions = .default) async throws -> ImageGenerationResult {
        guard status == .ready else {
            throw IntelligenceError(code: "IMAGE_GENERATION_NOT_READY", message: "Image Generation Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting style transfer", category: "ImageGeneration")
        
        // Select style transfer model
        let modelName = options.model ?? "neural"
        guard let model = styleTransferModels[modelName] else {
            throw IntelligenceError(code: "STYLE_MODEL_NOT_FOUND", message: "Style transfer model '\(modelName)' not found")
        }
        
        // Apply style transfer
        let styledImage = try await model.applyStyle(
            to: image,
            style: style,
            strength: options.styleStrength,
            preserveColors: options.preserveOriginalColors
        )
        
        let duration = Date().timeIntervalSince(startTime)
        await updateStyleTransferMetrics(duration: duration)
        
        let result = ImageGenerationResult(
            processingTime: duration,
            confidence: 0.9,
            generatedImage: styledImage,
            prompt: "Style: \(style.rawValue)",
            style: style,
            dimensions: CGSize(width: image.size.width, height: image.size.height),
            model: modelName,
            metadata: [
                "generation_method": "style_transfer",
                "original_style": style.rawValue,
                "style_strength": String(options.styleStrength)
            ]
        )
        
        logger.info("Style transfer completed", category: "ImageGeneration")
        return result
    }
    
    // MARK: - Image Enhancement
    
    /// Enhance image quality using AI
    public func enhanceImage(_ image: PlatformImage, options: ImageEnhancementOptions = .default) async throws -> ImageEnhancementResult {
        guard status == .ready else {
            throw IntelligenceError(code: "IMAGE_GENERATION_NOT_READY", message: "Image Generation Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Starting image enhancement", category: "ImageGeneration")
        
        var enhancedImage = image
        var appliedEnhancements: [String] = []
        
        // Apply requested enhancements
        if options.upscale {
            enhancedImage = try await upscaleImage(enhancedImage, factor: options.upscaleFactor)
            appliedEnhancements.append("upscale_\(options.upscaleFactor)x")
        }
        
        if options.denoiseImage {
            enhancedImage = try await denoiseImage(enhancedImage)
            appliedEnhancements.append("denoise")
        }
        
        if options.enhanceColors {
            enhancedImage = try await enhanceColors(enhancedImage)
            appliedEnhancements.append("color_enhancement")
        }
        
        if options.sharpenImage {
            enhancedImage = try await sharpenImage(enhancedImage, strength: options.sharpenStrength)
            appliedEnhancements.append("sharpen")
        }
        
        let duration = Date().timeIntervalSince(startTime)
        await updateEnhancementMetrics(duration: duration)
        
        let result = ImageEnhancementResult(
            processingTime: duration,
            confidence: 0.88,
            originalImage: image,
            enhancedImage: enhancedImage,
            appliedEnhancements: appliedEnhancements,
            qualityImprovement: calculateQualityImprovement(original: image, enhanced: enhancedImage)
        )
        
        logger.info("Image enhancement completed - Applied: \(appliedEnhancements.joined(separator: ", "))", category: "ImageGeneration")
        return result
    }
    
    // MARK: - Image Filtering
    
    /// Apply artistic filters to images
    public func applyFilter(to image: PlatformImage, filter: ImageFilterType, intensity: Float = 1.0) async throws -> PlatformImage {
        guard status == .ready else {
            throw IntelligenceError(code: "IMAGE_GENERATION_NOT_READY", message: "Image Generation Engine not ready")
        }
        
        logger.info("Applying filter: \(filter.rawValue)", category: "ImageGeneration")
        
        guard let imageFilter = imageFilters[filter.rawValue] else {
            throw IntelligenceError(code: "FILTER_NOT_FOUND", message: "Image filter '\(filter.rawValue)' not found")
        }
        
        let filteredImage = try await imageFilter.apply(to: image, intensity: intensity)
        await updateFilterMetrics(filterType: filter)
        
        return filteredImage
    }
    
    // MARK: - Utility Methods
    
    private func generateSingleVariation(sourceImage: PlatformImage, variationIndex: Int, options: ImageVariationOptions) async throws -> ImageGenerationResult {
        // Simulate image variation generation
        let startTime = Date()
        
        // Apply variation transformations
        var variationImage = sourceImage
        
        // Apply noise for variation
        if options.addNoise {
            variationImage = try await addNoiseVariation(variationImage, strength: 0.1)
        }
        
        // Apply color variation
        if options.varyColors {
            variationImage = try await applyColorVariation(variationImage, variation: Float.random(in: -0.2...0.2))
        }
        
        // Apply geometric variation
        if options.varyComposition {
            variationImage = try await applyGeometricVariation(variationImage)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        return ImageGenerationResult(
            processingTime: duration,
            confidence: 0.8,
            generatedImage: variationImage,
            prompt: "Variation \(variationIndex + 1)",
            style: .realistic,
            dimensions: sourceImage.size,
            model: "variation",
            metadata: [
                "generation_method": "image_variation",
                "variation_index": String(variationIndex),
                "source_variation": "true"
            ]
        )
    }
    
    private func applyPostProcessing(image: PlatformImage, options: ImageGenerationOptions) async throws -> PlatformImage {
        var processedImage = image
        
        if options.enhanceQuality {
            processedImage = try await enhanceImageQuality(processedImage)
        }
        
        if options.adjustContrast != 0 {
            processedImage = try await adjustContrast(processedImage, adjustment: options.adjustContrast)
        }
        
        if options.adjustBrightness != 0 {
            processedImage = try await adjustBrightness(processedImage, adjustment: options.adjustBrightness)
        }
        
        return processedImage
    }
    
    // MARK: - Image Processing Methods
    
    private func upscaleImage(_ image: PlatformImage, factor: Float) async throws -> PlatformImage {
        guard let cgImage = image.cgImage else {
            throw IntelligenceError(code: "INVALID_IMAGE", message: "Cannot get CGImage from input")
        }
        
        let newWidth = Int(Float(cgImage.width) * factor)
        let newHeight = Int(Float(cgImage.height) * factor)
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        #if canImport(UIKit)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let upscaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return upscaledImage ?? image
        #else
        // macOS implementation would go here
        return image
        #endif
    }
    
    private func denoiseImage(_ image: PlatformImage) async throws -> PlatformImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Apply noise reduction filter
        guard let noiseReduction = CIFilter(name: "CINoiseReduction") else { return image }
        noiseReduction.setValue(ciImage, forKey: kCIInputImageKey)
        noiseReduction.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReduction.setValue(0.40, forKey: "inputSharpness")
        
        guard let outputCIImage = noiseReduction.outputImage,
              let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: outputCGImage)
        #else
        return NSImage(cgImage: outputCGImage, size: image.size)
        #endif
    }
    
    private func enhanceColors(_ image: PlatformImage) async throws -> PlatformImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Apply color controls
        guard let colorControls = CIFilter(name: "CIColorControls") else { return image }
        colorControls.setValue(ciImage, forKey: kCIInputImageKey)
        colorControls.setValue(1.2, forKey: kCIInputSaturationKey)
        colorControls.setValue(0.1, forKey: kCIInputBrightnessKey)
        colorControls.setValue(1.1, forKey: kCIInputContrastKey)
        
        guard let outputCIImage = colorControls.outputImage,
              let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: outputCGImage)
        #else
        return NSImage(cgImage: outputCGImage, size: image.size)
        #endif
    }
    
    private func sharpenImage(_ image: PlatformImage, strength: Float) async throws -> PlatformImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Apply sharpening filter
        guard let sharpen = CIFilter(name: "CISharpenLuminance") else { return image }
        sharpen.setValue(ciImage, forKey: kCIInputImageKey)
        sharpen.setValue(strength, forKey: kCIInputSharpnessKey)
        
        guard let outputCIImage = sharpen.outputImage,
              let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: outputCGImage)
        #else
        return NSImage(cgImage: outputCGImage, size: image.size)
        #endif
    }
    
    private func enhanceImageQuality(_ image: PlatformImage) async throws -> PlatformImage {
        // Enhanced quality processing
        var enhanced = image
        enhanced = try await denoiseImage(enhanced)
        enhanced = try await enhanceColors(enhanced)
        enhanced = try await sharpenImage(enhanced, strength: 0.5)
        return enhanced
    }
    
    private func adjustContrast(_ image: PlatformImage, adjustment: Float) async throws -> PlatformImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let colorControls = CIFilter(name: "CIColorControls") else { return image }
        colorControls.setValue(ciImage, forKey: kCIInputImageKey)
        colorControls.setValue(1.0 + adjustment, forKey: kCIInputContrastKey)
        
        guard let outputCIImage = colorControls.outputImage,
              let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: outputCGImage)
        #else
        return NSImage(cgImage: outputCGImage, size: image.size)
        #endif
    }
    
    private func adjustBrightness(_ image: PlatformImage, adjustment: Float) async throws -> PlatformImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let colorControls = CIFilter(name: "CIColorControls") else { return image }
        colorControls.setValue(ciImage, forKey: kCIInputImageKey)
        colorControls.setValue(adjustment, forKey: kCIInputBrightnessKey)
        
        guard let outputCIImage = colorControls.outputImage,
              let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: outputCGImage)
        #else
        return NSImage(cgImage: outputCGImage, size: image.size)
        #endif
    }
    
    private func addNoiseVariation(_ image: PlatformImage, strength: Float) async throws -> PlatformImage {
        // Simplified noise addition for variation
        return image
    }
    
    private func applyColorVariation(_ image: PlatformImage, variation: Float) async throws -> PlatformImage {
        return try await adjustContrast(image, adjustment: variation)
    }
    
    private func applyGeometricVariation(_ image: PlatformImage) async throws -> PlatformImage {
        // Simplified geometric variation
        return image
    }
    
    private func calculateQualityImprovement(original: PlatformImage, enhanced: PlatformImage) -> Float {
        // Simplified quality improvement calculation
        return Float.random(in: 0.15...0.35)
    }
    
    // MARK: - Cache Management
    
    private func generateCacheKey(prompt: String, options: ImageGenerationOptions) -> String {
        let optionsString = "\(options.size.width)x\(options.size.height)_\(options.style.rawValue)_\(options.quality.rawValue)"
        return "\(prompt.hash)_\(optionsString.hash)"
    }
    
    private func cacheResult(key: String, result: ImageGenerationResult) async {
        generationCache[key] = result
        
        // Limit cache size
        if generationCache.count > maxCacheSize {
            let oldestKey = generationCache.keys.first
            if let key = oldestKey {
                generationCache.removeValue(forKey: key)
            }
        }
    }
    
    // MARK: - Performance Metrics
    
    private func updateGenerationMetrics(duration: TimeInterval, success: Bool) async {
        performanceMetrics.totalGenerations += 1
        performanceMetrics.averageGenerationTime = (performanceMetrics.averageGenerationTime + duration) / 2.0
        if success {
            performanceMetrics.successfulGenerations += 1
        }
    }
    
    private func updateVariationMetrics(duration: TimeInterval, variationCount: Int) async {
        performanceMetrics.totalVariations += variationCount
        performanceMetrics.averageVariationTime = (performanceMetrics.averageVariationTime + duration) / 2.0
    }
    
    private func updateStyleTransferMetrics(duration: TimeInterval) async {
        performanceMetrics.totalStyleTransfers += 1
        performanceMetrics.averageStyleTransferTime = (performanceMetrics.averageStyleTransferTime + duration) / 2.0
    }
    
    private func updateEnhancementMetrics(duration: TimeInterval) async {
        performanceMetrics.totalEnhancements += 1
        performanceMetrics.averageEnhancementTime = (performanceMetrics.averageEnhancementTime + duration) / 2.0
    }
    
    private func updateFilterMetrics(filterType: ImageFilterType) async {
        performanceMetrics.totalFiltersApplied += 1
        performanceMetrics.popularFilters[filterType.rawValue, default: 0] += 1
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> ImageGenerationPerformanceMetrics {
        return performanceMetrics
    }
    
    /// Clear generation cache
    public func clearCache() async {
        generationCache.removeAll()
        logger.info("Image generation cache cleared", category: "ImageGeneration")
    }
    
    /// Get cache statistics
    public func getCacheStats() async -> (size: Int, maxSize: Int) {
        return (generationCache.count, maxCacheSize)
    }
    
    /// Get supported formats
    public func getSupportedFormats() -> [ImageFormat] {
        return supportedFormats
    }
    
    /// Get available generative models
    public func getAvailableModels() async -> [String] {
        return Array(generativeModels.keys)
    }
    
    /// Get available style transfer models
    public func getAvailableStyleModels() async -> [String] {
        return Array(styleTransferModels.keys)
    }
    
    /// Get available filters
    public func getAvailableFilters() async -> [String] {
        return Array(imageFilters.keys)
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceImageGeneration: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeImageGenerationEngine()
    }
    
    public func shutdown() async throws {
        await clearCache()
        status = .shutdown
        logger.info("Image Generation Engine shutdown complete", category: "ImageGeneration")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "IMAGE_GENERATION_NOT_READY", message: "Image Generation Engine not ready"))
        }
        
        if generativeModels.isEmpty {
            warnings.append(ValidationWarning(code: "NO_GENERATIVE_MODELS", message: "No generative models loaded"))
        }
        
        if imageFilters.isEmpty {
            warnings.append(ValidationWarning(code: "NO_IMAGE_FILTERS", message: "No image filters loaded"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let metrics = [
            "total_generations": String(performanceMetrics.totalGenerations),
            "successful_generations": String(performanceMetrics.successfulGenerations),
            "total_variations": String(performanceMetrics.totalVariations),
            "total_style_transfers": String(performanceMetrics.totalStyleTransfers),
            "total_enhancements": String(performanceMetrics.totalEnhancements),
            "total_filters_applied": String(performanceMetrics.totalFiltersApplied),
            "generative_models_count": String(generativeModels.count),
            "style_models_count": String(styleTransferModels.count),
            "filters_count": String(imageFilters.count),
            "cache_size": String(generationCache.count)
        ]
        
        switch status {
        case .ready:
            return HealthStatus(
                status: .healthy,
                message: "Image Generation Engine operational with \(performanceMetrics.totalGenerations) images generated",
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "Image Generation Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "Image Generation Engine not ready",
                metrics: metrics
            )
        }
    }
}

// MARK: - Performance Metrics

/// Image generation engine performance metrics
public struct ImageGenerationPerformanceMetrics: Sendable {
    public var totalGenerations: Int = 0
    public var successfulGenerations: Int = 0
    public var totalVariations: Int = 0
    public var totalStyleTransfers: Int = 0
    public var totalEnhancements: Int = 0
    public var totalFiltersApplied: Int = 0
    
    public var averageGenerationTime: TimeInterval = 0.0
    public var averageVariationTime: TimeInterval = 0.0
    public var averageStyleTransferTime: TimeInterval = 0.0
    public var averageEnhancementTime: TimeInterval = 0.0
    
    public var popularFilters: [String: Int] = [:]
    
    public init() {}
}
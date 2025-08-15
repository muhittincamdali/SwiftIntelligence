import Foundation
import CoreImage
import CoreML
import Vision
import UIKit
import SwiftUI
import os.log

/// Advanced Image Generation Engine with multi-provider support and local models
@MainActor
public class ImageGenerationEngine: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = ImageGenerationEngine()
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "ImageGeneration")
    private let processingQueue = DispatchQueue(label: "image.generation", qos: .userInitiated)
    
    // MARK: - Providers
    private var providers: [String: ImageGenerationProvider] = [:]
    private var activeProvider: ImageGenerationProvider?
    
    // MARK: - Local Models
    private var localModels: [String: MLModel] = [:]
    private var styleTransferModels: [String: MLModel] = [:]
    private var upscalingModel: MLModel?
    private var inpaintingModel: MLModel?
    
    // MARK: - Configuration
    @Published public var configuration: ImageGenerationConfiguration = .default
    
    // MARK: - State Management
    @Published public var isGenerating = false
    @Published public var generationProgress: Float = 0.0
    @Published public var lastError: ImageGenerationError?
    @Published public var currentUsage = ImageGenerationUsage()
    
    // MARK: - Cache and Storage
    private let imageCache = NSCache<NSString, UIImage>()
    private let generationCache = NSCache<NSString, ImageGenerationResult>()
    
    // MARK: - Rate Limiting
    private var rateLimiter: ImageRateLimiter
    
    // MARK: - Core Image Context
    private let ciContext = CIContext()
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        // Configure caches
        imageCache.countLimit = 50
        imageCache.totalCostLimit = 100_000_000 // 100MB
        
        generationCache.countLimit = 100
        generationCache.totalCostLimit = 50_000_000 // 50MB
        
        // Initialize rate limiter
        rateLimiter = ImageRateLimiter(maxRequests: 20, timeWindow: 60) // 20 requests per minute
        
        Task {
            try await initializeEngine()
        }
    }
    
    // MARK: - Engine Initialization
    private func initializeEngine() async throws {
        logger.info("Initializing Image Generation Engine...")
        
        // Setup providers
        await setupProviders()
        
        // Load local models
        await loadLocalModels()
        
        // Initialize image processing pipeline
        await setupImageProcessingPipeline()
        
        logger.info("Image Generation Engine initialized successfully")
    }
    
    private func setupProviders() async {
        // OpenAI DALL-E Provider
        if !configuration.openAI.apiKey.isEmpty {
            let openAIProvider = OpenAIImageProvider(
                apiKey: configuration.openAI.apiKey,
                baseURL: configuration.openAI.baseURL
            )
            providers["openai"] = openAIProvider
        }
        
        // Midjourney Provider (hypothetical)
        if !configuration.midjourney.apiKey.isEmpty {
            let midjourneyProvider = MidjourneyProvider(
                apiKey: configuration.midjourney.apiKey,
                baseURL: configuration.midjourney.baseURL
            )
            providers["midjourney"] = midjourneyProvider
        }
        
        // Stability AI Provider
        if !configuration.stabilityAI.apiKey.isEmpty {
            let stabilityProvider = StabilityAIProvider(
                apiKey: configuration.stabilityAI.apiKey,
                baseURL: configuration.stabilityAI.baseURL
            )
            providers["stability"] = stabilityProvider
        }
        
        // Local Provider
        let localProvider = LocalImageProvider()
        providers["local"] = localProvider
        
        // Set default provider
        activeProvider = providers[configuration.defaultProvider]
        
        logger.info("Image generation providers initialized")
    }
    
    private func loadLocalModels() async {
        logger.info("Loading local image generation models...")
        
        // Load style transfer models
        await loadStyleTransferModels()
        
        // Load upscaling model
        await loadUpscalingModel()
        
        // Load inpainting model
        await loadInpaintingModel()
        
        // Load other specialized models
        await loadSpecializedModels()
        
        logger.info("Local models loaded successfully")
    }
    
    private func loadStyleTransferModels() async {
        let styleNames = ["abstract", "impressionist", "cubist", "anime", "photorealistic"]
        
        for styleName in styleNames {
            do {
                if let modelURL = Bundle.module.url(forResource: "StyleTransfer_\(styleName)", withExtension: "mlmodel") {
                    let model = try MLModel(contentsOf: modelURL)
                    styleTransferModels[styleName] = model
                    logger.info("Loaded style transfer model: \(styleName)")
                }
            } catch {
                logger.warning("Failed to load style transfer model \(styleName): \(error.localizedDescription)")
            }
        }
    }
    
    private func loadUpscalingModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "ImageUpscalingModel", withExtension: "mlmodel") {
                upscalingModel = try MLModel(contentsOf: modelURL)
                logger.info("Image upscaling model loaded successfully")
            }
        } catch {
            logger.error("Failed to load upscaling model: \(error.localizedDescription)")
        }
    }
    
    private func loadInpaintingModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "ImageInpaintingModel", withExtension: "mlmodel") {
                inpaintingModel = try MLModel(contentsOf: modelURL)
                logger.info("Image inpainting model loaded successfully")
            }
        } catch {
            logger.error("Failed to load inpainting model: \(error.localizedDescription)")
        }
    }
    
    private func loadSpecializedModels() async {
        let modelNames = ["BackgroundRemoval", "ObjectDetection", "FaceEnhancement", "ColorCorrection"]
        
        for modelName in modelNames {
            do {
                if let modelURL = Bundle.module.url(forResource: modelName, withExtension: "mlmodel") {
                    let model = try MLModel(contentsOf: modelURL)
                    localModels[modelName] = model
                    logger.info("Loaded specialized model: \(modelName)")
                }
            } catch {
                logger.warning("Failed to load specialized model \(modelName): \(error.localizedDescription)")
            }
        }
    }
    
    private func setupImageProcessingPipeline() async {
        // Configure image processing filters and pipelines
        logger.info("Image processing pipeline configured")
    }
    
    // MARK: - Configuration
    
    public func updateConfiguration(_ config: ImageGenerationConfiguration) {
        configuration = config
        
        Task {
            await setupProviders()
            activeProvider = providers[config.defaultProvider]
            
            // Update rate limiter
            rateLimiter = ImageRateLimiter(
                maxRequests: config.rateLimiting.maxRequests,
                timeWindow: config.rateLimiting.timeWindow
            )
        }
        
        logger.info("Image generation configuration updated")
    }
    
    public func setProvider(_ providerName: String) throws {
        guard let provider = providers[providerName] else {
            throw ImageGenerationError.providerNotFound(providerName)
        }
        
        activeProvider = provider
        logger.info("Active image generation provider set to: \(providerName)")
    }
    
    // MARK: - Image Generation
    
    /// Generate images from text prompt
    public func generateImages(
        from prompt: String,
        options: ImageGenerationOptions = .default
    ) async throws -> ImageGenerationResult {
        
        guard let provider = activeProvider else {
            throw ImageGenerationError.noActiveProvider
        }
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        isGenerating = true
        generationProgress = 0.0
        lastError = nil
        
        do {
            let request = ImageGenerationRequest(
                prompt: prompt,
                options: options
            )
            
            // Check cache
            if let cachedResult = getCachedResult(for: request) {
                isGenerating = false
                return cachedResult
            }
            
            // Update progress
            generationProgress = 0.1
            
            let result = try await provider.generateImages(request: request)
            
            // Update usage
            updateUsage(result.usage)
            
            // Cache result
            cacheResult(result, for: request)
            
            // Update progress
            generationProgress = 1.0
            isGenerating = false
            
            return result
            
        } catch {
            isGenerating = false
            generationProgress = 0.0
            let imageError = mapError(error)
            lastError = imageError
            throw imageError
        }
    }
    
    /// Generate variations of an existing image
    public func generateImageVariations(
        from image: UIImage,
        options: ImageVariationOptions = .default
    ) async throws -> ImageGenerationResult {
        
        guard let provider = activeProvider else {
            throw ImageGenerationError.noActiveProvider
        }
        
        try await rateLimiter.checkRateLimit()
        
        isGenerating = true
        generationProgress = 0.0
        
        do {
            let request = ImageVariationRequest(
                sourceImage: image,
                options: options
            )
            
            generationProgress = 0.2
            
            let result = try await provider.generateVariations(request: request)
            
            updateUsage(result.usage)
            generationProgress = 1.0
            isGenerating = false
            
            return result
            
        } catch {
            isGenerating = false
            let imageError = mapError(error)
            lastError = imageError
            throw imageError
        }
    }
    
    /// Edit images using inpainting
    public func editImage(
        image: UIImage,
        mask: UIImage,
        prompt: String,
        options: ImageEditOptions = .default
    ) async throws -> ImageGenerationResult {
        
        guard let provider = activeProvider else {
            throw ImageGenerationError.noActiveProvider
        }
        
        try await rateLimiter.checkRateLimit()
        
        isGenerating = true
        generationProgress = 0.0
        
        do {
            let request = ImageEditRequest(
                sourceImage: image,
                maskImage: mask,
                prompt: prompt,
                options: options
            )
            
            generationProgress = 0.3
            
            let result = try await provider.editImage(request: request)
            
            updateUsage(result.usage)
            generationProgress = 1.0
            isGenerating = false
            
            return result
            
        } catch {
            isGenerating = false
            let imageError = mapError(error)
            lastError = imageError
            throw imageError
        }
    }
    
    // MARK: - Style Transfer
    
    /// Apply style transfer to an image
    public func applyStyleTransfer(
        to image: UIImage,
        style: StyleTransferStyle,
        intensity: Float = 1.0
    ) async throws -> UIImage {
        
        guard let styleModel = styleTransferModels[style.rawValue] else {
            throw ImageGenerationError.modelNotAvailable(style.rawValue)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.performStyleTransfer(
                        image: image,
                        model: styleModel,
                        intensity: intensity
                    )
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performStyleTransfer(
        image: UIImage,
        model: MLModel,
        intensity: Float
    ) throws -> UIImage {
        
        // Convert UIImage to CVPixelBuffer
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert image to pixel buffer")
        }
        
        // Prepare model input
        let input = StyleTransferInput(image: pixelBuffer, intensity: intensity)
        
        // Run prediction
        let prediction = try model.prediction(from: input)
        
        // Convert output back to UIImage
        guard let outputImage = prediction.outputImage?.toUIImage() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert output to UIImage")
        }
        
        return outputImage
    }
    
    // MARK: - Image Enhancement
    
    /// Upscale image using AI
    public func upscaleImage(
        _ image: UIImage,
        scaleFactor: Float = 2.0
    ) async throws -> UIImage {
        
        guard let model = upscalingModel else {
            throw ImageGenerationError.modelNotAvailable("upscaling")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.performImageUpscaling(
                        image: image,
                        model: model,
                        scaleFactor: scaleFactor
                    )
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performImageUpscaling(
        image: UIImage,
        model: MLModel,
        scaleFactor: Float
    ) throws -> UIImage {
        
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert image to pixel buffer")
        }
        
        let input = UpscalingInput(image: pixelBuffer, scale: scaleFactor)
        let prediction = try model.prediction(from: input)
        
        guard let outputImage = prediction.outputImage?.toUIImage() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert upscaled image")
        }
        
        return outputImage
    }
    
    /// Remove background from image
    public func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let model = localModels["BackgroundRemoval"] else {
            throw ImageGenerationError.modelNotAvailable("BackgroundRemoval")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.performBackgroundRemoval(image: image, model: model)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performBackgroundRemoval(image: UIImage, model: MLModel) throws -> UIImage {
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert image")
        }
        
        let input = BackgroundRemovalInput(image: pixelBuffer)
        let prediction = try model.prediction(from: input)
        
        guard let outputImage = prediction.outputImage?.toUIImage() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to process background removal")
        }
        
        return outputImage
    }
    
    // MARK: - Batch Processing
    
    /// Generate multiple images concurrently
    public func batchGenerateImages(
        prompts: [String],
        options: ImageGenerationOptions = .default,
        maxConcurrency: Int = 3
    ) async throws -> [ImageGenerationResult] {
        
        return try await withThrowingTaskGroup(of: ImageGenerationResult.self) { group in
            var results: [ImageGenerationResult] = []
            
            // Add tasks with concurrency limit
            var activeCount = 0
            var promptIndex = 0
            
            func addNextTask() {
                guard promptIndex < prompts.count, activeCount < maxConcurrency else { return }
                
                let prompt = prompts[promptIndex]
                promptIndex += 1
                activeCount += 1
                
                group.addTask {
                    defer { activeCount -= 1 }
                    return try await self.generateImages(from: prompt, options: options)
                }
                
                addNextTask()
            }
            
            // Start initial tasks
            for _ in 0..<min(maxConcurrency, prompts.count) {
                addNextTask()
            }
            
            // Collect results
            while results.count < prompts.count {
                if let result = try await group.next() {
                    results.append(result)
                    addNextTask()
                }
            }
            
            return results
        }
    }
    
    // MARK: - Image Analysis and Processing
    
    /// Analyze image content for generation feedback
    public func analyzeImageContent(_ image: UIImage) async throws -> ImageAnalysisResult {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let analysis = try self.performImageAnalysis(image)
                    continuation.resume(returning: analysis)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performImageAnalysis(_ image: UIImage) throws -> ImageAnalysisResult {
        guard let cgImage = image.cgImage else {
            throw ImageGenerationError.imageProcessingFailed("Invalid image format")
        }
        
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        try handler.perform([request])
        
        guard let results = request.results else {
            throw ImageGenerationError.imageProcessingFailed("No analysis results")
        }
        
        let classifications = results.prefix(10).map { observation in
            ImageClassification(
                label: observation.identifier,
                confidence: observation.confidence
            )
        }
        
        return ImageAnalysisResult(
            classifications: Array(classifications),
            dominantColors: extractDominantColors(from: image),
            imageSize: image.size,
            aspectRatio: image.size.width / image.size.height
        )
    }
    
    private func extractDominantColors(from image: UIImage) -> [UIColor] {
        // Simplified color extraction - in production, use more sophisticated algorithm
        return [UIColor.red, UIColor.blue, UIColor.green] // Placeholder
    }
    
    // MARK: - Provider Management
    
    public func getAvailableProviders() -> [String] {
        return Array(providers.keys)
    }
    
    public func getProviderInfo(_ providerName: String) -> ImageProviderInfo? {
        guard let provider = providers[providerName] else { return nil }
        
        return ImageProviderInfo(
            name: provider.name,
            supportedFormats: provider.supportedFormats,
            maxImageSize: provider.maxImageSize,
            features: ImageProviderFeatures(
                textToImage: provider.supportsTextToImage,
                imageVariations: provider.supportsImageVariations,
                imageEditing: provider.supportsImageEditing,
                styleTransfer: provider.supportsStyleTransfer,
                upscaling: provider.supportsUpscaling,
                isLocal: provider.isLocal
            )
        )
    }
    
    // MARK: - Usage and Monitoring
    
    public func getUsageStatistics() -> ImageGenerationUsage {
        return currentUsage
    }
    
    public func resetUsageStatistics() {
        currentUsage = ImageGenerationUsage()
    }
    
    public func getRateLimitStatus() -> RateLimitStatus {
        return rateLimiter.getStatus()
    }
    
    // MARK: - Cache Management
    
    public func clearCache() {
        imageCache.removeAllObjects()
        generationCache.removeAllObjects()
        logger.info("Image generation cache cleared")
    }
    
    public func getCacheInfo() -> CacheInfo {
        return CacheInfo(
            count: imageCache.countLimit,
            size: imageCache.totalCostLimit,
            currentCount: 0, // NSCache doesn't provide current count
            estimatedSize: 0  // NSCache doesn't provide current size
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func getCachedResult(for request: ImageGenerationRequest) -> ImageGenerationResult? {
        guard configuration.enableCaching else { return nil }
        
        let cacheKey = NSString(string: request.cacheKey)
        return generationCache.object(forKey: cacheKey)
    }
    
    private func cacheResult(_ result: ImageGenerationResult, for request: ImageGenerationRequest) {
        guard configuration.enableCaching else { return }
        
        let cacheKey = NSString(string: request.cacheKey)
        let cost = result.images.reduce(0) { $0 + estimateImageCost($1) }
        generationCache.setObject(result, forKey: cacheKey, cost: cost)
    }
    
    private func estimateImageCost(_ image: GeneratedImage) -> Int {
        // Rough estimation based on image size and format
        let pixels = Int(image.size.width * image.size.height)
        return pixels * 4 // RGBA bytes
    }
    
    private func updateUsage(_ usage: ImageGenerationTokenUsage) {
        currentUsage.totalRequests += 1
        currentUsage.totalImages += usage.imagesGenerated
        currentUsage.estimatedCost += calculateCost(usage: usage)
    }
    
    private func calculateCost(usage: ImageGenerationTokenUsage) -> Double {
        // Simplified cost calculation - would use actual provider pricing
        let costPerImage = 0.02 // $0.02 per image
        return Double(usage.imagesGenerated) * costPerImage
    }
    
    private func mapError(_ error: Error) -> ImageGenerationError {
        if let imageError = error as? ImageGenerationError {
            return imageError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .requestTimeout
            default:
                return .networkError(urlError.localizedDescription)
            }
        }
        
        return .unknownError(error.localizedDescription)
    }
}

// MARK: - Rate Limiter

private class ImageRateLimiter {
    private let maxRequests: Int
    private let timeWindow: TimeInterval
    private var requestTimestamps: [Date] = []
    private let queue = DispatchQueue(label: "image.rate.limiter", attributes: .concurrent)
    
    init(maxRequests: Int, timeWindow: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }
    
    func checkRateLimit() async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                let now = Date()
                let cutoff = now.addingTimeInterval(-self.timeWindow)
                
                self.requestTimestamps = self.requestTimestamps.filter { $0 > cutoff }
                
                if self.requestTimestamps.count >= self.maxRequests {
                    continuation.resume(throwing: ImageGenerationError.rateLimitExceeded)
                } else {
                    self.requestTimestamps.append(now)
                    continuation.resume()
                }
            }
        }
    }
    
    func getStatus() -> RateLimitStatus {
        return queue.sync {
            let now = Date()
            let cutoff = now.addingTimeInterval(-timeWindow)
            let recentRequests = requestTimestamps.filter { $0 > cutoff }
            
            return RateLimitStatus(
                remainingRequests: max(0, maxRequests - recentRequests.count),
                resetTime: recentRequests.first?.addingTimeInterval(timeWindow) ?? now,
                totalLimit: maxRequests
            )
        }
    }
}

// MARK: - Model Input Types

private struct StyleTransferInput: MLFeatureProvider {
    let image: CVPixelBuffer
    let intensity: Float
    
    var featureNames: Set<String> {
        return ["image", "intensity"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "image":
            return MLFeatureValue(pixelBuffer: image)
        case "intensity":
            return MLFeatureValue(double: Double(intensity))
        default:
            return nil
        }
    }
}

private struct UpscalingInput: MLFeatureProvider {
    let image: CVPixelBuffer
    let scale: Float
    
    var featureNames: Set<String> {
        return ["image", "scale"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "image":
            return MLFeatureValue(pixelBuffer: image)
        case "scale":
            return MLFeatureValue(double: Double(scale))
        default:
            return nil
        }
    }
}

private struct BackgroundRemovalInput: MLFeatureProvider {
    let image: CVPixelBuffer
    
    var featureNames: Set<String> {
        return ["image"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "image":
            return MLFeatureValue(pixelBuffer: image)
        default:
            return nil
        }
    }
}

// MARK: - Extensions

extension MLModel {
    func prediction(from input: MLFeatureProvider) throws -> ImageGenerationOutput {
        let output = try prediction(from: input)
        return ImageGenerationOutput(mlOutput: output)
    }
}

private struct ImageGenerationOutput {
    let mlOutput: MLFeatureProvider
    
    var outputImage: CVPixelBuffer? {
        return mlOutput.featureValue(for: "output_image")?.imageBufferValue
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(self.size.width),
                                         Int(self.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(self.size.width),
                                height: Int(self.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

extension CVPixelBuffer {
    func toUIImage() -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
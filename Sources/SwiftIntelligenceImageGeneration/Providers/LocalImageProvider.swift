import Foundation
import UIKit
import CoreML
import Vision
import CoreImage
import os.log

/// Local on-device image generation provider for privacy-focused applications
public class LocalImageProvider: ImageGenerationProvider {
    
    // MARK: - Properties
    public let name = "Local Image Generation"
    public let supportedFormats: [ImageFormat] = [.png, .jpeg, .heif]
    public let maxImageSize = CGSize(width: 1024, height: 1024)
    public let supportsTextToImage = true
    public let supportsImageVariations = true
    public let supportsImageEditing = true
    public let supportsStyleTransfer = true
    public let supportsUpscaling = true
    public let isLocal = true
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "LocalImageProvider")
    private let processingQueue = DispatchQueue(label: "local.image.processing", qos: .userInitiated)
    private let ciContext = CIContext()
    
    // MARK: - Local Models
    private var textToImageModel: MLModel?
    private var variationModel: MLModel?
    private var inpaintingModel: MLModel?
    private var styleTransferModels: [String: MLModel] = [:]
    private var upscalingModel: MLModel?
    
    // MARK: - Text Processing
    private let textEncoder = LocalTextEncoder()
    private let promptProcessor = PromptProcessor()
    
    // MARK: - Initialization
    public init() {
        Task {
            await loadLocalModels()
        }
    }
    
    private func loadLocalModels() async {
        logger.info("Loading local image generation models...")
        
        // Load text-to-image model
        await loadTextToImageModel()
        
        // Load variation model
        await loadVariationModel()
        
        // Load inpainting model
        await loadInpaintingModel()
        
        // Load style transfer models
        await loadStyleTransferModels()
        
        // Load upscaling model
        await loadUpscalingModel()
        
        logger.info("Local image generation models loaded")
    }
    
    private func loadTextToImageModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalTextToImageModel", withExtension: "mlmodel") {
                textToImageModel = try MLModel(contentsOf: modelURL)
                logger.info("Text-to-image model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load text-to-image model: \(error.localizedDescription)")
        }
    }
    
    private func loadVariationModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalImageVariationModel", withExtension: "mlmodel") {
                variationModel = try MLModel(contentsOf: modelURL)
                logger.info("Image variation model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load variation model: \(error.localizedDescription)")
        }
    }
    
    private func loadInpaintingModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalInpaintingModel", withExtension: "mlmodel") {
                inpaintingModel = try MLModel(contentsOf: modelURL)
                logger.info("Inpainting model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load inpainting model: \(error.localizedDescription)")
        }
    }
    
    private func loadStyleTransferModels() async {
        let styles = ["artistic", "photorealistic", "cartoon", "abstract", "anime"]
        
        for style in styles {
            do {
                if let modelURL = Bundle.module.url(forResource: "StyleTransfer_\(style)", withExtension: "mlmodel") {
                    let model = try MLModel(contentsOf: modelURL)
                    styleTransferModels[style] = model
                    logger.info("Style transfer model loaded: \(style)")
                }
            } catch {
                logger.warning("Failed to load style transfer model \(style): \(error.localizedDescription)")
            }
        }
    }
    
    private func loadUpscalingModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalUpscalingModel", withExtension: "mlmodel") {
                upscalingModel = try MLModel(contentsOf: modelURL)
                logger.info("Upscaling model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load upscaling model: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Generation
    public func generateImages(request: ImageGenerationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        guard let model = textToImageModel else {
            throw ImageGenerationError.modelNotAvailable("text-to-image")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let images = try self.performTextToImageGeneration(
                        prompt: request.prompt,
                        model: model,
                        options: request.options
                    )
                    
                    let processingTime = Date().timeIntervalSince(startTime)
                    
                    let result = ImageGenerationResult(
                        images: images,
                        usage: ImageGenerationTokenUsage(
                            imagesGenerated: images.count,
                            processingTime: processingTime,
                            providerCost: 0.0 // Local generation is free
                        ),
                        processingTime: processingTime,
                        metadata: ImageGenerationMetadata(
                            provider: self.name,
                            model: "local-text-to-image",
                            parameters: [
                                "size": request.options.size.rawValue,
                                "style": request.options.style.rawValue,
                                "steps": "\(request.options.steps)"
                            ]
                        )
                    )
                    
                    continuation.resume(returning: result)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performTextToImageGeneration(
        prompt: String,
        model: MLModel,
        options: ImageGenerationOptions
    ) throws -> [GeneratedImage] {
        
        var generatedImages: [GeneratedImage] = []
        
        // Process the prompt
        let processedPrompt = promptProcessor.process(prompt, style: options.style)
        let textEmbedding = textEncoder.encode(processedPrompt)
        
        // Generate the requested number of images
        for i in 0..<options.count {
            let image = try generateSingleImage(
                textEmbedding: textEmbedding,
                model: model,
                options: options,
                seed: options.seed ?? Int.random(in: 0...Int.max)
            )
            
            let generatedImage = GeneratedImage(
                imageData: image.pngData(),
                imageURL: nil,
                size: image.size,
                format: .png,
                quality: options.quality,
                prompt: prompt,
                revisedPrompt: processedPrompt,
                seed: options.seed
            )
            
            generatedImages.append(generatedImage)
        }
        
        return generatedImages
    }
    
    private func generateSingleImage(
        textEmbedding: [Float],
        model: MLModel,
        options: ImageGenerationOptions,
        seed: Int
    ) throws -> UIImage {
        
        // Create model input
        let input = LocalTextToImageInput(
            textEmbedding: textEmbedding,
            width: Int(options.size.size.width),
            height: Int(options.size.size.height),
            steps: options.steps,
            guidance: Float(options.guidance),
            seed: seed
        )
        
        // Run the model
        let prediction = try model.prediction(from: input)
        
        // Extract the generated image
        guard let outputImage = prediction.featureValue(for: "generated_image")?.imageBufferValue else {
            throw ImageGenerationError.imageProcessingFailed("Failed to extract generated image")
        }
        
        // Convert to UIImage
        guard let uiImage = convertCVPixelBufferToUIImage(outputImage) else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert pixel buffer to UIImage")
        }
        
        // Apply style if needed
        return try applyStyleEnhancements(to: uiImage, style: options.style)
    }
    
    // MARK: - Image Variations
    public func generateVariations(request: ImageVariationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        guard let model = variationModel else {
            throw ImageGenerationError.modelNotAvailable("image-variation")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let images = try self.performImageVariation(
                        sourceImage: request.sourceImage,
                        model: model,
                        options: request.options
                    )
                    
                    let processingTime = Date().timeIntervalSince(startTime)
                    
                    let result = ImageGenerationResult(
                        images: images,
                        usage: ImageGenerationTokenUsage(
                            imagesGenerated: images.count,
                            processingTime: processingTime,
                            providerCost: 0.0
                        ),
                        processingTime: processingTime,
                        metadata: ImageGenerationMetadata(
                            provider: self.name,
                            model: "local-image-variation",
                            parameters: [
                                "variations": "\(request.options.count)",
                                "similarity": "\(request.options.similarityStrength)"
                            ]
                        )
                    )
                    
                    continuation.resume(returning: result)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performImageVariation(
        sourceImage: UIImage,
        model: MLModel,
        options: ImageVariationOptions
    ) throws -> [GeneratedImage] {
        
        guard let pixelBuffer = sourceImage.toCVPixelBuffer() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert source image")
        }
        
        var variations: [GeneratedImage] = []
        
        for i in 0..<options.count {
            let input = LocalImageVariationInput(
                sourceImage: pixelBuffer,
                variationStrength: Float(1.0 - options.similarityStrength),
                seed: Int.random(in: 0...Int.max)
            )
            
            let prediction = try model.prediction(from: input)
            
            guard let outputBuffer = prediction.featureValue(for: "variation_image")?.imageBufferValue,
                  let variationImage = convertCVPixelBufferToUIImage(outputBuffer) else {
                continue
            }
            
            let generatedImage = GeneratedImage(
                imageData: variationImage.pngData(),
                imageURL: nil,
                size: variationImage.size,
                format: .png,
                quality: options.quality,
                prompt: nil,
                revisedPrompt: nil,
                seed: nil
            )
            
            variations.append(generatedImage)
        }
        
        return variations
    }
    
    // MARK: - Image Editing
    public func editImage(request: ImageEditRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        guard let model = inpaintingModel else {
            throw ImageGenerationError.modelNotAvailable("inpainting")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let editedImage = try self.performImageEditing(
                        sourceImage: request.sourceImage,
                        maskImage: request.maskImage,
                        prompt: request.prompt,
                        model: model,
                        options: request.options
                    )
                    
                    let processingTime = Date().timeIntervalSince(startTime)
                    
                    let result = ImageGenerationResult(
                        images: [editedImage],
                        usage: ImageGenerationTokenUsage(
                            imagesGenerated: 1,
                            processingTime: processingTime,
                            providerCost: 0.0
                        ),
                        processingTime: processingTime,
                        metadata: ImageGenerationMetadata(
                            provider: self.name,
                            model: "local-inpainting",
                            parameters: [
                                "strength": "\(request.options.strength)",
                                "steps": "\(request.options.steps)"
                            ]
                        )
                    )
                    
                    continuation.resume(returning: result)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performImageEditing(
        sourceImage: UIImage,
        maskImage: UIImage,
        prompt: String,
        model: MLModel,
        options: ImageEditOptions
    ) throws -> GeneratedImage {
        
        guard let sourceBuffer = sourceImage.toCVPixelBuffer(),
              let maskBuffer = maskImage.toCVPixelBuffer() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert images to pixel buffers")
        }
        
        let processedPrompt = promptProcessor.process(prompt, style: .natural)
        let textEmbedding = textEncoder.encode(processedPrompt)
        
        let input = LocalInpaintingInput(
            sourceImage: sourceBuffer,
            maskImage: maskBuffer,
            textEmbedding: textEmbedding,
            strength: Float(options.strength),
            steps: options.steps,
            guidance: Float(options.guidance)
        )
        
        let prediction = try model.prediction(from: input)
        
        guard let outputBuffer = prediction.featureValue(for: "edited_image")?.imageBufferValue,
              let editedUIImage = convertCVPixelBufferToUIImage(outputBuffer) else {
            throw ImageGenerationError.imageProcessingFailed("Failed to generate edited image")
        }
        
        return GeneratedImage(
            imageData: editedUIImage.pngData(),
            imageURL: nil,
            size: editedUIImage.size,
            format: .png,
            quality: options.quality,
            prompt: prompt,
            revisedPrompt: processedPrompt,
            seed: nil
        )
    }
    
    // MARK: - Style Enhancement
    private func applyStyleEnhancements(to image: UIImage, style: ImageStyle) throws -> UIImage {
        switch style {
        case .natural, .photorealistic:
            return image // No additional processing needed
        case .artistic, .abstract, .cartoon, .anime:
            return try applyArtisticStyle(to: image, style: style)
        default:
            return image
        }
    }
    
    private func applyArtisticStyle(to image: UIImage, style: ImageStyle) throws -> UIImage {
        guard let styleModel = styleTransferModels[style.rawValue] else {
            return image // Return original if style model not available
        }
        
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            throw ImageGenerationError.imageProcessingFailed("Failed to convert image for style transfer")
        }
        
        let input = LocalStyleTransferInput(
            image: pixelBuffer,
            intensity: 0.8
        )
        
        let prediction = try styleModel.prediction(from: input)
        
        guard let styledBuffer = prediction.featureValue(for: "styled_image")?.imageBufferValue,
              let styledImage = convertCVPixelBufferToUIImage(styledBuffer) else {
            return image // Return original if style transfer fails
        }
        
        return styledImage
    }
    
    // MARK: - Helper Methods
    
    private func convertCVPixelBufferToUIImage(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Local Model Input Types

private struct LocalTextToImageInput: MLFeatureProvider {
    let textEmbedding: [Float]
    let width: Int
    let height: Int
    let steps: Int
    let guidance: Float
    let seed: Int
    
    var featureNames: Set<String> {
        return ["text_embedding", "width", "height", "steps", "guidance", "seed"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "text_embedding":
            return try? MLFeatureValue(multiArray: MLMultiArray(textEmbedding))
        case "width":
            return MLFeatureValue(int64: Int64(width))
        case "height":
            return MLFeatureValue(int64: Int64(height))
        case "steps":
            return MLFeatureValue(int64: Int64(steps))
        case "guidance":
            return MLFeatureValue(double: Double(guidance))
        case "seed":
            return MLFeatureValue(int64: Int64(seed))
        default:
            return nil
        }
    }
}

private struct LocalImageVariationInput: MLFeatureProvider {
    let sourceImage: CVPixelBuffer
    let variationStrength: Float
    let seed: Int
    
    var featureNames: Set<String> {
        return ["source_image", "variation_strength", "seed"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "source_image":
            return MLFeatureValue(pixelBuffer: sourceImage)
        case "variation_strength":
            return MLFeatureValue(double: Double(variationStrength))
        case "seed":
            return MLFeatureValue(int64: Int64(seed))
        default:
            return nil
        }
    }
}

private struct LocalInpaintingInput: MLFeatureProvider {
    let sourceImage: CVPixelBuffer
    let maskImage: CVPixelBuffer
    let textEmbedding: [Float]
    let strength: Float
    let steps: Int
    let guidance: Float
    
    var featureNames: Set<String> {
        return ["source_image", "mask_image", "text_embedding", "strength", "steps", "guidance"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "source_image":
            return MLFeatureValue(pixelBuffer: sourceImage)
        case "mask_image":
            return MLFeatureValue(pixelBuffer: maskImage)
        case "text_embedding":
            return try? MLFeatureValue(multiArray: MLMultiArray(textEmbedding))
        case "strength":
            return MLFeatureValue(double: Double(strength))
        case "steps":
            return MLFeatureValue(int64: Int64(steps))
        case "guidance":
            return MLFeatureValue(double: Double(guidance))
        default:
            return nil
        }
    }
}

private struct LocalStyleTransferInput: MLFeatureProvider {
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

// MARK: - Text Processing Components

private class LocalTextEncoder {
    func encode(_ text: String) -> [Float] {
        // Simplified text encoding - in production, use proper tokenization and embedding
        let words = text.lowercased().components(separatedBy: .whitespacesAndPunctuation)
        let embedding = words.reduce([Float]()) { result, word in
            var wordEmbedding = result
            // Create a simple hash-based embedding
            let hash = word.hashValue
            for i in 0..<512 { // 512-dimensional embedding
                let value = Float(sin(Double(hash + i * 7) * 0.001))
                wordEmbedding.append(value)
            }
            return wordEmbedding
        }
        
        // Normalize to fixed size (512 dimensions)
        let targetSize = 512
        if embedding.count > targetSize {
            return Array(embedding.prefix(targetSize))
        } else if embedding.count < targetSize {
            var normalizedEmbedding = embedding
            while normalizedEmbedding.count < targetSize {
                normalizedEmbedding.append(0.0)
            }
            return normalizedEmbedding
        }
        
        return embedding
    }
}

private class PromptProcessor {
    func process(_ prompt: String, style: ImageStyle) -> String {
        var processedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add style-specific modifiers
        switch style {
        case .photorealistic:
            processedPrompt += ", photorealistic, high quality, detailed"
        case .artistic:
            processedPrompt += ", artistic, creative, expressive"
        case .cartoon:
            processedPrompt += ", cartoon style, animated, colorful"
        case .anime:
            processedPrompt += ", anime style, manga, Japanese animation"
        case .abstract:
            processedPrompt += ", abstract art, non-representational, modern"
        default:
            break
        }
        
        return processedPrompt
    }
}

// MARK: - Extensions

extension MLMultiArray {
    convenience init(_ array: [Float]) throws {
        let shape = [NSNumber(value: array.count)]
        try self.init(shape: shape, dataType: .float32)
        
        let pointer = self.dataPointer.bindMemory(to: Float.self, capacity: array.count)
        for (index, value) in array.enumerated() {
            pointer[index] = value
        }
    }
}
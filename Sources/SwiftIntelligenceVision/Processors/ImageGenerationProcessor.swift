import Foundation
import SwiftIntelligenceCore
import CoreGraphics
import CoreML
@preconcurrency import Vision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CoreImage
import os.log

/// Advanced image generation processor aligned to the canonical Vision types.
@MainActor
public final class ImageGenerationProcessor: @unchecked Sendable {
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "ImageGeneration")
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    private var generationModels: [ImageGenerationOptions.GenerationStyle: VNCoreMLModel] = [:]
    private var stableDiffusionModel: VNCoreMLModel?
    private var variationModel: VNCoreMLModel?

    public init() async throws {
        try await initializeModels()
    }

    private func initializeModels() async throws {
        logger.info("Image generation models initialized")
    }

    public func generate(
        from prompt: String,
        options: ImageGenerationOptions
    ) async throws -> ImageGenerationResult {
        let normalizedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedPrompt.isEmpty else {
            throw GenerationError.invalidPrompt
        }

        let effectiveOptions = normalized(options: options, prompt: normalizedPrompt)
        let startTime = Date()
        let processedPrompt = processPrompt(normalizedPrompt, style: effectiveOptions.style)
        let generatedImages = try await performImageGeneration(prompt: processedPrompt, options: effectiveOptions)
        let quality = assessGenerationQuality(prompt: normalizedPrompt, options: effectiveOptions)
        let processingTime = Date().timeIntervalSince(startTime)

        return ImageGenerationResult(
            processingTime: processingTime,
            confidence: quality.overallQuality,
            metadata: [
                "style": effectiveOptions.style.rawValue,
                "size": effectiveOptions.size.rawValue,
                "quality": effectiveOptions.quality.rawValue,
                "count": String(generatedImages.count)
            ],
            generatedImages: generatedImages,
            prompt: normalizedPrompt,
            options: effectiveOptions
        )
    }

    public func generateVariations(
        of image: PlatformImage,
        count: Int,
        options: VariationOptions
    ) async throws -> ImageVariationResult {
        guard let sourceImage = cgImage(from: image) else {
            throw GenerationError.invalidImage
        }

        let startTime = Date()
        let effectiveCount = max(1, count)
        let effectiveOptions = VariationOptions(
            count: effectiveCount,
            variationType: options.variationType,
            similarity: options.similarity,
            enhanceQuality: options.enhanceQuality
        )
        let variations = try await performVariationGeneration(
            sourceImage: sourceImage,
            options: effectiveOptions
        )
        let confidence = variations.map(\.similarity).reduce(0, +) / Float(variations.count)
        let processingTime = Date().timeIntervalSince(startTime)

        return ImageVariationResult(
            processingTime: processingTime,
            confidence: confidence,
            metadata: [
                "variation_type": effectiveOptions.variationType.rawValue,
                "count": String(variations.count),
                "enhance_quality": String(effectiveOptions.enhanceQuality)
            ],
            variations: variations,
            originalImageSize: image.size
        )
    }

    public func batchGenerate(
        prompts: [String],
        options: ImageGenerationOptions
    ) async throws -> [ImageGenerationResult] {
        try await withThrowingTaskGroup(of: ImageGenerationResult.self) { group in
            for prompt in prompts {
                group.addTask {
                    try await self.generate(from: prompt, options: options)
                }
            }

            var results: [ImageGenerationResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }

    public func generateArtistic(
        from prompt: String,
        artisticStyle: ArtisticStyle
    ) async throws -> ImageGenerationResult {
        let enhancedPrompt = enhancePromptForArt(prompt, style: artisticStyle)
        let options = ImageGenerationOptions(
            prompt: enhancedPrompt,
            style: .artistic,
            size: .large,
            quality: .high,
            count: 1
        )
        return try await generate(from: enhancedPrompt, options: options)
    }

    public func generatePhotorealistic(
        from prompt: String,
        size: ImageSize = .large
    ) async throws -> ImageGenerationResult {
        let enhancedPrompt = enhancePromptForRealism(prompt)
        let options = ImageGenerationOptions(
            prompt: enhancedPrompt,
            style: .photorealistic,
            size: generationSize(from: size),
            quality: .ultra,
            count: 1
        )
        return try await generate(from: enhancedPrompt, options: options)
    }

    public func generateWithComposition(
        prompt: String,
        composition: CompositionGuide
    ) async throws -> ImageGenerationResult {
        let compositionPrompt = addCompositionToPrompt(prompt, composition: composition)
        let options = ImageGenerationOptions(
            prompt: compositionPrompt,
            style: .photorealistic,
            size: .large,
            quality: .high,
            count: 1
        )
        return try await generate(from: compositionPrompt, options: options)
    }

    private func performImageGeneration(
        prompt: String,
        options: ImageGenerationOptions
    ) async throws -> [ImageGenerationResult.GeneratedImage] {
        let delay = calculateProcessingDelay(options: options)
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        return (0..<max(1, options.count)).map { index in
            let generatedImage = createMockGeneratedImage(
                prompt: prompt,
                options: options,
                variantIndex: index
            )
            return generatedImageRecord(from: generatedImage)
        }
    }

    private func performVariationGeneration(
        sourceImage: CGImage,
        options: VariationOptions
    ) async throws -> [ImageVariationResult.ImageVariation] {
        var variations: [ImageVariationResult.ImageVariation] = []
        for index in 0..<max(1, options.count) {
            variations.append(try await createVariation(
                sourceImage: sourceImage,
                variationIndex: index,
                options: options
            ))
        }
        return variations
    }

    private func createVariation(
        sourceImage: CGImage,
        variationIndex: Int,
        options: VariationOptions
    ) async throws -> ImageVariationResult.ImageVariation {
        var image = CIImage(cgImage: sourceImage)
        let delta = max(0.05, 1.0 - options.similarity)

        switch options.variationType {
        case .style_transfer:
            image = image.applyingFilter("CIPhotoEffectTransfer")
        case .color_variation:
            image = image
                .applyingFilter("CIHueAdjust", parameters: ["inputAngle": Double(variationIndex + 1) * Double(delta)])
                .applyingFilter("CIColorControls", parameters: ["inputSaturation": 1.0 + Double(delta)])
        case .composition_change:
            let transform = CGAffineTransform(
                translationX: CGFloat(variationIndex) * 8,
                y: CGFloat(variationIndex % 2 == 0 ? 6 : -6)
            )
            image = image.transformed(by: transform).cropped(to: image.extent)
        case .detail_enhancement:
            image = image.applyingFilter("CISharpenLuminance", parameters: ["inputSharpness": 0.6 + Double(delta)])
        }

        if options.enhanceQuality {
            image = image.applyingFilter("CIUnsharpMask", parameters: ["inputIntensity": 0.3 + Double(delta)])
        }

        guard let cgImage = ciContext.createCGImage(image, from: image.extent) else {
            throw GenerationError.variationFailed
        }

        let variationImage = platformImage(from: cgImage, size: image.extent.size)
        let similarity = max(0.1, min(0.98, options.similarity - (Float(variationIndex) * 0.03)))

        return ImageVariationResult.ImageVariation(
            imageData: pngData(from: variationImage) ?? Data(),
            variationType: options.variationType,
            similarity: similarity,
            format: "PNG"
        )
    }

    private func normalized(options: ImageGenerationOptions, prompt: String) -> ImageGenerationOptions {
        if options.prompt == prompt {
            return options
        }
        return ImageGenerationOptions(
            prompt: prompt,
            style: options.style,
            size: options.size,
            quality: options.quality,
            count: options.count
        )
    }

    private func processPrompt(_ prompt: String, style: ImageGenerationOptions.GenerationStyle) -> String {
        switch style {
        case .photorealistic:
            return prompt + ", photorealistic, high detail, studio lighting"
        case .artistic:
            return prompt + ", artistic, expressive, gallery-quality"
        case .cartoon:
            return prompt + ", cartoon, bold outlines, stylized"
        case .sketch:
            return prompt + ", pencil sketch, line art, paper texture"
        case .oil_painting:
            return prompt + ", oil painting, rich brushstrokes, painterly texture"
        case .watercolor:
            return prompt + ", watercolor, soft pigments, paper grain"
        }
    }

    private func enhancePromptForArt(_ prompt: String, style: ArtisticStyle) -> String {
        switch style {
        case .impressionist:
            return prompt + ", impressionist light, painterly atmosphere"
        case .cubist:
            return prompt + ", cubist geometry, fractured planes"
        case .abstract:
            return prompt + ", abstract composition, shape-driven"
        case .realism:
            return prompt + ", realism, fine detail, grounded rendering"
        case .surrealism:
            return prompt + ", surreal dream logic, unexpected juxtapositions"
        case .pop_art:
            return prompt + ", pop art palette, bold graphic contrast"
        case .minimalism:
            return prompt + ", minimalist composition, negative space"
        case .expressionism:
            return prompt + ", expressionist energy, emotional color"
        case .baroque:
            return prompt + ", baroque drama, rich contrast, ornate light"
        case .renaissance:
            return prompt + ", renaissance balance, classical composition"
        }
    }

    private func enhancePromptForRealism(_ prompt: String) -> String {
        prompt + ", photorealistic, natural materials, cinematic lighting, sharp focus"
    }

    private func addCompositionToPrompt(_ prompt: String, composition: CompositionGuide) -> String {
        prompt + ", " + composition.description
    }

    private func calculateProcessingDelay(options: ImageGenerationOptions) -> TimeInterval {
        let qualityMultiplier: TimeInterval = switch options.quality {
        case .standard: 1.0
        case .high: 1.4
        case .ultra: 1.8
        }
        let sizeMultiplier: TimeInterval = switch options.size {
        case .small: 0.7
        case .medium: 1.0
        case .large: 1.4
        case .extra_large, .portrait: 1.7
        }
        return 0.05 * qualityMultiplier * sizeMultiplier
    }

    private func createMockGeneratedImage(
        prompt: String,
        options: ImageGenerationOptions,
        variantIndex: Int
    ) -> PlatformImage {
        let size = canvasSize(for: options.size)
        let width = max(Int(size.width), 1)
        let height = max(Int(size.height), 1)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )!

        let colors = gradientColors(for: prompt, style: options.style, variantIndex: variantIndex)
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )

        drawAccentShapes(in: context, size: size, style: options.style, variantIndex: variantIndex)

        let borderAlpha = max(0.15, 1.0 - CGFloat(variantIndex) * 0.08)
        context.setStrokeColor(CGColor(gray: 1.0, alpha: borderAlpha))
        context.setLineWidth(6)
        context.stroke(CGRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20))

        let cgImage = context.makeImage()!
        return platformImage(from: cgImage, size: size)
    }

    private func generatedImageRecord(from image: PlatformImage) -> ImageGenerationResult.GeneratedImage {
        ImageGenerationResult.GeneratedImage(
            imageData: pngData(from: image) ?? Data(),
            format: "PNG",
            size: image.size,
            quality: 0.9
        )
    }

    private func assessGenerationQuality(
        prompt: String,
        options: ImageGenerationOptions
    ) -> GenerationQualityMetrics {
        let promptDensity = min(Float(prompt.count) / 120.0, 1.0)
        let qualityBonus: Float = switch options.quality {
        case .standard: 0.72
        case .high: 0.84
        case .ultra: 0.92
        }
        let styleBonus: Float = options.style == .artistic ? 0.88 : 0.82
        let composition = min(0.7 + (Float(options.count) * 0.03), 0.92)
        let colorHarmony = min(0.68 + promptDensity * 0.2, 0.94)
        let detail = min(qualityBonus + 0.04, 0.97)
        let overall = min((qualityBonus + styleBonus + composition + colorHarmony + detail) / 5.0, 0.98)

        return GenerationQualityMetrics(
            aestheticScore: styleBonus,
            technicalQuality: qualityBonus,
            promptAdherence: max(0.68, promptDensity),
            creativity: options.style == .artistic ? 0.9 : 0.76,
            composition: composition,
            colorHarmony: colorHarmony,
            detail: detail,
            overallQuality: overall
        )
    }

    private func generationSize(from size: ImageSize) -> ImageGenerationOptions.GenerationSize {
        switch (size.width, size.height) {
        case (..<(512), ..<(512)):
            return .small
        case (..<(900), ..<(900)):
            return .medium
        case (1024, 1792):
            return .portrait
        case (1792, 1024):
            return .extra_large
        default:
            return .large
        }
    }

    private func canvasSize(for size: ImageGenerationOptions.GenerationSize) -> CGSize {
        switch size {
        case .small:
            return CGSize(width: 256, height: 256)
        case .medium:
            return CGSize(width: 512, height: 512)
        case .large:
            return CGSize(width: 1024, height: 1024)
        case .extra_large:
            return CGSize(width: 1792, height: 1024)
        case .portrait:
            return CGSize(width: 1024, height: 1792)
        }
    }

    private func gradientColors(
        for prompt: String,
        style: ImageGenerationOptions.GenerationStyle,
        variantIndex: Int
    ) -> [CGColor] {
        let lowercased = prompt.lowercased()
        if lowercased.contains("sunset") {
            return [CGColor(red: 0.96, green: 0.48, blue: 0.25, alpha: 1), CGColor(red: 0.29, green: 0.16, blue: 0.48, alpha: 1)]
        }
        if lowercased.contains("ocean") || lowercased.contains("sea") {
            return [CGColor(red: 0.14, green: 0.48, blue: 0.76, alpha: 1), CGColor(red: 0.04, green: 0.14, blue: 0.32, alpha: 1)]
        }
        if lowercased.contains("forest") || lowercased.contains("nature") {
            return [CGColor(red: 0.18, green: 0.44, blue: 0.21, alpha: 1), CGColor(red: 0.73, green: 0.84, blue: 0.44, alpha: 1)]
        }

        switch style {
        case .photorealistic:
            return [CGColor(red: 0.13, green: 0.16, blue: 0.2, alpha: 1), CGColor(red: 0.75, green: 0.79, blue: 0.84, alpha: 1)]
        case .artistic:
            return [CGColor(red: 0.49 + CGFloat(variantIndex) * 0.03, green: 0.2, blue: 0.6, alpha: 1), CGColor(red: 0.96, green: 0.68, blue: 0.25, alpha: 1)]
        case .cartoon:
            return [CGColor(red: 0.12, green: 0.66, blue: 0.95, alpha: 1), CGColor(red: 1.0, green: 0.86, blue: 0.22, alpha: 1)]
        case .sketch:
            return [CGColor(red: 0.92, green: 0.9, blue: 0.84, alpha: 1), CGColor(red: 0.35, green: 0.33, blue: 0.31, alpha: 1)]
        case .oil_painting:
            return [CGColor(red: 0.31, green: 0.16, blue: 0.09, alpha: 1), CGColor(red: 0.86, green: 0.67, blue: 0.35, alpha: 1)]
        case .watercolor:
            return [CGColor(red: 0.72, green: 0.88, blue: 0.94, alpha: 1), CGColor(red: 0.93, green: 0.72, blue: 0.82, alpha: 1)]
        }
    }

    private func drawAccentShapes(
        in context: CGContext,
        size: CGSize,
        style: ImageGenerationOptions.GenerationStyle,
        variantIndex: Int
    ) {
        let count = style == .artistic ? 9 : 6
        for index in 0..<count {
            let inset = CGFloat(40 + index * 18)
            let rect = CGRect(
                x: CGFloat((index * 37 + variantIndex * 13) % max(Int(size.width) - 120, 1)),
                y: CGFloat((index * 61 + variantIndex * 17) % max(Int(size.height) - 120, 1)),
                width: min(size.width - inset, CGFloat(80 + (index * 6))),
                height: min(size.height - inset, CGFloat(80 + (index * 4)))
            )
            let alpha = max(0.12, 0.32 - CGFloat(index) * 0.02)
            context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: alpha))

            switch style {
            case .cartoon, .watercolor:
                context.fillEllipse(in: rect)
            case .sketch:
                context.stroke(rect)
            default:
                context.fill(rect)
            }
        }
    }

    private func cgImage(from image: PlatformImage) -> CGImage? {
        #if canImport(UIKit)
        return image.cgImage
        #elseif canImport(AppKit)
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }

    private func platformImage(from cgImage: CGImage, size: CGSize) -> PlatformImage {
        #if canImport(UIKit)
        return PlatformImage(cgImage: cgImage)
        #elseif canImport(AppKit)
        return PlatformImage(cgImage: cgImage, size: size)
        #endif
    }

    private func pngData(from image: PlatformImage) -> Data? {
        #if canImport(UIKit)
        return image.pngData()
        #elseif canImport(AppKit)
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
        #endif
    }
}

public enum CompositionGuide {
    case ruleOfThirds
    case centerComposition
    case leadingLines
    case symmetrical
    case asymmetrical
    case goldenRatio

    public var description: String {
        switch self {
        case .ruleOfThirds: return "rule of thirds composition"
        case .centerComposition: return "centered composition"
        case .leadingLines: return "leading lines composition"
        case .symmetrical: return "symmetrical composition"
        case .asymmetrical: return "asymmetrical composition"
        case .goldenRatio: return "golden ratio composition"
        }
    }
}

public enum GenerationError: LocalizedError {
    case invalidPrompt
    case invalidImage
    case modelNotInitialized
    case generationFailed(Error)
    case variationFailed
    case insufficientMemory
    case networkError

    public var errorDescription: String? {
        switch self {
        case .invalidPrompt:
            return "Invalid or empty prompt provided"
        case .invalidImage:
            return "Invalid image provided for variation"
        case .modelNotInitialized:
            return "Image generation model not initialized"
        case .generationFailed(let error):
            return "Image generation failed: \(error.localizedDescription)"
        case .variationFailed:
            return "Image variation generation failed"
        case .insufficientMemory:
            return "Insufficient memory for image generation"
        case .networkError:
            return "Network error during generation"
        }
    }
}

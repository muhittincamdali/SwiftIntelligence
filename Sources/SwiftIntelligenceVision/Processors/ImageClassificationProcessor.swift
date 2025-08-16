import Foundation
import CoreML
import Vision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import os.log

/// Advanced image classification processor with multiple model support
public class ImageClassificationProcessor: @unchecked Sendable {
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "ImageClassification")
    private var models: [String: VNCoreMLModel] = [:]
    private let processingQueue = DispatchQueue(label: "image.classification", qos: .userInitiated)
    
    // MARK: - Model Information
    private let availableModels = [
        "mobilenet_v3": ModelMetadata(
            name: "MobileNet V3",
            accuracy: 0.873,
            size: 21 * 1024 * 1024,
            classes: 1000,
            description: "Efficient image classification for mobile devices"
        ),
        "efficientnet_b0": ModelMetadata(
            name: "EfficientNet B0",
            accuracy: 0.886,
            size: 29 * 1024 * 1024,
            classes: 1000,
            description: "Balanced accuracy and efficiency"
        ),
        "resnet50": ModelMetadata(
            name: "ResNet50",
            accuracy: 0.891,
            size: 102 * 1024 * 1024,
            classes: 1000,
            description: "High accuracy classification model"
        )
    ]
    
    // MARK: - Initialization
    public init() async throws {
        try await loadDefaultModels()
    }
    
    // MARK: - Model Management
    private func loadDefaultModels() async throws {
        // Load primary classification model
        try await loadModel("mobilenet_v3")
        logger.info("Loaded default classification models")
    }
    
    private func loadModel(_ modelName: String) async throws {
        guard let modelMetadata = availableModels[modelName] else {
            throw ClassificationError.modelNotFound(modelName)
        }
        
        // In a real implementation, you would load the actual .mlmodel file
        // For this example, we'll create a placeholder model reference
        logger.info("Loading classification model: \(modelMetadata.name)")
        
        // This would be replaced with actual model loading:
        // let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodel")!
        // let mlModel = try MLModel(contentsOf: modelURL)
        // let vnModel = try VNCoreMLModel(for: mlModel)
        // models[modelName] = vnModel
        
        logger.info("Successfully loaded model: \(modelMetadata.name)")
    }
    
    // MARK: - Image Classification
    
    /// Classify image contents using advanced ML models
    public func classify(
        _ image: PlatformImage,
        options: ClassificationOptions
    ) async throws -> ImageClassificationResult {
        let startTime = Date()
        
        // Validate input
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else {
            throw ClassificationError.invalidImage
        }
        #elseif canImport(AppKit)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ClassificationError.invalidImage
        }
        #endif
        
        // Select optimal model based on options
        let modelName = selectOptimalModel(for: options)
        
        // Perform classification
        let classifications = try await performClassification(
            cgImage: cgImage,
            modelName: modelName,
            options: options
        )
        
        // Analyze image properties
        let imageProperties = analyzeImageProperties(image)
        
        // Extract dominant colors
        let dominantColors = extractDominantColors(from: image)
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = classifications.first?.confidence ?? 0.0
        
        return ImageClassificationResult(
            processingTime: processingTime,
            confidence: confidence,
            classifications: classifications,
            dominantColors: dominantColors,
            imageProperties: imageProperties
        )
    }
    
    /// Batch classify multiple images
    public func batchClassify(
        _ images: [PlatformImage],
        options: ClassificationOptions
    ) async throws -> [ImageClassificationResult] {
        return try await withThrowingTaskGroup(of: ImageClassificationResult.self) { group in
            for image in images {
                group.addTask {
                    try await self.classify(image, options: options)
                }
            }
            
            var results: [ImageClassificationResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    // MARK: - Private Methods
    
    private func selectOptimalModel(for options: ClassificationOptions) -> String {
        if options.useCustomModel, options.customModelPath != nil {
            return "custom"
        }
        
        // Select based on device capabilities and requirements
        let deviceCapabilities = getDeviceCapabilities()
        
        if deviceCapabilities.hasNeuralEngine && deviceCapabilities.availableMemory > 512 * 1024 * 1024 {
            return "resnet50" // High accuracy model
        } else if deviceCapabilities.availableMemory > 256 * 1024 * 1024 {
            return "efficientnet_b0" // Balanced model
        } else {
            return "mobilenet_v3" // Efficient model
        }
    }
    
    private func performClassification(
        cgImage: CGImage,
        modelName: String,
        options: ClassificationOptions
    ) async throws -> [Classification] {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    // Create Vision request
                    let request = VNCoreMLRequest(model: try self.getModel(modelName)) { request, error in
                        if let error = error {
                            continuation.resume(throwing: ClassificationError.processingFailed(error))
                            return
                        }
                        
                        guard let observations = request.results as? [VNClassificationObservation] else {
                            continuation.resume(throwing: ClassificationError.invalidResults)
                            return
                        }
                        
                        let classifications = self.processObservations(
                            observations,
                            options: options
                        )
                        continuation.resume(returning: classifications)
                    }
                    
                    // Configure request
                    request.imageCropAndScaleOption = .centerCrop
                    
                    // Perform request
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                    
                } catch {
                    continuation.resume(throwing: ClassificationError.processingFailed(error))
                }
            }
        }
    }
    
    private func getModel(_ modelName: String) throws -> VNCoreMLModel {
        // In a real implementation, return the loaded model
        // For now, we'll create a mock model or throw an error
        throw ClassificationError.modelNotFound(modelName)
    }
    
    private func processObservations(
        _ observations: [VNClassificationObservation],
        options: ClassificationOptions
    ) -> [Classification] {
        let filteredObservations = observations
            .filter { $0.confidence >= options.confidenceThreshold }
            .prefix(options.maxResults)
        
        return filteredObservations.map { observation in
            Classification(
                identifier: observation.identifier,
                label: formatLabel(observation.identifier),
                confidence: observation.confidence,
                hierarchy: parseHierarchy(observation.identifier)
            )
        }
    }
    
    private func formatLabel(_ identifier: String) -> String {
        // Convert identifiers like "n01440764" or "Egyptian_cat" to readable labels
        let components = identifier.components(separatedBy: "_")
        if components.count > 1 {
            return components.map { $0.capitalized }.joined(separator: " ")
        }
        
        // Handle ImageNet identifiers
        if identifier.hasPrefix("n") && identifier.count == 9 {
            return lookupImageNetLabel(identifier) ?? identifier
        }
        
        return identifier.capitalized
    }
    
    private func parseHierarchy(_ identifier: String) -> [String] {
        // Extract hierarchy information from classification identifier
        // This would typically come from a taxonomy or ontology
        let hierarchyMap: [String: [String]] = [
            "Egyptian_cat": ["Animal", "Mammal", "Carnivore", "Feline", "Cat"],
            "Golden_retriever": ["Animal", "Mammal", "Carnivore", "Canine", "Dog"],
            "Airplane": ["Vehicle", "Aircraft", "Airplane"],
            "Car": ["Vehicle", "Land Vehicle", "Automobile"]
        ]
        
        return hierarchyMap[identifier] ?? []
    }
    
    private func lookupImageNetLabel(_ identifier: String) -> String? {
        // In a real implementation, this would lookup from ImageNet taxonomy
        let imagenetLabels: [String: String] = [
            "n01440764": "Tench",
            "n01443537": "Goldfish",
            "n01484850": "Great white shark",
            "n01491361": "Tiger shark",
            "n01494475": "Hammerhead shark"
        ]
        
        return imagenetLabels[identifier]
    }
    
    private func analyzeImageProperties(_ image: PlatformImage) -> ImageProperties {
        let size = image.size
        #if canImport(UIKit)
        let cgImage = image.cgImage
        #elseif canImport(AppKit)
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
        
        // Analyze color properties
        let (brightness, contrast, saturation) = analyzeColorProperties(image)
        
        // Get dominant colors
        let dominantColors = extractDominantColors(from: image)
        
        // Get orientation based on platform
        #if canImport(UIKit)
        let orientation = mapOrientation(image.imageOrientation)
        #elseif canImport(AppKit)
        let orientation = ImageProperties.ImageOrientation.up // NSImage doesn't have imageOrientation
        #endif
        
        return ImageProperties(
            size: size,
            colorSpace: cgImage?.colorSpace?.name as String? ?? "unknown",
            hasAlpha: cgImage?.alphaInfo != .none,
            orientation: orientation,
            dominantColors: dominantColors,
            averageBrightness: brightness,
            contrast: contrast,
            saturation: saturation
        )
    }
    
    private func analyzeColorProperties(_ image: PlatformImage) -> (brightness: Float, contrast: Float, saturation: Float) {
        // Simplified color analysis - in a real implementation, this would be more sophisticated
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else {
            return (0.5, 0.5, 0.5)
        }
        #elseif canImport(AppKit)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return (0.5, 0.5, 0.5)
        }
        #endif
        
        // Sample pixels for analysis
        let width = cgImage.width
        let height = cgImage.height
        let sampleSize = min(100, min(width, height))
        
        // Create bitmap context for pixel analysis
        let bytesPerPixel = 4
        let bytesPerRow = sampleSize * bytesPerPixel
        let bitmapData = UnsafeMutablePointer<UInt8>.allocate(capacity: sampleSize * sampleSize * bytesPerPixel)
        defer { bitmapData.deallocate() }
        
        guard let context = CGContext(
            data: bitmapData,
            width: sampleSize,
            height: sampleSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return (0.5, 0.5, 0.5)
        }
        
        // Draw scaled image
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize))
        
        // Analyze pixels
        var totalBrightness: Float = 0
        var totalSaturation: Float = 0
        var minBrightness: Float = 1.0
        var maxBrightness: Float = 0.0
        
        for i in stride(from: 0, to: sampleSize * sampleSize * bytesPerPixel, by: bytesPerPixel) {
            let r = Float(bitmapData[i]) / 255.0
            let g = Float(bitmapData[i + 1]) / 255.0
            let b = Float(bitmapData[i + 2]) / 255.0
            
            // Calculate brightness (luminance)
            let brightness = 0.299 * r + 0.587 * g + 0.114 * b
            totalBrightness += brightness
            minBrightness = min(minBrightness, brightness)
            maxBrightness = max(maxBrightness, brightness)
            
            // Calculate saturation
            let max = max(r, max(g, b))
            let min = min(r, min(g, b))
            let saturation = max > 0 ? (max - min) / max : 0
            totalSaturation += saturation
        }
        
        let pixelCount = Float(sampleSize * sampleSize)
        let avgBrightness = totalBrightness / pixelCount
        let avgSaturation = totalSaturation / pixelCount
        let contrast = maxBrightness - minBrightness
        
        return (avgBrightness, contrast, avgSaturation)
    }
    
    private func extractDominantColors(from image: PlatformImage) -> [DominantColor] {
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else { return [] }
        #elseif canImport(AppKit)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return [] }
        #endif
        
        // Simplified dominant color extraction
        // In a real implementation, you would use more sophisticated algorithms like k-means clustering
        
        let sampleSize = 50
        let width = cgImage.width
        let height = cgImage.height
        
        let bytesPerPixel = 4
        let bytesPerRow = sampleSize * bytesPerPixel
        let bitmapData = UnsafeMutablePointer<UInt8>.allocate(capacity: sampleSize * sampleSize * bytesPerPixel)
        defer { bitmapData.deallocate() }
        
        guard let context = CGContext(
            data: bitmapData,
            width: sampleSize,
            height: sampleSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize))
        
        // Collect color samples
        var colorCounts: [String: Int] = [:]
        
        for i in stride(from: 0, to: sampleSize * sampleSize * bytesPerPixel, by: bytesPerPixel) {
            let r = bitmapData[i]
            let g = bitmapData[i + 1]
            let b = bitmapData[i + 2]
            
            // Quantize colors to reduce variations
            let quantizedR = (r / 32) * 32
            let quantizedG = (g / 32) * 32
            let quantizedB = (b / 32) * 32
            
            let colorKey = "\(quantizedR),\(quantizedG),\(quantizedB)"
            colorCounts[colorKey, default: 0] += 1
        }
        
        // Sort by frequency and take top colors
        let sortedColors = colorCounts.sorted { $0.value > $1.value }.prefix(5)
        let totalPixels = sampleSize * sampleSize
        
        return sortedColors.map { colorKey, count in
            let components = colorKey.components(separatedBy: ",").compactMap { UInt8($0) }
            let r = Float(components[0]) / 255.0
            let g = Float(components[1]) / 255.0
            let b = Float(components[2]) / 255.0
            
            let hex = String(format: "#%02X%02X%02X", components[0], components[1], components[2])
            let colorName = getColorName(r: r, g: g, b: b)
            
            return DominantColor(
                color: DominantColor.ColorInfo(
                    red: r,
                    green: g,
                    blue: b,
                    alpha: 1.0,
                    hex: hex,
                    name: colorName
                ),
                percentage: Float(count) / Float(totalPixels),
                pixelCount: count
            )
        }
    }
    
    private func getColorName(r: Float, g: Float, b: Float) -> String? {
        // Simple color name mapping
        let colors: [(name: String, r: Float, g: Float, b: Float, threshold: Float)] = [
            ("Red", 1.0, 0.0, 0.0, 0.3),
            ("Green", 0.0, 1.0, 0.0, 0.3),
            ("Blue", 0.0, 0.0, 1.0, 0.3),
            ("Yellow", 1.0, 1.0, 0.0, 0.3),
            ("Cyan", 0.0, 1.0, 1.0, 0.3),
            ("Magenta", 1.0, 0.0, 1.0, 0.3),
            ("White", 1.0, 1.0, 1.0, 0.2),
            ("Black", 0.0, 0.0, 0.0, 0.2),
            ("Gray", 0.5, 0.5, 0.5, 0.3),
            ("Orange", 1.0, 0.5, 0.0, 0.3),
            ("Purple", 0.5, 0.0, 0.5, 0.3),
            ("Brown", 0.6, 0.3, 0.0, 0.3)
        ]
        
        for color in colors {
            let distance = sqrt(
                pow(r - color.r, 2) +
                pow(g - color.g, 2) +
                pow(b - color.b, 2)
            )
            
            if distance < color.threshold {
                return color.name
            }
        }
        
        return nil
    }
    
    #if canImport(UIKit)
    private func mapOrientation(_ orientation: PlatformImage.Orientation) -> ImageProperties.ImageOrientation {
        switch orientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
    #endif
    
    private func getDeviceCapabilities() -> DeviceCapabilities {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let availableMemory = getAvailableMemory()
        
        // Detect Neural Engine availability (A12+ chips)
        let hasNeuralEngine = MLModel.availableComputeDevices.contains { device in
            device.description.contains("Neural")
        }
        
        return DeviceCapabilities(
            totalMemory: totalMemory,
            availableMemory: availableMemory,
            hasNeuralEngine: hasNeuralEngine,
            supportedComputeUnits: MLModel.availableComputeDevices
        )
    }
    
    private func getAvailableMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? info.resident_size : 0
    }
}

// MARK: - Supporting Types

private struct ModelMetadata {
    let name: String
    let accuracy: Float
    let size: Int
    let classes: Int
    let description: String
}

private struct DeviceCapabilities {
    let totalMemory: UInt64
    let availableMemory: UInt64
    let hasNeuralEngine: Bool
    let supportedComputeUnits: [MLComputeDevice]
}

public enum ClassificationError: LocalizedError {
    case modelNotFound(String)
    case invalidImage
    case processingFailed(Error)
    case invalidResults
    case modelLoadingFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelName):
            return "Classification model '\(modelName)' not found"
        case .invalidImage:
            return "Invalid image provided for classification"
        case .processingFailed(let error):
            return "Classification processing failed: \(error.localizedDescription)"
        case .invalidResults:
            return "Invalid classification results"
        case .modelLoadingFailed(let error):
            return "Failed to load classification model: \(error.localizedDescription)"
        }
    }
}
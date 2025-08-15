import Foundation
import UIKit
import os.log

/// Midjourney image generation provider for artistic and creative AI image generation
public class MidjourneyProvider: ImageGenerationProvider {
    
    // MARK: - Properties
    public let name = "Midjourney"
    public let supportedFormats: [ImageFormat] = [.png, .jpeg, .webp]
    public let maxImageSize = CGSize(width: 2048, height: 2048)
    public let supportsTextToImage = true
    public let supportsImageVariations = true
    public let supportsImageEditing = false // Midjourney doesn't support direct editing
    public let supportsStyleTransfer = false
    public let supportsUpscaling = true
    public let isLocal = false
    
    private let apiKey: String
    private let baseURL: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Midjourney")
    
    private let supportedVersions = ["4", "5", "5.1", "5.2", "6"]
    private let supportedAspectRatios = ["1:1", "3:2", "2:3", "16:9", "9:16", "4:3", "3:4"]
    
    // MARK: - Initialization
    public init(apiKey: String, baseURL: String = "https://api.midjourney.com/v1") {
        self.apiKey = apiKey
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180.0 // Midjourney can take longer
        config.timeoutIntervalForResource = 600.0
        self.urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Image Generation
    public func generateImages(request: ImageGenerationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        let url = URL(string: "\(baseURL)/imagine")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = MidjourneyImagineRequest(
            prompt: enhancePromptForMidjourney(request.prompt, options: request.options),
            version: determineVersion(for: request.options),
            aspectRatio: mapAspectRatio(request.options.aspectRatio),
            quality: mapQualityToMidjourney(request.options.quality),
            stylize: mapStyleToStylize(request.options.style),
            chaos: mapGuidanceToChaos(request.options.guidance),
            seed: request.options.seed,
            stop: nil, // Let it complete fully
            upscale: false, // We'll handle upscaling separately
            variation: false
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode == 429 {
                throw ImageGenerationError.rateLimitExceeded
            }
            
            if httpResponse.statusCode == 401 {
                throw ImageGenerationError.unauthorizedAccess
            }
            
            if httpResponse.statusCode != 200 {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw ImageGenerationError.invalidPrompt(message)
                }
                throw ImageGenerationError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let midjourneyResponse = try JSONDecoder().decode(MidjourneyImagineResponse.self, from: data)
            
            // Midjourney works asynchronously, we need to poll for completion
            let finalResult = try await pollForCompletion(taskId: midjourneyResponse.taskId)
            
            let images = try processImagineResult(finalResult, originalPrompt: request.prompt)
            let processingTime = Date().timeIntervalSince(startTime)
            
            return ImageGenerationResult(
                images: images,
                usage: ImageGenerationTokenUsage(
                    imagesGenerated: images.count,
                    processingTime: processingTime,
                    providerCost: estimateCost(for: request.options)
                ),
                processingTime: processingTime,
                metadata: ImageGenerationMetadata(
                    provider: name,
                    model: "midjourney-\(requestBody.version)",
                    parameters: [
                        "version": requestBody.version,
                        "aspect_ratio": requestBody.aspectRatio,
                        "quality": "\(requestBody.quality)",
                        "stylize": "\(requestBody.stylize)",
                        "chaos": "\(requestBody.chaos)"
                    ]
                )
            )
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            logger.error("Midjourney generation failed: \(error.localizedDescription)")
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Image Variations
    public func generateVariations(request: ImageVariationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        // First, we need to upload the image to Midjourney
        let imageURL = try await uploadImage(request.sourceImage)
        
        let url = URL(string: "\(baseURL)/vary")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = MidjourneyVaryRequest(
            imageURL: imageURL,
            variationStrength: mapSimilarityToVariationStrength(request.options.similarityStrength),
            count: request.options.count
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw ImageGenerationError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let midjourneyResponse = try JSONDecoder().decode(MidjourneyVaryResponse.self, from: data)
            
            // Poll for completion
            let finalResult = try await pollForVariationCompletion(taskId: midjourneyResponse.taskId)
            
            let images = try processVariationResult(finalResult)
            let processingTime = Date().timeIntervalSince(startTime)
            
            return ImageGenerationResult(
                images: images,
                usage: ImageGenerationTokenUsage(
                    imagesGenerated: images.count,
                    processingTime: processingTime,
                    providerCost: estimateVariationCost(for: request.options)
                ),
                processingTime: processingTime,
                metadata: ImageGenerationMetadata(
                    provider: name,
                    model: "midjourney-variations",
                    parameters: [
                        "variation_strength": "\(requestBody.variationStrength)",
                        "variations": "\(request.options.count)"
                    ]
                )
            )
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Image Editing (Not Supported)
    public func editImage(request: ImageEditRequest) async throws -> ImageGenerationResult {
        throw ImageGenerationError.unsupportedFormat
    }
    
    // MARK: - Upscaling
    public func upscaleImage(_ image: UIImage, scaleFactor: Float = 2.0) async throws -> UIImage {
        let imageURL = try await uploadImage(image)
        
        let url = URL(string: "\(baseURL)/upscale")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = MidjourneyUpscaleRequest(
            imageURL: imageURL,
            upscaleLevel: mapScaleFactorToUpscaleLevel(scaleFactor)
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw ImageGenerationError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let midjourneyResponse = try JSONDecoder().decode(MidjourneyUpscaleResponse.self, from: data)
            
            // Poll for completion
            let finalResult = try await pollForUpscaleCompletion(taskId: midjourneyResponse.taskId)
            
            guard let imageURLString = finalResult.imageURL,
                  let imageURL = URL(string: imageURLString),
                  let imageData = try? Data(contentsOf: imageURL),
                  let upscaledImage = UIImage(data: imageData) else {
                throw ImageGenerationError.imageProcessingFailed("Failed to process upscaled image")
            }
            
            return upscaledImage
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func enhancePromptForMidjourney(_ prompt: String, options: ImageGenerationOptions) -> String {
        var enhancedPrompt = prompt
        
        // Add style-specific enhancements
        switch options.style {
        case .photorealistic:
            enhancedPrompt += ", photorealistic, hyperrealistic, professional photography"
        case .artistic:
            enhancedPrompt += ", artistic, creative, expressive, fine art"
        case .vivid:
            enhancedPrompt += ", vibrant colors, high contrast, dynamic"
        case .cartoon:
            enhancedPrompt += ", cartoon style, animated, stylized"
        case .anime:
            enhancedPrompt += ", anime style, manga, Japanese animation"
        case .abstract:
            enhancedPrompt += ", abstract art, non-representational, modern art"
        case .minimalist:
            enhancedPrompt += ", minimalist, clean, simple, elegant"
        default:
            break
        }
        
        // Add quality enhancers
        if options.quality == .hd || options.quality == .ultra {
            enhancedPrompt += ", high quality, detailed, sharp"
        }
        
        return enhancedPrompt
    }
    
    private func determineVersion(for options: ImageGenerationOptions) -> String {
        // Use latest version for high quality, older versions for specific styles
        if options.quality == .ultra {
            return "6"
        } else if options.style == .anime || options.style == .cartoon {
            return "5.2" // Better for stylized content
        } else {
            return "5.2" // Current stable version
        }
    }
    
    private func mapAspectRatio(_ ratio: AspectRatio) -> String {
        switch ratio {
        case .square:
            return "1:1"
        case .portrait:
            return "2:3"
        case .landscape:
            return "3:2"
        case .widescreen:
            return "16:9"
        case .ultrawide:
            return "21:9"
        }
    }
    
    private func mapQualityToMidjourney(_ quality: ImageQuality) -> Int {
        switch quality {
        case .standard:
            return 1
        case .hd:
            return 2
        case .ultra:
            return 5
        }
    }
    
    private func mapStyleToStylize(_ style: ImageStyle) -> Int {
        switch style {
        case .natural, .photorealistic:
            return 100 // Low stylization for realistic images
        case .artistic, .vivid:
            return 250 // Medium stylization
        case .abstract, .cartoon, .anime:
            return 750 // High stylization for creative styles
        case .minimalist:
            return 50 // Very low stylization
        }
    }
    
    private func mapGuidanceToChaos(_ guidance: Double) -> Int {
        // Midjourney chaos is inverse of guidance (higher chaos = less predictable)
        let normalizedGuidance = max(1.0, min(20.0, guidance))
        let chaos = Int((20.0 - normalizedGuidance) / 20.0 * 100)
        return max(0, min(100, chaos))
    }
    
    private func mapSimilarityToVariationStrength(_ similarity: Double) -> Double {
        // Higher similarity = lower variation strength
        return 1.0 - similarity
    }
    
    private func mapScaleFactorToUpscaleLevel(_ scaleFactor: Float) -> String {
        if scaleFactor <= 2.0 {
            return "Light"
        } else if scaleFactor <= 4.0 {
            return "Beta"
        } else {
            return "Max"
        }
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        let url = URL(string: "\(baseURL)/upload")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            formData.append(imageData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        urlRequest.httpBody = formData
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ImageGenerationError.networkError("Failed to upload image")
        }
        
        let uploadResponse = try JSONDecoder().decode(MidjourneyUploadResponse.self, from: data)
        return uploadResponse.imageURL
    }
    
    private func pollForCompletion(taskId: String) async throws -> MidjourneyTaskResult {
        let maxPollingAttempts = 60 // 5 minutes with 5-second intervals
        var attempts = 0
        
        while attempts < maxPollingAttempts {
            let url = URL(string: "\(baseURL)/task/\(taskId)")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ImageGenerationError.networkError("Failed to poll task status")
            }
            
            let taskResult = try JSONDecoder().decode(MidjourneyTaskResult.self, from: data)
            
            if taskResult.status == "completed" {
                return taskResult
            } else if taskResult.status == "failed" {
                throw ImageGenerationError.imageProcessingFailed(taskResult.error ?? "Generation failed")
            }
            
            // Wait before next poll
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            attempts += 1
        }
        
        throw ImageGenerationError.requestTimeout
    }
    
    private func pollForVariationCompletion(taskId: String) async throws -> MidjourneyVariationResult {
        let maxPollingAttempts = 60
        var attempts = 0
        
        while attempts < maxPollingAttempts {
            let url = URL(string: "\(baseURL)/variation-task/\(taskId)")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ImageGenerationError.networkError("Failed to poll variation status")
            }
            
            let result = try JSONDecoder().decode(MidjourneyVariationResult.self, from: data)
            
            if result.status == "completed" {
                return result
            } else if result.status == "failed" {
                throw ImageGenerationError.imageProcessingFailed(result.error ?? "Variation failed")
            }
            
            try await Task.sleep(nanoseconds: 5_000_000_000)
            attempts += 1
        }
        
        throw ImageGenerationError.requestTimeout
    }
    
    private func pollForUpscaleCompletion(taskId: String) async throws -> MidjourneyUpscaleResult {
        let maxPollingAttempts = 40
        var attempts = 0
        
        while attempts < maxPollingAttempts {
            let url = URL(string: "\(baseURL)/upscale-task/\(taskId)")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ImageGenerationError.networkError("Failed to poll upscale status")
            }
            
            let result = try JSONDecoder().decode(MidjourneyUpscaleResult.self, from: data)
            
            if result.status == "completed" {
                return result
            } else if result.status == "failed" {
                throw ImageGenerationError.imageProcessingFailed(result.error ?? "Upscale failed")
            }
            
            try await Task.sleep(nanoseconds: 5_000_000_000)
            attempts += 1
        }
        
        throw ImageGenerationError.requestTimeout
    }
    
    private func processImagineResult(_ result: MidjourneyTaskResult, originalPrompt: String) throws -> [GeneratedImage] {
        guard let imageURLs = result.imageURLs, !imageURLs.isEmpty else {
            throw ImageGenerationError.imageProcessingFailed("No images in result")
        }
        
        return imageURLs.compactMap { imageURL in
            GeneratedImage(
                imageData: nil,
                imageURL: imageURL,
                size: CGSize(width: 1024, height: 1024), // Midjourney default
                format: .jpeg,
                quality: .hd,
                prompt: originalPrompt,
                revisedPrompt: result.enhancedPrompt,
                seed: result.seed
            )
        }
    }
    
    private func processVariationResult(_ result: MidjourneyVariationResult) throws -> [GeneratedImage] {
        guard let imageURLs = result.variationURLs, !imageURLs.isEmpty else {
            throw ImageGenerationError.imageProcessingFailed("No variations in result")
        }
        
        return imageURLs.compactMap { imageURL in
            GeneratedImage(
                imageData: nil,
                imageURL: imageURL,
                size: CGSize(width: 1024, height: 1024),
                format: .jpeg,
                quality: .hd,
                prompt: nil,
                revisedPrompt: nil,
                seed: nil
            )
        }
    }
    
    private func estimateCost(for options: ImageGenerationOptions) -> Double {
        // Midjourney pricing (simplified estimate)
        let baseCost = 0.08 // $0.08 per image
        let qualityMultiplier = options.quality == .ultra ? 2.0 : 1.0
        return baseCost * qualityMultiplier * Double(options.count)
    }
    
    private func estimateVariationCost(for options: ImageVariationOptions) -> Double {
        let baseCost = 0.06 // Slightly less for variations
        return baseCost * Double(options.count)
    }
}

// MARK: - Midjourney Request Types

private struct MidjourneyImagineRequest: Codable {
    let prompt: String
    let version: String
    let aspectRatio: String
    let quality: Int
    let stylize: Int
    let chaos: Int
    let seed: Int?
    let stop: Int?
    let upscale: Bool
    let variation: Bool
    
    enum CodingKeys: String, CodingKey {
        case prompt, version, quality, stylize, chaos, seed, stop, upscale, variation
        case aspectRatio = "aspect_ratio"
    }
}

private struct MidjourneyVaryRequest: Codable {
    let imageURL: String
    let variationStrength: Double
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case count
        case imageURL = "image_url"
        case variationStrength = "variation_strength"
    }
}

private struct MidjourneyUpscaleRequest: Codable {
    let imageURL: String
    let upscaleLevel: String
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case upscaleLevel = "upscale_level"
    }
}

// MARK: - Midjourney Response Types

private struct MidjourneyImagineResponse: Codable {
    let taskId: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
    }
}

private struct MidjourneyVaryResponse: Codable {
    let taskId: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
    }
}

private struct MidjourneyUpscaleResponse: Codable {
    let taskId: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
    }
}

private struct MidjourneyUploadResponse: Codable {
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
    }
}

private struct MidjourneyTaskResult: Codable {
    let taskId: String
    let status: String
    let imageURLs: [String]?
    let enhancedPrompt: String?
    let seed: Int?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
        case imageURLs = "image_urls"
        case enhancedPrompt = "enhanced_prompt"
        case seed, error
    }
}

private struct MidjourneyVariationResult: Codable {
    let taskId: String
    let status: String
    let variationURLs: [String]?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
        case variationURLs = "variation_urls"
        case error
    }
}

private struct MidjourneyUpscaleResult: Codable {
    let taskId: String
    let status: String
    let imageURL: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
        case imageURL = "image_url"
        case error
    }
}
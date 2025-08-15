import Foundation
import UIKit
import os.log

/// OpenAI DALL-E image generation provider
public class OpenAIImageProvider: ImageGenerationProvider {
    
    // MARK: - Properties
    public let name = "OpenAI DALL-E"
    public let supportedFormats: [ImageFormat] = [.png, .jpeg]
    public let maxImageSize = CGSize(width: 2048, height: 2048)
    public let supportsTextToImage = true
    public let supportsImageVariations = true
    public let supportsImageEditing = true
    public let supportsStyleTransfer = false
    public let supportsUpscaling = false
    public let isLocal = false
    
    private let apiKey: String
    private let baseURL: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "OpenAIImage")
    
    private let supportedModels = ["dall-e-2", "dall-e-3"]
    
    // MARK: - Initialization
    public init(apiKey: String, baseURL: String = "https://api.openai.com/v1") {
        self.apiKey = apiKey
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120.0
        config.timeoutIntervalForResource = 600.0
        self.urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Image Generation
    public func generateImages(request: ImageGenerationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        let url = URL(string: "\(baseURL)/images/generations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = OpenAIImageGenerationRequest(
            model: determineModel(for: request.options),
            prompt: request.prompt,
            n: request.options.count,
            size: mapSizeToOpenAI(request.options.size),
            quality: mapQualityToOpenAI(request.options.quality),
            style: mapStyleToOpenAI(request.options.style),
            responseFormat: "url"
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
            
            let openAIResponse = try JSONDecoder().decode(OpenAIImageResponse.self, from: data)
            
            let images = try await downloadImages(from: openAIResponse.data, originalPrompt: request.prompt)
            
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
                    model: requestBody.model,
                    parameters: [
                        "size": requestBody.size,
                        "quality": requestBody.quality,
                        "style": requestBody.style
                    ]
                )
            )
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            logger.error("OpenAI image generation failed: \(error.localizedDescription)")
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Image Variations
    public func generateVariations(request: ImageVariationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        let url = URL(string: "\(baseURL)/images/variations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        // Add image data
        if let imageData = request.sourceImage.pngData() {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            formData.append(imageData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add parameters
        let parameters = [
            "n": "\(request.options.count)",
            "size": mapSizeToOpenAI(request.options.size),
            "response_format": "url"
        ]
        
        for (key, value) in parameters {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            formData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        urlRequest.httpBody = formData
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw ImageGenerationError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIImageResponse.self, from: data)
            
            let images = try await downloadImages(from: openAIResponse.data, originalPrompt: nil)
            
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
                    model: "dall-e-2", // Variations only work with DALL-E 2
                    parameters: [
                        "size": mapSizeToOpenAI(request.options.size),
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
    
    // MARK: - Image Editing
    public func editImage(request: ImageEditRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        let url = URL(string: "\(baseURL)/images/edits")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        // Add source image
        if let imageData = request.sourceImage.pngData() {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            formData.append(imageData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add mask image
        if let maskData = request.maskImage.pngData() {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"mask\"; filename=\"mask.png\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            formData.append(maskData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add parameters
        let parameters = [
            "prompt": request.prompt,
            "n": "1", // OpenAI editing only supports 1 image at a time
            "size": mapSizeToOpenAI(request.options.size),
            "response_format": "url"
        ]
        
        for (key, value) in parameters {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            formData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        urlRequest.httpBody = formData
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw ImageGenerationError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIImageResponse.self, from: data)
            
            let images = try await downloadImages(from: openAIResponse.data, originalPrompt: request.prompt)
            
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
                    model: "dall-e-2", // Editing only works with DALL-E 2
                    parameters: [
                        "size": mapSizeToOpenAI(request.options.size),
                        "edit": "true"
                    ]
                )
            )
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func determineModel(for options: ImageGenerationOptions) -> String {
        // DALL-E 3 for higher quality and newer features
        if options.quality == .hd || options.size == .xlarge || options.size == .xxlarge {
            return "dall-e-3"
        }
        // DALL-E 2 for standard usage
        return "dall-e-2"
    }
    
    private func mapSizeToOpenAI(_ size: ImageResolution) -> String {
        switch size {
        case .small:
            return "256x256"
        case .medium:
            return "512x512"
        case .large:
            return "1024x1024"
        case .xlarge:
            return "1792x1024" // DALL-E 3 supports non-square sizes
        case .xxlarge:
            return "1024x1792" // DALL-E 3 supports non-square sizes
        }
    }
    
    private func mapQualityToOpenAI(_ quality: ImageQuality) -> String {
        switch quality {
        case .standard:
            return "standard"
        case .hd, .ultra:
            return "hd"
        }
    }
    
    private func mapStyleToOpenAI(_ style: ImageStyle) -> String {
        switch style {
        case .natural, .photorealistic:
            return "natural"
        case .vivid, .artistic, .abstract:
            return "vivid"
        default:
            return "natural"
        }
    }
    
    private func downloadImages(from data: [OpenAIImageData], originalPrompt: String?) async throws -> [GeneratedImage] {
        var images: [GeneratedImage] = []
        
        for (index, imageData) in data.enumerated() {
            if let urlString = imageData.url {
                // For URL response, we store the URL and let the client decide whether to download
                let generatedImage = GeneratedImage(
                    imageData: nil,
                    imageURL: urlString,
                    size: parseSize(from: urlString),
                    format: .png,
                    quality: .standard,
                    prompt: originalPrompt,
                    revisedPrompt: imageData.revisedPrompt,
                    seed: nil
                )
                images.append(generatedImage)
            } else if let base64String = imageData.b64Json {
                // For base64 response, convert to data
                if let data = Data(base64Encoded: base64String) {
                    let generatedImage = GeneratedImage(
                        imageData: data,
                        imageURL: nil,
                        size: CGSize(width: 1024, height: 1024), // Default size
                        format: .png,
                        quality: .standard,
                        prompt: originalPrompt,
                        revisedPrompt: imageData.revisedPrompt,
                        seed: nil
                    )
                    images.append(generatedImage)
                }
            }
        }
        
        return images
    }
    
    private func parseSize(from urlString: String) -> CGSize {
        // Extract size information from URL if available
        // This is a simplified implementation
        return CGSize(width: 1024, height: 1024)
    }
    
    private func estimateCost(for options: ImageGenerationOptions) -> Double {
        // OpenAI DALL-E pricing (simplified)
        let basePrice: Double
        
        switch options.size {
        case .small:
            basePrice = 0.016 // $0.016 per image for 256x256
        case .medium:
            basePrice = 0.018 // $0.018 per image for 512x512
        case .large:
            basePrice = 0.020 // $0.020 per image for 1024x1024
        case .xlarge, .xxlarge:
            basePrice = 0.040 // $0.040 per image for HD
        }
        
        let qualityMultiplier = options.quality == .hd ? 2.0 : 1.0
        return basePrice * qualityMultiplier * Double(options.count)
    }
    
    private func estimateCost(for options: ImageVariationOptions) -> Double {
        // Variation pricing is typically lower than generation
        let basePrice = 0.018
        return basePrice * Double(options.count)
    }
    
    private func estimateCost(for options: ImageEditOptions) -> Double {
        // Edit pricing
        let basePrice = 0.020
        return basePrice // Only 1 image for edits
    }
}

// MARK: - OpenAI Request Types

private struct OpenAIImageGenerationRequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let size: String
    let quality: String
    let style: String
    let responseFormat: String
    
    enum CodingKeys: String, CodingKey {
        case model, prompt, n, size, quality, style
        case responseFormat = "response_format"
    }
}

// MARK: - OpenAI Response Types

private struct OpenAIImageResponse: Codable {
    let created: Int
    let data: [OpenAIImageData]
}

private struct OpenAIImageData: Codable {
    let url: String?
    let b64Json: String?
    let revisedPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case b64Json = "b64_json"
        case revisedPrompt = "revised_prompt"
    }
}
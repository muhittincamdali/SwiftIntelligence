import Foundation
import UIKit
import os.log

/// Stability AI image generation provider (Stable Diffusion)
public class StabilityAIProvider: ImageGenerationProvider {
    
    // MARK: - Properties
    public let name = "Stability AI"
    public let supportedFormats: [ImageFormat] = [.png, .jpeg, .webp]
    public let maxImageSize = CGSize(width: 2048, height: 2048)
    public let supportsTextToImage = true
    public let supportsImageVariations = true
    public let supportsImageEditing = true
    public let supportsStyleTransfer = false
    public let supportsUpscaling = true
    public let isLocal = false
    
    private let apiKey: String
    private let baseURL: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "StabilityAI")
    
    private let supportedEngines = [
        "stable-diffusion-xl-1024-v1-0",
        "stable-diffusion-v1-6",
        "stable-diffusion-512-v2-1",
        "esrgan-v1-x2plus"
    ]
    
    // MARK: - Initialization
    public init(apiKey: String, baseURL: String = "https://api.stability.ai/v1") {
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
        
        let engine = determineEngine(for: request.options)
        let url = URL(string: "\(baseURL)/generation/\(engine)/text-to-image")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/vnd.stability.client.v1+json", forHTTPHeaderField: "Accept")
        
        let requestBody = StabilityAIGenerationRequest(
            textPrompts: [
                StabilityAITextPrompt(text: request.prompt, weight: 1.0),
                StabilityAITextPrompt(text: request.options.negativePrompt ?? "blurry, low quality", weight: -1.0)
            ].compactMap { $0.text.isEmpty ? nil : $0 },
            width: Int(request.options.size.size.width),
            height: Int(request.options.size.size.height),
            cfgScale: request.options.guidance,
            steps: request.options.steps,
            samples: request.options.count,
            seed: request.options.seed,
            stylePreset: mapStyleToStabilityAI(request.options.style)
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
                   let message = errorData["message"] as? String {
                    throw ImageGenerationError.invalidPrompt(message)
                }
                throw ImageGenerationError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let stabilityResponse = try JSONDecoder().decode(StabilityAIResponse.self, from: data)
            
            let images = stabilityResponse.artifacts.compactMap { artifact -> GeneratedImage? in
                guard let imageData = Data(base64Encoded: artifact.base64) else { return nil }
                
                return GeneratedImage(
                    imageData: imageData,
                    imageURL: nil,
                    size: request.options.size.size,
                    format: .png,
                    quality: request.options.quality,
                    prompt: request.prompt,
                    revisedPrompt: nil,
                    seed: artifact.seed
                )
            }
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return ImageGenerationResult(
                images: images,
                usage: ImageGenerationTokenUsage(
                    imagesGenerated: images.count,
                    processingTime: processingTime,
                    providerCost: estimateCost(for: request.options, engine: engine)
                ),
                processingTime: processingTime,
                metadata: ImageGenerationMetadata(
                    provider: name,
                    model: engine,
                    parameters: [
                        "cfg_scale": "\(request.options.guidance)",
                        "steps": "\(request.options.steps)",
                        "style_preset": mapStyleToStabilityAI(request.options.style) ?? "none"
                    ]
                )
            )
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            logger.error("Stability AI generation failed: \(error.localizedDescription)")
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Image Variations
    public func generateVariations(request: ImageVariationRequest) async throws -> ImageGenerationResult {
        let startTime = Date()
        
        let engine = determineEngineForVariations()
        let url = URL(string: "\(baseURL)/generation/\(engine)/image-to-image")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/vnd.stability.client.v1+json", forHTTPHeaderField: "Accept")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        // Add init image
        if let imageData = request.sourceImage.jpegData(compressionQuality: 0.9) {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"init_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            formData.append(imageData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add text prompts
        let textPrompts = [
            ["text": "variation", "weight": "1.0"]
        ]
        
        for (index, prompt) in textPrompts.enumerated() {
            for (key, value) in prompt {
                formData.append("--\(boundary)\r\n".data(using: .utf8)!)
                formData.append("Content-Disposition: form-data; name=\"text_prompts[\(index)][\(key)]\"\r\n\r\n".data(using: .utf8)!)
                formData.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add other parameters
        let parameters = [
            "image_strength": "\(1.0 - request.options.similarityStrength)",
            "cfg_scale": "7.0",
            "steps": "30",
            "samples": "\(request.options.count)"
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
            
            let stabilityResponse = try JSONDecoder().decode(StabilityAIResponse.self, from: data)
            
            let images = stabilityResponse.artifacts.compactMap { artifact -> GeneratedImage? in
                guard let imageData = Data(base64Encoded: artifact.base64) else { return nil }
                
                return GeneratedImage(
                    imageData: imageData,
                    imageURL: nil,
                    size: request.sourceImage.size,
                    format: .png,
                    quality: request.options.quality,
                    prompt: nil,
                    revisedPrompt: nil,
                    seed: artifact.seed
                )
            }
            
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
                    model: engine,
                    parameters: [
                        "image_strength": "\(1.0 - request.options.similarityStrength)",
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
        
        let engine = determineEngineForEditing()
        let url = URL(string: "\(baseURL)/generation/\(engine)/image-to-image/masking")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/vnd.stability.client.v1+json", forHTTPHeaderField: "Accept")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        // Add init image
        if let imageData = request.sourceImage.jpegData(compressionQuality: 0.9) {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"init_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            formData.append(imageData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add mask image
        if let maskData = request.maskImage.jpegData(compressionQuality: 0.9) {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"mask_image\"; filename=\"mask.jpg\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            formData.append(maskData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add text prompts
        let textPrompts = [
            ["text": request.prompt, "weight": "1.0"]
        ]
        
        for (index, prompt) in textPrompts.enumerated() {
            for (key, value) in prompt {
                formData.append("--\(boundary)\r\n".data(using: .utf8)!)
                formData.append("Content-Disposition: form-data; name=\"text_prompts[\(index)][\(key)]\"\r\n\r\n".data(using: .utf8)!)
                formData.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add parameters
        let parameters = [
            "mask_source": "MASK_IMAGE_BLACK",
            "cfg_scale": "\(request.options.guidance)",
            "steps": "\(request.options.steps)",
            "samples": "1"
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
            
            let stabilityResponse = try JSONDecoder().decode(StabilityAIResponse.self, from: data)
            
            let images = stabilityResponse.artifacts.compactMap { artifact -> GeneratedImage? in
                guard let imageData = Data(base64Encoded: artifact.base64) else { return nil }
                
                return GeneratedImage(
                    imageData: imageData,
                    imageURL: nil,
                    size: request.sourceImage.size,
                    format: .png,
                    quality: request.options.quality,
                    prompt: request.prompt,
                    revisedPrompt: nil,
                    seed: artifact.seed
                )
            }
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return ImageGenerationResult(
                images: images,
                usage: ImageGenerationTokenUsage(
                    imagesGenerated: images.count,
                    processingTime: processingTime,
                    providerCost: estimateEditCost()
                ),
                processingTime: processingTime,
                metadata: ImageGenerationMetadata(
                    provider: name,
                    model: engine,
                    parameters: [
                        "mask_source": "MASK_IMAGE_BLACK",
                        "cfg_scale": "\(request.options.guidance)",
                        "steps": "\(request.options.steps)"
                    ]
                )
            )
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Upscaling
    public func upscaleImage(_ image: UIImage, scaleFactor: Float = 2.0) async throws -> UIImage {
        let url = URL(string: "\(baseURL)/generation/esrgan-v1-x2plus/image-to-image/upscale")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/vnd.stability.client.v1+json", forHTTPHeaderField: "Accept")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        // Add image
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            formData.append(imageData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Add width parameter
        let targetWidth = Int(image.size.width * CGFloat(scaleFactor))
        formData.append("--\(boundary)\r\n".data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"width\"\r\n\r\n".data(using: .utf8)!)
        formData.append("\(targetWidth)\r\n".data(using: .utf8)!)
        
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
            
            let stabilityResponse = try JSONDecoder().decode(StabilityAIResponse.self, from: data)
            
            if let artifact = stabilityResponse.artifacts.first,
               let imageData = Data(base64Encoded: artifact.base64),
               let upscaledImage = UIImage(data: imageData) {
                return upscaledImage
            } else {
                throw ImageGenerationError.imageProcessingFailed("Failed to process upscaled image")
            }
            
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func determineEngine(for options: ImageGenerationOptions) -> String {
        // Choose engine based on size and quality requirements
        if options.size == .xlarge || options.size == .xxlarge || options.quality == .hd {
            return "stable-diffusion-xl-1024-v1-0"
        } else if options.size == .large {
            return "stable-diffusion-v1-6"
        } else {
            return "stable-diffusion-512-v2-1"
        }
    }
    
    private func determineEngineForVariations() -> String {
        return "stable-diffusion-v1-6"
    }
    
    private func determineEngineForEditing() -> String {
        return "stable-diffusion-v1-6"
    }
    
    private func mapStyleToStabilityAI(_ style: ImageStyle) -> String? {
        switch style {
        case .photorealistic:
            return "photographic"
        case .artistic:
            return "digital-art"
        case .anime:
            return "anime"
        case .abstract:
            return "abstract"
        case .cartoon:
            return "comic-book"
        default:
            return nil
        }
    }
    
    private func estimateCost(for options: ImageGenerationOptions, engine: String) -> Double {
        // Stability AI pricing varies by engine and image size
        let baseCost: Double
        
        switch engine {
        case "stable-diffusion-xl-1024-v1-0":
            baseCost = 0.04 // $0.04 per image
        case "stable-diffusion-v1-6":
            baseCost = 0.02 // $0.02 per image
        case "stable-diffusion-512-v2-1":
            baseCost = 0.015 // $0.015 per image
        default:
            baseCost = 0.02
        }
        
        return baseCost * Double(options.count)
    }
    
    private func estimateVariationCost(for options: ImageVariationOptions) -> Double {
        return 0.025 * Double(options.count)
    }
    
    private func estimateEditCost() -> Double {
        return 0.03 // $0.03 per edit
    }
}

// MARK: - Stability AI Request Types

private struct StabilityAIGenerationRequest: Codable {
    let textPrompts: [StabilityAITextPrompt]
    let width: Int
    let height: Int
    let cfgScale: Double
    let steps: Int
    let samples: Int
    let seed: Int?
    let stylePreset: String?
    
    enum CodingKeys: String, CodingKey {
        case textPrompts = "text_prompts"
        case width, height
        case cfgScale = "cfg_scale"
        case steps, samples, seed
        case stylePreset = "style_preset"
    }
}

private struct StabilityAITextPrompt: Codable {
    let text: String
    let weight: Double
}

// MARK: - Stability AI Response Types

private struct StabilityAIResponse: Codable {
    let artifacts: [StabilityAIArtifact]
}

private struct StabilityAIArtifact: Codable {
    let base64: String
    let seed: Int
    let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case base64, seed
        case finishReason = "finishReason"
    }
}
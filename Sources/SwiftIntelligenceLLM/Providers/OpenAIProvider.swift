import Foundation
import Network
import os.log

/// OpenAI API provider implementation
public class OpenAIProvider: LLMProvider {
    
    // MARK: - Properties
    public let name = "OpenAI"
    public let supportedModels = [
        "gpt-4", "gpt-4-turbo", "gpt-4-turbo-preview",
        "gpt-3.5-turbo", "gpt-3.5-turbo-16k",
        "text-davinci-003", "text-davinci-002",
        "code-davinci-002", "code-cushman-001"
    ]
    
    public let supportsChatCompletion = true
    public let supportsStreaming = true
    public let supportsEmbeddings = true
    public let supportsModeration = true
    public let supportsImageGeneration = true
    public let isLocal = false
    
    private let apiKey: String
    private let organizationID: String?
    private let baseURL: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "OpenAI")
    
    // MARK: - Initialization
    public init(apiKey: String, baseURL: String = "https://api.openai.com/v1", organizationID: String? = nil) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.organizationID = organizationID
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 300.0
        self.urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Chat Completion
    public func chatCompletion(request: LLMRequest) async throws -> LLMResponse {
        let startTime = Date()
        
        guard supportedModels.contains(request.model) else {
            throw LLMError.modelNotFound(request.model)
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        if let orgID = organizationID {
            urlRequest.setValue(orgID, forHTTPHeaderField: "OpenAI-Organization")
        }
        
        let requestBody = OpenAIChatRequest(
            model: request.model,
            messages: request.messages.map { OpenAIMessage(role: $0.role.rawValue, content: $0.content) },
            temperature: request.options.temperature,
            maxTokens: request.options.maxTokens,
            topP: request.options.topP,
            frequencyPenalty: request.options.frequencyPenalty,
            presencePenalty: request.options.presencePenalty,
            stop: request.options.stopSequences.isEmpty ? nil : request.options.stopSequences
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode == 429 {
                throw LLMError.rateLimitExceeded
            }
            
            if httpResponse.statusCode == 401 {
                throw LLMError.unauthorizedAccess
            }
            
            if httpResponse.statusCode != 200 {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw LLMError.invalidRequest(message)
                }
                throw LLMError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            
            let choices = openAIResponse.choices.map { choice in
                LLMChoice(
                    index: choice.index,
                    message: LLMMessage(
                        role: LLMMessage.Role(rawValue: choice.message.role) ?? .assistant,
                        content: choice.message.content ?? ""
                    ),
                    finishReason: choice.finishReason.flatMap { LLMChoice.FinishReason(rawValue: $0) }
                )
            }
            
            let usage = LLMTokenUsage(
                promptTokens: openAIResponse.usage.promptTokens,
                completionTokens: openAIResponse.usage.completionTokens
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return LLMResponse(
                id: openAIResponse.id,
                choices: choices,
                usage: usage,
                model: openAIResponse.model,
                processingTime: processingTime
            )
            
        } catch let error as LLMError {
            throw error
        } catch {
            logger.error("OpenAI request failed: \(error.localizedDescription)")
            throw LLMError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Streaming Chat Completion
    public func streamingChatCompletion(request: LLMRequest) -> AsyncThrowingStream<LLMStreamingResponse, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard supportedModels.contains(request.model) else {
                        continuation.finish(throwing: LLMError.modelNotFound(request.model))
                        return
                    }
                    
                    let url = URL(string: "\(baseURL)/chat/completions")!
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    
                    if let orgID = organizationID {
                        urlRequest.setValue(orgID, forHTTPHeaderField: "OpenAI-Organization")
                    }
                    
                    let requestBody = OpenAIChatRequest(
                        model: request.model,
                        messages: request.messages.map { OpenAIMessage(role: $0.role.rawValue, content: $0.content) },
                        temperature: request.options.temperature,
                        maxTokens: request.options.maxTokens,
                        topP: request.options.topP,
                        frequencyPenalty: request.options.frequencyPenalty,
                        presencePenalty: request.options.presencePenalty,
                        stop: request.options.stopSequences.isEmpty ? nil : request.options.stopSequences,
                        stream: true
                    )
                    
                    let jsonData = try JSONEncoder().encode(requestBody)
                    urlRequest.httpBody = jsonData
                    
                    let (asyncBytes, response) = try await urlSession.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: LLMError.networkError("Invalid response type"))
                        return
                    }
                    
                    if httpResponse.statusCode != 200 {
                        continuation.finish(throwing: LLMError.networkError("HTTP \(httpResponse.statusCode)"))
                        return
                    }
                    
                    var buffer = ""
                    for try await byte in asyncBytes {
                        buffer.append(Character(UnicodeScalar(byte)!))
                        
                        // Process complete lines
                        while let newlineIndex = buffer.firstIndex(of: "\n") {
                            let line = String(buffer[..<newlineIndex])
                            buffer.removeSubrange(...newlineIndex)
                            
                            // Skip empty lines and non-data lines
                            if line.isEmpty || !line.hasPrefix("data: ") {
                                continue
                            }
                            
                            let jsonString = String(line.dropFirst(6)) // Remove "data: " prefix
                            
                            // Check for stream end
                            if jsonString.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                                continuation.finish()
                                return
                            }
                            
                            // Parse streaming response
                            if let jsonData = jsonString.data(using: .utf8) {
                                do {
                                    let streamResponse = try JSONDecoder().decode(OpenAIStreamingResponse.self, from: jsonData)
                                    
                                    let streamingChoices = streamResponse.choices.map { choice in
                                        LLMStreamingChoice(
                                            index: choice.index,
                                            delta: LLMDelta(
                                                role: choice.delta.role.flatMap { LLMMessage.Role(rawValue: $0) },
                                                content: choice.delta.content
                                            ),
                                            finishReason: choice.finishReason.flatMap { LLMChoice.FinishReason(rawValue: $0) }
                                        )
                                    }
                                    
                                    let response = LLMStreamingResponse(
                                        id: streamResponse.id,
                                        choices: streamingChoices,
                                        model: streamResponse.model
                                    )
                                    
                                    continuation.yield(response)
                                } catch {
                                    // Ignore malformed chunks but log them
                                    logger.warning("Failed to parse streaming chunk: \(jsonString)")
                                }
                            }
                        }
                    }
                    
                    continuation.finish()
                    
                } catch {
                    continuation.finish(throwing: LLMError.networkError(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Embeddings
    public func generateEmbeddings(request: LLMEmbeddingRequest) async throws -> LLMEmbeddingResponse {
        let url = URL(string: "\(baseURL)/embeddings")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        if let orgID = organizationID {
            urlRequest.setValue(orgID, forHTTPHeaderField: "OpenAI-Organization")
        }
        
        let requestBody = OpenAIEmbeddingRequest(
            model: request.model,
            input: request.texts
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw LLMError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIEmbeddingResponse.self, from: data)
            
            let embeddings = openAIResponse.data.enumerated().map { index, embedding in
                LLMEmbedding(
                    index: embedding.index,
                    embedding: embedding.embedding,
                    text: request.texts[safe: index] ?? ""
                )
            }
            
            let usage = LLMTokenUsage(
                promptTokens: openAIResponse.usage.promptTokens,
                completionTokens: 0
            )
            
            return LLMEmbeddingResponse(
                embeddings: embeddings,
                usage: usage,
                model: request.model
            )
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Moderation
    public func moderateContent(request: LLMModerationRequest) async throws -> LLMModerationResponse {
        let url = URL(string: "\(baseURL)/moderations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = OpenAIModerationRequest(input: request.input)
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw LLMError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIModerationResponse.self, from: data)
            
            if let result = openAIResponse.results.first {
                return LLMModerationResponse(
                    flagged: result.flagged,
                    categories: LLMModerationResponse.ModerationCategories(
                        hate: result.categories.hate,
                        hateThreatening: result.categories.hateThreatening,
                        harassment: result.categories.harassment,
                        harassmentThreatening: result.categories.harassmentThreatening,
                        selfHarm: result.categories.selfHarm,
                        selfHarmIntent: result.categories.selfHarmIntent,
                        selfHarmInstructions: result.categories.selfHarmInstructions,
                        sexual: result.categories.sexual,
                        sexualMinors: result.categories.sexualMinors,
                        violence: result.categories.violence,
                        violenceGraphic: result.categories.violenceGraphic
                    ),
                    categoryScores: LLMModerationResponse.ModerationScores(
                        hate: result.categoryScores.hate,
                        hateThreatening: result.categoryScores.hateThreatening,
                        harassment: result.categoryScores.harassment,
                        harassmentThreatening: result.categoryScores.harassmentThreatening,
                        selfHarm: result.categoryScores.selfHarm,
                        selfHarmIntent: result.categoryScores.selfHarmIntent,
                        selfHarmInstructions: result.categoryScores.selfHarmInstructions,
                        sexual: result.categoryScores.sexual,
                        sexualMinors: result.categoryScores.sexualMinors,
                        violence: result.categoryScores.violence,
                        violenceGraphic: result.categoryScores.violenceGraphic
                    )
                )
            } else {
                throw LLMError.responseParsingError
            }
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Image Generation
    public func generateImage(request: LLMImageRequest) async throws -> LLMImageResponse {
        let startTime = Date()
        
        let url = URL(string: "\(baseURL)/images/generations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = OpenAIImageRequest(
            prompt: request.prompt,
            n: request.options.n,
            size: request.options.size.rawValue,
            quality: request.options.quality.rawValue,
            style: request.options.style.rawValue,
            responseFormat: request.options.responseFormat.rawValue
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.networkError("Invalid response type")
            }
            
            if httpResponse.statusCode != 200 {
                throw LLMError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIImageResponse.self, from: data)
            
            let images = openAIResponse.data.map { imageData in
                LLMImage(
                    url: imageData.url,
                    data: imageData.b64Json?.data(using: .utf8),
                    revisedPrompt: imageData.revisedPrompt
                )
            }
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return LLMImageResponse(
                images: images,
                usage: nil, // OpenAI doesn't return usage for image generation
                processingTime: processingTime
            )
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - OpenAI Request Types

private struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int?
    let topP: Double
    let frequencyPenalty: Double
    let presencePenalty: Double
    let stop: [String]?
    let stream: Bool
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
        case stop, stream
    }
    
    init(
        model: String,
        messages: [OpenAIMessage],
        temperature: Double,
        maxTokens: Int?,
        topP: Double,
        frequencyPenalty: Double,
        presencePenalty: Double,
        stop: [String]?,
        stream: Bool = false
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.stop = stop
        self.stream = stream
    }
}

private struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

private struct OpenAIEmbeddingRequest: Codable {
    let model: String
    let input: [String]
}

private struct OpenAIModerationRequest: Codable {
    let input: String
}

private struct OpenAIImageRequest: Codable {
    let prompt: String
    let n: Int
    let size: String
    let quality: String
    let style: String
    let responseFormat: String
    
    enum CodingKeys: String, CodingKey {
        case prompt, n, size, quality, style
        case responseFormat = "response_format"
    }
}

// MARK: - OpenAI Response Types

private struct OpenAIChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}

private struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIResponseMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

private struct OpenAIResponseMessage: Codable {
    let role: String
    let content: String?
}

private struct OpenAIStreamingResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIStreamingChoice]
}

private struct OpenAIStreamingChoice: Codable {
    let index: Int
    let delta: OpenAIDelta
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, delta
        case finishReason = "finish_reason"
    }
}

private struct OpenAIDelta: Codable {
    let role: String?
    let content: String?
}

private struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

private struct OpenAIEmbeddingResponse: Codable {
    let object: String
    let data: [OpenAIEmbeddingData]
    let model: String
    let usage: OpenAIUsage
}

private struct OpenAIEmbeddingData: Codable {
    let object: String
    let embedding: [Double]
    let index: Int
}

private struct OpenAIModerationResponse: Codable {
    let id: String
    let model: String
    let results: [OpenAIModerationResult]
}

private struct OpenAIModerationResult: Codable {
    let flagged: Bool
    let categories: OpenAIModerationCategories
    let categoryScores: OpenAIModerationScores
    
    enum CodingKeys: String, CodingKey {
        case flagged, categories
        case categoryScores = "category_scores"
    }
}

private struct OpenAIModerationCategories: Codable {
    let hate: Bool
    let hateThreatening: Bool
    let harassment: Bool
    let harassmentThreatening: Bool
    let selfHarm: Bool
    let selfHarmIntent: Bool
    let selfHarmInstructions: Bool
    let sexual: Bool
    let sexualMinors: Bool
    let violence: Bool
    let violenceGraphic: Bool
    
    enum CodingKeys: String, CodingKey {
        case hate
        case hateThreatening = "hate/threatening"
        case harassment
        case harassmentThreatening = "harassment/threatening"
        case selfHarm = "self-harm"
        case selfHarmIntent = "self-harm/intent"
        case selfHarmInstructions = "self-harm/instructions"
        case sexual
        case sexualMinors = "sexual/minors"
        case violence
        case violenceGraphic = "violence/graphic"
    }
}

private struct OpenAIModerationScores: Codable {
    let hate: Double
    let hateThreatening: Double
    let harassment: Double
    let harassmentThreatening: Double
    let selfHarm: Double
    let selfHarmIntent: Double
    let selfHarmInstructions: Double
    let sexual: Double
    let sexualMinors: Double
    let violence: Double
    let violenceGraphic: Double
    
    enum CodingKeys: String, CodingKey {
        case hate
        case hateThreatening = "hate/threatening"
        case harassment
        case harassmentThreatening = "harassment/threatening"
        case selfHarm = "self-harm"
        case selfHarmIntent = "self-harm/intent"
        case selfHarmInstructions = "self-harm/instructions"
        case sexual
        case sexualMinors = "sexual/minors"
        case violence
        case violenceGraphic = "violence/graphic"
    }
}

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

// MARK: - Extensions

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
import Foundation
import Network
import os.log

/// Anthropic Claude API provider implementation
public class AnthropicProvider: LLMProvider {
    
    // MARK: - Properties
    public let name = "Anthropic"
    public let supportedModels = [
        "claude-3-opus-20240229",
        "claude-3-sonnet-20240229",
        "claude-3-haiku-20240307",
        "claude-2.1",
        "claude-2.0",
        "claude-instant-1.2"
    ]
    
    public let supportsChatCompletion = true
    public let supportsStreaming = true
    public let supportsEmbeddings = false
    public let supportsModeration = false
    public let supportsImageGeneration = false
    public let isLocal = false
    
    private let apiKey: String
    private let baseURL: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Anthropic")
    
    // MARK: - Initialization
    public init(apiKey: String, baseURL: String = "https://api.anthropic.com/v1") {
        self.apiKey = apiKey
        self.baseURL = baseURL
        
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
        
        let url = URL(string: "\(baseURL)/messages")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let requestBody = try createAnthropicRequest(from: request)
        
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
            
            let anthropicResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
            
            let choices = anthropicResponse.content.enumerated().map { index, content in
                LLMChoice(
                    index: index,
                    message: LLMMessage(
                        role: .assistant,
                        content: content.text
                    ),
                    finishReason: mapAnthropicStopReason(anthropicResponse.stopReason)
                )
            }
            
            let usage = LLMTokenUsage(
                promptTokens: anthropicResponse.usage.inputTokens,
                completionTokens: anthropicResponse.usage.outputTokens
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return LLMResponse(
                id: anthropicResponse.id,
                choices: choices,
                usage: usage,
                model: anthropicResponse.model,
                processingTime: processingTime
            )
            
        } catch let error as LLMError {
            throw error
        } catch {
            logger.error("Anthropic request failed: \(error.localizedDescription)")
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
                    
                    let url = URL(string: "\(baseURL)/messages")!
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                    urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
                    
                    var requestBody = try self.createAnthropicRequest(from: request)
                    requestBody.stream = true
                    
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
                            
                            // Skip empty lines and non-event lines
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
                                    let streamEvent = try JSONDecoder().decode(AnthropicStreamEvent.self, from: jsonData)
                                    
                                    switch streamEvent.type {
                                    case "content_block_delta":
                                        if let delta = streamEvent.delta,
                                           let text = delta.text {
                                            let streamingChoice = LLMStreamingChoice(
                                                index: streamEvent.index ?? 0,
                                                delta: LLMDelta(role: nil, content: text),
                                                finishReason: nil
                                            )
                                            
                                            let response = LLMStreamingResponse(
                                                id: "anthropic-stream",
                                                choices: [streamingChoice],
                                                model: request.model
                                            )
                                            
                                            continuation.yield(response)
                                        }
                                    case "message_stop":
                                        continuation.finish()
                                        return
                                    default:
                                        // Handle other event types as needed
                                        continue
                                    }
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
    
    // MARK: - Embeddings (Not Supported)
    public func generateEmbeddings(request: LLMEmbeddingRequest) async throws -> LLMEmbeddingResponse {
        throw LLMError.featureNotSupported("embeddings")
    }
    
    // MARK: - Moderation (Not Supported)
    public func moderateContent(request: LLMModerationRequest) async throws -> LLMModerationResponse {
        throw LLMError.featureNotSupported("moderation")
    }
    
    // MARK: - Image Generation (Not Supported)
    public func generateImage(request: LLMImageRequest) async throws -> LLMImageResponse {
        throw LLMError.featureNotSupported("image_generation")
    }
    
    // MARK: - Private Helper Methods
    
    private func createAnthropicRequest(from request: LLMRequest) throws -> AnthropicRequest {
        var systemMessage = ""
        var messages: [AnthropicMessage] = []
        
        for message in request.messages {
            switch message.role {
            case .system:
                // Anthropic uses system parameter instead of system messages
                systemMessage = message.content
            case .user, .assistant:
                messages.append(AnthropicMessage(
                    role: message.role.rawValue,
                    content: message.content
                ))
            case .function:
                // Anthropic doesn't support function messages in the same way
                // Convert to user message with function context
                messages.append(AnthropicMessage(
                    role: "user",
                    content: "Function result: \(message.content)"
                ))
            }
        }
        
        return AnthropicRequest(
            model: request.model,
            maxTokens: request.options.maxTokens ?? 4096,
            system: systemMessage.isEmpty ? nil : systemMessage,
            messages: messages,
            temperature: request.options.temperature,
            topP: request.options.topP,
            stopSequences: request.options.stopSequences.isEmpty ? nil : request.options.stopSequences,
            stream: false
        )
    }
    
    private func mapAnthropicStopReason(_ stopReason: String?) -> LLMChoice.FinishReason? {
        guard let stopReason = stopReason else { return nil }
        
        switch stopReason {
        case "end_turn":
            return .stop
        case "max_tokens":
            return .length
        case "stop_sequence":
            return .stop
        default:
            return .stop
        }
    }
}

// MARK: - Anthropic Request Types

private struct AnthropicRequest: Codable {
    let model: String
    let maxTokens: Int
    let system: String?
    let messages: [AnthropicMessage]
    let temperature: Double
    let topP: Double
    let stopSequences: [String]?
    var stream: Bool
    
    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system, messages, temperature
        case topP = "top_p"
        case stopSequences = "stop_sequences"
        case stream
    }
    
    init(
        model: String,
        maxTokens: Int,
        system: String?,
        messages: [AnthropicMessage],
        temperature: Double,
        topP: Double,
        stopSequences: [String]?,
        stream: Bool
    ) {
        self.model = model
        self.maxTokens = maxTokens
        self.system = system
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.stopSequences = stopSequences
        self.stream = stream
    }
}

private struct AnthropicMessage: Codable {
    let role: String
    let content: String
}

// MARK: - Anthropic Response Types

private struct AnthropicResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [AnthropicContent]
    let model: String
    let stopReason: String?
    let stopSequence: String?
    let usage: AnthropicUsage
    
    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
        case usage
    }
}

private struct AnthropicContent: Codable {
    let type: String
    let text: String
}

private struct AnthropicUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

private struct AnthropicStreamEvent: Codable {
    let type: String
    let index: Int?
    let delta: AnthropicDelta?
}

private struct AnthropicDelta: Codable {
    let type: String?
    let text: String?
}
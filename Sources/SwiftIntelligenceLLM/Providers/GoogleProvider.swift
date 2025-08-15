import Foundation
import Network
import os.log

/// Google Gemini API provider implementation
public class GoogleProvider: LLMProvider {
    
    // MARK: - Properties
    public let name = "Google"
    public let supportedModels = [
        "gemini-pro",
        "gemini-pro-vision",
        "gemini-ultra",
        "text-bison-001",
        "text-bison-002",
        "chat-bison-001",
        "chat-bison-002"
    ]
    
    public let supportsChatCompletion = true
    public let supportsStreaming = true
    public let supportsEmbeddings = true
    public let supportsModeration = false
    public let supportsImageGeneration = false
    public let isLocal = false
    
    private let apiKey: String
    private let baseURL: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Google")
    
    // MARK: - Initialization
    public init(apiKey: String, baseURL: String = "https://generativelanguage.googleapis.com/v1") {
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
        
        let url = URL(string: "\(baseURL)/models/\(request.model):generateContent?key=\(apiKey)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = createGoogleRequest(from: request)
        
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
            
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
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
            
            let googleResponse = try JSONDecoder().decode(GoogleResponse.self, from: data)
            
            let choices = googleResponse.candidates.enumerated().map { index, candidate in
                LLMChoice(
                    index: index,
                    message: LLMMessage(
                        role: .assistant,
                        content: candidate.content.parts.first?.text ?? ""
                    ),
                    finishReason: mapGoogleFinishReason(candidate.finishReason)
                )
            }
            
            // Google doesn't always return usage information
            let usage = LLMTokenUsage(
                promptTokens: googleResponse.usageMetadata?.promptTokenCount ?? 0,
                completionTokens: googleResponse.usageMetadata?.candidatesTokenCount ?? 0
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return LLMResponse(
                id: "google-\(UUID().uuidString)",
                choices: choices,
                usage: usage,
                model: request.model,
                processingTime: processingTime
            )
            
        } catch let error as LLMError {
            throw error
        } catch {
            logger.error("Google request failed: \(error.localizedDescription)")
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
                    
                    let url = URL(string: "\(baseURL)/models/\(request.model):streamGenerateContent?key=\(apiKey)")!
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let requestBody = self.createGoogleRequest(from: request)
                    
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
                        
                        // Process complete lines (Google uses different streaming format)
                        while let newlineIndex = buffer.firstIndex(of: "\n") {
                            let line = String(buffer[..<newlineIndex])
                            buffer.removeSubrange(...newlineIndex)
                            
                            // Skip empty lines
                            if line.isEmpty || line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                continue
                            }
                            
                            // Parse streaming response
                            if let jsonData = line.data(using: .utf8) {
                                do {
                                    let streamResponse = try JSONDecoder().decode(GoogleResponse.self, from: jsonData)
                                    
                                    if let candidate = streamResponse.candidates.first,
                                       let text = candidate.content.parts.first?.text {
                                        
                                        let streamingChoice = LLMStreamingChoice(
                                            index: 0,
                                            delta: LLMDelta(role: nil, content: text),
                                            finishReason: mapGoogleFinishReason(candidate.finishReason)
                                        )
                                        
                                        let response = LLMStreamingResponse(
                                            id: "google-stream",
                                            choices: [streamingChoice],
                                            model: request.model
                                        )
                                        
                                        continuation.yield(response)
                                        
                                        // Check if this is the final chunk
                                        if candidate.finishReason != nil {
                                            continuation.finish()
                                            return
                                        }
                                    }
                                } catch {
                                    // Ignore malformed chunks but log them
                                    logger.warning("Failed to parse streaming chunk: \(line)")
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
        let url = URL(string: "\(baseURL)/models/embedding-001:embedContent?key=\(apiKey)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var embeddings: [LLMEmbedding] = []
        
        // Process texts individually as Google's API typically handles one at a time
        for (index, text) in request.texts.enumerated() {
            let requestBody = GoogleEmbeddingRequest(
                model: request.model,
                content: GoogleEmbeddingContent(parts: [GoogleEmbeddingPart(text: text)])
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
                
                let googleResponse = try JSONDecoder().decode(GoogleEmbeddingResponse.self, from: data)
                
                if let embedding = googleResponse.embedding?.values {
                    embeddings.append(LLMEmbedding(
                        index: index,
                        embedding: embedding,
                        text: text
                    ))
                }
                
            } catch let error as LLMError {
                throw error
            } catch {
                throw LLMError.networkError(error.localizedDescription)
            }
        }
        
        let usage = LLMTokenUsage(
            promptTokens: request.texts.reduce(0) { $0 + $1.count / 4 }, // Rough estimate
            completionTokens: 0
        )
        
        return LLMEmbeddingResponse(
            embeddings: embeddings,
            usage: usage,
            model: request.model
        )
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
    
    private func createGoogleRequest(from request: LLMRequest) -> GoogleRequest {
        var contents: [GoogleContent] = []
        
        for message in request.messages {
            // Google uses different role names
            let role = mapLLMRoleToGoogleRole(message.role)
            
            // Skip system messages or convert them to user messages with context
            if message.role == .system {
                contents.append(GoogleContent(
                    role: "user",
                    parts: [GooglePart(text: "System: \(message.content)")]
                ))
            } else {
                contents.append(GoogleContent(
                    role: role,
                    parts: [GooglePart(text: message.content)]
                ))
            }
        }
        
        let generationConfig = GoogleGenerationConfig(
            temperature: request.options.temperature,
            topP: request.options.topP,
            maxOutputTokens: request.options.maxTokens,
            stopSequences: request.options.stopSequences.isEmpty ? nil : request.options.stopSequences
        )
        
        return GoogleRequest(
            contents: contents,
            generationConfig: generationConfig
        )
    }
    
    private func mapLLMRoleToGoogleRole(_ role: LLMMessage.Role) -> String {
        switch role {
        case .user:
            return "user"
        case .assistant:
            return "model"
        case .system:
            return "user" // Google doesn't have system role, convert to user
        case .function:
            return "function" // Google supports function role in some contexts
        }
    }
    
    private func mapGoogleFinishReason(_ finishReason: String?) -> LLMChoice.FinishReason? {
        guard let finishReason = finishReason else { return nil }
        
        switch finishReason {
        case "STOP":
            return .stop
        case "MAX_TOKENS":
            return .length
        case "SAFETY":
            return .contentFilter
        case "RECITATION":
            return .contentFilter
        default:
            return .stop
        }
    }
}

// MARK: - Google Request Types

private struct GoogleRequest: Codable {
    let contents: [GoogleContent]
    let generationConfig: GoogleGenerationConfig
}

private struct GoogleContent: Codable {
    let role: String
    let parts: [GooglePart]
}

private struct GooglePart: Codable {
    let text: String
}

private struct GoogleGenerationConfig: Codable {
    let temperature: Double
    let topP: Double
    let maxOutputTokens: Int?
    let stopSequences: [String]?
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case topP = "topP"
        case maxOutputTokens = "maxOutputTokens"
        case stopSequences = "stopSequences"
    }
}

private struct GoogleEmbeddingRequest: Codable {
    let model: String
    let content: GoogleEmbeddingContent
}

private struct GoogleEmbeddingContent: Codable {
    let parts: [GoogleEmbeddingPart]
}

private struct GoogleEmbeddingPart: Codable {
    let text: String
}

// MARK: - Google Response Types

private struct GoogleResponse: Codable {
    let candidates: [GoogleCandidate]
    let usageMetadata: GoogleUsageMetadata?
}

private struct GoogleCandidate: Codable {
    let content: GoogleContent
    let finishReason: String?
    let safetyRatings: [GoogleSafetyRating]?
}

private struct GoogleUsageMetadata: Codable {
    let promptTokenCount: Int
    let candidatesTokenCount: Int
    let totalTokenCount: Int
}

private struct GoogleSafetyRating: Codable {
    let category: String
    let probability: String
}

private struct GoogleEmbeddingResponse: Codable {
    let embedding: GoogleEmbedding?
}

private struct GoogleEmbedding: Codable {
    let values: [Double]
}
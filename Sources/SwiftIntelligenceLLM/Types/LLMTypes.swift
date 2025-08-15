import Foundation
import Network

// MARK: - Core LLM Types

public struct LLMConfiguration {
    public let openAI: OpenAIConfiguration
    public let anthropic: AnthropicConfiguration
    public let google: GoogleConfiguration
    public let defaultProvider: String
    public let defaultModel: String
    public let defaultEmbeddingModel: String
    public let rateLimiting: RateLimitingConfiguration
    public let enableCaching: Bool
    public let timeout: TimeInterval
    public let retryAttempts: Int
    public let privacyMode: PrivacyMode
    
    public enum PrivacyMode {
        case standard
        case enhanced
        case strict
    }
    
    public struct OpenAIConfiguration {
        public let apiKey: String
        public let organizationID: String?
        public let baseURL: String
        
        public init(apiKey: String, organizationID: String? = nil, baseURL: String = "https://api.openai.com/v1") {
            self.apiKey = apiKey
            self.organizationID = organizationID
            self.baseURL = baseURL
        }
    }
    
    public struct AnthropicConfiguration {
        public let apiKey: String
        public let baseURL: String
        
        public init(apiKey: String, baseURL: String = "https://api.anthropic.com/v1") {
            self.apiKey = apiKey
            self.baseURL = baseURL
        }
    }
    
    public struct GoogleConfiguration {
        public let apiKey: String
        public let baseURL: String
        
        public init(apiKey: String, baseURL: String = "https://generativelanguage.googleapis.com/v1") {
            self.apiKey = apiKey
            self.baseURL = baseURL
        }
    }
    
    public struct RateLimitingConfiguration {
        public let maxRequests: Int
        public let timeWindow: TimeInterval
        
        public init(maxRequests: Int = 60, timeWindow: TimeInterval = 60) {
            self.maxRequests = maxRequests
            self.timeWindow = timeWindow
        }
    }
    
    public init(
        openAI: OpenAIConfiguration,
        anthropic: AnthropicConfiguration,
        google: GoogleConfiguration,
        defaultProvider: String = "openai",
        defaultModel: String = "gpt-4",
        defaultEmbeddingModel: String = "text-embedding-ada-002",
        rateLimiting: RateLimitingConfiguration = RateLimitingConfiguration(),
        enableCaching: Bool = true,
        timeout: TimeInterval = 30,
        retryAttempts: Int = 3,
        privacyMode: PrivacyMode = .standard
    ) {
        self.openAI = openAI
        self.anthropic = anthropic
        self.google = google
        self.defaultProvider = defaultProvider
        self.defaultModel = defaultModel
        self.defaultEmbeddingModel = defaultEmbeddingModel
        self.rateLimiting = rateLimiting
        self.enableCaching = enableCaching
        self.timeout = timeout
        self.retryAttempts = retryAttempts
        self.privacyMode = privacyMode
    }
    
    public static let `default` = LLMConfiguration(
        openAI: OpenAIConfiguration(apiKey: ""),
        anthropic: AnthropicConfiguration(apiKey: ""),
        google: GoogleConfiguration(apiKey: "")
    )
}

// MARK: - Message Types

public struct LLMMessage: Codable, Hashable {
    public let role: Role
    public let content: String
    public let timestamp: Date
    public let metadata: [String: String]
    
    public enum Role: String, Codable, CaseIterable {
        case system = "system"
        case user = "user"
        case assistant = "assistant"
        case function = "function"
    }
    
    public init(role: Role, content: String, metadata: [String: String] = [:]) {
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.metadata = metadata
    }
}

public struct LLMOptions: Hashable, Codable {
    public let temperature: Double
    public let maxTokens: Int?
    public let topP: Double
    public let frequencyPenalty: Double
    public let presencePenalty: Double
    public let stopSequences: [String]
    public let enableStreaming: Bool
    
    public init(
        temperature: Double = 0.7,
        maxTokens: Int? = nil,
        topP: Double = 1.0,
        frequencyPenalty: Double = 0.0,
        presencePenalty: Double = 0.0,
        stopSequences: [String] = [],
        enableStreaming: Bool = false
    ) {
        self.temperature = max(0.0, min(2.0, temperature))
        self.maxTokens = maxTokens
        self.topP = max(0.0, min(1.0, topP))
        self.frequencyPenalty = max(-2.0, min(2.0, frequencyPenalty))
        self.presencePenalty = max(-2.0, min(2.0, presencePenalty))
        self.stopSequences = stopSequences
        self.enableStreaming = enableStreaming
    }
    
    public static let `default` = LLMOptions()
    
    public static let creative = LLMOptions(
        temperature: 1.0,
        topP: 0.9,
        frequencyPenalty: 0.5
    )
    
    public static let precise = LLMOptions(
        temperature: 0.2,
        topP: 0.8,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0
    )
    
    public static let balanced = LLMOptions(
        temperature: 0.7,
        topP: 0.95,
        frequencyPenalty: 0.1,
        presencePenalty: 0.1
    )
}

// MARK: - Request Types

public struct LLMRequest: Codable {
    public let messages: [LLMMessage]
    public let model: String
    public let options: LLMOptions
    public let requestId: String
    public let timestamp: Date
    
    public init(messages: [LLMMessage], model: String, options: LLMOptions) {
        self.messages = messages
        self.model = model
        self.options = options
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
    
    public var cacheKey: String {
        let messagesHash = messages.map { "\($0.role.rawValue):\($0.content)" }.joined(separator: "|")
        return "\(model)_\(messagesHash)_\(options.hashValue)".data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
    }
}

public struct LLMEmbeddingRequest: Codable {
    public let texts: [String]
    public let model: String
    public let requestId: String
    public let timestamp: Date
    
    public init(texts: [String], model: String) {
        self.texts = texts
        self.model = model
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
}

public struct LLMModerationRequest: Codable {
    public let input: String
    public let requestId: String
    public let timestamp: Date
    
    public init(input: String) {
        self.input = input
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
}

public struct LLMImageRequest: Codable {
    public let prompt: String
    public let options: LLMImageGenerationOptions
    public let requestId: String
    public let timestamp: Date
    
    public init(prompt: String, options: LLMImageGenerationOptions) {
        self.prompt = prompt
        self.options = options
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
}

// MARK: - Response Types

public struct LLMResponse: Codable {
    public let id: String
    public let choices: [LLMChoice]
    public let usage: LLMTokenUsage
    public let model: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    
    public init(
        id: String,
        choices: [LLMChoice],
        usage: LLMTokenUsage,
        model: String,
        processingTime: TimeInterval
    ) {
        self.id = id
        self.choices = choices
        self.usage = usage
        self.model = model
        self.timestamp = Date()
        self.processingTime = processingTime
    }
}

public struct LLMChoice: Codable {
    public let index: Int
    public let message: LLMMessage
    public let finishReason: FinishReason?
    
    public enum FinishReason: String, Codable {
        case stop = "stop"
        case length = "length"
        case functionCall = "function_call"
        case contentFilter = "content_filter"
    }
    
    public init(index: Int, message: LLMMessage, finishReason: FinishReason?) {
        self.index = index
        self.message = message
        self.finishReason = finishReason
    }
}

public struct LLMStreamingResponse: Codable {
    public let id: String
    public let choices: [LLMStreamingChoice]
    public let model: String
    public let timestamp: Date
    
    public init(id: String, choices: [LLMStreamingChoice], model: String) {
        self.id = id
        self.choices = choices
        self.model = model
        self.timestamp = Date()
    }
}

public struct LLMStreamingChoice: Codable {
    public let index: Int
    public let delta: LLMDelta
    public let finishReason: LLMChoice.FinishReason?
    
    public init(index: Int, delta: LLMDelta, finishReason: LLMChoice.FinishReason?) {
        self.index = index
        self.delta = delta
        self.finishReason = finishReason
    }
}

public struct LLMDelta: Codable {
    public let role: LLMMessage.Role?
    public let content: String?
    
    public init(role: LLMMessage.Role?, content: String?) {
        self.role = role
        self.content = content
    }
}

public struct LLMTokenUsage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    
    public init(promptTokens: Int, completionTokens: Int) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = promptTokens + completionTokens
    }
}

public struct LLMEmbeddingResponse: Codable {
    public let embeddings: [LLMEmbedding]
    public let usage: LLMTokenUsage
    public let model: String
    
    public init(embeddings: [LLMEmbedding], usage: LLMTokenUsage, model: String) {
        self.embeddings = embeddings
        self.usage = usage
        self.model = model
    }
}

public struct LLMEmbedding: Codable {
    public let index: Int
    public let embedding: [Double]
    public let text: String
    
    public init(index: Int, embedding: [Double], text: String) {
        self.index = index
        self.embedding = embedding
        self.text = text
    }
}

public struct LLMModerationResponse: Codable {
    public let flagged: Bool
    public let categories: ModerationCategories
    public let categoryScores: ModerationScores
    
    public struct ModerationCategories: Codable {
        public let hate: Bool
        public let hateThreatening: Bool
        public let harassment: Bool
        public let harassmentThreatening: Bool
        public let selfHarm: Bool
        public let selfHarmIntent: Bool
        public let selfHarmInstructions: Bool
        public let sexual: Bool
        public let sexualMinors: Bool
        public let violence: Bool
        public let violenceGraphic: Bool
    }
    
    public struct ModerationScores: Codable {
        public let hate: Double
        public let hateThreatening: Double
        public let harassment: Double
        public let harassmentThreatening: Double
        public let selfHarm: Double
        public let selfHarmIntent: Double
        public let selfHarmInstructions: Double
        public let sexual: Double
        public let sexualMinors: Double
        public let violence: Double
        public let violenceGraphic: Double
    }
}

public struct LLMImageResponse: Codable {
    public let images: [LLMImage]
    public let usage: LLMTokenUsage?
    public let processingTime: TimeInterval
    
    public init(images: [LLMImage], usage: LLMTokenUsage?, processingTime: TimeInterval) {
        self.images = images
        self.usage = usage
        self.processingTime = processingTime
    }
}

public struct LLMImage: Codable {
    public let url: String?
    public let data: Data?
    public let revisedPrompt: String?
    
    public init(url: String?, data: Data?, revisedPrompt: String?) {
        self.url = url
        self.data = data
        self.revisedPrompt = revisedPrompt
    }
}

public struct LLMImageGenerationOptions: Codable {
    public let size: ImageSize
    public let quality: ImageQuality
    public let style: ImageStyle
    public let responseFormat: ResponseFormat
    public let n: Int
    
    public enum ImageSize: String, Codable, CaseIterable {
        case small = "256x256"
        case medium = "512x512"
        case large = "1024x1024"
        case hd = "1792x1024"
        case square = "1024x1024"
    }
    
    public enum ImageQuality: String, Codable, CaseIterable {
        case standard = "standard"
        case hd = "hd"
    }
    
    public enum ImageStyle: String, Codable, CaseIterable {
        case vivid = "vivid"
        case natural = "natural"
    }
    
    public enum ResponseFormat: String, Codable, CaseIterable {
        case url = "url"
        case b64Json = "b64_json"
    }
    
    public init(
        size: ImageSize = .large,
        quality: ImageQuality = .standard,
        style: ImageStyle = .vivid,
        responseFormat: ResponseFormat = .url,
        n: Int = 1
    ) {
        self.size = size
        self.quality = quality
        self.style = style
        self.responseFormat = responseFormat
        self.n = max(1, min(10, n))
    }
    
    public static let `default` = LLMImageGenerationOptions()
}

// MARK: - Batch Processing Types

public enum BatchLLMRequest {
    case chat(messages: [LLMMessage], model: String?, options: LLMOptions)
    case text(prompt: String, model: String?, options: LLMOptions)
    
    public var type: RequestType {
        switch self {
        case .chat: return .chat
        case .text: return .text
        }
    }
    
    public enum RequestType {
        case chat
        case text
    }
}

// MARK: - Provider Types

public struct LLMProviderInfo {
    public let name: String
    public let models: [String]
    public let features: LLMProviderFeatures
    
    public init(name: String, models: [String], features: LLMProviderFeatures) {
        self.name = name
        self.models = models
        self.features = features
    }
}

public struct LLMProviderFeatures {
    public let chatCompletion: Bool
    public let streaming: Bool
    public let embeddings: Bool
    public let moderation: Bool
    public let imageGeneration: Bool
    public let isLocal: Bool
    
    public init(
        chatCompletion: Bool,
        streaming: Bool,
        embeddings: Bool,
        moderation: Bool,
        imageGeneration: Bool,
        isLocal: Bool
    ) {
        self.chatCompletion = chatCompletion
        self.streaming = streaming
        self.embeddings = embeddings
        self.moderation = moderation
        self.imageGeneration = imageGeneration
        self.isLocal = isLocal
    }
}

// MARK: - Usage and Monitoring Types

public struct LLMUsage {
    public var totalRequests: Int
    public var totalTokens: Int
    public var promptTokens: Int
    public var completionTokens: Int
    public var estimatedCost: Double
    public var startDate: Date
    
    public init() {
        self.totalRequests = 0
        self.totalTokens = 0
        self.promptTokens = 0
        self.completionTokens = 0
        self.estimatedCost = 0.0
        self.startDate = Date()
    }
}

public struct RateLimitStatus {
    public let remainingRequests: Int
    public let resetTime: Date
    public let totalLimit: Int
    
    public init(remainingRequests: Int, resetTime: Date, totalLimit: Int) {
        self.remainingRequests = remainingRequests
        self.resetTime = resetTime
        self.totalLimit = totalLimit
    }
}

public struct CacheInfo {
    public let count: Int
    public let size: Int
    public let currentCount: Int
    public let estimatedSize: Int
    
    public init(count: Int, size: Int, currentCount: Int, estimatedSize: Int) {
        self.count = count
        self.size = size
        self.currentCount = currentCount
        self.estimatedSize = estimatedSize
    }
}

// MARK: - Error Types

public enum LLMError: LocalizedError {
    case invalidConfiguration
    case noActiveProvider
    case providerNotFound(String)
    case networkUnavailable
    case requestTimeout
    case rateLimitExceeded
    case unauthorizedAccess
    case insufficientQuota
    case modelNotFound(String)
    case invalidRequest(String)
    case responseParsingError
    case featureNotSupported(String)
    case networkError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid LLM configuration"
        case .noActiveProvider:
            return "No active LLM provider configured"
        case .providerNotFound(let provider):
            return "Provider '\(provider)' not found"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .requestTimeout:
            return "Request timed out"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .unauthorizedAccess:
            return "Unauthorized access - check API key"
        case .insufficientQuota:
            return "Insufficient API quota"
        case .modelNotFound(let model):
            return "Model '\(model)' not found"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .responseParsingError:
            return "Failed to parse response"
        case .featureNotSupported(let feature):
            return "Feature '\(feature)' not supported by provider"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidConfiguration:
            return "Check your API keys and provider configuration"
        case .noActiveProvider:
            return "Configure at least one LLM provider"
        case .providerNotFound:
            return "Verify the provider name and availability"
        case .networkUnavailable:
            return "Check your internet connection"
        case .requestTimeout:
            return "Try again or increase timeout duration"
        case .rateLimitExceeded:
            return "Wait before making more requests"
        case .unauthorizedAccess:
            return "Verify your API key is correct and has proper permissions"
        case .insufficientQuota:
            return "Check your API usage limits and billing"
        case .modelNotFound:
            return "Use a supported model name"
        case .invalidRequest:
            return "Check request parameters and format"
        case .responseParsingError:
            return "Try the request again"
        case .featureNotSupported:
            return "Use a different provider or disable this feature"
        case .networkError, .unknownError:
            return "Try again later"
        }
    }
}

// MARK: - Protocol Definitions

public protocol LLMProvider {
    var name: String { get }
    var supportedModels: [String] { get }
    var supportsChatCompletion: Bool { get }
    var supportsStreaming: Bool { get }
    var supportsEmbeddings: Bool { get }
    var supportsModeration: Bool { get }
    var supportsImageGeneration: Bool { get }
    var isLocal: Bool { get }
    
    func chatCompletion(request: LLMRequest) async throws -> LLMResponse
    func streamingChatCompletion(request: LLMRequest) -> AsyncThrowingStream<LLMStreamingResponse, Error>
    func generateEmbeddings(request: LLMEmbeddingRequest) async throws -> LLMEmbeddingResponse
    func moderateContent(request: LLMModerationRequest) async throws -> LLMModerationResponse
    func generateImage(request: LLMImageRequest) async throws -> LLMImageResponse
}

// MARK: - Extensions

extension LLMMessage: CustomStringConvertible {
    public var description: String {
        return "\(role.rawValue): \(content.prefix(100))..."
    }
}

extension LLMOptions {
    public var hashValue: Int {
        var hasher = Hasher()
        hasher.combine(temperature)
        hasher.combine(maxTokens)
        hasher.combine(topP)
        hasher.combine(frequencyPenalty)
        hasher.combine(presencePenalty)
        hasher.combine(stopSequences)
        hasher.combine(enableStreaming)
        return hasher.finalize()
    }
}

extension EntityExtractionOptions {
    public var hashValue: Int {
        var hasher = Hasher()
        hasher.combine(includeBuiltInEntities)
        hasher.combine(includePatternEntities)
        hasher.combine(includeCustomEntities)
        hasher.combine(confidenceThreshold)
        hasher.combine(entityTypes)
        return hasher.finalize()
    }
}
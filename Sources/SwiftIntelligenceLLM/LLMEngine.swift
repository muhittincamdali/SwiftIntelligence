import Foundation
import Network
import CryptoKit
import os.log

/// Advanced Large Language Model Integration Engine
@MainActor
public class LLMEngine: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = LLMEngine()
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "LLM")
    private let networkQueue = DispatchQueue(label: "llm.network", qos: .userInitiated)
    
    // MARK: - Network Components
    private let urlSession: URLSession
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = true
    
    // MARK: - Configuration
    @Published public var configuration: LLMConfiguration = .default
    
    // MARK: - Providers
    private var providers: [String: LLMProvider] = [:]
    private var activeProvider: LLMProvider?
    
    // MARK: - State Management
    @Published public var isProcessing = false
    @Published public var currentUsage = LLMUsage()
    @Published public var lastError: LLMError?
    
    // MARK: - Cache and Storage
    private let responseCache = NSCache<NSString, LLMResponse>()
    private let conversationManager = ConversationManager()
    
    // MARK: - Rate Limiting
    private var rateLimiter: RateLimiter
    
    // MARK: - Initialization
    private init() {
        // Configure URL session
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 300.0
        urlSession = URLSession(configuration: sessionConfig)
        
        // Initialize rate limiter
        rateLimiter = RateLimiter(maxRequests: 60, timeWindow: 60) // 60 requests per minute
        
        // Configure cache
        responseCache.countLimit = 100
        responseCache.totalCostLimit = 50_000_000 // 50MB
        
        setupProviders()
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - Setup
    
    private func setupProviders() {
        // OpenAI Provider
        let openAIProvider = OpenAIProvider(
            apiKey: configuration.openAI.apiKey,
            baseURL: configuration.openAI.baseURL,
            organizationID: configuration.openAI.organizationID
        )
        providers["openai"] = openAIProvider
        
        // Anthropic Provider
        let anthropicProvider = AnthropicProvider(
            apiKey: configuration.anthropic.apiKey,
            baseURL: configuration.anthropic.baseURL
        )
        providers["anthropic"] = anthropicProvider
        
        // Google Provider
        let googleProvider = GoogleProvider(
            apiKey: configuration.google.apiKey,
            baseURL: configuration.google.baseURL
        )
        providers["google"] = googleProvider
        
        // Local Provider (for on-device models)
        let localProvider = LocalProvider()
        providers["local"] = localProvider
        
        // Set default provider
        activeProvider = providers[configuration.defaultProvider]
        
        logger.info("LLM providers initialized")
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        
        networkMonitor.start(queue: networkQueue)
    }
    
    // MARK: - Configuration
    
    public func updateConfiguration(_ config: LLMConfiguration) {
        configuration = config
        setupProviders()
        activeProvider = providers[config.defaultProvider]
        
        // Update rate limiter
        rateLimiter = RateLimiter(
            maxRequests: config.rateLimiting.maxRequests,
            timeWindow: config.rateLimiting.timeWindow
        )
        
        logger.info("LLM configuration updated")
    }
    
    public func setProvider(_ providerName: String) throws {
        guard let provider = providers[providerName] else {
            throw LLMError.providerNotFound(providerName)
        }
        
        activeProvider = provider
        logger.info("Active provider set to: \(providerName)")
    }
    
    // MARK: - Chat Completion
    
    /// Generate chat completion with messages
    public func chatCompletion(
        messages: [LLMMessage],
        model: String? = nil,
        options: LLMOptions = .default
    ) async throws -> LLMResponse {
        
        guard let provider = activeProvider else {
            throw LLMError.noActiveProvider
        }
        
        // Check network availability for cloud providers
        if !provider.isLocal && !isNetworkAvailable {
            throw LLMError.networkUnavailable
        }
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        isProcessing = true
        lastError = nil
        
        do {
            let request = LLMRequest(
                messages: messages,
                model: model ?? configuration.defaultModel,
                options: options
            )
            
            // Check cache
            if let cachedResponse = getCachedResponse(for: request) {
                return cachedResponse
            }
            
            let response = try await provider.chatCompletion(request: request)
            
            // Update usage
            updateUsage(response.usage)
            
            // Cache response
            cacheResponse(response, for: request)
            
            isProcessing = false
            return response
            
        } catch {
            isProcessing = false
            let llmError = mapError(error)
            lastError = llmError
            throw llmError
        }
    }
    
    /// Generate single text completion
    public func textCompletion(
        prompt: String,
        model: String? = nil,
        options: LLMOptions = .default
    ) async throws -> LLMResponse {
        
        let message = LLMMessage(role: .user, content: prompt)
        return try await chatCompletion(messages: [message], model: model, options: options)
    }
    
    /// Generate streaming chat completion
    public func streamingChatCompletion(
        messages: [LLMMessage],
        model: String? = nil,
        options: LLMOptions = .default
    ) -> AsyncThrowingStream<LLMStreamingResponse, Error> {
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let provider = activeProvider else {
                        continuation.finish(throwing: LLMError.noActiveProvider)
                        return
                    }
                    
                    if !provider.isLocal && !isNetworkAvailable {
                        continuation.finish(throwing: LLMError.networkUnavailable)
                        return
                    }
                    
                    try await rateLimiter.checkRateLimit()
                    
                    let request = LLMRequest(
                        messages: messages,
                        model: model ?? configuration.defaultModel,
                        options: options
                    )
                    
                    let stream = provider.streamingChatCompletion(request: request)
                    
                    for try await chunk in stream {
                        continuation.yield(chunk)
                    }
                    
                    continuation.finish()
                    
                } catch {
                    continuation.finish(throwing: mapError(error))
                }
            }
        }
    }
    
    // MARK: - Conversation Management
    
    /// Start a new conversation
    public func startConversation(
        systemPrompt: String? = nil,
        conversationId: String? = nil
    ) -> String {
        return conversationManager.startConversation(
            systemPrompt: systemPrompt,
            conversationId: conversationId
        )
    }
    
    /// Continue an existing conversation
    public func continueConversation(
        conversationId: String,
        userMessage: String,
        model: String? = nil,
        options: LLMOptions = .default
    ) async throws -> LLMResponse {
        
        let messages = conversationManager.getMessages(conversationId: conversationId)
        let newMessage = LLMMessage(role: .user, content: userMessage)
        let allMessages = messages + [newMessage]
        
        let response = try await chatCompletion(messages: allMessages, model: model, options: options)
        
        // Add messages to conversation
        conversationManager.addMessage(conversationId: conversationId, message: newMessage)
        
        if let assistantContent = response.choices.first?.message.content {
            let assistantMessage = LLMMessage(role: .assistant, content: assistantContent)
            conversationManager.addMessage(conversationId: conversationId, message: assistantMessage)
        }
        
        return response
    }
    
    /// Get conversation history
    public func getConversation(conversationId: String) -> [LLMMessage] {
        return conversationManager.getMessages(conversationId: conversationId)
    }
    
    /// Clear conversation history
    public func clearConversation(conversationId: String) {
        conversationManager.clearConversation(conversationId: conversationId)
    }
    
    // MARK: - Specialized Functions
    
    /// Generate text embeddings
    public func generateEmbeddings(
        texts: [String],
        model: String? = nil
    ) async throws -> LLMEmbeddingResponse {
        
        guard let provider = activeProvider else {
            throw LLMError.noActiveProvider
        }
        
        guard provider.supportsEmbeddings else {
            throw LLMError.featureNotSupported("embeddings")
        }
        
        try await rateLimiter.checkRateLimit()
        
        let request = LLMEmbeddingRequest(
            texts: texts,
            model: model ?? configuration.defaultEmbeddingModel
        )
        
        return try await provider.generateEmbeddings(request: request)
    }
    
    /// Moderate content
    public func moderateContent(text: String) async throws -> LLMModerationResponse {
        guard let provider = activeProvider else {
            throw LLMError.noActiveProvider
        }
        
        guard provider.supportsModeration else {
            throw LLMError.featureNotSupported("moderation")
        }
        
        let request = LLMModerationRequest(input: text)
        return try await provider.moderateContent(request: request)
    }
    
    /// Generate images (if supported by provider)
    public func generateImage(
        prompt: String,
        options: LLMImageGenerationOptions = .default
    ) async throws -> LLMImageResponse {
        
        guard let provider = activeProvider else {
            throw LLMError.noActiveProvider
        }
        
        guard provider.supportsImageGeneration else {
            throw LLMError.featureNotSupported("image_generation")
        }
        
        let request = LLMImageRequest(
            prompt: prompt,
            options: options
        )
        
        return try await provider.generateImage(request: request)
    }
    
    // MARK: - Batch Processing
    
    /// Process multiple requests in batch
    public func batchProcess(
        requests: [BatchLLMRequest],
        maxConcurrency: Int = 3
    ) async throws -> [LLMResponse] {
        
        return try await withThrowingTaskGroup(of: LLMResponse.self) { group in
            var results: [LLMResponse] = []
            
            // Add tasks with concurrency limit
            var activeCount = 0
            var requestIndex = 0
            
            func addNextTask() {
                guard requestIndex < requests.count, activeCount < maxConcurrency else { return }
                
                let request = requests[requestIndex]
                requestIndex += 1
                activeCount += 1
                
                group.addTask {
                    defer { activeCount -= 1 }
                    
                    switch request.type {
                    case .chat(let messages, let model, let options):
                        return try await self.chatCompletion(messages: messages, model: model, options: options)
                    case .text(let prompt, let model, let options):
                        return try await self.textCompletion(prompt: prompt, model: model, options: options)
                    }
                }
                
                // Add more tasks if available
                addNextTask()
            }
            
            // Start initial tasks
            for _ in 0..<min(maxConcurrency, requests.count) {
                addNextTask()
            }
            
            // Collect results
            while results.count < requests.count {
                if let result = try await group.next() {
                    results.append(result)
                    addNextTask() // Add next task when one completes
                }
            }
            
            return results
        }
    }
    
    // MARK: - Provider Management
    
    /// Get available providers
    public func getAvailableProviders() -> [String] {
        return Array(providers.keys)
    }
    
    /// Get provider information
    public func getProviderInfo(_ providerName: String) -> LLMProviderInfo? {
        guard let provider = providers[providerName] else { return nil }
        
        return LLMProviderInfo(
            name: provider.name,
            models: provider.supportedModels,
            features: LLMProviderFeatures(
                chatCompletion: provider.supportsChatCompletion,
                streaming: provider.supportsStreaming,
                embeddings: provider.supportsEmbeddings,
                moderation: provider.supportsModeration,
                imageGeneration: provider.supportsImageGeneration,
                isLocal: provider.isLocal
            )
        )
    }
    
    // MARK: - Usage and Monitoring
    
    /// Get current usage statistics
    public func getUsageStatistics() -> LLMUsage {
        return currentUsage
    }
    
    /// Reset usage statistics
    public func resetUsageStatistics() {
        currentUsage = LLMUsage()
    }
    
    /// Get rate limit status
    public func getRateLimitStatus() -> RateLimitStatus {
        return rateLimiter.getStatus()
    }
    
    // MARK: - Cache Management
    
    public func clearCache() {
        responseCache.removeAllObjects()
        logger.info("Response cache cleared")
    }
    
    public func getCacheInfo() -> CacheInfo {
        return CacheInfo(
            count: responseCache.countLimit,
            size: responseCache.totalCostLimit,
            currentCount: 0, // NSCache doesn't provide current count
            estimatedSize: 0  // NSCache doesn't provide current size
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func getCachedResponse(for request: LLMRequest) -> LLMResponse? {
        guard configuration.enableCaching else { return nil }
        
        let cacheKey = NSString(string: request.cacheKey)
        return responseCache.object(forKey: cacheKey)
    }
    
    private func cacheResponse(_ response: LLMResponse, for request: LLMRequest) {
        guard configuration.enableCaching else { return }
        
        let cacheKey = NSString(string: request.cacheKey)
        let cost = response.usage.totalTokens
        responseCache.setObject(response, forKey: cacheKey, cost: cost)
    }
    
    private func updateUsage(_ usage: LLMTokenUsage) {
        currentUsage.totalRequests += 1
        currentUsage.totalTokens += usage.totalTokens
        currentUsage.promptTokens += usage.promptTokens
        currentUsage.completionTokens += usage.completionTokens
        currentUsage.estimatedCost += calculateCost(usage: usage)
    }
    
    private func calculateCost(usage: LLMTokenUsage) -> Double {
        // Simplified cost calculation - would use actual provider pricing
        let promptCostPer1K = 0.01 // $0.01 per 1K prompt tokens
        let completionCostPer1K = 0.02 // $0.02 per 1K completion tokens
        
        let promptCost = Double(usage.promptTokens) / 1000.0 * promptCostPer1K
        let completionCost = Double(usage.completionTokens) / 1000.0 * completionCostPer1K
        
        return promptCost + completionCost
    }
    
    private func mapError(_ error: Error) -> LLMError {
        if let llmError = error as? LLMError {
            return llmError
        }
        
        // Map common network errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .requestTimeout
            default:
                return .networkError(urlError.localizedDescription)
            }
        }
        
        return .unknownError(error.localizedDescription)
    }
}

// MARK: - Rate Limiter

private class RateLimiter {
    private let maxRequests: Int
    private let timeWindow: TimeInterval
    private var requestTimestamps: [Date] = []
    private let queue = DispatchQueue(label: "rate.limiter", attributes: .concurrent)
    
    init(maxRequests: Int, timeWindow: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }
    
    func checkRateLimit() async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                let now = Date()
                let cutoff = now.addingTimeInterval(-self.timeWindow)
                
                // Remove old timestamps
                self.requestTimestamps = self.requestTimestamps.filter { $0 > cutoff }
                
                if self.requestTimestamps.count >= self.maxRequests {
                    continuation.resume(throwing: LLMError.rateLimitExceeded)
                } else {
                    self.requestTimestamps.append(now)
                    continuation.resume()
                }
            }
        }
    }
    
    func getStatus() -> RateLimitStatus {
        return queue.sync {
            let now = Date()
            let cutoff = now.addingTimeInterval(-timeWindow)
            let recentRequests = requestTimestamps.filter { $0 > cutoff }
            
            return RateLimitStatus(
                remainingRequests: max(0, maxRequests - recentRequests.count),
                resetTime: recentRequests.first?.addingTimeInterval(timeWindow) ?? now,
                totalLimit: maxRequests
            )
        }
    }
}

// MARK: - Conversation Manager

private class ConversationManager {
    private var conversations: [String: [LLMMessage]] = [:]
    private let queue = DispatchQueue(label: "conversation.manager", attributes: .concurrent)
    
    func startConversation(systemPrompt: String?, conversationId: String?) -> String {
        let id = conversationId ?? UUID().uuidString
        
        queue.async(flags: .barrier) {
            var messages: [LLMMessage] = []
            
            if let systemPrompt = systemPrompt {
                messages.append(LLMMessage(role: .system, content: systemPrompt))
            }
            
            self.conversations[id] = messages
        }
        
        return id
    }
    
    func addMessage(conversationId: String, message: LLMMessage) {
        queue.async(flags: .barrier) {
            self.conversations[conversationId, default: []].append(message)
        }
    }
    
    func getMessages(conversationId: String) -> [LLMMessage] {
        return queue.sync {
            return conversations[conversationId] ?? []
        }
    }
    
    func clearConversation(conversationId: String) {
        queue.async(flags: .barrier) {
            self.conversations[conversationId] = nil
        }
    }
}
import Foundation
import CoreML
import NaturalLanguage
import os.log

/// Local on-device LLM provider for privacy-focused applications
public class LocalProvider: LLMProvider {
    
    // MARK: - Properties
    public let name = "Local"
    public let supportedModels = [
        "local-chat-small",
        "local-chat-medium",
        "local-embedding",
        "local-classification"
    ]
    
    public let supportsChatCompletion = true
    public let supportsStreaming = false // Most local models don't support streaming
    public let supportsEmbeddings = true
    public let supportsModeration = true
    public let supportsImageGeneration = false
    public let isLocal = true
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "LocalProvider")
    private var loadedModels: [String: MLModel] = [:]
    private let modelQueue = DispatchQueue(label: "local.model.processing", qos: .userInitiated)
    
    // MARK: - Model Management
    private var chatModel: MLModel?
    private var embeddingModel: MLModel?
    private var moderationModel: MLModel?
    
    // MARK: - Initialization
    public init() {
        Task {
            await loadLocalModels()
        }
    }
    
    private func loadLocalModels() async {
        logger.info("Loading local models...")
        
        // Load chat model
        await loadChatModel()
        
        // Load embedding model
        await loadEmbeddingModel()
        
        // Load moderation model
        await loadModerationModel()
        
        logger.info("Local models initialization completed")
    }
    
    private func loadChatModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalChatModel", withExtension: "mlmodel") {
                chatModel = try MLModel(contentsOf: modelURL)
                loadedModels["local-chat-small"] = chatModel
                logger.info("Local chat model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load local chat model: \(error.localizedDescription)")
        }
    }
    
    private func loadEmbeddingModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalEmbeddingModel", withExtension: "mlmodel") {
                embeddingModel = try MLModel(contentsOf: modelURL)
                loadedModels["local-embedding"] = embeddingModel
                logger.info("Local embedding model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load local embedding model: \(error.localizedDescription)")
        }
    }
    
    private func loadModerationModel() async {
        do {
            if let modelURL = Bundle.module.url(forResource: "LocalModerationModel", withExtension: "mlmodel") {
                moderationModel = try MLModel(contentsOf: modelURL)
                loadedModels["local-classification"] = moderationModel
                logger.info("Local moderation model loaded successfully")
            }
        } catch {
            logger.warning("Failed to load local moderation model: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Chat Completion
    public func chatCompletion(request: LLMRequest) async throws -> LLMResponse {
        let startTime = Date()
        
        guard let model = loadedModels[request.model] else {
            throw LLMError.modelNotFound(request.model)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            modelQueue.async {
                do {
                    // Prepare input for the model
                    let inputText = self.prepareInputText(from: request.messages)
                    let prediction = try self.performChatPrediction(
                        model: model,
                        inputText: inputText,
                        options: request.options
                    )
                    
                    let processingTime = Date().timeIntervalSince(startTime)
                    
                    let response = LLMResponse(
                        id: "local-\(UUID().uuidString)",
                        choices: [
                            LLMChoice(
                                index: 0,
                                message: LLMMessage(role: .assistant, content: prediction.text),
                                finishReason: prediction.finishReason
                            )
                        ],
                        usage: prediction.usage,
                        model: request.model,
                        processingTime: processingTime
                    )
                    
                    continuation.resume(returning: response)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Streaming Chat Completion (Not Supported)
    public func streamingChatCompletion(request: LLMRequest) -> AsyncThrowingStream<LLMStreamingResponse, Error> {
        return AsyncThrowingStream { continuation in
            continuation.finish(throwing: LLMError.featureNotSupported("streaming"))
        }
    }
    
    // MARK: - Embeddings
    public func generateEmbeddings(request: LLMEmbeddingRequest) async throws -> LLMEmbeddingResponse {
        guard let model = embeddingModel else {
            throw LLMError.modelNotFound("local-embedding")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            modelQueue.async {
                do {
                    var embeddings: [LLMEmbedding] = []
                    
                    for (index, text) in request.texts.enumerated() {
                        let embedding = try self.generateEmbedding(model: model, text: text)
                        embeddings.append(LLMEmbedding(
                            index: index,
                            embedding: embedding,
                            text: text
                        ))
                    }
                    
                    let usage = LLMTokenUsage(
                        promptTokens: request.texts.reduce(0) { $0 + $1.count / 4 }, // Rough estimate
                        completionTokens: 0
                    )
                    
                    let response = LLMEmbeddingResponse(
                        embeddings: embeddings,
                        usage: usage,
                        model: request.model
                    )
                    
                    continuation.resume(returning: response)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Moderation
    public func moderateContent(request: LLMModerationRequest) async throws -> LLMModerationResponse {
        guard let model = moderationModel else {
            throw LLMError.modelNotFound("local-classification")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            modelQueue.async {
                do {
                    let moderationResult = try self.moderateText(model: model, text: request.input)
                    continuation.resume(returning: moderationResult)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Image Generation (Not Supported)
    public func generateImage(request: LLMImageRequest) async throws -> LLMImageResponse {
        throw LLMError.featureNotSupported("image_generation")
    }
    
    // MARK: - Private Helper Methods
    
    private func prepareInputText(from messages: [LLMMessage]) -> String {
        var inputText = ""
        
        for message in messages {
            switch message.role {
            case .system:
                inputText += "System: \(message.content)\n"
            case .user:
                inputText += "User: \(message.content)\n"
            case .assistant:
                inputText += "Assistant: \(message.content)\n"
            case .function:
                inputText += "Function: \(message.content)\n"
            }
        }
        
        inputText += "Assistant: "
        return inputText
    }
    
    private func performChatPrediction(
        model: MLModel,
        inputText: String,
        options: LLMOptions
    ) throws -> LocalPredictionResult {
        
        // This is a simplified implementation
        // In a real implementation, you would:
        // 1. Tokenize the input text
        // 2. Convert to the model's expected input format
        // 3. Run the prediction
        // 4. Decode the output tokens back to text
        
        // For demonstration, we'll create a mock response
        let mockResponses = [
            "I understand your question and I'm here to help.",
            "That's an interesting point. Let me provide some information about that.",
            "Based on the context provided, here's what I can tell you:",
            "I'd be happy to assist you with that request.",
            "Let me think about that and provide you with a helpful response."
        ]
        
        let randomResponse = mockResponses.randomElement() ?? "I'm processing your request."
        
        // Simulate processing time based on input length
        let processingDelay = Double(inputText.count) / 10000.0
        Thread.sleep(forTimeInterval: min(processingDelay, 1.0))
        
        return LocalPredictionResult(
            text: randomResponse,
            finishReason: .stop,
            usage: LLMTokenUsage(
                promptTokens: inputText.count / 4, // Rough token estimation
                completionTokens: randomResponse.count / 4
            )
        )
    }
    
    private func generateEmbedding(model: MLModel, text: String) throws -> [Double] {
        // This is a simplified implementation
        // In a real implementation, you would:
        // 1. Preprocess the text (tokenization, normalization)
        // 2. Convert to the model's expected input format
        // 3. Run the embedding model
        // 4. Extract the embedding vector
        
        // For demonstration, we'll create a mock embedding
        // Real embeddings are typically 768, 1024, or 1536 dimensions
        let embeddingDimension = 768
        var embedding: [Double] = []
        
        // Generate a pseudo-random but deterministic embedding based on text hash
        let textHash = text.hashValue
        var seed = textHash
        
        for _ in 0..<embeddingDimension {
            // Simple linear congruential generator for deterministic randomness
            seed = (seed &* 1103515245 + 12345) & 0x7fffffff
            let normalizedValue = Double(seed) / Double(0x7fffffff) * 2.0 - 1.0
            embedding.append(normalizedValue)
        }
        
        // Normalize the embedding vector
        let magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
        if magnitude > 0 {
            embedding = embedding.map { $0 / magnitude }
        }
        
        return embedding
    }
    
    private func moderateText(model: MLModel, text: String) throws -> LLMModerationResponse {
        // This is a simplified implementation
        // In a real implementation, you would:
        // 1. Preprocess the text
        // 2. Run the classification model
        // 3. Interpret the output probabilities
        
        // For demonstration, we'll create a basic content filter
        let flaggedTerms = ["hate", "harassment", "violence", "sexual"]
        let lowercaseText = text.lowercased()
        
        var flagged = false
        var scores: [String: Double] = [:]
        
        for term in flaggedTerms {
            let score = lowercaseText.contains(term) ? 0.8 : 0.1
            scores[term] = score
            if score > 0.5 {
                flagged = true
            }
        }
        
        return LLMModerationResponse(
            flagged: flagged,
            categories: LLMModerationResponse.ModerationCategories(
                hate: scores["hate"] ?? 0.1 > 0.5,
                hateThreatening: false,
                harassment: scores["harassment"] ?? 0.1 > 0.5,
                harassmentThreatening: false,
                selfHarm: false,
                selfHarmIntent: false,
                selfHarmInstructions: false,
                sexual: scores["sexual"] ?? 0.1 > 0.5,
                sexualMinors: false,
                violence: scores["violence"] ?? 0.1 > 0.5,
                violenceGraphic: false
            ),
            categoryScores: LLMModerationResponse.ModerationScores(
                hate: scores["hate"] ?? 0.1,
                hateThreatening: 0.05,
                harassment: scores["harassment"] ?? 0.1,
                harassmentThreatening: 0.05,
                selfHarm: 0.05,
                selfHarmIntent: 0.05,
                selfHarmInstructions: 0.05,
                sexual: scores["sexual"] ?? 0.1,
                sexualMinors: 0.05,
                violence: scores["violence"] ?? 0.1,
                violenceGraphic: 0.05
            )
        )
    }
    
    // MARK: - Model Loading Utilities
    
    public func loadCustomModel(at url: URL, modelName: String) async throws {
        do {
            let model = try MLModel(contentsOf: url)
            loadedModels[modelName] = model
            logger.info("Custom model '\(modelName)' loaded successfully")
        } catch {
            logger.error("Failed to load custom model '\(modelName)': \(error.localizedDescription)")
            throw LLMError.modelNotFound(modelName)
        }
    }
    
    public func unloadModel(_ modelName: String) {
        loadedModels.removeValue(forKey: modelName)
        logger.info("Model '\(modelName)' unloaded")
    }
    
    public func getModelInfo(_ modelName: String) -> ModelInfo? {
        guard let model = loadedModels[modelName] else {
            return nil
        }
        
        return ModelInfo(
            name: modelName,
            isLoaded: true,
            memoryUsage: estimateModelMemoryUsage(model),
            inputDescription: model.modelDescription.inputDescriptionsByName.description,
            outputDescription: model.modelDescription.outputDescriptionsByName.description
        )
    }
    
    private func estimateModelMemoryUsage(_ model: MLModel) -> Int {
        // Rough estimation of model memory usage
        // In practice, this would need more sophisticated calculation
        return 50_000_000 // 50MB estimate
    }
}

// MARK: - Supporting Types

private struct LocalPredictionResult {
    let text: String
    let finishReason: LLMChoice.FinishReason
    let usage: LLMTokenUsage
}

public struct ModelInfo {
    public let name: String
    public let isLoaded: Bool
    public let memoryUsage: Int
    public let inputDescription: String
    public let outputDescription: String
    
    public init(name: String, isLoaded: Bool, memoryUsage: Int, inputDescription: String, outputDescription: String) {
        self.name = name
        self.isLoaded = isLoaded
        self.memoryUsage = memoryUsage
        self.inputDescription = inputDescription
        self.outputDescription = outputDescription
    }
}

// MARK: - Extensions

extension LocalProvider {
    
    /// Get all loaded models information
    public func getAllModelsInfo() -> [ModelInfo] {
        return loadedModels.keys.compactMap { getModelInfo($0) }
    }
    
    /// Check if a model is loaded and ready
    public func isModelLoaded(_ modelName: String) -> Bool {
        return loadedModels[modelName] != nil
    }
    
    /// Get memory usage for all loaded models
    public func getTotalMemoryUsage() -> Int {
        return loadedModels.values.reduce(0) { total, model in
            total + estimateModelMemoryUsage(model)
        }
    }
}
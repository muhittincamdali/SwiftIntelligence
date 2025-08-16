//
// AIServiceClient.swift
// SwiftIntelligence Server Integration Example
//
// Backend API integration patterns for AI/ML services
//

import Foundation
import SwiftIntelligence
import Combine

/// Example AI Service Client for backend integration
/// Demonstrates best practices for server communication with SwiftIntelligence
@MainActor
public final class AIServiceClient: ObservableObject {
    
    // MARK: - Properties
    
    private let baseURL: URL
    private let session: URLSession
    private let apiKey: String
    private let intelligenceEngine: IntelligenceEngine
    
    @Published public var isProcessing = false
    @Published public var error: Error?
    
    // Rate limiting
    private let rateLimiter: RateLimiter
    
    // Circuit breaker for fault tolerance
    private let circuitBreaker: CircuitBreaker
    
    // Request queue for offline support
    private let requestQueue: RequestQueue
    
    // MARK: - Configuration
    
    public struct Configuration {
        public let baseURL: URL
        public let apiKey: String
        public let timeout: TimeInterval
        public let maxRetries: Int
        public let enableOfflineMode: Bool
        public let enableCaching: Bool
        
        public static let `default` = Configuration(
            baseURL: URL(string: "https://api.example.com/v1")!,
            apiKey: "",
            timeout: 30,
            maxRetries: 3,
            enableOfflineMode: true,
            enableCaching: true
        )
    }
    
    // MARK: - Initialization
    
    public init(configuration: Configuration) async throws {
        self.baseURL = configuration.baseURL
        self.apiKey = configuration.apiKey
        
        // Configure URLSession with custom settings
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        sessionConfig.waitsForConnectivity = true
        sessionConfig.httpAdditionalHeaders = [
            "Authorization": "Bearer \(configuration.apiKey)",
            "Content-Type": "application/json",
            "X-Framework-Version": "SwiftIntelligence/1.0.0"
        ]
        
        self.session = URLSession(configuration: sessionConfig)
        
        // Initialize SwiftIntelligence
        self.intelligenceEngine = IntelligenceEngine.shared
        try await intelligenceEngine.initialize()
        
        // Initialize rate limiter
        self.rateLimiter = RateLimiter(
            requestsPerSecond: 10,
            burstSize: 20
        )
        
        // Initialize circuit breaker
        self.circuitBreaker = CircuitBreaker(
            failureThreshold: 5,
            resetTimeout: 60
        )
        
        // Initialize request queue for offline support
        self.requestQueue = RequestQueue(
            maxSize: 100,
            enablePersistence: configuration.enableOfflineMode
        )
    }
    
    // MARK: - Hybrid Processing (Local + Server)
    
    /// Process text with hybrid approach - local preprocessing + server enhancement
    public func processTextHybrid(_ text: String) async throws -> HybridTextResult {
        isProcessing = true
        defer { isProcessing = false }
        
        // Step 1: Local preprocessing with SwiftIntelligence
        let nlpEngine = try await intelligenceEngine.getNaturalLanguageEngine()
        let localResult = try await nlpEngine.analyzeText(
            text,
            options: NLPAnalysisOptions(
                enableSentiment: true,
                enableEntities: true,
                enableKeywords: true
            )
        )
        
        // Step 2: Prepare enhanced request for server
        let request = TextAnalysisRequest(
            text: text,
            localAnalysis: localResult,
            requestEnhancements: true
        )
        
        // Step 3: Send to server with rate limiting and circuit breaker
        let serverResult = try await sendWithProtection { [weak self] in
            guard let self = self else { throw ServiceError.deallocated }
            return try await self.sendTextAnalysisRequest(request)
        }
        
        // Step 4: Combine results
        return HybridTextResult(
            local: localResult,
            server: serverResult,
            confidence: calculateConfidence(local: localResult, server: serverResult)
        )
    }
    
    /// Process image with progressive enhancement
    public func processImageProgressive(_ image: Data) async throws -> AsyncStream<ImageProcessingUpdate> {
        AsyncStream { continuation in
            Task {
                do {
                    // Step 1: Quick local analysis
                    continuation.yield(.started)
                    
                    let visionEngine = try await intelligenceEngine.getVisionEngine()
                    let quickResult = try await visionEngine.quickAnalysis(image)
                    continuation.yield(.localAnalysisComplete(quickResult))
                    
                    // Step 2: Detailed local analysis
                    let detailedResult = try await visionEngine.detailedAnalysis(image)
                    continuation.yield(.detailedAnalysisComplete(detailedResult))
                    
                    // Step 3: Server enhancement (if available)
                    if await circuitBreaker.canMakeRequest() {
                        let serverResult = try await sendImageToServer(image)
                        continuation.yield(.serverEnhancementComplete(serverResult))
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.yield(.error(error))
                    continuation.finish()
                }
            }
        }
    }
    
    // MARK: - Server Communication
    
    private func sendTextAnalysisRequest(_ request: TextAnalysisRequest) async throws -> ServerTextResult {
        let url = baseURL.appendingPathComponent("analyze/text")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(ServerTextResult.self, from: data)
        case 429:
            throw ServiceError.rateLimitExceeded
        case 500...599:
            throw ServiceError.serverError(httpResponse.statusCode)
        default:
            throw ServiceError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
    
    private func sendImageToServer(_ imageData: Data) async throws -> ServerImageResult {
        let url = baseURL.appendingPathComponent("analyze/image")
        
        // Create multipart request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceError.invalidResponse
        }
        
        return try JSONDecoder().decode(ServerImageResult.self, from: data)
    }
    
    // MARK: - Protection Mechanisms
    
    private func sendWithProtection<T>(
        _ operation: () async throws -> T
    ) async throws -> T {
        // Check circuit breaker
        guard await circuitBreaker.canMakeRequest() else {
            throw ServiceError.circuitBreakerOpen
        }
        
        // Apply rate limiting
        try await rateLimiter.waitForPermission()
        
        do {
            let result = try await operation()
            await circuitBreaker.recordSuccess()
            return result
        } catch {
            await circuitBreaker.recordFailure()
            
            // Queue for retry if offline
            if isNetworkError(error) {
                await requestQueue.enqueue(operation)
            }
            
            throw error
        }
    }
    
    // MARK: - Streaming Support
    
    /// Stream processing for real-time AI responses
    public func streamChat(_ message: String) -> AsyncThrowingStream<ChatResponse, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = baseURL.appendingPathComponent("chat/stream")
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.httpBody = try JSONEncoder().encode(["message": message])
                    urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    
                    let (bytes, response) = try await session.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw ServiceError.invalidResponse
                    }
                    
                    for try await line in bytes.lines {
                        if line.hasPrefix("data: ") {
                            let jsonData = line.dropFirst(6).data(using: .utf8)!
                            let response = try JSONDecoder().decode(ChatResponse.self, from: jsonData)
                            continuation.yield(response)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Batch Processing
    
    /// Batch process multiple items efficiently
    public func batchProcess<T: Encodable, R: Decodable>(
        items: [T],
        endpoint: String,
        batchSize: Int = 10
    ) async throws -> [R] {
        var results: [R] = []
        
        for batch in items.chunked(into: batchSize) {
            let batchResults = try await processBatch(batch, endpoint: endpoint)
            results.append(contentsOf: batchResults)
            
            // Add delay between batches to respect rate limits
            try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
        
        return results
    }
    
    private func processBatch<T: Encodable, R: Decodable>(
        _ items: [T],
        endpoint: String
    ) async throws -> [R] {
        let url = baseURL.appendingPathComponent(endpoint)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(["items": items])
        
        let (data, _) = try await session.data(for: urlRequest)
        let response = try JSONDecoder().decode(BatchResponse<R>.self, from: data)
        
        return response.results
    }
    
    // MARK: - Caching
    
    private func cacheResult<T: Codable>(_ result: T, for key: String) async {
        // Use SwiftIntelligence's cache manager
        let cacheManager = await intelligenceEngine.getCacheManager()
        await cacheManager.store(result, for: key, ttl: 3600) // 1 hour TTL
    }
    
    private func getCachedResult<T: Codable>(_ type: T.Type, for key: String) async -> T? {
        let cacheManager = await intelligenceEngine.getCacheManager()
        return await cacheManager.retrieve(type, for: key)
    }
    
    // MARK: - Helper Methods
    
    private func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return urlError.code == .notConnectedToInternet ||
                   urlError.code == .networkConnectionLost
        }
        return false
    }
    
    private func calculateConfidence(
        local: NLPAnalysisResult,
        server: ServerTextResult
    ) -> Double {
        // Weighted average of local and server confidence
        let localWeight = 0.4
        let serverWeight = 0.6
        
        return (local.confidence * localWeight) + (server.confidence * serverWeight)
    }
}

// MARK: - Supporting Types

public struct TextAnalysisRequest: Codable {
    let text: String
    let localAnalysis: NLPAnalysisResult
    let requestEnhancements: Bool
}

public struct ServerTextResult: Codable {
    let enhanced: Bool
    let insights: [String]
    let confidence: Double
    let metadata: [String: String]
}

public struct ServerImageResult: Codable {
    let objects: [DetectedObject]
    let scene: SceneAnalysis
    let quality: ImageQuality
}

public struct HybridTextResult {
    public let local: NLPAnalysisResult
    public let server: ServerTextResult
    public let confidence: Double
}

public enum ImageProcessingUpdate {
    case started
    case localAnalysisComplete(QuickAnalysisResult)
    case detailedAnalysisComplete(DetailedAnalysisResult)
    case serverEnhancementComplete(ServerImageResult)
    case error(Error)
}

public struct ChatResponse: Codable {
    let id: String
    let content: String
    let isComplete: Bool
    let metadata: [String: String]?
}

public struct BatchResponse<T: Decodable>: Decodable {
    let results: [T]
    let errors: [String]?
    let metadata: [String: String]?
}

// MARK: - Error Types

public enum ServiceError: LocalizedError {
    case invalidResponse
    case rateLimitExceeded
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case circuitBreakerOpen
    case deallocated
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error: \(code)"
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        case .circuitBreakerOpen:
            return "Service temporarily unavailable due to failures"
        case .deallocated:
            return "Service client was deallocated"
        case .networkUnavailable:
            return "Network connection unavailable"
        }
    }
}

// MARK: - Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
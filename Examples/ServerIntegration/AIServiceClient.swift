//
// AIServiceClient.swift
// SwiftIntelligence Server Integration Example
//
// Hybrid on-device + backend integration example for the current modular API.
//

import Foundation
import Combine
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceVision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@MainActor
public final class AIServiceClient: ObservableObject {
    private let baseURL: URL
    private let session: URLSession
    private let apiKey: String
    private let nlpEngine: NLPEngine
    private let visionEngine: VisionEngine
    private let tokenizer: PrivacyTokenizer
    private let rateLimiter: RateLimiter
    private let circuitBreaker: CircuitBreaker
    private let requestQueue: RequestQueue
    private let cache = ExampleResponseCache()

    @Published public var isProcessing = false
    @Published public var error: Error?

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

    public init(configuration: Configuration) async throws {
        self.baseURL = configuration.baseURL
        self.apiKey = configuration.apiKey
        self.nlpEngine = .shared
        self.visionEngine = .shared
        self.tokenizer = PrivacyTokenizer()
        self.rateLimiter = RateLimiter(requestsPerSecond: 10, burstSize: 20)
        self.circuitBreaker = CircuitBreaker(failureThreshold: 5, resetTimeout: 60)
        self.requestQueue = RequestQueue(maxSize: 100, enablePersistence: configuration.enableOfflineMode)

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = configuration.timeout
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(configuration.apiKey)",
            "Content-Type": "application/json",
            "X-Framework-Version": "SwiftIntelligence/\(SwiftIntelligenceCore.version)"
        ]
        self.session = URLSession(configuration: sessionConfiguration)

        let endpoints = EndpointsConfiguration(baseURL: configuration.baseURL.deletingLastPathComponent().absoluteString)
        SwiftIntelligenceCore.shared.configure(
            with: IntelligenceConfiguration.production.with(
                requestTimeout: configuration.timeout,
                endpoints: endpoints
            )
        )

        try await ensureVisionReady()
    }

    public func processTextHybrid(_ text: String) async throws -> HybridTextResult {
        isProcessing = true
        defer { isProcessing = false }

        let cacheKey = "text-\(text.hashValue)"
        if let cached: HybridTextResult = await cache.value(for: cacheKey) {
            return cached
        }

        let tokenizedText = try await tokenizeForTransport(text)
        let localResult = try await nlpEngine.analyze(text: text, options: .comprehensive)
        let localSummary = LocalTextAnalysisSummary(result: localResult)
        let request = TextAnalysisRequest(
            originalTextHash: tokenizedText.originalDataHash,
            redactedText: tokenizedText.tokens.first ?? text,
            localSummary: localSummary,
            requestEnhancements: true
        )

        do {
            let serverResult = try await sendWithProtection {
                try await self.sendTextAnalysisRequest(request)
            }
            let result = HybridTextResult(
                local: localSummary,
                server: serverResult,
                confidence: calculateConfidence(local: localResult.confidence, server: serverResult.confidence),
                redactedText: request.redactedText
            )
            await cache.store(result, for: cacheKey)
            return result
        } catch {
            self.error = error
            throw error
        }
    }

    public func processImageProgressive(_ image: PlatformImage) -> AsyncStream<ImageProcessingUpdate> {
        AsyncStream { continuation in
            Task { @MainActor in
                do {
                    continuation.yield(.started)
                    try await ensureVisionReady()

                    let classification = try await visionEngine.classifyImage(image, options: .default)
                    continuation.yield(.localClassificationComplete(LocalImageSummary(result: classification)))

                    let document = try await visionEngine.analyzeDocument(image, options: .default)
                    continuation.yield(.documentAnalysisComplete(LocalDocumentSummary(result: document)))

                    if await circuitBreaker.canMakeRequest() {
                        let imageData = try imageUploadPayload(for: image)
                        let serverResult = try await sendImageToServer(imageData)
                        continuation.yield(.serverEnhancementComplete(serverResult))
                    }

                    continuation.finish()
                } catch {
                    self.error = error
                    continuation.yield(.error(error))
                    continuation.finish()
                }
            }
        }
    }

    public func streamChat(_ message: String) -> AsyncThrowingStream<ChatResponse, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = baseURL.appendingPathComponent("chat/stream")
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = try JSONEncoder().encode(["message": message])
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

                    let (bytes, response) = try await session.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw ServiceError.invalidResponse
                    }

                    for try await line in bytes.lines where line.hasPrefix("data: ") {
                        let jsonData = Data(line.dropFirst(6).utf8)
                        continuation.yield(try JSONDecoder().decode(ChatResponse.self, from: jsonData))
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

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
        case 200 ... 299:
            return try JSONDecoder().decode(ServerTextResult.self, from: data)
        case 429:
            throw ServiceError.rateLimitExceeded
        case 500 ... 599:
            throw ServiceError.serverError(httpResponse.statusCode)
        default:
            throw ServiceError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    private func sendImageToServer(_ imageData: Data) async throws -> ServerImageResult {
        let url = baseURL.appendingPathComponent("analyze/image")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(data: imageData, boundary: boundary)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw ServiceError.unexpectedStatusCode(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(ServerImageResult.self, from: data)
    }

    private func sendWithProtection<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        guard await circuitBreaker.canMakeRequest() else {
            throw ServiceError.circuitBreakerOpen
        }

        try await rateLimiter.waitForPermission()

        do {
            let result = try await operation()
            await circuitBreaker.recordSuccess()
            return result
        } catch {
            await circuitBreaker.recordFailure()
            if isNetworkError(error) {
                await requestQueue.enqueue(operation)
            }
            throw error
        }
    }

    private func ensureVisionReady() async throws {
        if !visionEngine.isInitialized {
            try await visionEngine.initialize()
        }
    }

    private func tokenizeForTransport(_ text: String) async throws -> TokenizedData {
        let context = TokenizationContext(
            purpose: .analytics,
            sensitivity: .high,
            retentionPolicy: .temporary
        )
        return try await tokenizer.tokenize(text, context: context)
    }

    private func makeMultipartBody(data: Data, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    private func imageUploadPayload(for image: PlatformImage) throws -> Data {
        #if canImport(UIKit)
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw ServiceError.unsupportedImage
        }
        return data
        #elseif canImport(AppKit)
        guard
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.85])
        else {
            throw ServiceError.unsupportedImage
        }
        return data
        #else
        throw ServiceError.unsupportedImage
        #endif
    }

    private func isNetworkError(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else {
            return false
        }
        return urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost
    }

    private func calculateConfidence(local: Float, server: Double) -> Double {
        (Double(local) * 0.4) + (server * 0.6)
    }
}

public struct TextAnalysisRequest: Codable {
    let originalTextHash: String
    let redactedText: String
    let localSummary: LocalTextAnalysisSummary
    let requestEnhancements: Bool
}

public struct LocalTextAnalysisSummary: Codable {
    public let language: String
    public let confidence: Float
    public let sentiment: SentimentSnapshot?
    public let entities: [EntitySnapshot]
    public let keywords: [KeywordSnapshot]
    public let sentenceCount: Int

    public init(result: NLPResult) {
        let sentiment = result.analysisResults["sentiment"] as? SentimentResult
        let entities = result.analysisResults["entities"] as? [NamedEntity] ?? []
        let keywords = result.analysisResults["keywords"] as? [Keyword] ?? []

        self.language = result.detectedLanguage.rawValue
        self.confidence = result.confidence
        self.sentiment = sentiment.map(SentimentSnapshot.init)
        self.entities = entities.map(EntitySnapshot.init)
        self.keywords = Array(keywords.prefix(8)).map(KeywordSnapshot.init)
        self.sentenceCount = result.sentences.count
    }
}

public struct SentimentSnapshot: Codable {
    public let label: String
    public let score: Float
    public let confidence: Float

    public init(_ result: SentimentResult) {
        label = result.sentiment.rawValue
        score = result.score
        confidence = result.confidence
    }
}

public struct EntitySnapshot: Codable {
    public let text: String
    public let type: String
    public let confidence: Float

    public init(_ entity: NamedEntity) {
        text = entity.text
        type = entity.type.rawValue
        confidence = entity.confidence
    }
}

public struct KeywordSnapshot: Codable {
    public let word: String
    public let score: Float

    public init(_ keyword: Keyword) {
        word = keyword.word
        score = keyword.score
    }
}

public struct LocalImageSummary {
    public let labels: [String]
    public let confidence: Float

    public init(result: ImageClassificationResult) {
        labels = Array(result.classifications.prefix(3)).map(\.label)
        confidence = result.confidence
    }
}

public struct LocalDocumentSummary {
    public let textPreview: String
    public let headingCount: Int
    public let confidence: Float

    public init(result: DocumentAnalysisResult) {
        textPreview = String(result.documentText.prefix(160))
        headingCount = result.layout.headings.count
        confidence = result.confidence
    }
}

public struct ServerTextResult: Codable {
    public let enhanced: Bool
    public let insights: [String]
    public let confidence: Double
    public let metadata: [String: String]
}

public struct ServerImageResult: Codable {
    public let labels: [String]
    public let extractedText: String?
    public let confidence: Double
    public let metadata: [String: String]
}

public struct HybridTextResult: Codable {
    public let local: LocalTextAnalysisSummary
    public let server: ServerTextResult
    public let confidence: Double
    public let redactedText: String
}

public enum ImageProcessingUpdate {
    case started
    case localClassificationComplete(LocalImageSummary)
    case documentAnalysisComplete(LocalDocumentSummary)
    case serverEnhancementComplete(ServerImageResult)
    case error(Error)
}

public struct ChatResponse: Codable {
    public let id: String
    public let content: String
    public let isComplete: Bool
    public let metadata: [String: String]?
}

public enum ServiceError: LocalizedError {
    case invalidResponse
    case rateLimitExceeded
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case circuitBreakerOpen
    case networkUnavailable
    case unsupportedImage

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
        case .networkUnavailable:
            return "Network connection unavailable"
        case .unsupportedImage:
            return "Image could not be encoded for upload"
        }
    }
}

private actor ExampleResponseCache {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func store<T: Encodable>(_ value: T, for key: String) async {
        storage[key] = try? encoder.encode(value)
    }

    func value<T: Decodable>(for key: String) async -> T? {
        guard let data = storage[key] else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }
}

private extension IntelligenceConfiguration {
    func with(requestTimeout: TimeInterval, endpoints: EndpointsConfiguration) -> IntelligenceConfiguration {
        IntelligenceConfiguration(
            debugMode: debugMode,
            performanceMonitoring: performanceMonitoring,
            verboseLogging: verboseLogging,
            memoryLimit: memoryLimit,
            requestTimeout: requestTimeout,
            cacheDuration: cacheDuration,
            maxConcurrentOperations: maxConcurrentOperations,
            privacyMode: privacyMode,
            telemetryEnabled: telemetryEnabled,
            endpoints: endpoints,
            modelPaths: modelPaths,
            enableOnDeviceProcessing: enableOnDeviceProcessing,
            enableCloudFallback: enableCloudFallback,
            enableNeuralEngine: enableNeuralEngine,
            batchSize: batchSize,
            logLevel: logLevel,
            performanceProfile: performanceProfile,
            privacyLevel: privacyLevel,
            cachePolicy: cachePolicy
        )
    }
}

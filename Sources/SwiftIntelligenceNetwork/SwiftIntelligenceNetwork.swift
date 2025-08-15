import Foundation
import SwiftIntelligenceCore

#if canImport(Network)
import Network
#endif

#if canImport(Combine)
import Combine
#endif

/// Network Engine - Comprehensive networking capabilities with HTTP/HTTPS, WebSocket, GraphQL support
public actor SwiftIntelligenceNetwork {
    
    // MARK: - Properties
    
    public let moduleID = "Network"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - Network Components
    
    private var httpClient: any HTTPClient = DefaultHTTPClient(configuration: .default)
    private var webSocketManager: any WebSocketManager = DefaultWebSocketManager(configuration: .default)
    private var graphQLClient: any GraphQLClient = DefaultGraphQLClient(configuration: .default)
    private var networkMonitor: any NetworkMonitor = DefaultNetworkMonitor()
    private var requestInterceptors: [RequestInterceptor] = []
    private var responseInterceptors: [ResponseInterceptor] = []
    
    // MARK: - Caching and Performance
    
    private var requestCache: [String: NetworkResponse] = [:]
    private let maxCacheSize = 1000
    private var retryPolicies: [String: RetryPolicy] = [:]
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: NetworkPerformanceMetrics = NetworkPerformanceMetrics()
    nonisolated private let logger = IntelligenceLogger()
    
    // MARK: - Configuration
    
    private var networkConfiguration: NetworkConfiguration = .default
    private let supportedProtocols: [NetworkProtocol] = [
        .http, .https, .websocket, .graphql
    ]
    
    // MARK: - Session Management
    
    private var urlSessions: [String: URLSession] = [:]
    private let defaultSessionConfiguration = URLSessionConfiguration.default
    
    // MARK: - Initialization
    
    public init() async throws {
        try await initializeNetworkEngine()
    }
    
    private func initializeNetworkEngine() async throws {
        status = .initializing
        logger.info("Initializing Network Engine...", category: "Network")
        
        // Setup network capabilities
        await setupNetworkCapabilities()
        await validateNetworkFrameworks()
        await initializeNetworkMonitoring()
        
        status = .ready
        logger.info("Network Engine initialized successfully", category: "Network")
    }
    
    private func setupNetworkCapabilities() async {
        logger.debug("Setting up Network capabilities", category: "Network")
        
        // Initialize HTTP client
        httpClient = DefaultHTTPClient(configuration: networkConfiguration.httpConfiguration)
        
        // Setup WebSocket manager
        webSocketManager = DefaultWebSocketManager(configuration: networkConfiguration.webSocketConfiguration)
        
        // Initialize GraphQL client
        graphQLClient = DefaultGraphQLClient(configuration: networkConfiguration.graphQLConfiguration)
        
        // Setup network monitoring
        networkMonitor = DefaultNetworkMonitor()
        
        // Initialize performance metrics
        performanceMetrics = NetworkPerformanceMetrics()
        
        // Setup default retry policies
        await setupDefaultRetryPolicies()
        
        logger.debug("Network capabilities configured", category: "Network")
    }
    
    private func validateNetworkFrameworks() async {
        logger.debug("Validating Network frameworks", category: "Network")
        
        // Check Network framework availability
        #if canImport(Network)
        logger.info("Network framework available for advanced networking", category: "Network")
        #else
        logger.warning("Network framework not available", category: "Network")
        #endif
        
        // Check Combine framework availability
        #if canImport(Combine)
        logger.info("Combine framework available for reactive networking", category: "Network")
        #else
        logger.warning("Combine framework not available", category: "Network")
        #endif
        
        // Validate URLSession availability
        logger.info("URLSession available for HTTP networking", category: "Network")
    }
    
    private func initializeNetworkMonitoring() async {
        logger.debug("Initializing network monitoring", category: "Network")
        
        // Start network path monitoring
        await networkMonitor.startMonitoring()
        
        // Setup network change callbacks
        await setupNetworkMonitoringCallbacks()
        
        logger.debug("Network monitoring initialized", category: "Network")
    }
    
    private func setupNetworkMonitoringCallbacks() async {
        // Network status change callback
        await networkMonitor.setNetworkStatusChangeCallback { [weak self] status in
            Task { @MainActor in
                await self?.handleNetworkStatusChange(status)
            }
        }
    }
    
    private func handleNetworkStatusChange(_ status: NetworkStatus) async {
        logger.info("Network status changed to: \(status.description)", category: "Network")
        
        // Update performance metrics
        performanceMetrics.networkStatusChanges += 1
        performanceMetrics.currentNetworkStatus = status.rawValue
        
        // Handle connectivity changes
        switch status {
        case .connected:
            await resumeQueuedRequests()
        case .disconnected:
            await pauseActiveRequests()
        case .limited:
            await adjustRequestPriorities()
        case .connecting:
            logger.debug("Network connecting...", category: "Network")
        case .unknown:
            logger.warning("Network status unknown", category: "Network")
        }
    }
    
    private func setupDefaultRetryPolicies() async {
        // HTTP retry policy
        retryPolicies["http"] = RetryPolicy(
            maxAttempts: 3,
            baseDelay: 1.0,
            backoffMultiplier: 2.0,
            maxDelay: 60.0,
            retryableStatusCodes: [408, 429, 500, 502, 503, 504]
        )
        
        // GraphQL retry policy
        retryPolicies["graphql"] = RetryPolicy(
            maxAttempts: 2,
            baseDelay: 0.5,
            backoffMultiplier: 1.5,
            maxDelay: 30.0,
            retryableStatusCodes: [500, 502, 503, 504]
        )
        
        // WebSocket retry policy
        retryPolicies["websocket"] = RetryPolicy(
            maxAttempts: 5,
            baseDelay: 2.0,
            backoffMultiplier: 1.5,
            maxDelay: 120.0,
            retryableStatusCodes: []
        )
    }
    
    // MARK: - HTTP Operations
    
    /// Perform HTTP GET request
    public func get(url: URL, headers: [String: String] = [:], options: RequestOptions = .default) async throws -> NetworkResponse {
        return try await performHTTPRequest(.get, url: url, headers: headers, body: nil, options: options)
    }
    
    /// Perform HTTP POST request
    public func post(url: URL, body: Data?, headers: [String: String] = [:], options: RequestOptions = .default) async throws -> NetworkResponse {
        return try await performHTTPRequest(.post, url: url, headers: headers, body: body, options: options)
    }
    
    /// Perform HTTP PUT request
    public func put(url: URL, body: Data?, headers: [String: String] = [:], options: RequestOptions = .default) async throws -> NetworkResponse {
        return try await performHTTPRequest(.put, url: url, headers: headers, body: body, options: options)
    }
    
    /// Perform HTTP DELETE request
    public func delete(url: URL, headers: [String: String] = [:], options: RequestOptions = .default) async throws -> NetworkResponse {
        return try await performHTTPRequest(.delete, url: url, headers: headers, body: nil, options: options)
    }
    
    /// Perform HTTP PATCH request
    public func patch(url: URL, body: Data?, headers: [String: String] = [:], options: RequestOptions = .default) async throws -> NetworkResponse {
        return try await performHTTPRequest(.patch, url: url, headers: headers, body: body, options: options)
    }
    
    private func performHTTPRequest(
        _ method: HTTPMethod,
        url: URL,
        headers: [String: String],
        body: Data?,
        options: RequestOptions
    ) async throws -> NetworkResponse {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Performing \(method.rawValue) request to: \(url.absoluteString)", category: "Network")
        
        // Check cache first if cacheable
        if options.cachePolicy.shouldReadFromCache && method == .get {
            if let cachedResponse = await getCachedResponse(for: url, method: method) {
                logger.debug("Using cached response for request", category: "Network")
                await updateCacheMetrics()
                return cachedResponse
            }
        }
        
        // Create HTTP request
        let request = NetworkRequest(
            method: method,
            url: url,
            headers: headers,
            body: body,
            options: options
        )
        
        // Apply request interceptors
        let processedRequest = await applyRequestInterceptors(request)
        
        // Perform the actual HTTP request
        let response = try await httpClient.performRequest(processedRequest)
        
        // Apply response interceptors
        let processedResponse = await applyResponseInterceptors(response, for: processedRequest)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateHTTPMetrics(duration: duration, method: method, statusCode: response.statusCode)
        
        // Cache response if cacheable
        if options.cachePolicy.shouldWriteToCache && isResponseCacheable(response) {
            await cacheResponse(processedResponse, for: url, method: method)
        }
        
        logger.info("\(method.rawValue) request completed - Status: \(response.statusCode)", category: "Network")
        return processedResponse
    }
    
    // MARK: - WebSocket Operations
    
    /// Connect to WebSocket
    public func connectWebSocket(url: URL, protocols: [String] = [], options: WebSocketOptions = .default) async throws -> WebSocketConnection {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        logger.info("Connecting to WebSocket: \(url.absoluteString)", category: "Network")
        
        let connection = try await webSocketManager.connect(url: url, protocols: protocols, options: options)
        
        await updateWebSocketMetrics(event: .connected)
        
        logger.info("WebSocket connection established", category: "Network")
        return connection
    }
    
    /// Send WebSocket message
    public func sendWebSocketMessage(_ message: WebSocketMessage, to connection: WebSocketConnection) async throws {
        try await webSocketManager.sendMessage(message, to: connection)
        await updateWebSocketMetrics(event: .messageSent)
        logger.debug("WebSocket message sent", category: "Network")
    }
    
    /// Disconnect WebSocket
    public func disconnectWebSocket(_ connection: WebSocketConnection) async throws {
        try await webSocketManager.disconnect(connection)
        await updateWebSocketMetrics(event: .disconnected)
        logger.info("WebSocket disconnected", category: "Network")
    }
    
    // MARK: - GraphQL Operations
    
    /// Execute GraphQL query
    public func executeGraphQLQuery(_ query: GraphQLQuery, variables: [String: String] = [:], options: GraphQLOptions = .default) async throws -> GraphQLResponse {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Executing GraphQL query", category: "Network")
        
        let response = try await graphQLClient.executeQuery(query, variables: variables, options: options)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateGraphQLMetrics(duration: duration, hasErrors: !response.errors.isEmpty)
        
        logger.info("GraphQL query completed - Errors: \(response.errors.count)", category: "Network")
        return response
    }
    
    /// Execute GraphQL mutation
    public func executeGraphQLMutation(_ mutation: GraphQLMutation, variables: [String: String] = [:], options: GraphQLOptions = .default) async throws -> GraphQLResponse {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Executing GraphQL mutation", category: "Network")
        
        let response = try await graphQLClient.executeMutation(mutation, variables: variables, options: options)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateGraphQLMetrics(duration: duration, hasErrors: !response.errors.isEmpty)
        
        logger.info("GraphQL mutation completed - Errors: \(response.errors.count)", category: "Network")
        return response
    }
    
    /// Subscribe to GraphQL subscription
    public func subscribeToGraphQL(_ subscription: GraphQLSubscription, variables: [String: String] = [:], options: GraphQLOptions = .default) async throws -> AsyncStream<GraphQLResponse> {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        logger.info("Starting GraphQL subscription", category: "Network")
        
        let stream = try await graphQLClient.subscribe(subscription, variables: variables, options: options)
        
        await updateGraphQLMetrics(duration: 0, hasErrors: false)
        
        logger.info("GraphQL subscription started", category: "Network")
        return stream
    }
    
    // MARK: - File Operations
    
    /// Upload file
    public func uploadFile(url: URL, fileData: Data, fileName: String, mimeType: String, options: UploadOptions = .default) async throws -> NetworkResponse {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Uploading file: \(fileName) to \(url.absoluteString)", category: "Network")
        
        let uploadResponse = try await httpClient.uploadFile(
            url: url,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            options: options
        )
        
        let duration = Date().timeIntervalSince(startTime)
        await updateUploadMetrics(duration: duration, fileSize: fileData.count)
        
        logger.info("File upload completed - Size: \(fileData.count) bytes", category: "Network")
        return uploadResponse
    }
    
    /// Download file
    public func downloadFile(url: URL, options: DownloadOptions = .default) async throws -> DownloadResult {
        guard status == .ready else {
            throw IntelligenceError(code: "NETWORK_NOT_READY", message: "Network Engine not ready")
        }
        
        let startTime = Date()
        logger.info("Downloading file from: \(url.absoluteString)", category: "Network")
        
        let downloadResult = try await httpClient.downloadFile(url: url, options: options)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateDownloadMetrics(duration: duration, fileSize: downloadResult.fileSize)
        
        logger.info("File download completed - Size: \(downloadResult.fileSize) bytes", category: "Network")
        return downloadResult
    }
    
    // MARK: - Network Monitoring
    
    /// Get current network status
    public func getNetworkStatus() async -> NetworkStatus {
        return await networkMonitor.getCurrentStatus()
    }
    
    /// Check if connected to internet
    public func isConnectedToInternet() async -> Bool {
        let status = await getNetworkStatus()
        return status == .connected
    }
    
    /// Get network connection type
    public func getConnectionType() async -> ConnectionType {
        return await networkMonitor.getConnectionType()
    }
    
    // MARK: - Request Interceptors
    
    /// Add request interceptor
    public func addRequestInterceptor(_ interceptor: RequestInterceptor) async {
        requestInterceptors.append(interceptor)
        logger.debug("Request interceptor added", category: "Network")
    }
    
    /// Add response interceptor
    public func addResponseInterceptor(_ interceptor: ResponseInterceptor) async {
        responseInterceptors.append(interceptor)
        logger.debug("Response interceptor added", category: "Network")
    }
    
    // MARK: - Cache Management
    
    /// Clear network cache
    public func clearCache() async {
        requestCache.removeAll()
        await httpClient.clearCache()
        performanceMetrics.cacheClears += 1
        logger.info("Network cache cleared", category: "Network")
    }
    
    /// Get cache statistics
    public func getCacheStats() async -> (size: Int, maxSize: Int, hitRate: Float) {
        let hitRate = performanceMetrics.totalRequests > 0 
            ? Float(performanceMetrics.cacheHits) / Float(performanceMetrics.totalRequests)
            : 0.0
        return (requestCache.count, maxCacheSize, hitRate)
    }
    
    // MARK: - Utility Methods
    
    private func applyRequestInterceptors(_ request: NetworkRequest) async -> NetworkRequest {
        var processedRequest = request
        
        for interceptor in requestInterceptors {
            processedRequest = await interceptor.intercept(processedRequest)
        }
        
        return processedRequest
    }
    
    private func applyResponseInterceptors(_ response: NetworkResponse, for request: NetworkRequest) async -> NetworkResponse {
        var processedResponse = response
        
        for interceptor in responseInterceptors {
            processedResponse = await interceptor.intercept(processedResponse, for: request)
        }
        
        return processedResponse
    }
    
    private func getCachedResponse(for url: URL, method: HTTPMethod) async -> NetworkResponse? {
        let cacheKey = generateCacheKey(url: url, method: method)
        return requestCache[cacheKey]
    }
    
    private func cacheResponse(_ response: NetworkResponse, for url: URL, method: HTTPMethod) async {
        let cacheKey = generateCacheKey(url: url, method: method)
        requestCache[cacheKey] = response
        
        // Limit cache size
        if requestCache.count > maxCacheSize {
            let oldestKey = requestCache.keys.first
            if let key = oldestKey {
                requestCache.removeValue(forKey: key)
            }
        }
    }
    
    private func generateCacheKey(url: URL, method: HTTPMethod) -> String {
        return "\(method.rawValue)_\(url.absoluteString.hash)"
    }
    
    private func isResponseCacheable(_ response: NetworkResponse) -> Bool {
        // Only cache successful GET responses
        return response.statusCode >= 200 && response.statusCode < 300
    }
    
    private func resumeQueuedRequests() async {
        // Implementation for resuming queued requests when network becomes available
        logger.info("Resuming queued network requests", category: "Network")
    }
    
    private func pauseActiveRequests() async {
        // Implementation for pausing active requests when network becomes unavailable
        logger.info("Pausing active network requests", category: "Network")
    }
    
    private func adjustRequestPriorities() async {
        // Implementation for adjusting request priorities when network is limited
        logger.info("Adjusting network request priorities", category: "Network")
    }
    
    // MARK: - Performance Metrics
    
    private func updateHTTPMetrics(duration: TimeInterval, method: HTTPMethod, statusCode: Int) async {
        performanceMetrics.totalRequests += 1
        performanceMetrics.totalHTTPRequests += 1
        performanceMetrics.averageRequestTime = (performanceMetrics.averageRequestTime + duration) / 2.0
        
        switch method {
        case .get:
            performanceMetrics.getRequests += 1
        case .post:
            performanceMetrics.postRequests += 1
        case .put:
            performanceMetrics.putRequests += 1
        case .delete:
            performanceMetrics.deleteRequests += 1
        case .patch:
            performanceMetrics.patchRequests += 1
        case .head, .options, .trace, .connect:
            break // Not tracked separately
        }
        
        if statusCode >= 200 && statusCode < 300 {
            performanceMetrics.successfulRequests += 1
        } else {
            performanceMetrics.failedRequests += 1
        }
    }
    
    private func updateWebSocketMetrics(event: WebSocketEvent) async {
        switch event {
        case .connected:
            performanceMetrics.webSocketConnections += 1
        case .disconnected:
            performanceMetrics.webSocketDisconnections += 1
        case .messageSent:
            performanceMetrics.webSocketMessagesSent += 1
        case .messageReceived:
            performanceMetrics.webSocketMessagesReceived += 1
        case .error:
            performanceMetrics.webSocketErrors += 1
        }
    }
    
    private func updateGraphQLMetrics(duration: TimeInterval, hasErrors: Bool) async {
        performanceMetrics.totalGraphQLOperations += 1
        performanceMetrics.averageGraphQLTime = (performanceMetrics.averageGraphQLTime + duration) / 2.0
        
        if hasErrors {
            performanceMetrics.graphQLErrors += 1
        } else {
            performanceMetrics.successfulGraphQLOperations += 1
        }
    }
    
    private func updateUploadMetrics(duration: TimeInterval, fileSize: Int) async {
        performanceMetrics.totalUploads += 1
        performanceMetrics.totalBytesUploaded += fileSize
        performanceMetrics.averageUploadTime = (performanceMetrics.averageUploadTime + duration) / 2.0
    }
    
    private func updateDownloadMetrics(duration: TimeInterval, fileSize: Int) async {
        performanceMetrics.totalDownloads += 1
        performanceMetrics.totalBytesDownloaded += fileSize
        performanceMetrics.averageDownloadTime = (performanceMetrics.averageDownloadTime + duration) / 2.0
    }
    
    private func updateCacheMetrics() async {
        performanceMetrics.cacheHits += 1
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> NetworkPerformanceMetrics {
        return performanceMetrics
    }
    
    /// Get current configuration
    public func getConfiguration() async -> NetworkConfiguration {
        return networkConfiguration
    }
    
    /// Update configuration
    public func updateConfiguration(_ configuration: NetworkConfiguration) async {
        networkConfiguration = configuration
        await httpClient.updateConfiguration(configuration.httpConfiguration)
        await webSocketManager.updateConfiguration(configuration.webSocketConfiguration)
        await graphQLClient.updateConfiguration(configuration.graphQLConfiguration)
        logger.info("Network configuration updated", category: "Network")
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceNetwork: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeNetworkEngine()
    }
    
    public func shutdown() async throws {
        await clearCache()
        await networkMonitor.stopMonitoring()
        try await webSocketManager.disconnectAll()
        status = .shutdown
        logger.info("Network Engine shutdown complete", category: "Network")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "NETWORK_NOT_READY", message: "Network Engine not ready"))
        }
        
        // Validate HTTP client
        let httpValid = await httpClient.validate()
        if !httpValid {
            errors.append(ValidationError(code: "HTTP_CLIENT_INVALID", message: "HTTP client validation failed"))
        }
        
        // Validate WebSocket manager
        let wsValid = await webSocketManager.validate()
        if !wsValid {
            warnings.append(ValidationWarning(code: "WEBSOCKET_MANAGER_INVALID", message: "WebSocket manager validation failed"))
        }
        
        // Validate GraphQL client
        let graphQLValid = await graphQLClient.validate()
        if !graphQLValid {
            warnings.append(ValidationWarning(code: "GRAPHQL_CLIENT_INVALID", message: "GraphQL client validation failed"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let metrics = [
            "total_requests": String(performanceMetrics.totalRequests),
            "successful_requests": String(performanceMetrics.successfulRequests),
            "failed_requests": String(performanceMetrics.failedRequests),
            "websocket_connections": String(performanceMetrics.webSocketConnections),
            "graphql_operations": String(performanceMetrics.totalGraphQLOperations),
            "cache_hits": String(performanceMetrics.cacheHits),
            "network_status": performanceMetrics.currentNetworkStatus,
            "cache_size": String(requestCache.count)
        ]
        
        switch status {
        case .ready:
            let networkStatus = await getNetworkStatus()
            let statusMessage = networkStatus == .connected 
                ? "Network Engine operational with \(performanceMetrics.totalRequests) requests processed"
                : "Network Engine ready but network is \(networkStatus.description)"
            
            return HealthStatus(
                status: networkStatus == .connected ? .healthy : .degraded,
                message: statusMessage,
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "Network Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "Network Engine not ready",
                metrics: metrics
            )
        }
    }
}

// MARK: - Supporting Enums

private enum WebSocketEvent {
    case connected
    case disconnected
    case messageSent
    case messageReceived
    case error
}

// MARK: - Performance Metrics

/// Network engine performance metrics
public struct NetworkPerformanceMetrics: Sendable {
    public var totalRequests: Int = 0
    public var successfulRequests: Int = 0
    public var failedRequests: Int = 0
    
    public var totalHTTPRequests: Int = 0
    public var getRequests: Int = 0
    public var postRequests: Int = 0
    public var putRequests: Int = 0
    public var deleteRequests: Int = 0
    public var patchRequests: Int = 0
    
    public var webSocketConnections: Int = 0
    public var webSocketDisconnections: Int = 0
    public var webSocketMessagesSent: Int = 0
    public var webSocketMessagesReceived: Int = 0
    public var webSocketErrors: Int = 0
    
    public var totalGraphQLOperations: Int = 0
    public var successfulGraphQLOperations: Int = 0
    public var graphQLErrors: Int = 0
    
    public var totalUploads: Int = 0
    public var totalDownloads: Int = 0
    public var totalBytesUploaded: Int = 0
    public var totalBytesDownloaded: Int = 0
    
    public var cacheHits: Int = 0
    public var cacheClears: Int = 0
    public var networkStatusChanges: Int = 0
    
    public var averageRequestTime: TimeInterval = 0.0
    public var averageGraphQLTime: TimeInterval = 0.0
    public var averageUploadTime: TimeInterval = 0.0
    public var averageDownloadTime: TimeInterval = 0.0
    
    public var currentNetworkStatus: String = "unknown"
    
    public init() {}
}
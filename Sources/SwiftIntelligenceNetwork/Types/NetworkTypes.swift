import Foundation
import SwiftIntelligenceCore

#if canImport(Network)
import Network
#endif

// MARK: - Core Network Types

public enum NetworkProtocol: String, CaseIterable, Codable {
    case http = "http"
    case https = "https"
    case websocket = "websocket"
    case graphql = "graphql"
    case ftp = "ftp"
    case tcp = "tcp"
    case udp = "udp"
}

public enum HTTPMethod: String, CaseIterable, Codable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public enum NetworkStatus: String, CaseIterable, Codable, Sendable {
    case connected = "connected"
    case disconnected = "disconnected"
    case connecting = "connecting"
    case limited = "limited"
    case unknown = "unknown"
    
    public var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .limited: return "Limited Connectivity"
        case .unknown: return "Unknown Status"
        }
    }
}

public enum ConnectionType: String, CaseIterable, Codable, Sendable {
    case wifi = "wifi"
    case cellular = "cellular"
    case ethernet = "ethernet"
    case bluetooth = "bluetooth"
    case other = "other"
    case unavailable = "unavailable"
    
    public var description: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .ethernet: return "Ethernet"
        case .bluetooth: return "Bluetooth"
        case .other: return "Other"
        case .unavailable: return "Unavailable"
        }
    }
}

// MARK: - Configuration Types

public struct NetworkConfiguration: Sendable {
    public let httpConfiguration: HTTPConfiguration
    public let webSocketConfiguration: WebSocketConfiguration
    public let graphQLConfiguration: GraphQLConfiguration
    public let timeoutConfiguration: TimeoutConfiguration
    public let retryConfiguration: RetryConfiguration
    public let cacheConfiguration: CacheConfiguration
    
    public init(
        httpConfiguration: HTTPConfiguration = .default,
        webSocketConfiguration: WebSocketConfiguration = .default,
        graphQLConfiguration: GraphQLConfiguration = .default,
        timeoutConfiguration: TimeoutConfiguration = .default,
        retryConfiguration: RetryConfiguration = .default,
        cacheConfiguration: CacheConfiguration = .default
    ) {
        self.httpConfiguration = httpConfiguration
        self.webSocketConfiguration = webSocketConfiguration
        self.graphQLConfiguration = graphQLConfiguration
        self.timeoutConfiguration = timeoutConfiguration
        self.retryConfiguration = retryConfiguration
        self.cacheConfiguration = cacheConfiguration
    }
    
    public static let `default` = NetworkConfiguration()
    
    public static let highPerformance = NetworkConfiguration(
        httpConfiguration: .highPerformance,
        webSocketConfiguration: .highPerformance,
        timeoutConfiguration: .fast,
        retryConfiguration: .aggressive,
        cacheConfiguration: .aggressive
    )
    
    public static let lowLatency = NetworkConfiguration(
        httpConfiguration: .lowLatency,
        webSocketConfiguration: .lowLatency,
        timeoutConfiguration: .immediate,
        retryConfiguration: .minimal,
        cacheConfiguration: .minimal
    )
}

public struct HTTPConfiguration: Sendable {
    public let maxConcurrentRequests: Int
    public let allowsCellularAccess: Bool
    public let waitsForConnectivity: Bool
    public let httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy
    public let httpShouldSetCookies: Bool
    public let httpMaximumConnectionsPerHost: Int
    public let networkServiceType: URLRequest.NetworkServiceType
    
    public init(
        maxConcurrentRequests: Int = 6,
        allowsCellularAccess: Bool = true,
        waitsForConnectivity: Bool = false,
        httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy = .always,
        httpShouldSetCookies: Bool = true,
        httpMaximumConnectionsPerHost: Int = 4,
        networkServiceType: URLRequest.NetworkServiceType = .default
    ) {
        self.maxConcurrentRequests = maxConcurrentRequests
        self.allowsCellularAccess = allowsCellularAccess
        self.waitsForConnectivity = waitsForConnectivity
        self.httpCookieAcceptPolicy = httpCookieAcceptPolicy
        self.httpShouldSetCookies = httpShouldSetCookies
        self.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost
        self.networkServiceType = networkServiceType
    }
    
    public static let `default` = HTTPConfiguration()
    
    public static let highPerformance = HTTPConfiguration(
        maxConcurrentRequests: 12,
        allowsCellularAccess: true,
        waitsForConnectivity: true,
        httpMaximumConnectionsPerHost: 8,
        networkServiceType: .responsiveData
    )
    
    public static let lowLatency = HTTPConfiguration(
        maxConcurrentRequests: 4,
        allowsCellularAccess: true,
        waitsForConnectivity: false,
        httpMaximumConnectionsPerHost: 2,
        networkServiceType: .responsiveData
    )
}

public struct WebSocketConfiguration: Sendable {
    public let pingInterval: TimeInterval
    public let pongTimeout: TimeInterval
    public let reconnectDelay: TimeInterval
    public let maxReconnectAttempts: Int
    public let enableCompression: Bool
    public let maxFrameSize: Int
    
    public init(
        pingInterval: TimeInterval = 30.0,
        pongTimeout: TimeInterval = 10.0,
        reconnectDelay: TimeInterval = 5.0,
        maxReconnectAttempts: Int = 3,
        enableCompression: Bool = true,
        maxFrameSize: Int = 1024 * 1024 // 1MB
    ) {
        self.pingInterval = pingInterval
        self.pongTimeout = pongTimeout
        self.reconnectDelay = reconnectDelay
        self.maxReconnectAttempts = maxReconnectAttempts
        self.enableCompression = enableCompression
        self.maxFrameSize = maxFrameSize
    }
    
    public static let `default` = WebSocketConfiguration()
    
    public static let highPerformance = WebSocketConfiguration(
        pingInterval: 15.0,
        pongTimeout: 5.0,
        reconnectDelay: 2.0,
        maxReconnectAttempts: 5,
        enableCompression: true,
        maxFrameSize: 2 * 1024 * 1024 // 2MB
    )
    
    public static let lowLatency = WebSocketConfiguration(
        pingInterval: 60.0,
        pongTimeout: 15.0,
        reconnectDelay: 10.0,
        maxReconnectAttempts: 2,
        enableCompression: false,
        maxFrameSize: 512 * 1024 // 512KB
    )
}

public struct GraphQLConfiguration: Sendable {
    public let endpoint: URL?
    public let subscriptionEndpoint: URL?
    public let enableIntrospection: Bool
    public let enableQueryDeduplication: Bool
    public let queryDepthLimit: Int
    public let queryComplexityLimit: Int
    public let enablePersistentQueries: Bool
    
    public init(
        endpoint: URL? = nil,
        subscriptionEndpoint: URL? = nil,
        enableIntrospection: Bool = true,
        enableQueryDeduplication: Bool = true,
        queryDepthLimit: Int = 10,
        queryComplexityLimit: Int = 1000,
        enablePersistentQueries: Bool = false
    ) {
        self.endpoint = endpoint
        self.subscriptionEndpoint = subscriptionEndpoint
        self.enableIntrospection = enableIntrospection
        self.enableQueryDeduplication = enableQueryDeduplication
        self.queryDepthLimit = queryDepthLimit
        self.queryComplexityLimit = queryComplexityLimit
        self.enablePersistentQueries = enablePersistentQueries
    }
    
    public static let `default` = GraphQLConfiguration()
}

public struct TimeoutConfiguration: Sendable {
    public let connectionTimeout: TimeInterval
    public let requestTimeout: TimeInterval
    public let resourceTimeout: TimeInterval
    public let webSocketTimeout: TimeInterval
    
    public init(
        connectionTimeout: TimeInterval = 30.0,
        requestTimeout: TimeInterval = 60.0,
        resourceTimeout: TimeInterval = 300.0,
        webSocketTimeout: TimeInterval = 60.0
    ) {
        self.connectionTimeout = connectionTimeout
        self.requestTimeout = requestTimeout
        self.resourceTimeout = resourceTimeout
        self.webSocketTimeout = webSocketTimeout
    }
    
    public static let `default` = TimeoutConfiguration()
    
    public static let fast = TimeoutConfiguration(
        connectionTimeout: 15.0,
        requestTimeout: 30.0,
        resourceTimeout: 120.0,
        webSocketTimeout: 30.0
    )
    
    public static let immediate = TimeoutConfiguration(
        connectionTimeout: 5.0,
        requestTimeout: 10.0,
        resourceTimeout: 30.0,
        webSocketTimeout: 10.0
    )
}

public struct RetryConfiguration: Sendable {
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let backoffMultiplier: Double
    public let maxDelay: TimeInterval
    public let jitterEnabled: Bool
    
    public init(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 1.0,
        backoffMultiplier: Double = 2.0,
        maxDelay: TimeInterval = 60.0,
        jitterEnabled: Bool = true
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.backoffMultiplier = backoffMultiplier
        self.maxDelay = maxDelay
        self.jitterEnabled = jitterEnabled
    }
    
    public static let `default` = RetryConfiguration()
    
    public static let aggressive = RetryConfiguration(
        maxAttempts: 5,
        baseDelay: 0.5,
        backoffMultiplier: 1.5,
        maxDelay: 30.0
    )
    
    public static let minimal = RetryConfiguration(
        maxAttempts: 1,
        baseDelay: 2.0,
        backoffMultiplier: 1.0,
        maxDelay: 5.0,
        jitterEnabled: false
    )
}

public struct CacheConfiguration: Sendable {
    public let memoryCapacity: Int
    public let diskCapacity: Int
    public let enableDiskCache: Bool
    public let defaultCachePolicy: CachePolicy
    public let maxAge: TimeInterval
    
    public init(
        memoryCapacity: Int = 100 * 1024 * 1024, // 100MB
        diskCapacity: Int = 500 * 1024 * 1024,   // 500MB
        enableDiskCache: Bool = true,
        defaultCachePolicy: CachePolicy = .useProtocolCachePolicy,
        maxAge: TimeInterval = 3600 // 1 hour
    ) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.enableDiskCache = enableDiskCache
        self.defaultCachePolicy = defaultCachePolicy
        self.maxAge = maxAge
    }
    
    public static let `default` = CacheConfiguration()
    
    public static let aggressive = CacheConfiguration(
        memoryCapacity: 200 * 1024 * 1024,
        diskCapacity: 1024 * 1024 * 1024,
        enableDiskCache: true,
        defaultCachePolicy: .returnCacheDataElseLoad,
        maxAge: 7200
    )
    
    public static let minimal = CacheConfiguration(
        memoryCapacity: 10 * 1024 * 1024,
        diskCapacity: 50 * 1024 * 1024,
        enableDiskCache: false,
        defaultCachePolicy: .reloadIgnoringLocalCacheData,
        maxAge: 300
    )
}

// MARK: - Request Types

public struct NetworkRequest: Sendable {
    public let id: String
    public let method: HTTPMethod
    public let url: URL
    public let headers: [String: String]
    public let body: Data?
    public let options: RequestOptions
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        method: HTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil,
        options: RequestOptions = .default,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.options = options
        self.timestamp = timestamp
    }
}

public struct RequestOptions: Sendable {
    public let timeout: TimeInterval
    public let cachePolicy: CachePolicy
    public let allowsCellularAccess: Bool
    public let allowsConstrainedNetworkAccess: Bool
    public let allowsExpensiveNetworkAccess: Bool
    public let waitsForConnectivity: Bool
    public let networkServiceType: URLRequest.NetworkServiceType
    
    public init(
        timeout: TimeInterval = 60.0,
        cachePolicy: CachePolicy = .useProtocolCachePolicy,
        allowsCellularAccess: Bool = true,
        allowsConstrainedNetworkAccess: Bool = true,
        allowsExpensiveNetworkAccess: Bool = true,
        waitsForConnectivity: Bool = false,
        networkServiceType: URLRequest.NetworkServiceType = .default
    ) {
        self.timeout = timeout
        self.cachePolicy = cachePolicy
        self.allowsCellularAccess = allowsCellularAccess
        self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        self.waitsForConnectivity = waitsForConnectivity
        self.networkServiceType = networkServiceType
    }
    
    public static let `default` = RequestOptions()
    
    public static let highPriority = RequestOptions(
        timeout: 30.0,
        cachePolicy: .reloadIgnoringLocalCacheData,
        networkServiceType: .responsiveData
    )
    
    public static let backgroundTask = RequestOptions(
        timeout: 300.0,
        cachePolicy: .returnCacheDataElseLoad,
        allowsConstrainedNetworkAccess: true,
        allowsExpensiveNetworkAccess: false,
        waitsForConnectivity: true,
        networkServiceType: .background
    )
}

public enum CachePolicy: String, CaseIterable, Codable, Sendable {
    case useProtocolCachePolicy = "useProtocolCachePolicy"
    case reloadIgnoringLocalCacheData = "reloadIgnoringLocalCacheData"
    case reloadIgnoringLocalAndRemoteCacheData = "reloadIgnoringLocalAndRemoteCacheData"
    case returnCacheDataElseLoad = "returnCacheDataElseLoad"
    case returnCacheDataDontLoad = "returnCacheDataDontLoad"
    case reloadRevalidatingCacheData = "reloadRevalidatingCacheData"
    
    public var shouldReadFromCache: Bool {
        switch self {
        case .returnCacheDataElseLoad, .returnCacheDataDontLoad, .useProtocolCachePolicy:
            return true
        default:
            return false
        }
    }
    
    public var shouldWriteToCache: Bool {
        switch self {
        case .reloadIgnoringLocalCacheData, .reloadIgnoringLocalAndRemoteCacheData:
            return false
        default:
            return true
        }
    }
}

// MARK: - Response Types

public struct NetworkResponse: Sendable {
    public let request: NetworkRequest
    public let statusCode: Int
    public let headers: [String: String]
    public let data: Data
    public let responseTime: TimeInterval
    public let fromCache: Bool
    public let timestamp: Date
    public let metadata: [String: String]
    
    public init(
        request: NetworkRequest,
        statusCode: Int,
        headers: [String: String] = [:],
        data: Data,
        responseTime: TimeInterval,
        fromCache: Bool = false,
        timestamp: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.request = request
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
        self.responseTime = responseTime
        self.fromCache = fromCache
        self.timestamp = timestamp
        self.metadata = metadata
    }
    
    public var isSuccessful: Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    public var isClientError: Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    public var isServerError: Bool {
        return statusCode >= 500
    }
    
    public var contentType: String? {
        return headers["Content-Type"] ?? headers["content-type"]
    }
    
    public var contentLength: Int {
        if let lengthString = headers["Content-Length"] ?? headers["content-length"],
           let length = Int(lengthString) {
            return length
        }
        return data.count
    }
}

// MARK: - WebSocket Types

public struct WebSocketConnection: Sendable {
    public let id: String
    public let url: URL
    public let protocols: [String]
    public let state: WebSocketState
    public let connectedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        url: URL,
        protocols: [String] = [],
        state: WebSocketState = .connecting,
        connectedAt: Date = Date()
    ) {
        self.id = id
        self.url = url
        self.protocols = protocols
        self.state = state
        self.connectedAt = connectedAt
    }
}

public enum WebSocketState: String, CaseIterable, Codable, Sendable {
    case connecting = "connecting"
    case open = "open"
    case closing = "closing"
    case closed = "closed"
}

public struct WebSocketMessage: Sendable {
    public let id: String
    public let type: MessageType
    public let data: Data
    public let timestamp: Date
    
    public enum MessageType: String, CaseIterable, Codable, Sendable {
        case text = "text"
        case binary = "binary"
        case ping = "ping"
        case pong = "pong"
        case close = "close"
    }
    
    public init(
        id: String = UUID().uuidString,
        type: MessageType,
        data: Data,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.timestamp = timestamp
    }
    
    public init(text: String) {
        self.init(
            type: .text,
            data: text.data(using: .utf8) ?? Data()
        )
    }
    
    public init(binary: Data) {
        self.init(type: .binary, data: binary)
    }
    
    public var textContent: String? {
        guard type == .text else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

public struct WebSocketOptions: Sendable {
    public let enableAutomaticReconnect: Bool
    public let reconnectInterval: TimeInterval
    public let maxReconnectAttempts: Int
    public let pingInterval: TimeInterval
    public let compressionEnabled: Bool
    
    public init(
        enableAutomaticReconnect: Bool = true,
        reconnectInterval: TimeInterval = 5.0,
        maxReconnectAttempts: Int = 3,
        pingInterval: TimeInterval = 30.0,
        compressionEnabled: Bool = true
    ) {
        self.enableAutomaticReconnect = enableAutomaticReconnect
        self.reconnectInterval = reconnectInterval
        self.maxReconnectAttempts = maxReconnectAttempts
        self.pingInterval = pingInterval
        self.compressionEnabled = compressionEnabled
    }
    
    public static let `default` = WebSocketOptions()
    
    public static let realtime = WebSocketOptions(
        enableAutomaticReconnect: true,
        reconnectInterval: 2.0,
        maxReconnectAttempts: 5,
        pingInterval: 15.0,
        compressionEnabled: false
    )
}

// MARK: - GraphQL Types

public struct GraphQLQuery: Sendable {
    public let query: String
    public let operationName: String?
    public let variables: [String: String]
    
    public init(query: String, operationName: String? = nil, variables: [String: String] = [:]) {
        self.query = query
        self.operationName = operationName
        self.variables = variables
    }
}

public struct GraphQLMutation: Sendable {
    public let mutation: String
    public let operationName: String?
    public let variables: [String: String]
    
    public init(mutation: String, operationName: String? = nil, variables: [String: String] = [:]) {
        self.mutation = mutation
        self.operationName = operationName
        self.variables = variables
    }
}

public struct GraphQLSubscription: Sendable {
    public let subscription: String
    public let operationName: String?
    public let variables: [String: String]
    
    public init(subscription: String, operationName: String? = nil, variables: [String: String] = [:]) {
        self.subscription = subscription
        self.operationName = operationName
        self.variables = variables
    }
}

public struct GraphQLResponse: Sendable {
    public let data: [String: String]?
    public let errors: [GraphQLError]
    public let extensions: [String: String]?
    public let timestamp: Date
    
    public init(
        data: [String: String]? = nil,
        errors: [GraphQLError] = [],
        extensions: [String: String]? = nil,
        timestamp: Date = Date()
    ) {
        self.data = data
        self.errors = errors
        self.extensions = extensions
        self.timestamp = timestamp
    }
    
    public var isSuccessful: Bool {
        return errors.isEmpty
    }
}

public struct GraphQLError: Codable, Sendable {
    public let message: String
    public let locations: [GraphQLLocation]?
    public let path: [String]?
    public let extensions: [String: String]?
    
    public init(
        message: String,
        locations: [GraphQLLocation]? = nil,
        path: [String]? = nil,
        extensions: [String: String]? = nil
    ) {
        self.message = message
        self.locations = locations
        self.path = path
        self.extensions = extensions
    }
}

public struct GraphQLLocation: Codable, Sendable {
    public let line: Int
    public let column: Int
    
    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

public struct GraphQLOptions: Sendable {
    public let timeout: TimeInterval
    public let enableCaching: Bool
    public let enableRetry: Bool
    public let headers: [String: String]
    
    public init(
        timeout: TimeInterval = 30.0,
        enableCaching: Bool = true,
        enableRetry: Bool = true,
        headers: [String: String] = [:]
    ) {
        self.timeout = timeout
        self.enableCaching = enableCaching
        self.enableRetry = enableRetry
        self.headers = headers
    }
    
    public static let `default` = GraphQLOptions()
    
    public static let realtime = GraphQLOptions(
        timeout: 10.0,
        enableCaching: false,
        enableRetry: false
    )
}

// MARK: - File Transfer Types

public struct UploadOptions: Sendable {
    public let timeout: TimeInterval
    public let maxFileSize: Int
    public let allowedMimeTypes: [String]
    public let enableProgressTracking: Bool
    public let additionalHeaders: [String: String]
    
    public init(
        timeout: TimeInterval = 300.0,
        maxFileSize: Int = 100 * 1024 * 1024, // 100MB
        allowedMimeTypes: [String] = [],
        enableProgressTracking: Bool = true,
        additionalHeaders: [String: String] = [:]
    ) {
        self.timeout = timeout
        self.maxFileSize = maxFileSize
        self.allowedMimeTypes = allowedMimeTypes
        self.enableProgressTracking = enableProgressTracking
        self.additionalHeaders = additionalHeaders
    }
    
    public static let `default` = UploadOptions()
    
    public static let imageUpload = UploadOptions(
        maxFileSize: 10 * 1024 * 1024,
        allowedMimeTypes: ["image/jpeg", "image/png", "image/gif", "image/webp"]
    )
    
    public static let documentUpload = UploadOptions(
        maxFileSize: 50 * 1024 * 1024,
        allowedMimeTypes: ["application/pdf", "application/msword", "text/plain"]
    )
}

public struct DownloadOptions: Sendable {
    public let timeout: TimeInterval
    public let maxFileSize: Int
    public let enableProgressTracking: Bool
    public let enableResuming: Bool
    public let destinationURL: URL?
    
    public init(
        timeout: TimeInterval = 300.0,
        maxFileSize: Int = 500 * 1024 * 1024, // 500MB
        enableProgressTracking: Bool = true,
        enableResuming: Bool = true,
        destinationURL: URL? = nil
    ) {
        self.timeout = timeout
        self.maxFileSize = maxFileSize
        self.enableProgressTracking = enableProgressTracking
        self.enableResuming = enableResuming
        self.destinationURL = destinationURL
    }
    
    public static let `default` = DownloadOptions()
    
    public static let streamingDownload = DownloadOptions(
        timeout: 0, // No timeout for streaming
        maxFileSize: Int.max,
        enableProgressTracking: true,
        enableResuming: true
    )
}

public struct DownloadResult: Sendable {
    public let url: URL
    public let fileSize: Int
    public let mimeType: String?
    public let downloadTime: TimeInterval
    public let metadata: [String: String]
    
    public init(
        url: URL,
        fileSize: Int,
        mimeType: String? = nil,
        downloadTime: TimeInterval,
        metadata: [String: String] = [:]
    ) {
        self.url = url
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.downloadTime = downloadTime
        self.metadata = metadata
    }
}

// MARK: - Retry Policy Types

public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let backoffMultiplier: Double
    public let maxDelay: TimeInterval
    public let retryableStatusCodes: [Int]
    public let retryableErrors: [URLError.Code]
    
    public init(
        maxAttempts: Int,
        baseDelay: TimeInterval,
        backoffMultiplier: Double,
        maxDelay: TimeInterval,
        retryableStatusCodes: [Int] = [408, 429, 500, 502, 503, 504],
        retryableErrors: [URLError.Code] = [.timedOut, .networkConnectionLost, .notConnectedToInternet]
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.backoffMultiplier = backoffMultiplier
        self.maxDelay = maxDelay
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableErrors = retryableErrors
    }
    
    public func shouldRetry(attempt: Int, statusCode: Int?, error: Error?) -> Bool {
        guard attempt < maxAttempts else { return false }
        
        if let statusCode = statusCode {
            return retryableStatusCodes.contains(statusCode)
        }
        
        if let urlError = error as? URLError {
            return retryableErrors.contains(urlError.code)
        }
        
        return false
    }
    
    public func delayForAttempt(_ attempt: Int) -> TimeInterval {
        let delay = baseDelay * pow(backoffMultiplier, Double(attempt))
        return min(delay, maxDelay)
    }
}

// MARK: - Interceptor Types

public protocol RequestInterceptor: Sendable {
    func intercept(_ request: NetworkRequest) async -> NetworkRequest
}

public protocol ResponseInterceptor: Sendable {
    func intercept(_ response: NetworkResponse, for request: NetworkRequest) async -> NetworkResponse
}

// MARK: - Network Client Protocols

public protocol HTTPClient: Sendable {
    init(configuration: HTTPConfiguration)
    func performRequest(_ request: NetworkRequest) async throws -> NetworkResponse
    func uploadFile(url: URL, fileData: Data, fileName: String, mimeType: String, options: UploadOptions) async throws -> NetworkResponse
    func downloadFile(url: URL, options: DownloadOptions) async throws -> DownloadResult
    func clearCache() async
    func updateConfiguration(_ configuration: HTTPConfiguration) async
    func validate() async -> Bool
}

public protocol WebSocketManager: Sendable {
    init(configuration: WebSocketConfiguration)
    func connect(url: URL, protocols: [String], options: WebSocketOptions) async throws -> WebSocketConnection
    func sendMessage(_ message: WebSocketMessage, to connection: WebSocketConnection) async throws
    func disconnect(_ connection: WebSocketConnection) async throws
    func disconnectAll() async throws
    func updateConfiguration(_ configuration: WebSocketConfiguration) async
    func validate() async -> Bool
}

public protocol GraphQLClient: Sendable {
    init(configuration: GraphQLConfiguration)
    func executeQuery(_ query: GraphQLQuery, variables: [String: String], options: GraphQLOptions) async throws -> GraphQLResponse
    func executeMutation(_ mutation: GraphQLMutation, variables: [String: String], options: GraphQLOptions) async throws -> GraphQLResponse
    func subscribe(_ subscription: GraphQLSubscription, variables: [String: String], options: GraphQLOptions) async throws -> AsyncStream<GraphQLResponse>
    func updateConfiguration(_ configuration: GraphQLConfiguration) async
    func validate() async -> Bool
}

public protocol NetworkMonitor: Sendable {
    func startMonitoring() async
    func stopMonitoring() async
    func getCurrentStatus() async -> NetworkStatus
    func getConnectionType() async -> ConnectionType
    func setNetworkStatusChangeCallback(_ callback: @escaping @Sendable (NetworkStatus) -> Void) async
}

// MARK: - Network Error Types

public enum NetworkError: LocalizedError, Sendable {
    case invalidURL(String)
    case invalidRequest(String)
    case invalidResponse(String)
    case connectionFailed(String)
    case timeout(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case serverError(Int, String)
    case parseError(String)
    case webSocketError(String)
    case graphQLError([GraphQLError])
    case uploadFailed(String)
    case downloadFailed(String)
    case cacheError(String)
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let message):
            return "Invalid URL: \(message)"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .timeout(let message):
            return "Request timed out: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        case .forbidden(let message):
            return "Forbidden: \(message)"
        case .notFound(let message):
            return "Not found: \(message)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .webSocketError(let message):
            return "WebSocket error: \(message)"
        case .graphQLError(let errors):
            return "GraphQL errors: \(errors.map { $0.message }.joined(separator: ", "))"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}

// MARK: - Default Implementations

// Simplified implementation stubs for protocols

public struct DefaultHTTPClient: HTTPClient {
    private let configuration: HTTPConfiguration
    
    public init(configuration: HTTPConfiguration) {
        self.configuration = configuration
    }
    
    public func performRequest(_ request: NetworkRequest) async throws -> NetworkResponse {
        // Simplified implementation
        return NetworkResponse(
            request: request,
            statusCode: 200,
            data: Data(),
            responseTime: 0.1
        )
    }
    
    public func uploadFile(url: URL, fileData: Data, fileName: String, mimeType: String, options: UploadOptions) async throws -> NetworkResponse {
        // Simplified implementation
        let request = NetworkRequest(method: .post, url: url, body: fileData)
        return NetworkResponse(
            request: request,
            statusCode: 201,
            data: Data(),
            responseTime: 1.0
        )
    }
    
    public func downloadFile(url: URL, options: DownloadOptions) async throws -> DownloadResult {
        // Simplified implementation
        return DownloadResult(
            url: url,
            fileSize: 1024,
            downloadTime: 0.5
        )
    }
    
    public func clearCache() async {
        // Implementation for cache clearing
    }
    
    public func updateConfiguration(_ configuration: HTTPConfiguration) async {
        // Implementation for configuration updates
    }
    
    public func validate() async -> Bool {
        return true
    }
}

public struct DefaultWebSocketManager: WebSocketManager {
    private let configuration: WebSocketConfiguration
    
    public init(configuration: WebSocketConfiguration) {
        self.configuration = configuration
    }
    
    public func connect(url: URL, protocols: [String], options: WebSocketOptions) async throws -> WebSocketConnection {
        return WebSocketConnection(url: url, protocols: protocols, state: .open)
    }
    
    public func sendMessage(_ message: WebSocketMessage, to connection: WebSocketConnection) async throws {
        // Implementation for sending messages
    }
    
    public func disconnect(_ connection: WebSocketConnection) async throws {
        // Implementation for disconnection
    }
    
    public func disconnectAll() async throws {
        // Implementation for disconnecting all connections
    }
    
    public func updateConfiguration(_ configuration: WebSocketConfiguration) async {
        // Implementation for configuration updates
    }
    
    public func validate() async -> Bool {
        return true
    }
}

public struct DefaultGraphQLClient: GraphQLClient {
    private let configuration: GraphQLConfiguration
    
    public init(configuration: GraphQLConfiguration) {
        self.configuration = configuration
    }
    
    public func executeQuery(_ query: GraphQLQuery, variables: [String: String], options: GraphQLOptions) async throws -> GraphQLResponse {
        return GraphQLResponse(data: [:])
    }
    
    public func executeMutation(_ mutation: GraphQLMutation, variables: [String: String], options: GraphQLOptions) async throws -> GraphQLResponse {
        return GraphQLResponse(data: [:])
    }
    
    public func subscribe(_ subscription: GraphQLSubscription, variables: [String: String], options: GraphQLOptions) async throws -> AsyncStream<GraphQLResponse> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func updateConfiguration(_ configuration: GraphQLConfiguration) async {
        // Implementation for configuration updates
    }
    
    public func validate() async -> Bool {
        return true
    }
}

public struct DefaultNetworkMonitor: NetworkMonitor {
    public init() {}
    
    public func startMonitoring() async {
        // Implementation for starting network monitoring
    }
    
    public func stopMonitoring() async {
        // Implementation for stopping network monitoring
    }
    
    public func getCurrentStatus() async -> NetworkStatus {
        return .connected
    }
    
    public func getConnectionType() async -> ConnectionType {
        return .wifi
    }
    
    public func setNetworkStatusChangeCallback(_ callback: @escaping @Sendable (NetworkStatus) -> Void) async {
        // Implementation for setting callback
    }
}
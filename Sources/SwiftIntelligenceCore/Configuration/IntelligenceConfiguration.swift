import Foundation

/// Global configuration for SwiftIntelligence framework
public struct IntelligenceConfiguration: Sendable {
    
    // MARK: - Properties
    
    /// Enable debug mode
    public let debugMode: Bool
    
    /// Enable performance monitoring
    public let performanceMonitoring: Bool
    
    /// Enable detailed logging
    public let verboseLogging: Bool
    
    /// Maximum memory limit (in MB)
    public let memoryLimit: Int
    
    /// Request timeout (in seconds)
    public let requestTimeout: TimeInterval
    
    /// Cache duration (in seconds)
    public let cacheDuration: TimeInterval
    
    /// Maximum concurrent operations
    public let maxConcurrentOperations: Int
    
    /// Enable privacy mode
    public let privacyMode: Bool
    
    /// Enable telemetry
    public let telemetryEnabled: Bool
    
    /// API endpoints configuration
    public let endpoints: EndpointsConfiguration
    
    /// Model paths configuration
    public let modelPaths: ModelPathsConfiguration
    
    // MARK: - Initialization
    
    public init(
        debugMode: Bool = false,
        performanceMonitoring: Bool = true,
        verboseLogging: Bool = false,
        memoryLimit: Int = 512,
        requestTimeout: TimeInterval = 30,
        cacheDuration: TimeInterval = 3600,
        maxConcurrentOperations: Int = 4,
        privacyMode: Bool = true,
        telemetryEnabled: Bool = false,
        endpoints: EndpointsConfiguration = EndpointsConfiguration(),
        modelPaths: ModelPathsConfiguration = ModelPathsConfiguration()
    ) {
        self.debugMode = debugMode
        self.performanceMonitoring = performanceMonitoring
        self.verboseLogging = verboseLogging
        self.memoryLimit = memoryLimit
        self.requestTimeout = requestTimeout
        self.cacheDuration = cacheDuration
        self.maxConcurrentOperations = maxConcurrentOperations
        self.privacyMode = privacyMode
        self.telemetryEnabled = telemetryEnabled
        self.endpoints = endpoints
        self.modelPaths = modelPaths
    }
    
    // MARK: - Presets
    
    /// Development configuration with debug features enabled
    public static var development: IntelligenceConfiguration {
        IntelligenceConfiguration(
            debugMode: true,
            performanceMonitoring: true,
            verboseLogging: true,
            memoryLimit: 1024,
            privacyMode: false,
            telemetryEnabled: false
        )
    }
    
    /// Production configuration optimized for performance
    public static var production: IntelligenceConfiguration {
        IntelligenceConfiguration(
            debugMode: false,
            performanceMonitoring: false,
            verboseLogging: false,
            memoryLimit: 256,
            privacyMode: true,
            telemetryEnabled: true
        )
    }
    
    /// Testing configuration for unit tests
    public static var testing: IntelligenceConfiguration {
        IntelligenceConfiguration(
            debugMode: true,
            performanceMonitoring: false,
            verboseLogging: false,
            memoryLimit: 128,
            requestTimeout: 5,
            cacheDuration: 0,
            maxConcurrentOperations: 1,
            privacyMode: false,
            telemetryEnabled: false
        )
    }
}

// MARK: - Supporting Types

/// API endpoints configuration
public struct EndpointsConfiguration: Sendable {
    public let baseURL: String
    public let apiVersion: String
    public let customEndpoints: [String: String]
    
    public init(
        baseURL: String = "https://api.swiftintelligence.com",
        apiVersion: String = "v1",
        customEndpoints: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.customEndpoints = customEndpoints
    }
}

/// Model paths configuration
public struct ModelPathsConfiguration: Sendable {
    public let basePath: String
    public let customPaths: [String: String]
    
    public init(
        basePath: String = "Models",
        customPaths: [String: String] = [:]
    ) {
        self.basePath = basePath
        self.customPaths = customPaths
    }
}
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
    
    /// Enable on-device processing
    public let enableOnDeviceProcessing: Bool
    
    /// Enable cloud fallback
    public let enableCloudFallback: Bool
    
    /// Neural Engine optimization
    public let enableNeuralEngine: Bool
    
    /// Batch processing size
    public let batchSize: Int
    
    /// Log level
    public let logLevel: IntelligenceLogLevel
    
    /// Performance profile
    public let performanceProfile: PerformanceProfile
    
    /// Privacy level
    public let privacyLevel: PrivacyLevel
    
    /// Cache policy
    public let cachePolicy: CachePolicy
    
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
        modelPaths: ModelPathsConfiguration = ModelPathsConfiguration(),
        enableOnDeviceProcessing: Bool = true,
        enableCloudFallback: Bool = false,
        enableNeuralEngine: Bool = true,
        batchSize: Int = 10,
        logLevel: IntelligenceLogLevel = .info,
        performanceProfile: PerformanceProfile = .balanced,
        privacyLevel: PrivacyLevel = .standard,
        cachePolicy: CachePolicy = .automatic
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
        self.enableOnDeviceProcessing = enableOnDeviceProcessing
        self.enableCloudFallback = enableCloudFallback
        self.enableNeuralEngine = enableNeuralEngine
        self.batchSize = batchSize
        self.logLevel = logLevel
        self.performanceProfile = performanceProfile
        self.privacyLevel = privacyLevel
        self.cachePolicy = cachePolicy
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
            telemetryEnabled: false,
            enableOnDeviceProcessing: true,
            enableCloudFallback: true,
            enableNeuralEngine: true,
            batchSize: 5,
            logLevel: .debug,
            performanceProfile: .balanced,
            privacyLevel: .minimal,
            cachePolicy: .aggressive
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
            telemetryEnabled: true,
            enableOnDeviceProcessing: true,
            enableCloudFallback: false,
            enableNeuralEngine: true,
            batchSize: 10,
            logLevel: .warning,
            performanceProfile: .optimized,
            privacyLevel: .high,
            cachePolicy: .automatic
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
            telemetryEnabled: false,
            enableOnDeviceProcessing: true,
            enableCloudFallback: false,
            enableNeuralEngine: false,
            batchSize: 1,
            logLevel: .info,
            performanceProfile: .minimal,
            privacyLevel: .minimal,
            cachePolicy: .disabled
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

// MARK: - Enumerations

/// Log level enumeration
public enum IntelligenceLogLevel: String, Sendable, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    case none = "NONE"
    
    public var priority: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        case .critical: return 4
        case .none: return 5
        }
    }
}

/// Performance profile enumeration
public enum PerformanceProfile: String, Sendable, CaseIterable {
    case minimal = "minimal"
    case battery = "battery"
    case balanced = "balanced"
    case optimized = "optimized"
    case performance = "performance"
    case enterprise = "enterprise"
}

/// Privacy level enumeration
public enum PrivacyLevel: String, Sendable, CaseIterable {
    case minimal = "minimal"
    case standard = "standard"
    case high = "high"
    case maximum = "maximum"
}

/// Cache policy enumeration
public enum CachePolicy: String, Sendable, CaseIterable {
    case disabled = "disabled"
    case conservative = "conservative"
    case automatic = "automatic"
    case aggressive = "aggressive"
}
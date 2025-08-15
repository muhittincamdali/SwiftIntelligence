import Foundation
import CoreML

/// Configuration for the SwiftIntelligence framework
public struct IntelligenceConfiguration {
    
    // MARK: - Processing Configuration
    
    /// Processing mode for AI operations
    public var processingMode: ProcessingMode = .hybrid
    
    /// Preferred compute units for ML operations
    public var computeUnits: MLComputeUnits = .all
    
    /// Maximum concurrent operations
    public var maxConcurrentOperations: Int = 4
    
    /// Memory management settings
    public var memoryConfiguration: MemoryConfiguration = .default
    
    // MARK: - Performance Configuration
    
    /// Performance mode affecting quality vs speed tradeoffs
    public var performanceMode: PerformanceMode = .balanced
    
    /// Enable/disable performance monitoring
    public var performanceMonitoringEnabled: Bool = true
    
    /// Batch size for batch processing operations
    public var defaultBatchSize: Int = 32
    
    /// Timeout for individual operations (in seconds)
    public var operationTimeout: TimeInterval = 30.0
    
    // MARK: - Privacy Configuration
    
    /// Privacy mode settings
    public var privacyMode: PrivacyMode = .standard
    
    /// Enable data anonymization
    public var dataAnonymizationEnabled: Bool = true
    
    /// Enable on-device processing only
    public var onDeviceOnly: Bool = false
    
    /// Data retention policy
    public var dataRetentionPolicy: DataRetentionPolicy = .session
    
    // MARK: - Model Configuration
    
    /// Automatic model updates
    public var automaticModelUpdates: Bool = true
    
    /// Model cache size limit (in bytes)
    public var modelCacheLimit: UInt64 = 1024 * 1024 * 1024 // 1GB
    
    /// Maximum models to keep in memory
    public var maxModelsInMemory: Int = 5
    
    /// Model download behavior
    public var modelDownloadBehavior: ModelDownloadBehavior = .onDemand
    
    // MARK: - Network Configuration
    
    /// Network timeout for model downloads
    public var networkTimeout: TimeInterval = 60.0
    
    /// Allow cellular data for model downloads
    public var allowsCellularModelDownloads: Bool = false
    
    /// Background downloads enabled
    public var backgroundDownloadsEnabled: Bool = true
    
    // MARK: - Logging Configuration
    
    /// Logging level
    public var logLevel: LogLevel = .info
    
    /// Enable performance logging
    public var performanceLoggingEnabled: Bool = true
    
    /// Enable error reporting
    public var errorReportingEnabled: Bool = true
    
    // MARK: - System Requirements
    
    /// Minimum memory requirement (in bytes)
    public var minimumMemoryRequirement: UInt64 = 1024 * 1024 * 512 // 512MB
    
    /// Minimum storage requirement for models (in bytes)
    public var minimumStorageRequirement: UInt64 = 1024 * 1024 * 1024 // 1GB
    
    // MARK: - Feature Flags
    
    /// Enable experimental features
    public var experimentalFeaturesEnabled: Bool = false
    
    /// Enable beta models
    public var betaModelsEnabled: Bool = false
    
    /// Enable advanced caching
    public var advancedCachingEnabled: Bool = true
    
    // MARK: - Initialization
    
    public init() {}
    
    /// Default configuration optimized for most use cases
    public static let `default` = IntelligenceConfiguration()
    
    /// High performance configuration
    public static let highPerformance: IntelligenceConfiguration = {
        var config = IntelligenceConfiguration()
        config.performanceMode = .highPerformance
        config.computeUnits = .all
        config.maxConcurrentOperations = 8
        config.defaultBatchSize = 64
        config.memoryConfiguration = .aggressive
        return config
    }()
    
    /// Privacy-focused configuration
    public static let privacyFocused: IntelligenceConfiguration = {
        var config = IntelligenceConfiguration()
        config.privacyMode = .strict
        config.onDeviceOnly = true
        config.dataAnonymizationEnabled = true
        config.dataRetentionPolicy = .none
        config.errorReportingEnabled = false
        return config
    }()
    
    /// Low memory configuration for resource-constrained devices
    public static let lowMemory: IntelligenceConfiguration = {
        var config = IntelligenceConfiguration()
        config.memoryConfiguration = .conservative
        config.maxModelsInMemory = 2
        config.defaultBatchSize = 16
        config.maxConcurrentOperations = 2
        config.performanceMode = .balanced
        return config
    }()
    
    /// Enterprise configuration with enhanced monitoring
    public static let enterprise: IntelligenceConfiguration = {
        var config = IntelligenceConfiguration()
        config.performanceMonitoringEnabled = true
        config.performanceLoggingEnabled = true
        config.errorReportingEnabled = true
        config.logLevel = .debug
        config.memoryConfiguration = .enterprise
        config.automaticModelUpdates = false // Manual control in enterprise
        return config
    }()
    
    // MARK: - Configuration Updates
    
    /// Update configuration with another configuration
    public mutating func update(with other: IntelligenceConfiguration) {
        self.processingMode = other.processingMode
        self.computeUnits = other.computeUnits
        self.maxConcurrentOperations = other.maxConcurrentOperations
        self.memoryConfiguration = other.memoryConfiguration
        self.performanceMode = other.performanceMode
        self.privacyMode = other.privacyMode
        self.onDeviceOnly = other.onDeviceOnly
        self.dataRetentionPolicy = other.dataRetentionPolicy
        // ... update other properties as needed
    }
    
    /// Validate configuration settings
    public func validate() throws {
        guard maxConcurrentOperations > 0 else {
            throw ConfigurationError.invalidConcurrentOperations
        }
        
        guard operationTimeout > 0 else {
            throw ConfigurationError.invalidTimeout
        }
        
        guard defaultBatchSize > 0 else {
            throw ConfigurationError.invalidBatchSize
        }
        
        guard modelCacheLimit > 0 else {
            throw ConfigurationError.invalidCacheLimit
        }
        
        guard maxModelsInMemory > 0 else {
            throw ConfigurationError.invalidModelLimit
        }
    }
}

// MARK: - Supporting Enums

public enum ProcessingMode: String, CaseIterable, Codable {
    case onDeviceOnly = "on_device_only"
    case cloudOnly = "cloud_only"
    case hybrid = "hybrid"
    case automatic = "automatic"
    
    public var description: String {
        switch self {
        case .onDeviceOnly:
            return "Process all data on-device for maximum privacy"
        case .cloudOnly:
            return "Use cloud services for processing"
        case .hybrid:
            return "Intelligently choose between on-device and cloud"
        case .automatic:
            return "Automatically optimize based on conditions"
        }
    }
}

public enum PerformanceMode: String, CaseIterable, Codable {
    case lowPower = "low_power"
    case balanced = "balanced"
    case highPerformance = "high_performance"
    case custom = "custom"
    
    public var description: String {
        switch self {
        case .lowPower:
            return "Optimize for battery life and thermal efficiency"
        case .balanced:
            return "Balance between performance and power consumption"
        case .highPerformance:
            return "Maximum performance regardless of power consumption"
        case .custom:
            return "Custom performance settings"
        }
    }
}

public enum PrivacyMode: String, CaseIterable, Codable {
    case minimal = "minimal"
    case standard = "standard"
    case strict = "strict"
    case custom = "custom"
    
    public var description: String {
        switch self {
        case .minimal:
            return "Basic privacy protections"
        case .standard:
            return "Standard privacy protections following best practices"
        case .strict:
            return "Maximum privacy with all protections enabled"
        case .custom:
            return "Custom privacy settings"
        }
    }
}

public enum DataRetentionPolicy: String, CaseIterable, Codable {
    case none = "none"
    case session = "session"
    case temporary = "temporary"
    case persistent = "persistent"
    case custom = "custom"
    
    public var retentionDuration: TimeInterval? {
        switch self {
        case .none:
            return 0
        case .session:
            return nil // Until app terminates
        case .temporary:
            return 24 * 60 * 60 // 24 hours
        case .persistent:
            return nil // Indefinite
        case .custom:
            return nil // User-defined
        }
    }
}

public enum ModelDownloadBehavior: String, CaseIterable, Codable {
    case onDemand = "on_demand"
    case preload = "preload"
    case automatic = "automatic"
    case manual = "manual"
    
    public var description: String {
        switch self {
        case .onDemand:
            return "Download models only when needed"
        case .preload:
            return "Download essential models at startup"
        case .automatic:
            return "Intelligently manage model downloads"
        case .manual:
            return "Manual control over all downloads"
        }
    }
}

public enum LogLevel: String, CaseIterable, Codable {
    case off = "off"
    case error = "error"
    case warning = "warning"
    case info = "info"
    case debug = "debug"
    case verbose = "verbose"
    
    public var priority: Int {
        switch self {
        case .off: return 0
        case .error: return 1
        case .warning: return 2
        case .info: return 3
        case .debug: return 4
        case .verbose: return 5
        }
    }
}

public struct MemoryConfiguration: Codable {
    public let maxMemoryUsage: UInt64
    public let aggressiveCleanup: Bool
    public let modelCacheSize: UInt64
    public let intermediateBufferSize: UInt64
    
    public init(
        maxMemoryUsage: UInt64,
        aggressiveCleanup: Bool,
        modelCacheSize: UInt64,
        intermediateBufferSize: UInt64
    ) {
        self.maxMemoryUsage = maxMemoryUsage
        self.aggressiveCleanup = aggressiveCleanup
        self.modelCacheSize = modelCacheSize
        self.intermediateBufferSize = intermediateBufferSize
    }
    
    public static let `default` = MemoryConfiguration(
        maxMemoryUsage: 512 * 1024 * 1024, // 512MB
        aggressiveCleanup: false,
        modelCacheSize: 256 * 1024 * 1024, // 256MB
        intermediateBufferSize: 64 * 1024 * 1024 // 64MB
    )
    
    public static let conservative = MemoryConfiguration(
        maxMemoryUsage: 256 * 1024 * 1024, // 256MB
        aggressiveCleanup: true,
        modelCacheSize: 128 * 1024 * 1024, // 128MB
        intermediateBufferSize: 32 * 1024 * 1024 // 32MB
    )
    
    public static let aggressive = MemoryConfiguration(
        maxMemoryUsage: 1024 * 1024 * 1024, // 1GB
        aggressiveCleanup: false,
        modelCacheSize: 512 * 1024 * 1024, // 512MB
        intermediateBufferSize: 128 * 1024 * 1024 // 128MB
    )
    
    public static let enterprise = MemoryConfiguration(
        maxMemoryUsage: 2048 * 1024 * 1024, // 2GB
        aggressiveCleanup: false,
        modelCacheSize: 1024 * 1024 * 1024, // 1GB
        intermediateBufferSize: 256 * 1024 * 1024 // 256MB
    )
}

// MARK: - Configuration Errors

public enum ConfigurationError: LocalizedError {
    case invalidConcurrentOperations
    case invalidTimeout
    case invalidBatchSize
    case invalidCacheLimit
    case invalidModelLimit
    case invalidMemoryConfiguration
    case invalidPrivacySettings
    
    public var errorDescription: String? {
        switch self {
        case .invalidConcurrentOperations:
            return "Maximum concurrent operations must be greater than 0"
        case .invalidTimeout:
            return "Operation timeout must be greater than 0"
        case .invalidBatchSize:
            return "Batch size must be greater than 0"
        case .invalidCacheLimit:
            return "Cache limit must be greater than 0"
        case .invalidModelLimit:
            return "Maximum models in memory must be greater than 0"
        case .invalidMemoryConfiguration:
            return "Invalid memory configuration"
        case .invalidPrivacySettings:
            return "Invalid privacy configuration"
        }
    }
}
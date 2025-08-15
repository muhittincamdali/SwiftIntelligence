import Foundation
import CoreML
import Vision

/// Configuration for Vision processing operations
public struct VisionConfiguration {
    
    // MARK: - Performance Settings
    
    /// Processing quality level
    public var qualityLevel: QualityLevel = .balanced
    
    /// Maximum concurrent operations
    public var maxConcurrentOperations: Int = 4
    
    /// Preferred compute units for ML operations
    public var computeUnits: MLComputeUnits = .all
    
    /// Memory optimization level
    public var memoryOptimization: MemoryOptimization = .balanced
    
    /// Enable GPU acceleration
    public var enableGPUAcceleration: Bool = true
    
    /// Enable Neural Engine usage
    public var enableNeuralEngine: Bool = true
    
    // MARK: - Image Processing Settings
    
    /// Maximum image size for processing
    public var maxImageSize: CGSize = CGSize(width: 4096, height: 4096)
    
    /// Image preprocessing options
    public var imagePreprocessing: ImagePreprocessingOptions = .default
    
    /// Output image format
    public var outputImageFormat: OutputImageFormat = .original
    
    /// JPEG compression quality (0.0-1.0)
    public var jpegCompressionQuality: Float = 0.85
    
    // MARK: - Caching Settings
    
    /// Enable result caching
    public var enableResultCaching: Bool = true
    
    /// Cache size limit in bytes
    public var cacheSizeLimit: UInt64 = 100 * 1024 * 1024 // 100MB
    
    /// Cache expiration time in seconds
    public var cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    /// Enable persistent caching
    public var enablePersistentCaching: Bool = false
    
    // MARK: - Real-time Processing Settings
    
    /// Frame rate for real-time processing
    public var targetFrameRate: Double = 30.0
    
    /// Skip frames when processing is slow
    public var enableFrameSkipping: Bool = true
    
    /// Real-time processing priority
    public var realtimePriority: RealtimePriority = .normal
    
    // MARK: - Privacy Settings
    
    /// Enable on-device processing only
    public var onDeviceOnly: Bool = true
    
    /// Data retention policy
    public var dataRetentionPolicy: DataRetentionPolicy = .session
    
    /// Enable anonymization
    public var enableAnonymization: Bool = false
    
    // MARK: - Debugging Settings
    
    /// Enable verbose logging
    public var verboseLogging: Bool = false
    
    /// Enable performance monitoring
    public var enablePerformanceMonitoring: Bool = true
    
    /// Save intermediate results for debugging
    public var saveIntermediateResults: Bool = false
    
    // MARK: - Model Settings
    
    /// Model selection strategy
    public var modelSelectionStrategy: ModelSelectionStrategy = .automatic
    
    /// Custom model paths
    public var customModelPaths: [VisionTaskType: URL] = [:]
    
    /// Model update behavior
    public var modelUpdateBehavior: ModelUpdateBehavior = .automatic
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Presets
    
    /// Default balanced configuration
    public static let `default` = VisionConfiguration()
    
    /// High performance configuration
    public static let highPerformance: VisionConfiguration = {
        var config = VisionConfiguration()
        config.qualityLevel = .high
        config.maxConcurrentOperations = 8
        config.computeUnits = .all
        config.memoryOptimization = .performance
        config.enableGPUAcceleration = true
        config.enableNeuralEngine = true
        config.targetFrameRate = 60.0
        config.enableFrameSkipping = false
        return config
    }()
    
    /// Low power configuration
    public static let lowPower: VisionConfiguration = {
        var config = VisionConfiguration()
        config.qualityLevel = .low
        config.maxConcurrentOperations = 2
        config.computeUnits = .cpuOnly
        config.memoryOptimization = .memory
        config.enableGPUAcceleration = false
        config.targetFrameRate = 15.0
        config.enableFrameSkipping = true
        return config
    }()
    
    /// Real-time optimized configuration
    public static let realtime: VisionConfiguration = {
        var config = VisionConfiguration()
        config.qualityLevel = .balanced
        config.maxConcurrentOperations = 6
        config.memoryOptimization = .performance
        config.targetFrameRate = 30.0
        config.enableFrameSkipping = true
        config.realtimePriority = .high
        config.enableResultCaching = false
        return config
    }()
    
    /// Privacy-focused configuration
    public static let privacyFocused: VisionConfiguration = {
        var config = VisionConfiguration()
        config.onDeviceOnly = true
        config.dataRetentionPolicy = .none
        config.enableAnonymization = true
        config.enableResultCaching = false
        config.enablePersistentCaching = false
        config.verboseLogging = false
        return config
    }()
    
    /// Enterprise configuration
    public static let enterprise: VisionConfiguration = {
        var config = VisionConfiguration()
        config.qualityLevel = .high
        config.memoryOptimization = .balanced
        config.enablePerformanceMonitoring = true
        config.verboseLogging = true
        config.enablePersistentCaching = true
        config.modelUpdateBehavior = .manual
        return config
    }()
    
    // MARK: - Configuration Management
    
    /// Update configuration with another configuration
    public mutating func update(with other: VisionConfiguration) {
        self.qualityLevel = other.qualityLevel
        self.maxConcurrentOperations = other.maxConcurrentOperations
        self.computeUnits = other.computeUnits
        self.memoryOptimization = other.memoryOptimization
        self.enableGPUAcceleration = other.enableGPUAcceleration
        self.enableNeuralEngine = other.enableNeuralEngine
        self.maxImageSize = other.maxImageSize
        self.imagePreprocessing = other.imagePreprocessing
        self.outputImageFormat = other.outputImageFormat
        self.jpegCompressionQuality = other.jpegCompressionQuality
        self.enableResultCaching = other.enableResultCaching
        self.cacheSizeLimit = other.cacheSizeLimit
        self.cacheExpirationTime = other.cacheExpirationTime
        self.targetFrameRate = other.targetFrameRate
        self.enableFrameSkipping = other.enableFrameSkipping
        self.onDeviceOnly = other.onDeviceOnly
        self.dataRetentionPolicy = other.dataRetentionPolicy
        self.enableAnonymization = other.enableAnonymization
        self.verboseLogging = other.verboseLogging
        self.enablePerformanceMonitoring = other.enablePerformanceMonitoring
    }
    
    /// Validate configuration settings
    public func validate() throws {
        guard maxConcurrentOperations > 0 else {
            throw VisionConfigurationError.invalidConcurrentOperations
        }
        
        guard maxImageSize.width > 0 && maxImageSize.height > 0 else {
            throw VisionConfigurationError.invalidImageSize
        }
        
        guard jpegCompressionQuality >= 0.0 && jpegCompressionQuality <= 1.0 else {
            throw VisionConfigurationError.invalidCompressionQuality
        }
        
        guard targetFrameRate > 0 else {
            throw VisionConfigurationError.invalidFrameRate
        }
        
        guard cacheSizeLimit > 0 else {
            throw VisionConfigurationError.invalidCacheSize
        }
    }
}

// MARK: - Supporting Enums

public enum QualityLevel: String, CaseIterable, Codable {
    case low = "low"
    case balanced = "balanced"
    case high = "high"
    case maximum = "maximum"
    
    public var description: String {
        switch self {
        case .low:
            return "Low quality, fast processing"
        case .balanced:
            return "Balanced quality and performance"
        case .high:
            return "High quality, slower processing"
        case .maximum:
            return "Maximum quality, slowest processing"
        }
    }
    
    public var visionRequestRevision: Int {
        switch self {
        case .low:
            return VNRecognizeTextRequestRevision1
        case .balanced:
            return VNRecognizeTextRequestRevision2
        case .high:
            return VNRecognizeTextRequestRevision3
        case .maximum:
            return VNRecognizeTextRequestRevision3
        }
    }
}

public enum MemoryOptimization: String, CaseIterable, Codable {
    case memory = "memory"
    case balanced = "balanced"
    case performance = "performance"
    
    public var description: String {
        switch self {
        case .memory:
            return "Optimize for low memory usage"
        case .balanced:
            return "Balance memory usage and performance"
        case .performance:
            return "Optimize for maximum performance"
        }
    }
}

public enum OutputImageFormat: String, CaseIterable, Codable {
    case original = "original"
    case jpeg = "jpeg"
    case png = "png"
    case heif = "heif"
    
    public var description: String {
        switch self {
        case .original:
            return "Keep original format"
        case .jpeg:
            return "JPEG format (lossy compression)"
        case .png:
            return "PNG format (lossless)"
        case .heif:
            return "HEIF format (efficient)"
        }
    }
}

public enum RealtimePriority: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case critical = "critical"
    
    public var qosClass: DispatchQoS.QoSClass {
        switch self {
        case .low:
            return .background
        case .normal:
            return .default
        case .high:
            return .userInitiated
        case .critical:
            return .userInteractive
        }
    }
}

public enum DataRetentionPolicy: String, CaseIterable, Codable {
    case none = "none"
    case session = "session"
    case temporary = "temporary"
    case persistent = "persistent"
    
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
        }
    }
}

public enum ModelSelectionStrategy: String, CaseIterable, Codable {
    case automatic = "automatic"
    case performance = "performance"
    case accuracy = "accuracy"
    case size = "size"
    case custom = "custom"
    
    public var description: String {
        switch self {
        case .automatic:
            return "Automatically select best model"
        case .performance:
            return "Prioritize processing speed"
        case .accuracy:
            return "Prioritize accuracy"
        case .size:
            return "Prioritize model size"
        case .custom:
            return "Use custom model selection"
        }
    }
}

public enum ModelUpdateBehavior: String, CaseIterable, Codable {
    case automatic = "automatic"
    case manual = "manual"
    case disabled = "disabled"
    
    public var description: String {
        switch self {
        case .automatic:
            return "Automatically update models"
        case .manual:
            return "Manual model updates"
        case .disabled:
            return "Disable model updates"
        }
    }
}

public struct ImagePreprocessingOptions: Codable {
    public let enableNormalization: Bool
    public let enableResize: Bool
    public let enableRotationCorrection: Bool
    public let enableNoiseReduction: Bool
    public let enableContrastEnhancement: Bool
    
    public init(
        enableNormalization: Bool = true,
        enableResize: Bool = true,
        enableRotationCorrection: Bool = true,
        enableNoiseReduction: Bool = false,
        enableContrastEnhancement: Bool = false
    ) {
        self.enableNormalization = enableNormalization
        self.enableResize = enableResize
        self.enableRotationCorrection = enableRotationCorrection
        self.enableNoiseReduction = enableNoiseReduction
        self.enableContrastEnhancement = enableContrastEnhancement
    }
    
    public static let `default` = ImagePreprocessingOptions()
    
    public static let minimal = ImagePreprocessingOptions(
        enableNormalization: true,
        enableResize: true,
        enableRotationCorrection: false,
        enableNoiseReduction: false,
        enableContrastEnhancement: false
    )
    
    public static let enhanced = ImagePreprocessingOptions(
        enableNormalization: true,
        enableResize: true,
        enableRotationCorrection: true,
        enableNoiseReduction: true,
        enableContrastEnhancement: true
    )
}

// MARK: - Configuration Errors

public enum VisionConfigurationError: LocalizedError {
    case invalidConcurrentOperations
    case invalidImageSize
    case invalidCompressionQuality
    case invalidFrameRate
    case invalidCacheSize
    case invalidModelPath
    case incompatibleSettings
    
    public var errorDescription: String? {
        switch self {
        case .invalidConcurrentOperations:
            return "Maximum concurrent operations must be greater than 0"
        case .invalidImageSize:
            return "Image size must have positive width and height"
        case .invalidCompressionQuality:
            return "JPEG compression quality must be between 0.0 and 1.0"
        case .invalidFrameRate:
            return "Target frame rate must be greater than 0"
        case .invalidCacheSize:
            return "Cache size limit must be greater than 0"
        case .invalidModelPath:
            return "Invalid custom model path"
        case .incompatibleSettings:
            return "Configuration settings are incompatible"
        }
    }
}
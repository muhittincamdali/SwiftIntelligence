import Foundation

/// SwiftIntelligence Core Module
/// The foundation framework providing common types, protocols, and utilities
@MainActor
public final class SwiftIntelligenceCore: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance for global configuration
    public static let shared = SwiftIntelligenceCore()
    
    // MARK: - Properties
    
    /// Current framework version
    public static let version = "1.0.0"
    
    /// Framework build number
    public static let buildNumber = "100"
    
    /// Current configuration
    @Published public private(set) var configuration: IntelligenceConfiguration
    
    /// Logger instance
    public let logger: IntelligenceLogger
    
    /// Performance monitor
    public let performanceMonitor: PerformanceMonitor
    
    /// Error handler
    public let errorHandler: ErrorHandler
    
    // MARK: - Initialization
    
    private init() {
        self.configuration = IntelligenceConfiguration()
        self.logger = IntelligenceLogger()
        self.performanceMonitor = PerformanceMonitor()
        self.errorHandler = ErrorHandler()
        
        setupFramework()
    }
    
    // MARK: - Configuration
    
    /// Configure the framework with custom settings
    /// - Parameter configuration: Custom configuration
    public func configure(with configuration: IntelligenceConfiguration) {
        self.configuration = configuration
        logger.log("SwiftIntelligence configured", level: .info)
    }
    
    /// Reset to default configuration
    public func resetConfiguration() {
        self.configuration = IntelligenceConfiguration()
        logger.log("Configuration reset to defaults", level: .info)
    }
    
    // MARK: - Framework Setup
    
    private func setupFramework() {
        logger.log("SwiftIntelligence Core v\(Self.version) initialized", level: .info)
        performanceMonitor.startMonitoring()
    }
    
    // MARK: - Resource Management
    
    /// Clean up resources
    public func cleanup() {
        performanceMonitor.stopMonitoring()
        logger.log("SwiftIntelligence Core cleaned up", level: .info)
    }
    
    /// Get current memory usage
    public func memoryUsage() -> MemoryUsage {
        performanceMonitor.currentMemoryUsage()
    }
    
    /// Get current CPU usage
    public func cpuUsage() -> CPUUsage {
        performanceMonitor.currentCPUUsage()
    }
}
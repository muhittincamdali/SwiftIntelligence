import Foundation
import CoreML
import Combine
import os.log

/// Main intelligence engine that orchestrates all AI/ML operations
@MainActor
public class IntelligenceEngine: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = IntelligenceEngine()
    
    // MARK: - Published Properties
    @Published public var isInitialized: Bool = false
    @Published public var status: EngineStatus = .idle
    @Published public var performance: PerformanceMetrics = PerformanceMetrics()
    
    // MARK: - Core Components
    public let configuration: IntelligenceConfiguration
    public let modelManager: ModelManager
    public let performanceMonitor: PerformanceMonitor
    public let privacyManager: PrivacyManager
    
    // MARK: - Processing Pipelines
    private var activePipelines: [String: ProcessingPipeline] = [:]
    private var pipelineQueue = DispatchQueue(label: "intelligence.pipeline", qos: .userInitiated)
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Logger
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Engine")
    
    // MARK: - Initialization
    private init() {
        self.configuration = IntelligenceConfiguration.default
        self.modelManager = ModelManager.shared
        self.performanceMonitor = PerformanceMonitor.shared
        self.privacyManager = PrivacyManager.shared
        
        setupBindings()
        setupPerformanceMonitoring()
    }
    
    /// Initialize with custom configuration
    public convenience init(configuration: IntelligenceConfiguration) {
        self.init()
        self.configuration.update(with: configuration)
    }
    
    // MARK: - Setup
    private func setupBindings() {
        modelManager.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modelStatus in
                self?.updateEngineStatus(based: modelStatus)
            }
            .store(in: &cancellables)
        
        performanceMonitor.$metrics
            .receive(on: DispatchQueue.main)
            .assign(to: \.performance, on: self)
            .store(in: &cancellables)
    }
    
    private func setupPerformanceMonitoring() {
        performanceMonitor.startMonitoring()
        
        // Memory pressure monitoring
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                self?.handleMemoryPressure()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    /// Initialize the intelligence engine
    public func initialize() async throws {
        logger.info("Initializing SwiftIntelligence Engine...")
        
        status = .initializing
        
        do {
            // Initialize core components
            try await modelManager.initialize()
            await privacyManager.initialize()
            
            // Preload essential models
            try await preloadEssentialModels()
            
            // Verify system capabilities
            try verifySystemCapabilities()
            
            isInitialized = true
            status = .ready
            
            logger.info("SwiftIntelligence Engine initialized successfully")
            
            // Start background optimization
            Task.detached(priority: .background) {
                await self.optimizePerformance()
            }
            
        } catch {
            status = .error(error)
            logger.error("Failed to initialize engine: \(error.localizedDescription)")
            throw IntelligenceError.initializationFailed(error)
        }
    }
    
    /// Create a processing pipeline for specific task
    public func createPipeline(
        for task: IntelligenceTask,
        options: PipelineOptions = .default
    ) async throws -> ProcessingPipeline {
        guard isInitialized else {
            throw IntelligenceError.engineNotInitialized
        }
        
        let pipelineId = UUID().uuidString
        let pipeline = try await ProcessingPipeline(
            id: pipelineId,
            task: task,
            options: options,
            engine: self
        )
        
        activePipelines[pipelineId] = pipeline
        
        logger.info("Created pipeline \(pipelineId) for task: \(task.type)")
        
        return pipeline
    }
    
    /// Execute a quick inference task
    public func quickInference<T>(
        task: IntelligenceTask,
        input: IntelligenceInput
    ) async throws -> T where T: IntelligenceOutput {
        let pipeline = try await createPipeline(for: task)
        defer { removePipeline(pipeline.id) }
        
        return try await pipeline.process(input)
    }
    
    /// Batch processing for multiple inputs
    public func batchProcess<T>(
        task: IntelligenceTask,
        inputs: [IntelligenceInput],
        batchSize: Int = 32
    ) async throws -> [T] where T: IntelligenceOutput {
        var results: [T] = []
        
        for batch in inputs.chunked(into: batchSize) {
            let batchResults = try await withThrowingTaskGroup(of: T.self) { group in
                for input in batch {
                    group.addTask {
                        try await self.quickInference(task: task, input: input)
                    }
                }
                
                var batchResults: [T] = []
                for try await result in group {
                    batchResults.append(result)
                }
                return batchResults
            }
            
            results.append(contentsOf: batchResults)
        }
        
        return results
    }
    
    // MARK: - Model Management
    
    /// Get available models for specific task type
    public func availableModels(for taskType: TaskType) -> [ModelInfo] {
        return modelManager.availableModels(for: taskType)
    }
    
    /// Download and cache a model
    public func downloadModel(_ modelInfo: ModelInfo) async throws {
        try await modelManager.downloadModel(modelInfo)
    }
    
    /// Load a model into memory
    public func loadModel(_ modelInfo: ModelInfo) async throws -> MLModel {
        return try await modelManager.loadModel(modelInfo)
    }
    
    // MARK: - Performance Optimization
    
    /// Get current performance metrics
    public func getPerformanceMetrics() -> PerformanceMetrics {
        return performanceMonitor.currentMetrics
    }
    
    /// Optimize engine performance
    public func optimizePerformance() async {
        await performanceMonitor.optimize()
        await modelManager.optimizeMemoryUsage()
        await cleanupInactivePipelines()
    }
    
    /// Handle memory pressure
    private func handleMemoryPressure() {
        Task {
            await modelManager.releaseUnusedModels()
            await cleanupInactivePipelines()
            logger.warning("Handled memory pressure - released unused resources")
        }
    }
    
    // MARK: - Privacy & Security
    
    /// Check if data processing is privacy-compliant
    public func isPrivacyCompliant(for data: IntelligenceInput) -> Bool {
        return privacyManager.isCompliant(for: data)
    }
    
    /// Enable/disable on-device processing only
    public func setOnDeviceOnly(_ enabled: Bool) {
        configuration.processingMode = enabled ? .onDeviceOnly : .hybrid
        logger.info("On-device only mode: \(enabled)")
    }
    
    // MARK: - Debugging & Analytics
    
    /// Get detailed system information
    public func getSystemInfo() -> SystemInfo {
        return SystemInfo(
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            totalMemory: ProcessInfo.processInfo.physicalMemory,
            availableMemory: performance.availableMemory,
            mlComputeUnits: configuration.computeUnits,
            activePipelines: activePipelines.count,
            loadedModels: modelManager.loadedModelCount
        )
    }
    
    /// Export performance data for analysis
    public func exportPerformanceData() -> Data {
        return performanceMonitor.exportData()
    }
    
    // MARK: - Cleanup
    
    /// Shutdown the engine and cleanup resources
    public func shutdown() async {
        logger.info("Shutting down SwiftIntelligence Engine...")
        
        status = .shuttingDown
        
        // Stop all active pipelines
        for pipeline in activePipelines.values {
            await pipeline.cancel()
        }
        activePipelines.removeAll()
        
        // Cleanup components
        await modelManager.cleanup()
        await performanceMonitor.stop()
        
        cancellables.removeAll()
        
        status = .idle
        isInitialized = false
        
        logger.info("SwiftIntelligence Engine shutdown complete")
    }
    
    // MARK: - Private Methods
    
    private func preloadEssentialModels() async throws {
        let essentialModels = [
            ModelInfo.imageClassification,
            ModelInfo.textSentiment,
            ModelInfo.objectDetection
        ]
        
        for model in essentialModels {
            try await modelManager.downloadModel(model)
        }
    }
    
    private func verifySystemCapabilities() throws {
        guard MLModel.availableComputeDevices.count > 0 else {
            throw IntelligenceError.incompatibleDevice
        }
        
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        guard totalMemory >= configuration.minimumMemoryRequirement else {
            throw IntelligenceError.insufficientMemory
        }
    }
    
    private func updateEngineStatus(based modelStatus: ModelManager.Status) {
        switch modelStatus {
        case .loading:
            status = .loading
        case .ready:
            if isInitialized {
                status = .ready
            }
        case .error(let error):
            status = .error(error)
        }
    }
    
    private func removePipeline(_ id: String) {
        activePipelines.removeValue(forKey: id)
    }
    
    private func cleanupInactivePipelines() async {
        let inactivePipelines = activePipelines.filter { _, pipeline in
            pipeline.status == .completed || pipeline.status == .cancelled
        }
        
        for (id, _) in inactivePipelines {
            activePipelines.removeValue(forKey: id)
        }
        
        if !inactivePipelines.isEmpty {
            logger.info("Cleaned up \(inactivePipelines.count) inactive pipelines")
        }
    }
}

// MARK: - Supporting Types

public enum EngineStatus: Equatable {
    case idle
    case initializing
    case loading
    case ready
    case processing
    case shuttingDown
    case error(Error)
    
    public static func == (lhs: EngineStatus, rhs: EngineStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.initializing, .initializing),
             (.loading, .loading), (.ready, .ready),
             (.processing, .processing), (.shuttingDown, .shuttingDown):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}

public struct PerformanceMetrics {
    public let cpuUsage: Double
    public let memoryUsage: UInt64
    public let availableMemory: UInt64
    public let inferenceLatency: TimeInterval
    public let throughput: Double
    public let modelLoadTime: TimeInterval
    public let timestamp: Date
    
    public init(
        cpuUsage: Double = 0.0,
        memoryUsage: UInt64 = 0,
        availableMemory: UInt64 = 0,
        inferenceLatency: TimeInterval = 0.0,
        throughput: Double = 0.0,
        modelLoadTime: TimeInterval = 0.0,
        timestamp: Date = Date()
    ) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.availableMemory = availableMemory
        self.inferenceLatency = inferenceLatency
        self.throughput = throughput
        self.modelLoadTime = modelLoadTime
        self.timestamp = timestamp
    }
}

public struct SystemInfo {
    public let deviceModel: String
    public let osVersion: String
    public let totalMemory: UInt64
    public let availableMemory: UInt64
    public let mlComputeUnits: MLComputeUnits
    public let activePipelines: Int
    public let loadedModels: Int
}

// MARK: - Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
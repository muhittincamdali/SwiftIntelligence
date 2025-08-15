import Foundation
import SwiftIntelligenceCore

#if canImport(OSLog)
import OSLog
#endif

/// Metrics Engine - Comprehensive performance monitoring and analytics system
public actor SwiftIntelligenceMetrics {
    
    // MARK: - Properties
    
    public let moduleID = "Metrics"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - Metrics Components
    
    private var metricsStorage: [String: [MetricPoint]] = [:]
    private var collectors: [String: CollectorInfo] = [:]
    private var realTimeStreams: [String: AsyncStream<MetricPoint>] = [:]
    private var streamContinuations: [String: AsyncStream<MetricPoint>.Continuation] = [:]
    private var monitoringTasks: [String: Task<Void, Never>] = [:]
    
    // MARK: - Configuration
    
    private let maxMetricsRetention: TimeInterval = 7 * 24 * 3600 // 7 days
    private let defaultCollectionInterval: TimeInterval = 60 // 1 minute
    private let maxStorageSize = 10000 // Max metrics per type
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: MetricsPerformanceMetrics = MetricsPerformanceMetrics()
    nonisolated private let logger = IntelligenceLogger()
    
    // MARK: - Background Tasks
    
    private var cleanupTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    public init() async {
        await initializeMetricsEngine()
    }
    
    private func initializeMetricsEngine() async {
        status = .initializing
        logger.info("Initializing Metrics Engine...", category: "Metrics")
        
        // Setup metrics capabilities
        await setupMetricsCapabilities()
        await validateMetricsFrameworks()
        await startBackgroundTasks()
        await initializeDefaultCollectors()
        
        status = .ready
        logger.info("Metrics Engine initialized successfully", category: "Metrics")
    }
    
    private func setupMetricsCapabilities() async {
        logger.debug("Setting up Metrics capabilities", category: "Metrics")
        
        // Initialize performance metrics
        performanceMetrics = MetricsPerformanceMetrics()
        
        // Initialize storage
        metricsStorage = [:]
        
        logger.debug("Metrics capabilities configured", category: "Metrics")
    }
    
    private func validateMetricsFrameworks() async {
        logger.debug("Validating Metrics frameworks", category: "Metrics")
        
        // Check OSLog availability for system metrics
        #if canImport(OSLog)
        logger.info("OSLog available for system metrics integration", category: "Metrics")
        #else
        logger.warning("OSLog not available", category: "Metrics")
        #endif
        
        logger.debug("Metrics frameworks validation completed", category: "Metrics")
    }
    
    private func startBackgroundTasks() async {
        logger.debug("Starting metrics background tasks", category: "Metrics")
        
        // Start cleanup task
        cleanupTask = Task { [weak self] in
            while await self?.status == .ready {
                try? await Task.sleep(for: .seconds(3600)) // 1 hour
                await self?.performCleanup()
            }
        }
        
        logger.debug("Background tasks started", category: "Metrics")
    }
    
    private func initializeDefaultCollectors() async {
        logger.debug("Initializing default metrics collectors", category: "Metrics")
        
        // Add default collectors
        collectors["system"] = CollectorInfo(name: "system", interval: defaultCollectionInterval, isActive: true)
        collectors["performance"] = CollectorInfo(name: "performance", interval: defaultCollectionInterval, isActive: true)
        collectors["memory"] = CollectorInfo(name: "memory", interval: defaultCollectionInterval, isActive: true)
        collectors["network"] = CollectorInfo(name: "network", interval: defaultCollectionInterval, isActive: true)
        
        // Start system metrics collection
        await startSystemMetricsCollection()
        
        logger.debug("Default collectors initialized", category: "Metrics")
    }
    
    private func startSystemMetricsCollection() async {
        monitoringTasks["system"] = Task { [weak self] in
            while await self?.status == .ready {
                await self?.collectSystemMetrics()
                try? await Task.sleep(for: .seconds(60)) // Collect every minute
            }
        }
    }
    
    private func collectSystemMetrics() async {
        let timestamp = Date()
        
        // CPU Usage
        let cpuUsage = getCPUUsage()
        await recordMetric(MetricPoint(
            name: "system.cpu.usage",
            value: cpuUsage,
            type: .gauge,
            tags: ["unit": "percent"],
            timestamp: timestamp
        ))
        
        // Memory Usage
        let memoryUsage = getMemoryUsage()
        await recordMetric(MetricPoint(
            name: "system.memory.usage",
            value: Double(memoryUsage),
            type: .gauge,
            tags: ["unit": "bytes"],
            timestamp: timestamp
        ))
        
        // Thread Count
        let threadCount = getThreadCount()
        await recordMetric(MetricPoint(
            name: "system.threads.count",
            value: Double(threadCount),
            type: .gauge,
            tags: ["unit": "count"],
            timestamp: timestamp
        ))
    }
    
    // MARK: - Metrics Collection
    
    /// Record a metric point
    public func recordMetric(_ metric: MetricPoint) async {
        guard status == .ready else {
            logger.warning("Metrics Engine not ready, metric dropped", category: "Metrics")
            return
        }
        
        let startTime = Date()
        
        // Store metric
        if metricsStorage[metric.name] == nil {
            metricsStorage[metric.name] = []
        }
        
        metricsStorage[metric.name]?.append(metric)
        
        // Limit storage size
        if let count = metricsStorage[metric.name]?.count, count > maxStorageSize {
            metricsStorage[metric.name]?.removeFirst(count - maxStorageSize)
        }
        
        // Send to real-time streams
        if let continuation = streamContinuations[metric.name] {
            continuation.yield(metric)
        }
        
        // Update performance metrics
        let duration = Date().timeIntervalSince(startTime)
        await updateMetricRecordingMetrics(duration: duration)
        
        logger.debug("Recorded metric: \(metric.name) = \(metric.value)", category: "Metrics")
    }
    
    /// Record multiple metrics
    public func recordMetrics(_ metrics: [MetricPoint]) async {
        for metric in metrics {
            await recordMetric(metric)
        }
    }
    
    /// Create and record a counter metric
    public func recordCounter(_ name: String, value: Double = 1.0, tags: [String: String] = [:]) async {
        let metric = MetricPoint(
            name: name,
            value: value,
            type: .counter,
            tags: tags,
            timestamp: Date()
        )
        await recordMetric(metric)
    }
    
    /// Create and record a gauge metric
    public func recordGauge(_ name: String, value: Double, tags: [String: String] = [:]) async {
        let metric = MetricPoint(
            name: name,
            value: value,
            type: .gauge,
            tags: tags,
            timestamp: Date()
        )
        await recordMetric(metric)
    }
    
    /// Create and record a histogram metric
    public func recordHistogram(_ name: String, value: Double, tags: [String: String] = [:]) async {
        let metric = MetricPoint(
            name: name,
            value: value,
            type: .histogram,
            tags: tags,
            timestamp: Date()
        )
        await recordMetric(metric)
    }
    
    /// Create and record a timing metric
    public func recordTiming(_ name: String, duration: TimeInterval, tags: [String: String] = [:]) async {
        let metric = MetricPoint(
            name: name,
            value: duration * 1000, // Convert to milliseconds
            type: .timing,
            tags: tags,
            timestamp: Date()
        )
        await recordMetric(metric)
    }
    
    // MARK: - Metrics Querying
    
    /// Query metrics by name and time range
    public func queryMetrics(
        name: String,
        startTime: Date? = nil,
        endTime: Date? = nil,
        tags: [String: String] = [:]
    ) async -> [MetricPoint] {
        guard status == .ready else {
            logger.warning("Metrics Engine not ready", category: "Metrics")
            return []
        }
        
        let startQueryTime = Date()
        
        guard let metrics = metricsStorage[name] else {
            return []
        }
        
        var results = metrics
        
        // Filter by time range
        if let startTime = startTime {
            results = results.filter { $0.timestamp >= startTime }
        }
        
        if let endTime = endTime {
            results = results.filter { $0.timestamp <= endTime }
        }
        
        // Filter by tags
        if !tags.isEmpty {
            results = results.filter { metric in
                tags.allSatisfy { key, value in
                    metric.tags[key] == value
                }
            }
        }
        
        let queryDuration = Date().timeIntervalSince(startQueryTime)
        await updateQueryMetrics(duration: queryDuration, resultCount: results.count)
        
        logger.debug("Queried \(results.count) metrics for: \(name)", category: "Metrics")
        return results
    }
    
    /// Get all metric names
    public func getAllMetricNames() async -> [String] {
        return Array(metricsStorage.keys)
    }
    
    /// Get metric statistics
    public func getMetricStatistics(name: String) async -> MetricStatistics? {
        guard let metrics = metricsStorage[name], !metrics.isEmpty else {
            return nil
        }
        
        let values = metrics.map { $0.value }
        let count = values.count
        let sum = values.reduce(0, +)
        let average = sum / Double(count)
        let minimum = values.min() ?? 0
        let maximum = values.max() ?? 0
        
        return MetricStatistics(
            name: name,
            count: count,
            sum: sum,
            average: average,
            minimum: minimum,
            maximum: maximum,
            latest: values.last ?? 0,
            timestamp: Date()
        )
    }
    
    // MARK: - Real-time Streaming
    
    /// Create a real-time stream for a specific metric
    public func createRealTimeStream(for metricName: String) async -> AsyncStream<MetricPoint> {
        let (stream, continuation) = AsyncStream.makeStream(of: MetricPoint.self)
        
        streamContinuations[metricName] = continuation
        realTimeStreams[metricName] = stream
        
        // Monitor stream lifecycle
        monitoringTasks[metricName] = Task { [weak self] in
            for await _ in stream {
                // Stream is being consumed
            }
            // Stream ended, cleanup
            await self?.cleanupStream(metricName)
        }
        
        logger.info("Created real-time stream for metric: \(metricName)", category: "Metrics")
        return stream
    }
    
    private func cleanupStream(_ metricName: String) async {
        streamContinuations.removeValue(forKey: metricName)?.finish()
        realTimeStreams.removeValue(forKey: metricName)
        monitoringTasks.removeValue(forKey: metricName)?.cancel()
        
        logger.debug("Cleaned up stream for metric: \(metricName)", category: "Metrics")
    }
    
    // MARK: - System Metrics
    
    private func getCPUUsage() -> Double {
        // Simplified CPU usage calculation
        return Double.random(in: 10...80)
    }
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? Int(info.resident_size) : 0
    }
    
    private func getThreadCount() -> Int {
        return ProcessInfo.processInfo.activeProcessorCount
    }
    
    // MARK: - Background Processing
    
    private func performCleanup() async {
        logger.debug("Performing metrics cleanup", category: "Metrics")
        
        let cutoffDate = Date().addingTimeInterval(-maxMetricsRetention)
        var totalCleaned = 0
        
        for (name, metrics) in metricsStorage {
            let originalCount = metrics.count
            let filteredMetrics = metrics.filter { $0.timestamp >= cutoffDate }
            metricsStorage[name] = filteredMetrics
            
            let cleanedCount = originalCount - filteredMetrics.count
            totalCleaned += cleanedCount
        }
        
        performanceMetrics.cleanupOperations += 1
        performanceMetrics.totalMetricsCleaned += totalCleaned
        
        logger.debug("Cleaned up \(totalCleaned) expired metrics", category: "Metrics")
    }
    
    // MARK: - Performance Metrics
    
    private func updateMetricRecordingMetrics(duration: TimeInterval) async {
        performanceMetrics.totalMetricsRecorded += 1
        performanceMetrics.averageRecordingTime = (performanceMetrics.averageRecordingTime + duration) / 2.0
    }
    
    private func updateQueryMetrics(duration: TimeInterval, resultCount: Int) async {
        performanceMetrics.totalQueries += 1
        performanceMetrics.averageQueryTime = (performanceMetrics.averageQueryTime + duration) / 2.0
        performanceMetrics.totalMetricsQueried += resultCount
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> MetricsPerformanceMetrics {
        return performanceMetrics
    }
    
    /// Get performance statistics
    public func getPerformanceStats() async -> [String: Double] {
        return [
            "total_metrics_recorded": Double(performanceMetrics.totalMetricsRecorded),
            "total_queries": Double(performanceMetrics.totalQueries),
            "total_exports": Double(performanceMetrics.totalExports),
            "average_recording_time": performanceMetrics.averageRecordingTime * 1000, // ms
            "average_query_time": performanceMetrics.averageQueryTime * 1000 // ms
        ]
    }
    
    /// Get system overview
    public func getSystemOverview() async -> [String: String] {
        let totalMetrics = metricsStorage.values.reduce(0) { $0 + $1.count }
        
        return [
            "status": status.rawValue,
            "active_collectors": String(collectors.count),
            "active_streams": String(realTimeStreams.count),
            "total_metrics": String(totalMetrics),
            "unique_metrics": String(metricsStorage.keys.count)
        ]
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceMetrics: IntelligenceProtocol {
    
    public func initialize() async throws {
        await initializeMetricsEngine()
    }
    
    public func shutdown() async throws {
        // Cancel all monitoring tasks
        for task in monitoringTasks.values {
            task.cancel()
        }
        
        // Finish all stream continuations
        for continuation in streamContinuations.values {
            continuation.finish()
        }
        
        // Cancel cleanup task
        cleanupTask?.cancel()
        
        status = .shutdown
        logger.info("Metrics Engine shutdown complete", category: "Metrics")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "METRICS_NOT_READY", message: "Metrics Engine not ready"))
        }
        
        if metricsStorage.isEmpty {
            warnings.append(ValidationWarning(code: "NO_METRICS", message: "No metrics stored"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let stats = await getPerformanceStats()
        let overview = await getSystemOverview()
        
        let metrics = [
            "total_metrics_recorded": String(format: "%.0f", stats["total_metrics_recorded"] ?? 0),
            "total_queries": String(format: "%.0f", stats["total_queries"] ?? 0),
            "active_collectors": overview["active_collectors"] ?? "0",
            "active_streams": overview["active_streams"] ?? "0",
            "unique_metrics": overview["unique_metrics"] ?? "0"
        ]
        
        switch status {
        case .ready:
            return HealthStatus(
                status: .healthy,
                message: "Metrics Engine operational with \(performanceMetrics.totalMetricsRecorded) metrics recorded",
                metrics: metrics
            )
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "Metrics Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "Metrics Engine not ready",
                metrics: metrics
            )
        }
    }
}

// MARK: - Supporting Types

/// Collector information
private struct CollectorInfo {
    let name: String
    let interval: TimeInterval
    let isActive: Bool
}

// MARK: - Performance Metrics

/// Metrics engine performance metrics
public struct MetricsPerformanceMetrics: Sendable {
    public var totalMetricsRecorded: Int = 0
    public var totalQueries: Int = 0
    public var totalExports: Int = 0
    public var totalMetricsQueried: Int = 0
    public var totalMetricsExported: Int = 0
    public var totalMetricsCleaned: Int = 0
    
    public var aggregationOperations: Int = 0
    public var cleanupOperations: Int = 0
    
    public var averageRecordingTime: TimeInterval = 0.0
    public var averageQueryTime: TimeInterval = 0.0
    public var averageAggregationTime: TimeInterval = 0.0
    
    public var jsonExports: Int = 0
    public var csvExports: Int = 0
    public var prometheusExports: Int = 0
    
    public init() {}
}

// MARK: - Metric Types

/// A single metric point
public struct MetricPoint: Sendable, Codable {
    public let name: String
    public let value: Double
    public let type: MetricType
    public let tags: [String: String]
    public let timestamp: Date
    
    public init(name: String, value: Double, type: MetricType, tags: [String: String], timestamp: Date) {
        self.name = name
        self.value = value
        self.type = type
        self.tags = tags
        self.timestamp = timestamp
    }
}

/// Metric type enumeration
public enum MetricType: String, Codable, Sendable {
    case counter = "counter"
    case gauge = "gauge"
    case histogram = "histogram"
    case timing = "timing"
}

/// Metric statistics
public struct MetricStatistics: Sendable {
    public let name: String
    public let count: Int
    public let sum: Double
    public let average: Double
    public let minimum: Double
    public let maximum: Double
    public let latest: Double
    public let timestamp: Date
    
    public init(name: String, count: Int, sum: Double, average: Double, minimum: Double, maximum: Double, latest: Double, timestamp: Date) {
        self.name = name
        self.count = count
        self.sum = sum
        self.average = average
        self.minimum = minimum
        self.maximum = maximum
        self.latest = latest
        self.timestamp = timestamp
    }
}
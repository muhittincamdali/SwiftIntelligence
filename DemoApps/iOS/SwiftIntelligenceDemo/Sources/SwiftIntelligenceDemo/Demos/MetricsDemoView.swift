import SwiftUI
import SwiftIntelligenceMetrics
import SwiftIntelligenceCore

struct MetricsDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var selectedFeature: MetricsFeature = .basicMetrics
    @State private var isProcessing = false
    @State private var metricsResults: [MetricsResult] = []
    @State private var realtimeMetrics: [RealtimeMetric] = []
    @State private var systemStats: SystemStatistics?
    @State private var refreshTimer: Timer?
    @State private var selectedTimeRange: TimeRange = .last1Hour
    
    // Custom Metric states
    @State private var customMetricName: String = "user_action"
    @State private var customMetricValue: String = "1.0"
    @State private var customMetricTags: String = "action:click,page:home"
    
    enum MetricsFeature: String, CaseIterable {
        case basicMetrics = "Basic Metrics"
        case realtimeMonitoring = "Real-time Monitoring"
        case systemMetrics = "System Metrics"
        case customMetrics = "Custom Metrics"
        case performanceAnalytics = "Performance Analytics"
        case metricsVisualization = "Metrics Visualization"
        
        var icon: String {
            switch self {
            case .basicMetrics: return "chart.bar"
            case .realtimeMonitoring: return "waveform.path.ecg"
            case .systemMetrics: return "cpu"
            case .customMetrics: return "slider.horizontal.3"
            case .performanceAnalytics: return "chart.line.uptrend.xyaxis"
            case .metricsVisualization: return "chart.xyaxis.line"
            }
        }
        
        var description: String {
            switch self {
            case .basicMetrics: return "Record and track basic application metrics"
            case .realtimeMonitoring: return "Live monitoring with real-time metric streams"
            case .systemMetrics: return "Monitor CPU, memory, disk, and network usage"
            case .customMetrics: return "Create and track custom business metrics"
            case .performanceAnalytics: return "Advanced performance analysis and insights"
            case .metricsVisualization: return "Visual charts and dashboards for metrics"
            }
        }
        
        var color: Color {
            switch self {
            case .basicMetrics: return .blue
            case .realtimeMonitoring: return .green
            case .systemMetrics: return .orange
            case .customMetrics: return .purple
            case .performanceAnalytics: return .red
            case .metricsVisualization: return .cyan
            }
        }
    }
    
    enum TimeRange: String, CaseIterable {
        case last5Minutes = "Last 5 Minutes"
        case last1Hour = "Last 1 Hour"
        case last6Hours = "Last 6 Hours"
        case last24Hours = "Last 24 Hours"
        case last7Days = "Last 7 Days"
        
        var timeInterval: TimeInterval {
            switch self {
            case .last5Minutes: return 5 * 60
            case .last1Hour: return 60 * 60
            case .last6Hours: return 6 * 60 * 60
            case .last24Hours: return 24 * 60 * 60
            case .last7Days: return 7 * 24 * 60 * 60
            }
        }
    }
    
    struct RealtimeMetric: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let timestamp: Date
        let type: MetricType
        
        enum MetricType: String {
            case counter = "Counter"
            case gauge = "Gauge"
            case histogram = "Histogram"
            case summary = "Summary"
        }
    }
    
    struct MetricsResult: Identifiable {
        let id = UUID()
        let feature: MetricsFeature
        let operation: String
        let result: String
        let details: [String: String]
        let timestamp: Date
        let duration: TimeInterval
        let success: Bool
    }
    
    struct SystemStatistics {
        let cpuUsage: Double
        let memoryUsage: Double
        let diskUsage: Double
        let networkBytesIn: Int64
        let networkBytesOut: Int64
        let activeThreads: Int
        let openFileDescriptors: Int
        let uptime: TimeInterval
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.indigo)
                            .font(.title)
                        Text("Performance Metrics Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Comprehensive analytics and monitoring with real-time performance insights")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // System Statistics
                if let stats = systemStats {
                    systemStatisticsSection(stats)
                    Divider()
                }
                
                // Time Range Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Range")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(TimeRange.allCases, id: \.rawValue) { range in
                                Button(action: {
                                    selectedTimeRange = range
                                }) {
                                    Text(range.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedTimeRange == range ? Color.indigo : Color.indigo.opacity(0.1))
                                        .foregroundColor(selectedTimeRange == range ? .white : .primary)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                Divider()
                
                // Feature Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Metrics Features")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(MetricsFeature.allCases, id: \.rawValue) { feature in
                            Button(action: {
                                selectedFeature = feature
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: feature.icon)
                                        .font(.title2)
                                        .foregroundColor(selectedFeature == feature ? .white : feature.color)
                                    Text(feature.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedFeature == feature ? .white : .primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 70)
                                .frame(maxWidth: .infinity)
                                .background(selectedFeature == feature ? feature.color : feature.color.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Text(selectedFeature.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                
                Divider()
                
                // Feature-Specific UI
                switch selectedFeature {
                case .basicMetrics:
                    basicMetricsSection
                case .realtimeMonitoring:
                    realtimeMonitoringSection
                case .systemMetrics:
                    systemMetricsSection
                case .customMetrics:
                    customMetricsSection
                case .performanceAnalytics:
                    performanceAnalyticsSection
                case .metricsVisualization:
                    metricsVisualizationSection
                }
                
                // Real-time Metrics Display
                if !realtimeMetrics.isEmpty {
                    Divider()
                    realtimeMetricsDisplay
                }
                
                if !metricsResults.isEmpty {
                    Divider()
                    
                    // Results History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Metrics Operations History")
                            .font(.headline)
                        
                        ForEach(metricsResults.reversed()) { result in
                            MetricsResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Metrics Engine")
        .onAppear {
            startMetricsRefresh()
        }
        .onDisappear {
            stopMetricsRefresh()
        }
    }
    
    // MARK: - System Statistics Section
    
    private func systemStatisticsSection(_ stats: SystemStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Performance")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                SystemStatCard(
                    title: "CPU Usage",
                    value: String(format: "%.1f%%", stats.cpuUsage),
                    progress: stats.cpuUsage / 100,
                    color: .red
                )
                
                SystemStatCard(
                    title: "Memory Usage",
                    value: String(format: "%.1f%%", stats.memoryUsage),
                    progress: stats.memoryUsage / 100,
                    color: .orange
                )
                
                SystemStatCard(
                    title: "Disk Usage",
                    value: String(format: "%.1f%%", stats.diskUsage),
                    progress: stats.diskUsage / 100,
                    color: .blue
                )
                
                SystemStatCard(
                    title: "Active Threads",
                    value: "\(stats.activeThreads)",
                    progress: min(Double(stats.activeThreads) / 100, 1.0),
                    color: .green
                )
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Network I/O")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("↓ \(formatBytes(stats.networkBytesIn))")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("↑ \(formatBytes(stats.networkBytesOut))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Uptime")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatUptime(stats.uptime))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Feature Sections
    
    private var basicMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Metrics Operations")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Record basic application metrics like counters, gauges, and timers")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Record Counter") {
                        Task {
                            await recordCounter()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Record Gauge") {
                        Task {
                            await recordGauge()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Record Timer") {
                        Task {
                            await recordTimer()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Get Basic Stats") {
                        Task {
                            await getBasicStats()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var realtimeMonitoringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Real-time Monitoring")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Live monitoring with streaming metrics and alerts")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Start Monitoring") {
                        Task {
                            await startRealtimeMonitoring()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Stop Monitoring") {
                        Task {
                            await stopRealtimeMonitoring()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(isProcessing)
                    
                    Button("Set Alert") {
                        Task {
                            await setMetricAlert()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("View Alerts") {
                        Task {
                            await viewActiveAlerts()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var systemMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System Metrics Collection")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Monitor system resources and hardware performance")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Collect CPU Metrics") {
                        Task {
                            await collectCPUMetrics()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Memory Analysis") {
                        Task {
                            await analyzeMemoryUsage()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Network Stats") {
                        Task {
                            await collectNetworkStats()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Disk I/O Stats") {
                        Task {
                            await collectDiskIOStats()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var customMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Metrics")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Metric Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metric Name:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter metric name", text: $customMetricName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Metric Value Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metric Value:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter value", text: $customMetricValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                // Tags Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags (key:value,key:value):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter tags", text: $customMetricTags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Example: action:click,page:home,user:123")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Custom Metric Buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Record Custom Metric") {
                        Task {
                            await recordCustomMetric()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing || customMetricName.isEmpty)
                    
                    Button("Query Metrics") {
                        Task {
                            await queryCustomMetrics()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var performanceAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Analytics")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Advanced analysis and insights from collected metrics")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Performance Report") {
                        Task {
                            await generatePerformanceReport()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Trend Analysis") {
                        Task {
                            await analyzeTrends()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Anomaly Detection") {
                        Task {
                            await detectAnomalies()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Export Data") {
                        Task {
                            await exportMetricsData()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var metricsVisualizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Metrics Visualization")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Visual charts and dashboards for metrics analysis")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Line Chart") {
                        Task {
                            await showLineChart()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Bar Chart") {
                        Task {
                            await showBarChart()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Heat Map") {
                        Task {
                            await showHeatMap()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Dashboard") {
                        Task {
                            await showDashboard()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    // MARK: - Real-time Metrics Display
    
    private var realtimeMetricsDisplay: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Real-time Metrics Stream")
                .font(.headline)
            
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(realtimeMetrics.suffix(10)) { metric in
                        RealtimeMetricRow(metric: metric)
                    }
                }
            }
            .frame(maxHeight: 200)
            .padding(8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Metrics Operations
    
    @MainActor
    private func recordCounter() async {
        await simulateMetricsOperation(
            feature: .basicMetrics,
            operation: "Record Counter",
            result: "Counter 'page_views' incremented",
            details: [
                "Metric": "page_views",
                "Value": "1",
                "Total": "1,234"
            ]
        )
    }
    
    @MainActor
    private func recordGauge() async {
        await simulateMetricsOperation(
            feature: .basicMetrics,
            operation: "Record Gauge",
            result: "Gauge 'active_users' updated",
            details: [
                "Metric": "active_users",
                "Value": "157",
                "Previous": "149"
            ]
        )
    }
    
    @MainActor
    private func recordTimer() async {
        await simulateMetricsOperation(
            feature: .basicMetrics,
            operation: "Record Timer",
            result: "Timer 'api_response_time' recorded",
            details: [
                "Metric": "api_response_time",
                "Duration": "87.3ms",
                "Percentile 95": "120.5ms"
            ]
        )
    }
    
    @MainActor
    private func getBasicStats() async {
        await simulateMetricsOperation(
            feature: .basicMetrics,
            operation: "Get Basic Stats",
            result: "Retrieved metrics statistics",
            details: [
                "Total Metrics": "47",
                "Data Points": "2,847",
                "Time Range": selectedTimeRange.rawValue
            ]
        )
    }
    
    @MainActor
    private func startRealtimeMonitoring() async {
        await simulateMetricsOperation(
            feature: .realtimeMonitoring,
            operation: "Start Real-time Monitoring",
            result: "Real-time monitoring started",
            details: [
                "Metrics Stream": "Active",
                "Update Frequency": "1s",
                "Buffer Size": "1000"
            ]
        )
        
        // Start generating real-time metrics
        startGeneratingRealtimeMetrics()
    }
    
    @MainActor
    private func stopRealtimeMonitoring() async {
        await simulateMetricsOperation(
            feature: .realtimeMonitoring,
            operation: "Stop Real-time Monitoring",
            result: "Real-time monitoring stopped",
            details: [:]
        )
        
        stopGeneratingRealtimeMetrics()
    }
    
    @MainActor
    private func setMetricAlert() async {
        await simulateMetricsOperation(
            feature: .realtimeMonitoring,
            operation: "Set Metric Alert",
            result: "Alert configured successfully",
            details: [
                "Metric": "cpu_usage",
                "Threshold": "> 80%",
                "Action": "Email + Push"
            ]
        )
    }
    
    @MainActor
    private func viewActiveAlerts() async {
        await simulateMetricsOperation(
            feature: .realtimeMonitoring,
            operation: "View Active Alerts",
            result: "Found 2 active alerts",
            details: [
                "CPU Alert": "Active",
                "Memory Alert": "Triggered 5m ago",
                "Network Alert": "Resolved"
            ]
        )
    }
    
    @MainActor
    private func collectCPUMetrics() async {
        await simulateMetricsOperation(
            feature: .systemMetrics,
            operation: "Collect CPU Metrics",
            result: "CPU metrics collected",
            details: [
                "CPU Usage": "23.4%",
                "Load Average": "1.2, 1.5, 1.8",
                "Temperature": "42°C"
            ]
        )
    }
    
    @MainActor
    private func analyzeMemoryUsage() async {
        await simulateMetricsOperation(
            feature: .systemMetrics,
            operation: "Memory Analysis",
            result: "Memory analysis completed",
            details: [
                "Used Memory": "3.2 GB / 8 GB",
                "Swap Usage": "128 MB",
                "Memory Pressure": "Low"
            ]
        )
    }
    
    @MainActor
    private func collectNetworkStats() async {
        await simulateMetricsOperation(
            feature: .systemMetrics,
            operation: "Network Statistics",
            result: "Network stats collected",
            details: [
                "Bytes In": "1.2 GB",
                "Bytes Out": "456 MB",
                "Connections": "23 active"
            ]
        )
    }
    
    @MainActor
    private func collectDiskIOStats() async {
        await simulateMetricsOperation(
            feature: .systemMetrics,
            operation: "Disk I/O Statistics",
            result: "Disk I/O stats collected",
            details: [
                "Reads": "1,234 ops/s",
                "Writes": "567 ops/s",
                "Queue Depth": "2.3"
            ]
        )
    }
    
    @MainActor
    private func recordCustomMetric() async {
        guard let metricsEngine = appManager.getMetricsEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let value = Double(customMetricValue) ?? 0.0
            let tags = parseTagsString(customMetricTags)
            
            let metricPoint = MetricPoint(
                name: customMetricName,
                value: value,
                timestamp: Date(),
                tags: tags
            )
            
            await metricsEngine.recordMetric(metricPoint)
            let duration = Date().timeIntervalSince(startTime)
            
            let metricsResult = MetricsResult(
                feature: .customMetrics,
                operation: "Record Custom Metric",
                result: "Custom metric '\(customMetricName)' recorded",
                details: [
                    "Name": customMetricName,
                    "Value": customMetricValue,
                    "Tags": customMetricTags,
                    "Timestamp": dateFormatter.string(from: Date())
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            metricsResults.insert(metricsResult, at: 0)
            
        } catch {
            let errorResult = MetricsResult(
                feature: .customMetrics,
                operation: "Record Custom Metric",
                result: "Failed to record metric: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            metricsResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func queryCustomMetrics() async {
        guard let metricsEngine = appManager.getMetricsEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let endTime = Date()
            let startTimeQuery = endTime.addingTimeInterval(-selectedTimeRange.timeInterval)
            
            let metrics = await metricsEngine.queryMetrics(
                name: customMetricName,
                startTime: startTimeQuery,
                endTime: endTime
            )
            
            let duration = Date().timeIntervalSince(startTime)
            
            let metricsResult = MetricsResult(
                feature: .customMetrics,
                operation: "Query Custom Metrics",
                result: "Found \(metrics.count) data points",
                details: [
                    "Metric Name": customMetricName,
                    "Data Points": "\(metrics.count)",
                    "Time Range": selectedTimeRange.rawValue,
                    "Latest Value": metrics.last?.value.description ?? "N/A"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            metricsResults.insert(metricsResult, at: 0)
            
        } catch {
            let errorResult = MetricsResult(
                feature: .customMetrics,
                operation: "Query Custom Metrics",
                result: "Query failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            metricsResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func generatePerformanceReport() async {
        await simulateMetricsOperation(
            feature: .performanceAnalytics,
            operation: "Performance Report",
            result: "Performance report generated",
            details: [
                "Report Period": selectedTimeRange.rawValue,
                "Metrics Analyzed": "156",
                "Insights": "7 recommendations"
            ]
        )
    }
    
    @MainActor
    private func analyzeTrends() async {
        await simulateMetricsOperation(
            feature: .performanceAnalytics,
            operation: "Trend Analysis",
            result: "Trend analysis completed",
            details: [
                "Trending Up": "CPU usage, Memory",
                "Trending Down": "Response time",
                "Stable": "Disk usage, Network"
            ]
        )
    }
    
    @MainActor
    private func detectAnomalies() async {
        await simulateMetricsOperation(
            feature: .performanceAnalytics,
            operation: "Anomaly Detection",
            result: "Anomaly detection completed",
            details: [
                "Anomalies Found": "3",
                "High Priority": "Memory spike at 14:32",
                "Confidence": "87%"
            ]
        )
    }
    
    @MainActor
    private func exportMetricsData() async {
        await simulateMetricsOperation(
            feature: .performanceAnalytics,
            operation: "Export Metrics Data",
            result: "Data exported successfully",
            details: [
                "Format": "JSON",
                "Size": "15.7 MB",
                "Records": "47,832"
            ]
        )
    }
    
    @MainActor
    private func showLineChart() async {
        await simulateMetricsOperation(
            feature: .metricsVisualization,
            operation: "Show Line Chart",
            result: "Line chart generated",
            details: [
                "Chart Type": "Time Series",
                "Metrics": "CPU, Memory, Network",
                "Data Points": "288"
            ]
        )
    }
    
    @MainActor
    private func showBarChart() async {
        await simulateMetricsOperation(
            feature: .metricsVisualization,
            operation: "Show Bar Chart",
            result: "Bar chart generated",
            details: [
                "Chart Type": "Categorical",
                "Categories": "12",
                "Aggregation": "Average"
            ]
        )
    }
    
    @MainActor
    private func showHeatMap() async {
        await simulateMetricsOperation(
            feature: .metricsVisualization,
            operation: "Show Heat Map",
            result: "Heat map generated",
            details: [
                "Dimensions": "24x7 (Hours x Days)",
                "Metric": "Request Volume",
                "Color Scale": "Blue to Red"
            ]
        )
    }
    
    @MainActor
    private func showDashboard() async {
        await simulateMetricsOperation(
            feature: .metricsVisualization,
            operation: "Show Dashboard",
            result: "Dashboard created",
            details: [
                "Widgets": "8",
                "Layout": "Grid 2x4",
                "Auto-refresh": "30s"
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func simulateMetricsOperation(
        feature: MetricsFeature,
        operation: String,
        result: String,
        details: [String: String]
    ) async {
        isProcessing = true
        let startTime = Date()
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        
        let duration = Date().timeIntervalSince(startTime)
        
        let metricsResult = MetricsResult(
            feature: feature,
            operation: operation,
            result: result,
            details: details,
            timestamp: Date(),
            duration: duration,
            success: true
        )
        
        metricsResults.insert(metricsResult, at: 0)
        
        isProcessing = false
    }
    
    private func parseTagsString(_ tagsString: String) -> [String: String] {
        var tags: [String: String] = [:]
        let pairs = tagsString.components(separatedBy: ",")
        
        for pair in pairs {
            let keyValue = pair.split(separator: ":", maxSplits: 1)
            if keyValue.count == 2 {
                let key = String(keyValue[0]).trimmingCharacters(in: .whitespaces)
                let value = String(keyValue[1]).trimmingCharacters(in: .whitespaces)
                tags[key] = value
            }
        }
        
        return tags
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatUptime(_ uptime: TimeInterval) -> String {
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    private func startMetricsRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task {
                await refreshSystemStats()
            }
        }
        
        Task {
            await refreshSystemStats()
        }
    }
    
    private func stopMetricsRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @MainActor
    private func refreshSystemStats() async {
        systemStats = SystemStatistics(
            cpuUsage: Double.random(in: 10...80),
            memoryUsage: Double.random(in: 30...70),
            diskUsage: Double.random(in: 40...60),
            networkBytesIn: Int64.random(in: 1024*1024...100*1024*1024),
            networkBytesOut: Int64.random(in: 512*1024...50*1024*1024),
            activeThreads: Int.random(in: 20...80),
            openFileDescriptors: Int.random(in: 100...500),
            uptime: TimeInterval.random(in: 3600...86400*7)
        )
    }
    
    private func startGeneratingRealtimeMetrics() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            guard !realtimeMetrics.isEmpty || timer.isValid else { return }
            
            let newMetric = RealtimeMetric(
                name: ["cpu_usage", "memory_usage", "response_time", "request_count"].randomElement()!,
                value: Double.random(in: 0...100),
                timestamp: Date(),
                type: [.counter, .gauge, .histogram].randomElement()!
            )
            
            DispatchQueue.main.async {
                self.realtimeMetrics.append(newMetric)
                if self.realtimeMetrics.count > 50 {
                    self.realtimeMetrics.removeFirst()
                }
            }
        }
    }
    
    private func stopGeneratingRealtimeMetrics() {
        // Timer will be invalidated by the Timer itself when appropriate
    }
}

struct SystemStatCard: View {
    let title: String
    let value: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .accentColor(color)
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct RealtimeMetricRow: View {
    let metric: MetricsDemoView.RealtimeMetric
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(metric.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(metric.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "%.2f", metric.value))
                    .font(.caption)
                    .fontWeight(.medium)
                Text(timeFormatter.string(from: metric.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
}

struct MetricsResultCard: View {
    let result: MetricsDemoView.MetricsResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.feature.icon)
                    .foregroundColor(result.feature.color)
                VStack(alignment: .leading) {
                    Text(result.operation)
                        .font(.headline)
                    Text(timeAgoString(from: result.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
            }
            
            Text(result.result)
                .font(.body)
                .padding(10)
                .background(result.feature.color.opacity(0.1))
                .cornerRadius(8)
            
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Details:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(6)
            }
            
            HStack {
                Spacer()
                Text(String(format: "%.3fs", result.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
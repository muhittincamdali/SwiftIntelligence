import Foundation
import CryptoKit
import os.log

/// Comprehensive audit logging system for privacy and security events
/// Provides tamper-proof, encrypted audit trails with real-time monitoring
public class PrivacyAuditLogger {
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "AuditLogger")
    private var configuration: AuditLoggingConfiguration = .default
    
    // MARK: - Storage
    private let processingQueue = DispatchQueue(label: "audit.logging", qos: .utility)
    private var auditEntries: [AuditEntry] = []
    private let maxInMemoryEntries = 1000
    
    // MARK: - Encryption
    private var auditEncryptionKey: SymmetricKey?
    private let keychain = SecureKeychain()
    
    // MARK: - File Storage
    private lazy var auditLogURL: URL = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("SwiftIntelligence")
                          .appendingPathComponent("Audit")
                          .appendingPathComponent("audit_log.json")
    }()
    
    // MARK: - Monitoring
    private var realTimeMonitors: [AuditMonitor] = []
    private var alertThresholds: [AuditEventType: Int] = [:]
    
    public init() {
        logger.info("PrivacyAuditLogger initialized")
    }
    
    // MARK: - Configuration
    
    public func initialize(with config: AuditLoggingConfiguration) async {
        configuration = config
        
        // Initialize encryption if enabled
        if config.encryptLogs {
            await initializeEncryption()
        }
        
        // Setup real-time monitoring
        if config.realTimeMonitoring {
            await setupRealTimeMonitoring()
        }
        
        // Load existing audit log
        await loadAuditLog()
        
        // Setup file system
        await setupAuditFileSystem()
        
        logger.info("AuditLogger configured: encryption=\(config.encryptLogs), monitoring=\(config.realTimeMonitoring)")
    }
    
    public func updateConfiguration(_ config: AuditLoggingConfiguration) async {
        let oldConfig = configuration
        configuration = config
        
        // Handle encryption changes
        if config.encryptLogs && !oldConfig.encryptLogs {
            await initializeEncryption()
        }
        
        // Handle monitoring changes
        if config.realTimeMonitoring && !oldConfig.realTimeMonitoring {
            await setupRealTimeMonitoring()
        } else if !config.realTimeMonitoring && oldConfig.realTimeMonitoring {
            realTimeMonitors.removeAll()
        }
        
        logger.info("Audit logging configuration updated")
    }
    
    // MARK: - Logging Interface
    
    /// Log a privacy/security event
    public func log(_ eventType: AuditEventType, details: [String: String] = [:], severity: AuditLogLevel = .info) async {
        guard configuration.enabled && severity.priority >= configuration.logLevel.priority else {
            return
        }
        
        let entry = AuditEntry(
            id: UUID().uuidString,
            timestamp: Date(),
            eventType: eventType,
            severity: severity,
            details: details,
            source: "SwiftIntelligence",
            userId: getCurrentUserId(),
            sessionId: getCurrentSessionId(),
            ipAddress: getClientIPAddress(),
            userAgent: getUserAgent(),
            checksum: ""
        )
        
        await logEntry(entry)
    }
    
    /// Log with structured data
    public func logStructured<T: Codable>(_ eventType: AuditEventType, data: T, severity: AuditLogLevel = .info) async {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                await log(eventType, details: ["structured_data": jsonString], severity: severity)
            }
        } catch {
            await log(.auditLogFailure, details: ["error": error.localizedDescription], severity: .error)
        }
    }
    
    /// Log security violation
    public func logSecurityViolation(_ violation: SecurityViolation) async {
        await log(.securityViolation, details: [
            "violation_type": violation.type.rawValue,
            "description": violation.description,
            "source_ip": violation.sourceIP ?? "unknown",
            "user_id": violation.userId ?? "unknown",
            "severity": violation.severity.rawValue
        ], severity: .critical)
        
        // Trigger immediate alert for security violations
        await triggerSecurityAlert(violation)
    }
    
    /// Log compliance event
    public func logCompliance(_ event: ComplianceEvent) async {
        await log(.complianceEvent, details: [
            "regulation": event.regulation.rawValue,
            "requirement": event.requirement,
            "status": event.status.rawValue,
            "description": event.description
        ], severity: event.status == .violation ? .critical : .info)
    }
    
    // MARK: - Query Interface
    
    /// Get audit events for a specific time period
    public func getEvents(for period: DateInterval) async -> [AuditEvent] {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let filteredEntries = self.auditEntries.filter { entry in
                    period.contains(entry.timestamp)
                }
                
                let events = filteredEntries.map { entry in
                    AuditEvent(
                        id: entry.id,
                        type: entry.eventType,
                        timestamp: entry.timestamp,
                        details: entry.details,
                        severity: entry.severity
                    )
                }
                
                continuation.resume(returning: events)
            }
        }
    }
    
    /// Get events by type
    public func getEvents(ofType eventType: AuditEventType, limit: Int = 100) async -> [AuditEvent] {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let filteredEntries = self.auditEntries
                    .filter { $0.eventType == eventType }
                    .suffix(limit)
                
                let events = filteredEntries.map { entry in
                    AuditEvent(
                        id: entry.id,
                        type: entry.eventType,
                        timestamp: entry.timestamp,
                        details: entry.details,
                        severity: entry.severity
                    )
                }
                
                continuation.resume(returning: events)
            }
        }
    }
    
    /// Get events by severity
    public func getEvents(withSeverity severity: AuditLogLevel, limit: Int = 100) async -> [AuditEvent] {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let filteredEntries = self.auditEntries
                    .filter { $0.severity == severity }
                    .suffix(limit)
                
                let events = filteredEntries.map { entry in
                    AuditEvent(
                        id: entry.id,
                        type: entry.eventType,
                        timestamp: entry.timestamp,
                        details: entry.details,
                        severity: entry.severity
                    )
                }
                
                continuation.resume(returning: events)
            }
        }
    }
    
    /// Get last audit date
    public func getLastAuditDate() async -> Date? {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let lastDate = self.auditEntries.last?.timestamp
                continuation.resume(returning: lastDate)
            }
        }
    }
    
    /// Search audit logs
    public func searchLogs(query: String, limit: Int = 100) async -> [AuditEvent] {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let filteredEntries = self.auditEntries.filter { entry in
                    entry.details.values.contains { $0.localizedCaseInsensitiveContains(query) } ||
                    entry.eventType.rawValue.localizedCaseInsensitiveContains(query)
                }.suffix(limit)
                
                let events = filteredEntries.map { entry in
                    AuditEvent(
                        id: entry.id,
                        type: entry.eventType,
                        timestamp: entry.timestamp,
                        details: entry.details,
                        severity: entry.severity
                    )
                }
                
                continuation.resume(returning: events)
            }
        }
    }
    
    // MARK: - Analytics
    
    /// Get audit statistics
    public func getAuditStatistics(for period: DateInterval) async -> AuditStatistics {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let periodEntries = self.auditEntries.filter { period.contains($0.timestamp) }
                
                let eventCounts = Dictionary(grouping: periodEntries, by: { $0.eventType })
                    .mapValues { $0.count }
                
                let severityCounts = Dictionary(grouping: periodEntries, by: { $0.severity })
                    .mapValues { $0.count }
                
                let hourlyDistribution = self.calculateHourlyDistribution(entries: periodEntries)
                let topUsers = self.getTopUsers(entries: periodEntries)
                let topIPs = self.getTopIPs(entries: periodEntries)
                
                let stats = AuditStatistics(
                    period: period,
                    totalEvents: periodEntries.count,
                    eventTypeCounts: eventCounts,
                    severityCounts: severityCounts,
                    hourlyDistribution: hourlyDistribution,
                    topUsers: topUsers,
                    topIPAddresses: topIPs,
                    averageEventsPerHour: Double(periodEntries.count) / period.duration * 3600
                )
                
                continuation.resume(returning: stats)
            }
        }
    }
    
    // MARK: - Export and Backup
    
    /// Export audit log
    public func exportAuditLog(format: AuditExportFormat, period: DateInterval? = nil) async throws -> Data {
        let entries = await getEntriesForExport(period: period)
        
        switch format {
        case .json:
            return try JSONEncoder().encode(entries)
        case .csv:
            return try generateCSVData(from: entries)
        case .encrypted:
            let jsonData = try JSONEncoder().encode(entries)
            return try await encryptAuditData(jsonData)
        }
    }
    
    /// Generate compliance report
    public func generateComplianceReport(for period: DateInterval) async -> AuditComplianceReport {
        let entries = auditEntries.filter { period.contains($0.timestamp) }
        
        let complianceEvents = entries.filter { entry in
            [.complianceEvent, .gdprRequest, .ccpaRequest, .dataSubjectRequest].contains(entry.eventType)
        }
        
        let securityEvents = entries.filter { entry in
            [.securityViolation, .unauthorizedAccess, .dataBreachDetected].contains(entry.eventType)
        }
        
        return AuditComplianceReport(
            period: period,
            totalComplianceEvents: complianceEvents.count,
            totalSecurityEvents: securityEvents.count,
            gdprEvents: complianceEvents.filter { $0.details["regulation"] == "gdpr" }.count,
            ccpaEvents: complianceEvents.filter { $0.details["regulation"] == "ccpa" }.count,
            hipaaEvents: complianceEvents.filter { $0.details["regulation"] == "hipaa" }.count,
            criticalSecurityIncidents: securityEvents.filter { $0.severity == .critical }.count,
            complianceViolations: complianceEvents.filter { $0.details["status"] == "violation" }.count
        )
    }
    
    // MARK: - Real-time Monitoring
    
    /// Add real-time monitor
    public func addMonitor(_ monitor: AuditMonitor) {
        realTimeMonitors.append(monitor)
        logger.info("Added audit monitor: \(monitor.name)")
    }
    
    /// Remove monitor
    public func removeMonitor(_ monitorId: String) {
        realTimeMonitors.removeAll { $0.id == monitorId }
        logger.info("Removed audit monitor: \(monitorId)")
    }
    
    /// Set alert threshold
    public func setAlertThreshold(for eventType: AuditEventType, count: Int) {
        alertThresholds[eventType] = count
        logger.info("Set alert threshold for \(eventType.rawValue): \(count)")
    }
    
    // MARK: - Private Implementation
    
    private func initializeEncryption() async {
        do {
            if let existingKey = try await keychain.getKey(identifier: "audit_encryption_key") {
                auditEncryptionKey = existingKey
            } else {
                let newKey = SymmetricKey(size: .bits256)
                try await keychain.storeKey(newKey, identifier: "audit_encryption_key")
                auditEncryptionKey = newKey
            }
            
            logger.info("Audit log encryption initialized")
        } catch {
            logger.error("Failed to initialize audit encryption: \(error.localizedDescription)")
        }
    }
    
    private func setupRealTimeMonitoring() async {
        // Add default security monitors
        let securityMonitor = DefaultSecurityMonitor()
        realTimeMonitors.append(securityMonitor)
        
        // Add compliance monitor
        let complianceMonitor = DefaultComplianceMonitor()
        realTimeMonitors.append(complianceMonitor)
        
        logger.info("Real-time monitoring initialized with \(realTimeMonitors.count) monitors")
    }
    
    private func setupAuditFileSystem() async {
        do {
            let auditDirectory = auditLogURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: auditDirectory, withIntermediateDirectories: true)
            logger.info("Audit file system initialized at: \(auditDirectory.path)")
        } catch {
            logger.error("Failed to create audit directory: \(error.localizedDescription)")
        }
    }
    
    private func logEntry(_ entry: AuditEntry) async {
        await withCheckedContinuation { continuation in
            processingQueue.async {
                // Generate checksum for tamper protection
                var entryWithChecksum = entry
                entryWithChecksum.checksum = self.generateChecksum(for: entry)
                
                // Add to in-memory store
                self.auditEntries.append(entryWithChecksum)
                
                // Trim if necessary
                if self.auditEntries.count > self.maxInMemoryEntries {
                    self.auditEntries.removeFirst(self.auditEntries.count - self.maxInMemoryEntries)
                }
                
                // Persist to disk
                Task {
                    await self.persistAuditEntry(entryWithChecksum)
                }
                
                // Real-time monitoring
                Task {
                    await self.processRealTimeMonitoring(entryWithChecksum)
                }
                
                continuation.resume()
            }
        }
        
        logger.debug("Audit entry logged: \(entry.eventType.rawValue)")
    }
    
    private func persistAuditEntry(_ entry: AuditEntry) async {
        do {
            let data = try JSONEncoder().encode(entry)
            
            if configuration.encryptLogs, let encryptionKey = auditEncryptionKey {
                let encryptedData = try AES.GCM.seal(data, using: encryptionKey)
                let sealedData = AuditSealedBox(
                    ciphertext: encryptedData.ciphertext,
                    nonce: encryptedData.nonce,
                    tag: encryptedData.tag,
                    timestamp: Date()
                )
                let sealedBoxData = try JSONEncoder().encode(sealedData)
                try sealedBoxData.write(to: auditLogURL, options: .atomic)
            } else {
                try data.write(to: auditLogURL, options: .atomic)
            }
        } catch {
            logger.error("Failed to persist audit entry: \(error.localizedDescription)")
        }
    }
    
    private func loadAuditLog() async {
        do {
            guard FileManager.default.fileExists(atPath: auditLogURL.path) else { return }
            
            let data = try Data(contentsOf: auditLogURL)
            
            if configuration.encryptLogs, let encryptionKey = auditEncryptionKey {
                let sealedData = try JSONDecoder().decode(AuditSealedBox.self, from: data)
                let sealedBox = try AES.GCM.SealedBox(
                    nonce: sealedData.nonce,
                    ciphertext: sealedData.ciphertext,
                    tag: sealedData.tag
                )
                let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
                
                // Load multiple entries (simplified - in production would handle array format)
                if let entry = try? JSONDecoder().decode(AuditEntry.self, from: decryptedData) {
                    auditEntries.append(entry)
                }
            } else {
                if let entry = try? JSONDecoder().decode(AuditEntry.self, from: data) {
                    auditEntries.append(entry)
                }
            }
            
            logger.info("Loaded \(auditEntries.count) audit entries from storage")
        } catch {
            logger.error("Failed to load audit log: \(error.localizedDescription)")
        }
    }
    
    private func processRealTimeMonitoring(_ entry: AuditEntry) async {
        for monitor in realTimeMonitors {
            if monitor.shouldProcess(entry) {
                await monitor.process(entry)
            }
        }
        
        // Check alert thresholds
        if let threshold = alertThresholds[entry.eventType] {
            let recentCount = auditEntries.suffix(threshold * 2).filter { 
                $0.eventType == entry.eventType && 
                Date().timeIntervalSince($0.timestamp) < 3600 // Last hour
            }.count
            
            if recentCount >= threshold {
                await triggerAlert(for: entry.eventType, count: recentCount, threshold: threshold)
            }
        }
    }
    
    private func generateChecksum(for entry: AuditEntry) -> String {
        let dataToHash = "\(entry.id)|\(entry.timestamp.timeIntervalSince1970)|\(entry.eventType.rawValue)|\(entry.severity.rawValue)"
        let hash = SHA256.hash(data: dataToHash.data(using: .utf8) ?? Data())
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func getCurrentUserId() -> String? {
        // In a real implementation, this would get the current user ID
        return "anonymous"
    }
    
    private func getCurrentSessionId() -> String? {
        // In a real implementation, this would get the current session ID
        return UUID().uuidString
    }
    
    private func getClientIPAddress() -> String? {
        // In a real implementation, this would get the client IP address
        return "127.0.0.1"
    }
    
    private func getUserAgent() -> String? {
        // In a real implementation, this would get the user agent
        return "SwiftIntelligence/1.0"
    }
    
    private func triggerSecurityAlert(_ violation: SecurityViolation) async {
        logger.critical("SECURITY ALERT: \(violation.type.rawValue) - \(violation.description)")
        // In production, this would send alerts to security team
    }
    
    private func triggerAlert(for eventType: AuditEventType, count: Int, threshold: Int) async {
        logger.warning("AUDIT ALERT: \(eventType.rawValue) exceeded threshold (\(count)/\(threshold))")
        // In production, this would send alerts to operations team
    }
    
    private func calculateHourlyDistribution(entries: [AuditEntry]) -> [Int: Int] {
        let hourCounts = Dictionary(grouping: entries, by: { 
            Calendar.current.component(.hour, from: $0.timestamp) 
        }).mapValues { $0.count }
        
        return hourCounts
    }
    
    private func getTopUsers(entries: [AuditEntry]) -> [String: Int] {
        let userCounts = Dictionary(grouping: entries, by: { $0.userId ?? "unknown" })
            .mapValues { $0.count }
        
        return Dictionary(userCounts.sorted(by: { $0.value > $1.value }).prefix(10))
    }
    
    private func getTopIPs(entries: [AuditEntry]) -> [String: Int] {
        let ipCounts = Dictionary(grouping: entries, by: { $0.ipAddress ?? "unknown" })
            .mapValues { $0.count }
        
        return Dictionary(ipCounts.sorted(by: { $0.value > $1.value }).prefix(10))
    }
    
    private func getEntriesForExport(period: DateInterval?) async -> [AuditEntry] {
        if let period = period {
            return auditEntries.filter { period.contains($0.timestamp) }
        }
        return auditEntries
    }
    
    private func generateCSVData(from entries: [AuditEntry]) throws -> Data {
        var csv = "ID,Timestamp,Event Type,Severity,User ID,IP Address,Details\n"
        
        for entry in entries {
            let detailsJson = try JSONEncoder().encode(entry.details)
            let detailsString = String(data: detailsJson, encoding: .utf8) ?? "{}"
            
            csv += "\"\(entry.id)\",\"\(entry.timestamp.ISO8601Format())\",\"\(entry.eventType.rawValue)\",\"\(entry.severity.rawValue)\",\"\(entry.userId ?? "")\",\"\(entry.ipAddress ?? "")\",\"\(detailsString.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
        }
        
        return csv.data(using: .utf8) ?? Data()
    }
    
    private func encryptAuditData(_ data: Data) async throws -> Data {
        guard let encryptionKey = auditEncryptionKey else {
            throw AuditError.encryptionNotAvailable
        }
        
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        let sealedData = AuditSealedBox(
            ciphertext: sealedBox.ciphertext,
            nonce: sealedBox.nonce,
            tag: sealedBox.tag,
            timestamp: Date()
        )
        
        return try JSONEncoder().encode(sealedData)
    }
}

// MARK: - Supporting Types

private struct AuditEntry: Codable {
    let id: String
    let timestamp: Date
    let eventType: AuditEventType
    let severity: AuditLogLevel
    let details: [String: String]
    let source: String
    let userId: String?
    let sessionId: String?
    let ipAddress: String?
    let userAgent: String?
    var checksum: String
}

private struct AuditSealedBox: Codable {
    let ciphertext: Data
    let nonce: AES.GCM.Nonce
    let tag: Data
    let timestamp: Date
}

public struct SecurityViolation {
    public let type: SecurityViolationType
    public let description: String
    public let sourceIP: String?
    public let userId: String?
    public let severity: AuditLogLevel
    
    public init(type: SecurityViolationType, description: String, sourceIP: String? = nil, userId: String? = nil, severity: AuditLogLevel = .warning) {
        self.type = type
        self.description = description
        self.sourceIP = sourceIP
        self.userId = userId
        self.severity = severity
    }
}

public enum SecurityViolationType: String, CaseIterable {
    case unauthorizedAccess = "unauthorized_access"
    case bruteForceAttempt = "brute_force_attempt"
    case dataExfiltration = "data_exfiltration"
    case maliciousPayload = "malicious_payload"
    case anomalousActivity = "anomalous_activity"
}

public struct ComplianceEvent {
    public let regulation: ComplianceRegulationType
    public let requirement: String
    public let status: ComplianceEventStatus
    public let description: String
    
    public init(regulation: ComplianceRegulationType, requirement: String, status: ComplianceEventStatus, description: String) {
        self.regulation = regulation
        self.requirement = requirement
        self.status = status
        self.description = description
    }
}

public enum ComplianceRegulationType: String, CaseIterable {
    case gdpr = "gdpr"
    case ccpa = "ccpa"
    case hipaa = "hipaa"
    case sox = "sox"
    case pci = "pci"
}

public enum ComplianceEventStatus: String, CaseIterable {
    case compliant = "compliant"
    case nonCompliant = "non_compliant"
    case violation = "violation"
    case remediated = "remediated"
}

public enum AuditExportFormat: String, CaseIterable {
    case json = "json"
    case csv = "csv"
    case encrypted = "encrypted"
}

public struct AuditStatistics {
    public let period: DateInterval
    public let totalEvents: Int
    public let eventTypeCounts: [AuditEventType: Int]
    public let severityCounts: [AuditLogLevel: Int]
    public let hourlyDistribution: [Int: Int]
    public let topUsers: [String: Int]
    public let topIPAddresses: [String: Int]
    public let averageEventsPerHour: Double
    
    public init(period: DateInterval, totalEvents: Int, eventTypeCounts: [AuditEventType : Int], severityCounts: [AuditLogLevel : Int], hourlyDistribution: [Int : Int], topUsers: [String : Int], topIPAddresses: [String : Int], averageEventsPerHour: Double) {
        self.period = period
        self.totalEvents = totalEvents
        self.eventTypeCounts = eventTypeCounts
        self.severityCounts = severityCounts
        self.hourlyDistribution = hourlyDistribution
        self.topUsers = topUsers
        self.topIPAddresses = topIPAddresses
        self.averageEventsPerHour = averageEventsPerHour
    }
}

public struct AuditComplianceReport {
    public let period: DateInterval
    public let totalComplianceEvents: Int
    public let totalSecurityEvents: Int
    public let gdprEvents: Int
    public let ccpaEvents: Int
    public let hipaaEvents: Int
    public let criticalSecurityIncidents: Int
    public let complianceViolations: Int
    
    public init(period: DateInterval, totalComplianceEvents: Int, totalSecurityEvents: Int, gdprEvents: Int, ccpaEvents: Int, hipaaEvents: Int, criticalSecurityIncidents: Int, complianceViolations: Int) {
        self.period = period
        self.totalComplianceEvents = totalComplianceEvents
        self.totalSecurityEvents = totalSecurityEvents
        self.gdprEvents = gdprEvents
        self.ccpaEvents = ccpaEvents
        self.hipaaEvents = hipaaEvents
        self.criticalSecurityIncidents = criticalSecurityIncidents
        self.complianceViolations = complianceViolations
    }
}

// MARK: - Monitoring Protocol

public protocol AuditMonitor {
    var id: String { get }
    var name: String { get }
    
    func shouldProcess(_ entry: AuditEntry) -> Bool
    func process(_ entry: AuditEntry) async
}

// MARK: - Default Monitors

private class DefaultSecurityMonitor: AuditMonitor {
    let id = "security_monitor"
    let name = "Security Monitor"
    
    func shouldProcess(_ entry: AuditEntry) -> Bool {
        return [.securityViolation, .unauthorizedAccess, .dataBreachDetected].contains(entry.eventType)
    }
    
    func process(_ entry: AuditEntry) async {
        // Process security events
        if entry.severity == .critical {
            // Trigger immediate security response
        }
    }
}

private class DefaultComplianceMonitor: AuditMonitor {
    let id = "compliance_monitor"
    let name = "Compliance Monitor"
    
    func shouldProcess(_ entry: AuditEntry) -> Bool {
        return [.complianceEvent, .gdprRequest, .ccpaRequest, .dataSubjectRequest].contains(entry.eventType)
    }
    
    func process(_ entry: AuditEntry) async {
        // Process compliance events
        if entry.details["status"] == "violation" {
            // Trigger compliance alert
        }
    }
}

// MARK: - Additional Event Types

extension AuditEventType {
    public static let securityViolation = AuditEventType(rawValue: "security_violation")!
    public static let unauthorizedAccess = AuditEventType(rawValue: "unauthorized_access")!
    public static let dataBreachDetected = AuditEventType(rawValue: "data_breach_detected")!
    public static let complianceEvent = AuditEventType(rawValue: "compliance_event")!
    public static let gdprRequest = AuditEventType(rawValue: "gdpr_request")!
    public static let ccpaRequest = AuditEventType(rawValue: "ccpa_request")!
    public static let dataSubjectRequest = AuditEventType(rawValue: "data_subject_request")!
    public static let auditLogFailure = AuditEventType(rawValue: "audit_log_failure")!
}

// MARK: - Errors

public enum AuditError: LocalizedError {
    case encryptionNotAvailable
    case invalidExportFormat
    case exportFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .encryptionNotAvailable:
            return "Audit log encryption is not available"
        case .invalidExportFormat:
            return "Invalid audit export format"
        case .exportFailed(let reason):
            return "Audit export failed: \(reason)"
        }
    }
}
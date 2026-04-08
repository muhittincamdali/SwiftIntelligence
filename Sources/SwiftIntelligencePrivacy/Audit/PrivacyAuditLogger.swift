import Foundation
import CryptoKit
import os.log

/// Simplified audit logger aligned with the canonical privacy type contracts.
public final class PrivacyAuditLogger: @unchecked Sendable {
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "AuditLogger")
    private var configuration: AuditLoggingConfiguration = .default
    private let processingQueue = DispatchQueue(label: "audit.logging", qos: .utility)
    private var auditEntries: [AuditEntry] = []
    private let maxInMemoryEntries = 1000
    private let keychain = SecureKeychain()
    private var auditEncryptionKey: SymmetricKey?

    private lazy var auditLogURL: URL = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath
            .appendingPathComponent("SwiftIntelligence")
            .appendingPathComponent("Audit")
            .appendingPathComponent("audit_log.json")
    }()

    private var realTimeMonitors: [any AuditMonitor] = []
    private var alertThresholds: [String: Int] = [:]

    public init() {
        logger.info("PrivacyAuditLogger initialized")
    }

    public func initialize(with config: AuditLoggingConfiguration) async {
        configuration = config
        if config.encryptionEnabled {
            await initializeEncryption()
        }
        if config.realTimeMonitoring {
            await setupRealTimeMonitoring()
        }
        await setupAuditFileSystem()
        await loadAuditLog()
        logger.info("AuditLogger configured: encryption=\(config.encryptionEnabled), monitoring=\(config.realTimeMonitoring)")
    }

    public func updateConfiguration(_ config: AuditLoggingConfiguration) async {
        let oldConfig = configuration
        configuration = config

        if config.encryptionEnabled && !oldConfig.encryptionEnabled {
            await initializeEncryption()
        }

        if config.realTimeMonitoring && !oldConfig.realTimeMonitoring {
            await setupRealTimeMonitoring()
        } else if !config.realTimeMonitoring {
            realTimeMonitors.removeAll()
        }

        logger.info("Audit logging configuration updated")
    }

    public func log(_ eventType: AuditEventType, details: [String: String] = [:], severity: AuditLogLevel = .info) async {
        guard shouldLog(level: severity) else { return }

        let entry = AuditEntry(
            level: severity,
            category: category(for: eventType),
            event: eventType.rawValue,
            details: details,
            userId: currentUserId(),
            sessionId: currentSessionId(),
            ipAddress: clientIPAddress(),
            userAgent: userAgent(),
            checksum: ""
        )

        await persist(entry)
    }

    public func logStructured<T: Codable>(_ eventType: AuditEventType, data: T, severity: AuditLogLevel = .info) async {
        do {
            let jsonData = try JSONEncoder().encode(data)
            let payload = String(data: jsonData, encoding: .utf8) ?? "{}"
            await log(eventType, details: ["structured_data": payload], severity: severity)
        } catch {
            await log(.configurationChange, details: ["error": error.localizedDescription], severity: .error)
        }
    }

    public func logSecurityViolation(_ violation: SecurityViolation) async {
        await log(.complianceViolation, details: [
            "violation_type": violation.type.rawValue,
            "description": violation.description,
            "source_ip": violation.sourceIP ?? "unknown",
            "user_id": violation.userId ?? "unknown",
            "severity": violation.severity.rawValue,
        ], severity: .critical)
    }

    public func logCompliance(_ event: ComplianceEvent) async {
        await log(.complianceViolation, details: [
            "regulation": event.regulation.rawValue,
            "requirement": event.requirement,
            "status": event.status.rawValue,
            "description": event.description,
        ], severity: event.status == .violation ? .critical : .info)
    }

    public func getEvents(for period: DateInterval) async -> [PrivacyAuditEvent] {
        let entries = await filteredEntries { period.contains($0.timestamp) }
        return entries.map(makeEvent)
    }

    public func getEvents(ofType eventType: AuditEventType, limit: Int = 100) async -> [PrivacyAuditEvent] {
        let entries = await filteredEntries { $0.event == eventType.rawValue }
        return Array(entries.suffix(limit)).map(makeEvent)
    }

    public func getEvents(withSeverity severity: AuditLogLevel, limit: Int = 100) async -> [PrivacyAuditEvent] {
        let entries = await filteredEntries { $0.level == severity }
        return Array(entries.suffix(limit)).map(makeEvent)
    }

    public func getLastAuditDate() async -> Date? {
        await withCheckedContinuation { continuation in
            processingQueue.async {
                continuation.resume(returning: self.auditEntries.last?.timestamp)
            }
        }
    }

    public func searchLogs(query: String, limit: Int = 100) async -> [PrivacyAuditEvent] {
        let entries = await filteredEntries {
            $0.event.localizedCaseInsensitiveContains(query) ||
            $0.details.values.contains(where: { $0.localizedCaseInsensitiveContains(query) })
        }
        return Array(entries.suffix(limit)).map(makeEvent)
    }

    public func getAuditStatistics(for period: DateInterval) async -> AuditStatistics {
        let entries = await filteredEntries { period.contains($0.timestamp) }
        let eventTypeCounts = Dictionary(grouping: entries, by: { AuditEventType(rawValue: $0.event) ?? .configurationChange }).mapValues { $0.count }
        let severityCounts = Dictionary(grouping: entries, by: { $0.level }).mapValues { $0.count }
        let hourlyDistribution = Dictionary(grouping: entries, by: { Calendar.current.component(.hour, from: $0.timestamp) }).mapValues { $0.count }
        let topUsers = Dictionary(grouping: entries, by: { $0.userId ?? "unknown" }).mapValues { $0.count }
        let topIPs = Dictionary(grouping: entries, by: { $0.ipAddress ?? "unknown" }).mapValues { $0.count }

        return AuditStatistics(
            period: period,
            totalEvents: entries.count,
            eventTypeCounts: eventTypeCounts,
            severityCounts: severityCounts,
            hourlyDistribution: hourlyDistribution,
            topUsers: Dictionary(uniqueKeysWithValues: topUsers.sorted(by: { $0.value > $1.value }).prefix(10).map { ($0.key, $0.value) }),
            topIPAddresses: Dictionary(uniqueKeysWithValues: topIPs.sorted(by: { $0.value > $1.value }).prefix(10).map { ($0.key, $0.value) }),
            averageEventsPerHour: period.duration > 0 ? Double(entries.count) / period.duration * 3600 : 0
        )
    }

    public func exportAuditLog(format: AuditExportFormat, period: DateInterval? = nil) async throws -> Data {
        let entries = period == nil ? auditEntries : await filteredEntries { period!.contains($0.timestamp) }
        switch format {
        case .json:
            return try JSONEncoder().encode(entries)
        case .csv:
            return try generateCSVData(from: entries)
        case .encrypted:
            guard let encryptionKey = auditEncryptionKey else {
                throw AuditError.encryptionNotAvailable
            }
            let jsonData = try JSONEncoder().encode(entries)
            let sealedBox = try AES.GCM.seal(jsonData, using: encryptionKey)
            let payload = AuditEncryptedPayload(
                ciphertext: sealedBox.ciphertext,
                nonce: Data(sealedBox.nonce),
                tag: sealedBox.tag,
                timestamp: Date()
            )
            return try JSONEncoder().encode(payload)
        }
    }

    public func generateComplianceReport(for period: DateInterval) async -> AuditComplianceReport {
        let events = await getEvents(for: period)
        let complianceEvents = events.filter { $0.type == .complianceViolation }
        let securityEvents = events.filter { $0.severity == .critical || $0.severity == .error }

        return AuditComplianceReport(
            period: period,
            totalComplianceEvents: complianceEvents.count,
            totalSecurityEvents: securityEvents.count,
            gdprEvents: complianceEvents.filter { $0.metadata["regulation"] == "gdpr" }.count,
            ccpaEvents: complianceEvents.filter { $0.metadata["regulation"] == "ccpa" }.count,
            hipaaEvents: complianceEvents.filter { $0.metadata["regulation"] == "hipaa" }.count,
            criticalSecurityIncidents: securityEvents.filter { $0.severity == .critical }.count,
            complianceViolations: complianceEvents.filter { $0.metadata["status"] == "violation" }.count
        )
    }

    public func addMonitor(_ monitor: any AuditMonitor) {
        realTimeMonitors.append(monitor)
    }

    public func removeMonitor(_ monitorId: String) {
        realTimeMonitors.removeAll { $0.id == monitorId }
    }

    public func setAlertThreshold(for eventType: AuditEventType, count: Int) {
        alertThresholds[eventType.rawValue] = count
    }

    private func shouldLog(level: AuditLogLevel) -> Bool {
        level >= configuration.level
    }

    private func persist(_ entry: AuditEntry) async {
        await withCheckedContinuation { continuation in
            processingQueue.async {
                let checksummed = AuditEntry(
                    id: entry.id,
                    timestamp: entry.timestamp,
                    level: entry.level,
                    category: entry.category,
                    event: entry.event,
                    details: entry.details,
                    userId: entry.userId,
                    sessionId: entry.sessionId,
                    ipAddress: entry.ipAddress,
                    userAgent: entry.userAgent,
                    checksum: self.generateChecksum(for: entry)
                )
                self.auditEntries.append(checksummed)
                if self.auditEntries.count > self.maxInMemoryEntries {
                    self.auditEntries.removeFirst(self.auditEntries.count - self.maxInMemoryEntries)
                }
                Task {
                    await self.persistAuditLog()
                    await self.processRealTimeMonitoring(checksummed)
                }
                continuation.resume()
            }
        }
    }

    private func persistAuditLog() async {
        do {
            let data = try JSONEncoder().encode(auditEntries)
            if configuration.encryptionEnabled, let encryptionKey = auditEncryptionKey {
                let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
                let payload = AuditEncryptedPayload(
                    ciphertext: sealedBox.ciphertext,
                    nonce: Data(sealedBox.nonce),
                    tag: sealedBox.tag,
                    timestamp: Date()
                )
                try JSONEncoder().encode(payload).write(to: auditLogURL, options: .atomic)
            } else {
                try data.write(to: auditLogURL, options: .atomic)
            }
        } catch {
            logger.error("Failed to persist audit log: \(error.localizedDescription)")
        }
    }

    private func loadAuditLog() async {
        do {
            guard FileManager.default.fileExists(atPath: auditLogURL.path) else { return }
            let data = try Data(contentsOf: auditLogURL)
            if configuration.encryptionEnabled, let encryptionKey = auditEncryptionKey {
                let payload = try JSONDecoder().decode(AuditEncryptedPayload.self, from: data)
                let nonce = try AES.GCM.Nonce(data: payload.nonce)
                let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: payload.ciphertext, tag: payload.tag)
                let decrypted = try AES.GCM.open(sealedBox, using: encryptionKey)
                auditEntries = try JSONDecoder().decode([AuditEntry].self, from: decrypted)
            } else {
                auditEntries = try JSONDecoder().decode([AuditEntry].self, from: data)
            }
        } catch {
            logger.error("Failed to load audit log: \(error.localizedDescription)")
            auditEntries = []
        }
    }

    private func initializeEncryption() async {
        do {
            if let existingKey = try await keychain.getKey(identifier: "audit_encryption_key") {
                auditEncryptionKey = existingKey
            } else {
                let newKey = SymmetricKey(size: .bits256)
                try await keychain.storeKey(newKey, identifier: "audit_encryption_key")
                auditEncryptionKey = newKey
            }
        } catch {
            logger.error("Failed to initialize audit encryption: \(error.localizedDescription)")
        }
    }

    private func setupRealTimeMonitoring() async {
        realTimeMonitors = [DefaultSecurityMonitor(), DefaultComplianceMonitor()]
    }

    private func setupAuditFileSystem() async {
        do {
            try FileManager.default.createDirectory(at: auditLogURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create audit directory: \(error.localizedDescription)")
        }
    }

    private func processRealTimeMonitoring(_ entry: AuditEntry) async {
        for monitor in realTimeMonitors where monitor.shouldProcess(entry) {
            await monitor.process(entry)
        }
        if let threshold = alertThresholds[entry.event] {
            let recentCount = auditEntries.suffix(threshold * 2).filter {
                $0.event == entry.event && Date().timeIntervalSince($0.timestamp) < 3600
            }.count
            if recentCount >= threshold {
                logger.warning("AUDIT ALERT: \(entry.event) exceeded threshold (\(recentCount)/\(threshold))")
            }
        }
    }

    private func filteredEntries(_ predicate: @Sendable @escaping (AuditEntry) -> Bool) async -> [AuditEntry] {
        await withCheckedContinuation { continuation in
            processingQueue.async {
                continuation.resume(returning: self.auditEntries.filter(predicate))
            }
        }
    }

    private func makeEvent(from entry: AuditEntry) -> PrivacyAuditEvent {
        PrivacyAuditEvent(
            id: entry.id,
            type: AuditEventType(rawValue: entry.event) ?? .configurationChange,
            description: entry.event,
            timestamp: entry.timestamp,
            metadata: entry.details,
            severity: severity(for: entry.level)
        )
    }

    private func severity(for level: AuditLogLevel) -> PrivacyAuditEvent.EventSeverity {
        switch level {
        case .trace, .debug, .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        case .critical:
            return .critical
        }
    }

    private func category(for eventType: AuditEventType) -> AuditCategory {
        switch eventType {
        case .dataEncryption:
            return .encryption
        case .dataDecryption:
            return .decryption
        case .dataAnonymization:
            return .anonymization
        case .secureDataDeletion:
            return .dataModification
        case .dataAccess, .secureDataRetrieval:
            return .dataAccess
        case .biometricAuthentication:
            return .authentication
        case .complianceViolation:
            return .compliance
        case .configurationChange, .privacyPolicyApplication:
            return .privacy
        case .secureDataStorage:
            return .dataModification
        }
    }

    private func generateChecksum(for entry: AuditEntry) -> String {
        let message = "\(entry.id)|\(entry.timestamp.timeIntervalSince1970)|\(entry.event)|\(entry.level.rawValue)"
        let hash = SHA256.hash(data: Data(message.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func generateCSVData(from entries: [AuditEntry]) throws -> Data {
        var csv = "ID,Timestamp,Event,Level,Category,User ID,IP Address,Details\n"
        for entry in entries {
            let detailsJSON = try JSONEncoder().encode(entry.details)
            let details = String(data: detailsJSON, encoding: .utf8) ?? "{}"
            csv += "\"\(entry.id)\",\"\(entry.timestamp.ISO8601Format())\",\"\(entry.event)\",\"\(entry.level.rawValue)\",\"\(entry.category.rawValue)\",\"\(entry.userId ?? "")\",\"\(entry.ipAddress ?? "")\",\"\(details.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
        }
        return Data(csv.utf8)
    }

    private func currentUserId() -> String? { "anonymous" }
    private func currentSessionId() -> String? { UUID().uuidString }
    private func clientIPAddress() -> String? { "127.0.0.1" }
    private func userAgent() -> String? { "SwiftIntelligence/1.0" }
}

private struct AuditEncryptedPayload: Codable {
    let ciphertext: Data
    let nonce: Data
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

    public init(period: DateInterval, totalEvents: Int, eventTypeCounts: [AuditEventType: Int], severityCounts: [AuditLogLevel: Int], hourlyDistribution: [Int: Int], topUsers: [String: Int], topIPAddresses: [String: Int], averageEventsPerHour: Double) {
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

public protocol AuditMonitor {
    var id: String { get }
    var name: String { get }
    func shouldProcess(_ entry: AuditEntry) -> Bool
    func process(_ entry: AuditEntry) async
}

private final class DefaultSecurityMonitor: AuditMonitor {
    let id = "security_monitor"
    let name = "Security Monitor"
    func shouldProcess(_ entry: AuditEntry) -> Bool { entry.category == .compliance && entry.level == .critical }
    func process(_ entry: AuditEntry) async {}
}

private final class DefaultComplianceMonitor: AuditMonitor {
    let id = "compliance_monitor"
    let name = "Compliance Monitor"
    func shouldProcess(_ entry: AuditEntry) -> Bool { entry.category == .compliance }
    func process(_ entry: AuditEntry) async {}
}

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

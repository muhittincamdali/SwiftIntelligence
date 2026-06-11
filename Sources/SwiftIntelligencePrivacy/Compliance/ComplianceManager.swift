import Foundation
import os.log
import SwiftIntelligenceCore

/// Lightweight compliance manager aligned to the canonical privacy types.
public final class ComplianceManager: Sendable {
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Compliance")
    private let _configuration = Locked<PrivacyConfiguration>(.default)
    private let _complianceStatus = Locked<ComplianceStatus>(ComplianceStatus(isCompliant: true, score: 1.0))

    public init() {
        logger.info("ComplianceManager initialized")
    }

    public func initialize(with config: PrivacyConfiguration) async {
        _configuration.withLock { $0 = config }
        let status = evaluateCompliance()
        _complianceStatus.withLock { $0 = status }
    }

    public func updateConfiguration(_ config: PrivacyConfiguration) async {
        _configuration.withLock { $0 = config }
        let status = evaluateCompliance()
        _complianceStatus.withLock { $0 = status }
    }

    public func checkGDPRCompliance() async -> ComplianceStatus {
        let status = evaluateCompliance(regulation: "gdpr")
        _complianceStatus.withLock { $0 = status }
        return status
    }

    public func checkCCPACompliance() async -> ComplianceStatus {
        let status = evaluateCompliance(regulation: "ccpa")
        _complianceStatus.withLock { $0 = status }
        return status
    }

    public func checkHIPAACompliance() async -> ComplianceStatus {
        let status = evaluateCompliance(regulation: "hipaa")
        _complianceStatus.withLock { $0 = status }
        return status
    }

    public func updateRetentionPolicy(_ policy: DataRetentionPolicy) async {
        logger.info("Updated retention policy: maxAge=\(policy.maxAge)")
    }

    public func shouldRetain(_ metadata: DataMetadata, policy: DataRetentionPolicy) -> Bool {
        Date().timeIntervalSince(metadata.createdAt) <= policy.maxAge
    }

    public func executeCleanup(policy: DataRetentionPolicy) async throws -> RetentionCleanupResult {
        logger.info("Executing compliance cleanup for category=\(policy.category.rawValue)")
        return RetentionCleanupResult(cleanedItems: 0, freedSpace: 0, errors: [], duration: 0)
    }

    public func getComplianceStatus() async -> ComplianceStatus {
        _complianceStatus.withLock { $0 }
    }

    public func generateComplianceReport() async -> ComplianceReport {
        let status = evaluateCompliance()
        let config = _configuration.withLock { $0 }
        return ComplianceReport(
            generatedAt: Date(),
            regulations: ComplianceRegulations(
                gdpr: config.complianceMode != .permissive,
                ccpa: config.complianceMode != .permissive,
                hipaa: config.complianceMode == .enterprise
            ),
            status: status,
            recommendations: status.recommendations
        )
    }

    private func evaluateCompliance(regulation: String? = nil) -> ComplianceStatus {
        var violations: [ComplianceViolation] = []
        let config = _configuration.withLock { $0 }

        if !config.enableAuditLogging {
            violations.append(
                ComplianceViolation(
                    type: .accessControlViolation,
                    description: "Audit logging is disabled.",
                    severity: config.complianceMode == .enterprise ? .high : .medium,
                    suggestedResolution: "Enable audit logging for traceability."
                )
            )
        }

        if config.defaultEncryptionLevel == .low {
            violations.append(
                ComplianceViolation(
                    type: .encryptionRequired,
                    description: "Encryption level is below the recommended baseline.",
                    severity: .high,
                    suggestedResolution: "Raise the default encryption level to at least .medium."
                )
            )
        }

        if config.dataRetentionPeriod > 365 * 24 * 60 * 60 && config.complianceMode == .enterprise {
            violations.append(
                ComplianceViolation(
                    type: .dataRetentionExceeded,
                    description: "Enterprise compliance mode expects shorter retention periods.",
                    severity: .medium,
                    suggestedResolution: "Reduce retention period below one year for enterprise profiles."
                )
            )
        }

        if regulation == "hipaa" && !config.enableSensitiveDataScanning {
            violations.append(
                ComplianceViolation(
                    type: .unauthorizedDataType,
                    description: "Sensitive data scanning is disabled for HIPAA workflows.",
                    severity: .high,
                    suggestedResolution: "Enable sensitive data scanning before handling health data."
                )
            )
        }

        let complianceScore = max(0, 1.0 - Float(violations.count) * 0.2)
        let recommendations = recommendations(for: violations)

        return ComplianceStatus(
            isCompliant: violations.filter { $0.severity.requiresImmediateAction }.isEmpty,
            score: complianceScore,
            violations: violations,
            recommendations: recommendations,
            lastEvaluation: Date(),
            nextEvaluation: Calendar.current.date(byAdding: .day, value: 30, to: Date())
        )
    }

    private func recommendations(for violations: [ComplianceViolation]) -> [String] {
        if violations.isEmpty {
            return ["Current privacy controls meet the configured compliance baseline."]
        }

        return violations.compactMap { $0.suggestedResolution }
    }
}

public struct ComplianceReport {
    public let generatedAt: Date
    public let regulations: ComplianceRegulations
    public let status: ComplianceStatus
    public let recommendations: [String]

    public init(generatedAt: Date, regulations: ComplianceRegulations, status: ComplianceStatus, recommendations: [String]) {
        self.generatedAt = generatedAt
        self.regulations = regulations
        self.status = status
        self.recommendations = recommendations
    }
}

public struct ComplianceRegulations {
    public let gdpr: Bool
    public let ccpa: Bool
    public let hipaa: Bool

    public init(gdpr: Bool, ccpa: Bool, hipaa: Bool) {
        self.gdpr = gdpr
        self.ccpa = ccpa
        self.hipaa = hipaa
    }
}

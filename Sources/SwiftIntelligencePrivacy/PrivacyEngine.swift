import Foundation
import CryptoKit
import LocalAuthentication
import os.log

/// Privacy engine aligned to the canonical privacy types used in this package.
@MainActor
public final class PrivacyEngine: NSObject, ObservableObject {
    public static let shared = PrivacyEngine()

    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Privacy")
    private let biometricContext = LAContext()

    @Published public var configuration: PrivacyConfiguration = .default
    @Published public var isPrivacyEnabled = true
    @Published public var encryptionStatus: EncryptionStatus = .inactive
    @Published public var biometricAuthStatus: BiometricAuthStatus = .unavailable
    @Published public var dataRetentionPolicy: DataRetentionPolicy = .default

    private var encryptionKeys: [String: SymmetricKey] = [:]
    private let keychain = SecureKeychain()
    private let dataProtection = DataProtectionManager()
    private let auditLogger = PrivacyAuditLogger()
    private let anonymizer = DataAnonymizer()
    private let tokenizer = PrivacyTokenizer()
    private let complianceManager = ComplianceManager()

    override init() {
        super.init()
        Task {
            await initializePrivacyEngine()
        }
    }

    private func initializePrivacyEngine() async {
        do {
            let masterKey = try await getOrCreateKey(identifier: "master_encryption_key")
            encryptionKeys["master_encryption_key"] = masterKey
            encryptionStatus = .active
        } catch {
            encryptionStatus = .error
            logger.error("Failed to initialize encryption: \(error.localizedDescription)")
        }

        biometricAuthStatus = buildBiometricStatus()
        await dataProtection.initialize(with: dataProtectionConfiguration(from: configuration))
        await auditLogger.initialize(with: auditLoggingConfiguration(from: configuration))
        await complianceManager.initialize(with: configuration)
    }

    public func updateConfiguration(_ config: PrivacyConfiguration) async throws {
        configuration = config
        dataRetentionPolicy = DataRetentionPolicy(
            maxAge: config.dataRetentionPeriod,
            autoDelete: true,
            compressionEnabled: false,
            category: .personal
        )
        await dataProtection.updateConfiguration(dataProtectionConfiguration(from: config))
        await auditLogger.updateConfiguration(auditLoggingConfiguration(from: config))
        await complianceManager.updateConfiguration(config)
        await auditLogger.log(.configurationChange, details: [
            "compliance_mode": config.complianceMode.rawValue,
            "audit_logging": String(config.enableAuditLogging),
        ])
    }

    public func encryptData(_ data: Data, context: EncryptionContext = .general) async throws -> EncryptedData {
        guard isPrivacyEnabled else { throw PrivacyError.permissionDenied }

        let key = try await key(for: context)
        let sealedBox = try AES.GCM.seal(data, using: key)
        let payload = sealedBox.ciphertext + sealedBox.tag

        await auditLogger.log(.dataEncryption, details: [
            "algorithm": context.algorithm.rawValue,
            "level": context.level.rawValue,
            "size": String(data.count),
        ])

        return EncryptedData(
            encryptedData: payload,
            keyId: context.keyId,
            iv: Data(sealedBox.nonce),
            keyDerivationMethod: "\(context.algorithm.rawValue)-\(context.level.rawValue)"
        )
    }

    public func decryptData(_ encryptedData: EncryptedData) async throws -> Data {
        guard isPrivacyEnabled else { throw PrivacyError.permissionDenied }
        guard encryptedData.encryptedData.count >= 16 else { throw PrivacyError.invalidData }

        let key = try await getOrCreateKey(identifier: encryptedData.keyId)
        let ciphertext = encryptedData.encryptedData.dropLast(16)
        let tag = encryptedData.encryptedData.suffix(16)
        let nonce = try AES.GCM.Nonce(data: encryptedData.iv)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        let decrypted = try AES.GCM.open(sealedBox, using: key)

        await auditLogger.log(.dataDecryption, details: [
            "key_id": encryptedData.keyId,
            "size": String(decrypted.count),
        ])

        return decrypted
    }

    public func authenticateWithBiometrics(reason: String = "Authenticate to access secure data") async throws -> Bool {
        guard configuration.enableBiometricAuthentication else {
            throw PrivacyError.permissionDenied
        }

        guard biometricContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            throw PrivacyError.biometricAuthFailed("Biometric authentication unavailable")
        }

        return try await withCheckedThrowingContinuation { continuation in
            biometricContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(throwing: PrivacyError.biometricAuthFailed(error?.localizedDescription ?? "Authentication failed"))
                }
            }
        }
    }

    public func anonymizeText(_ text: String, level: AnonymizationLevel = .standard) async throws -> AnonymizedData {
        let result = try await anonymizer.anonymize(text, level: level)
        await auditLogger.log(.dataAnonymization, details: ["level": level.rawValue])
        return result
    }

    public func anonymizeData<T: Codable & Sendable>(_ data: T, level: AnonymizationLevel = .standard) async throws -> AnonymizedData {
        let result = try await anonymizer.anonymize(data, level: level)
        await auditLogger.log(.dataAnonymization, details: ["level": level.rawValue, "structured": "true"])
        return result
    }

    public func tokenizeData(_ data: String, context: TokenizationContext) async throws -> TokenizedData {
        let result = try await tokenizer.tokenize(data, context: context)
        await auditLogger.log(.secureDataStorage, details: ["purpose": context.purpose.rawValue])
        return result
    }

    public func detokenizeData(_ tokenizedData: TokenizedData) async throws -> String {
        let result = try await tokenizer.detokenize(tokenizedData)
        await auditLogger.log(.secureDataRetrieval, details: ["tokens": String(tokenizedData.tokens.count)])
        return result
    }

    public func protectSensitiveData(_ data: Data, classification: DataClassification) async throws -> ProtectedData {
        let result = try await dataProtection.protect(data, classification: classification)
        await auditLogger.log(.secureDataStorage, details: ["classification": classification.rawValue])
        return result
    }

    public func validateDataIntegrity(_ protectedData: ProtectedData) async throws -> Bool {
        try await dataProtection.validateIntegrity(protectedData)
    }

    public func secureDelete(_ data: inout Data) async throws {
        try await dataProtection.secureDelete(&data)
        await auditLogger.log(.secureDataDeletion, details: ["remaining_size": String(data.count)])
    }

    public func setDataRetentionPolicy(_ policy: DataRetentionPolicy) async {
        dataRetentionPolicy = policy
        await complianceManager.updateRetentionPolicy(policy)
        await auditLogger.log(.configurationChange, details: ["retention_max_age": String(policy.maxAge)])
    }

    public func shouldRetainData(_ metadata: DataMetadata) -> Bool {
        complianceManager.shouldRetain(metadata, policy: dataRetentionPolicy)
    }

    public func executeRetentionCleanup() async throws -> RetentionCleanupResult {
        try await complianceManager.executeCleanup(policy: dataRetentionPolicy)
    }

    public func checkGDPRCompliance() async -> ComplianceStatus {
        await complianceManager.checkGDPRCompliance()
    }

    public func checkCCPACompliance() async -> ComplianceStatus {
        await complianceManager.checkCCPACompliance()
    }

    public func generatePrivacyReport(period: DateInterval) async throws -> PrivacyReport {
        let compliance = await complianceManager.getComplianceStatus()
        let auditEvents = await auditLogger.getEvents(for: period)
        let vulnerabilities = compliance.violations.map {
            PrivacyVulnerability(
                title: $0.type.rawValue,
                description: $0.description,
                severity: vulnerabilitySeverity(from: $0.severity),
                impact: $0.description,
                mitigation: $0.suggestedResolution ?? "Review and remediate this violation."
            )
        }

        var recommendations = compliance.recommendations
        if auditEvents.isEmpty {
            recommendations.append("Generate audit activity for the selected period before publishing a privacy score.")
        }

        let score = max(0, min(1, compliance.score)) * 100
        let status = vulnerabilities.isEmpty ? "secure" : "attention-required"

        return PrivacyReport(
            status: status,
            vulnerabilities: vulnerabilities,
            recommendations: recommendations,
            score: score
        )
    }

    public func setPrivacyEnabled(_ enabled: Bool) async {
        isPrivacyEnabled = enabled
        await auditLogger.log(.configurationChange, details: ["privacy_enabled": String(enabled)])
    }

    public func getPrivacyStatus() async -> PrivacyStatus {
        let compliance = await complianceManager.getComplianceStatus()
        let issues = compliance.violations.map(\.description)
        return PrivacyStatus(
            isSecure: isPrivacyEnabled && encryptionStatus.isEnabled && compliance.isCompliant,
            encryptionEnabled: encryptionStatus.isEnabled,
            dataRetentionCompliant: compliance.violations.contains(where: { $0.type == .dataRetentionExceeded }) == false,
            accessControlsActive: configuration.enableBiometricAuthentication,
            lastAudit: await auditLogger.getLastAuditDate(),
            issues: issues
        )
    }

    public func encryptString(_ string: String, context: EncryptionContext = .general) async throws -> EncryptedData {
        guard let data = string.data(using: .utf8) else { throw PrivacyError.invalidData }
        return try await encryptData(data, context: context)
    }

    public func decryptToString(_ encryptedData: EncryptedData) async throws -> String {
        let data = try await decryptData(encryptedData)
        guard let string = String(data: data, encoding: .utf8) else { throw PrivacyError.invalidData }
        return string
    }

    public func encryptBatch(_ dataItems: [(Data, EncryptionContext)]) async throws -> [EncryptedData] {
        var results: [EncryptedData] = []
        for (data, context) in dataItems {
            results.append(try await encryptData(data, context: context))
        }
        return results
    }

    private func getOrCreateKey(identifier: String) async throws -> SymmetricKey {
        if let existingKey = encryptionKeys[identifier] {
            return existingKey
        }
        if let storedKey = try keychain.getKey(identifier: identifier) {
            encryptionKeys[identifier] = storedKey
            return storedKey
        }
        let newKey = SymmetricKey(size: .bits256)
        try keychain.storeKey(newKey, identifier: identifier)
        encryptionKeys[identifier] = newKey
        return newKey
    }

    private func key(for context: EncryptionContext) async throws -> SymmetricKey {
        try await getOrCreateKey(identifier: context.keyId)
    }

    private func buildBiometricStatus() -> BiometricAuthStatus {
        guard configuration.enableBiometricAuthentication else {
            return .unavailable
        }
        var error: NSError?
        guard biometricContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .unavailable
        }
        switch biometricContext.biometryType {
        case .faceID:
            return BiometricAuthStatus(isEnabled: true, availableTypes: [.faceID], currentType: .faceID)
        case .touchID:
            return BiometricAuthStatus(isEnabled: true, availableTypes: [.touchID], currentType: .touchID)
        default:
            return .available
        }
    }

    private func auditLoggingConfiguration(from config: PrivacyConfiguration) -> AuditLoggingConfiguration {
        AuditLoggingConfiguration(
            level: config.enableAuditLogging ? .info : .error,
            destination: .file,
            retentionPeriod: config.dataRetentionPeriod,
            encryptionEnabled: config.defaultEncryptionLevel == .high || config.defaultEncryptionLevel == .maximum,
            realTimeMonitoring: config.enableAuditLogging,
            alertThresholds: .default
        )
    }

    private func dataProtectionConfiguration(from config: PrivacyConfiguration) -> DataProtectionConfiguration {
        let memoryProtection: MemoryProtectionLevel = {
            switch config.defaultEncryptionLevel {
            case .low: return .basic
            case .medium, .high: return .enhanced
            case .maximum: return .maximum
            }
        }()
        let diskProtection: DiskProtectionLevel = {
            switch config.defaultEncryptionLevel {
            case .low: return .basic
            case .medium, .high: return .enhanced
            case .maximum: return .maximum
            }
        }()
        return DataProtectionConfiguration(
            enableIntegrityChecks: true,
            enableSecureDelete: true,
            enableCompression: false,
            enableEncryption: true,
            memoryProtection: memoryProtection,
            diskProtection: diskProtection
        )
    }

    private func vulnerabilitySeverity(from severity: ViolationSeverity) -> PrivacyVulnerability.VulnerabilitySeverity {
        switch severity {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        case .critical: return .critical
        }
    }
}

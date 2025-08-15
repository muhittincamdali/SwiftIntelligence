import Foundation
import CryptoKit
import LocalAuthentication
import os.log

/// Advanced Privacy Engine for SwiftIntelligence AI/ML Framework
/// Provides comprehensive data protection, encryption, and privacy compliance
@MainActor
public class PrivacyEngine: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = PrivacyEngine()
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "Privacy")
    private let processingQueue = DispatchQueue(label: "privacy.processing", qos: .userInitiated)
    
    // MARK: - Configuration
    @Published public var configuration: PrivacyConfiguration = .default
    
    // MARK: - State Management
    @Published public var isPrivacyEnabled = true
    @Published public var encryptionStatus: EncryptionStatus = .inactive
    @Published public var biometricAuthStatus: BiometricAuthStatus = .unavailable
    @Published public var dataRetentionPolicy: DataRetentionPolicy = .default
    
    // MARK: - Encryption
    private var encryptionKeys: [String: SymmetricKey] = [:]
    private var keychain: SecureKeychain
    
    // MARK: - Biometric Authentication
    private let biometricContext = LAContext()
    
    // MARK: - Data Protection
    private let dataProtection: DataProtectionManager
    private let auditLogger: PrivacyAuditLogger
    
    // MARK: - Anonymization
    private let anonymizer: DataAnonymizer
    private let tokenizer: PrivacyTokenizer
    
    // MARK: - Compliance
    private let complianceManager: ComplianceManager
    
    // MARK: - Initialization
    override init() {
        self.keychain = SecureKeychain()
        self.dataProtection = DataProtectionManager()
        self.auditLogger = PrivacyAuditLogger()
        self.anonymizer = DataAnonymizer()
        self.tokenizer = PrivacyTokenizer()
        self.complianceManager = ComplianceManager()
        
        super.init()
        
        Task {
            await initializePrivacyEngine()
        }
    }
    
    // MARK: - Engine Initialization
    
    private func initializePrivacyEngine() async {
        logger.info("Initializing Privacy Engine...")
        
        // Initialize encryption system
        await initializeEncryption()
        
        // Setup biometric authentication
        await setupBiometricAuth()
        
        // Initialize data protection
        await initializeDataProtection()
        
        // Setup audit logging
        await setupAuditLogging()
        
        // Initialize compliance monitoring
        await initializeCompliance()
        
        logger.info("Privacy Engine initialized successfully")
    }
    
    private func initializeEncryption() async {
        do {
            // Generate or retrieve master encryption key
            let masterKey = try await getMasterEncryptionKey()
            encryptionKeys["master"] = masterKey
            
            // Initialize data-specific encryption keys
            try await generateDataEncryptionKeys()
            
            encryptionStatus = .active
            logger.info("Encryption system initialized")
            
        } catch {
            logger.error("Failed to initialize encryption: \(error.localizedDescription)")
            encryptionStatus = .error(error.localizedDescription)
        }
    }
    
    private func setupBiometricAuth() async {
        var error: NSError?
        
        guard biometricContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricAuthStatus = .unavailable
            logger.info("Biometric authentication unavailable: \(error?.localizedDescription ?? "Unknown")")
            return
        }
        
        let biometryType = biometricContext.biometryType
        switch biometryType {
        case .faceID:
            biometricAuthStatus = .available(.faceID)
        case .touchID:
            biometricAuthStatus = .available(.touchID)
        case .opticID:
            biometricAuthStatus = .available(.opticID)
        default:
            biometricAuthStatus = .unavailable
        }
        
        logger.info("Biometric authentication configured: \(biometricAuthStatus)")
    }
    
    private func initializeDataProtection() async {
        await dataProtection.initialize(with: configuration.dataProtection)
        logger.info("Data protection initialized")
    }
    
    private func setupAuditLogging() async {
        await auditLogger.initialize(with: configuration.auditLogging)
        logger.info("Privacy audit logging configured")
    }
    
    private func initializeCompliance() async {
        await complianceManager.initialize(with: configuration.compliance)
        logger.info("Compliance monitoring initialized")
    }
    
    // MARK: - Configuration Management
    
    public func updateConfiguration(_ config: PrivacyConfiguration) async throws {
        let oldConfig = configuration
        configuration = config
        
        do {
            // Validate configuration
            try config.validate()
            
            // Update encryption settings
            if oldConfig.encryption != config.encryption {
                await updateEncryptionConfiguration(config.encryption)
            }
            
            // Update data protection settings
            if oldConfig.dataProtection != config.dataProtection {
                await dataProtection.updateConfiguration(config.dataProtection)
            }
            
            // Update compliance settings
            if oldConfig.compliance != config.compliance {
                await complianceManager.updateConfiguration(config.compliance)
            }
            
            // Update audit logging
            if oldConfig.auditLogging != config.auditLogging {
                await auditLogger.updateConfiguration(config.auditLogging)
            }
            
            await auditLogger.log(.configurationUpdated, details: [
                "previous_config": String(describing: oldConfig),
                "new_config": String(describing: config)
            ])
            
            logger.info("Privacy configuration updated successfully")
            
        } catch {
            // Rollback configuration on failure
            configuration = oldConfig
            throw PrivacyError.configurationUpdateFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Data Encryption
    
    /// Encrypt sensitive data using AES-256-GCM
    public func encryptData(_ data: Data, context: EncryptionContext = .general) async throws -> EncryptedData {
        guard isPrivacyEnabled else {
            throw PrivacyError.privacyDisabled
        }
        
        guard encryptionStatus == .active else {
            throw PrivacyError.encryptionUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let contextKey = context.rawValue
                    guard let encryptionKey = self.encryptionKeys[contextKey] ?? self.encryptionKeys["master"] else {
                        throw PrivacyError.encryptionKeyNotFound(contextKey)
                    }
                    
                    let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
                    
                    let encryptedData = EncryptedData(
                        data: sealedBox.ciphertext,
                        nonce: sealedBox.nonce,
                        tag: sealedBox.tag,
                        context: context,
                        timestamp: Date(),
                        algorithm: .aes256GCM
                    )
                    
                    // Log encryption event
                    Task {
                        await self.auditLogger.log(.dataEncrypted, details: [
                            "context": context.rawValue,
                            "data_size": "\(data.count)",
                            "algorithm": "AES-256-GCM"
                        ])
                    }
                    
                    continuation.resume(returning: encryptedData)
                    
                } catch {
                    continuation.resume(throwing: PrivacyError.encryptionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    /// Decrypt encrypted data
    public func decryptData(_ encryptedData: EncryptedData) async throws -> Data {
        guard isPrivacyEnabled else {
            throw PrivacyError.privacyDisabled
        }
        
        guard encryptionStatus == .active else {
            throw PrivacyError.encryptionUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let contextKey = encryptedData.context.rawValue
                    guard let encryptionKey = self.encryptionKeys[contextKey] ?? self.encryptionKeys["master"] else {
                        throw PrivacyError.encryptionKeyNotFound(contextKey)
                    }
                    
                    let sealedBox = try AES.GCM.SealedBox(
                        nonce: encryptedData.nonce,
                        ciphertext: encryptedData.data,
                        tag: encryptedData.tag
                    )
                    
                    let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
                    
                    // Log decryption event
                    Task {
                        await self.auditLogger.log(.dataDecrypted, details: [
                            "context": encryptedData.context.rawValue,
                            "data_size": "\(decryptedData.count)",
                            "algorithm": encryptedData.algorithm.rawValue
                        ])
                    }
                    
                    continuation.resume(returning: decryptedData)
                    
                } catch {
                    continuation.resume(throwing: PrivacyError.decryptionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Biometric Authentication
    
    /// Authenticate using biometrics
    public func authenticateWithBiometrics(reason: String = "Authenticate to access secure data") async throws -> Bool {
        guard case .available = biometricAuthStatus else {
            throw PrivacyError.biometricUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            biometricContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                if success {
                    Task {
                        await self.auditLogger.log(.biometricAuthSuccess, details: [
                            "reason": reason,
                            "biometry_type": String(describing: self.biometricContext.biometryType)
                        ])
                    }
                    continuation.resume(returning: true)
                } else {
                    let privacyError: PrivacyError
                    if let error = error as? LAError {
                        privacyError = self.mapLAError(error)
                    } else {
                        privacyError = .biometricAuthFailed(error?.localizedDescription ?? "Unknown error")
                    }
                    
                    Task {
                        await self.auditLogger.log(.biometricAuthFailure, details: [
                            "reason": reason,
                            "error": error?.localizedDescription ?? "Unknown"
                        ])
                    }
                    
                    continuation.resume(throwing: privacyError)
                }
            }
        }
    }
    
    // MARK: - Data Anonymization
    
    /// Anonymize text data by removing or masking PII
    public func anonymizeText(_ text: String, level: AnonymizationLevel = .standard) async throws -> AnonymizedData {
        return try await anonymizer.anonymize(text, level: level)
    }
    
    /// Anonymize structured data
    public func anonymizeData<T: Codable>(_ data: T, level: AnonymizationLevel = .standard) async throws -> AnonymizedData {
        return try await anonymizer.anonymize(data, level: level)
    }
    
    /// Tokenize sensitive data for secure processing
    public func tokenizeData(_ data: String, context: TokenizationContext) async throws -> TokenizedData {
        return try await tokenizer.tokenize(data, context: context)
    }
    
    /// Detokenize previously tokenized data
    public func detokenizeData(_ tokenizedData: TokenizedData) async throws -> String {
        return try await tokenizer.detokenize(tokenizedData)
    }
    
    // MARK: - Data Protection
    
    /// Apply data protection measures
    public func protectSensitiveData(_ data: Data, classification: DataClassification) async throws -> ProtectedData {
        return try await dataProtection.protect(data, classification: classification)
    }
    
    /// Validate data integrity
    public func validateDataIntegrity(_ protectedData: ProtectedData) async throws -> Bool {
        return try await dataProtection.validateIntegrity(protectedData)
    }
    
    /// Secure delete of sensitive data
    public func secureDelete(_ data: inout Data) async throws {
        try await dataProtection.secureDelete(&data)
        
        await auditLogger.log(.secureDataDeletion, details: [
            "data_size": "\(data.count)",
            "method": "cryptographic_erasure"
        ])
    }
    
    // MARK: - Data Retention
    
    /// Set data retention policy
    public func setDataRetentionPolicy(_ policy: DataRetentionPolicy) async {
        dataRetentionPolicy = policy
        await complianceManager.updateRetentionPolicy(policy)
        
        await auditLogger.log(.retentionPolicyUpdated, details: [
            "policy": String(describing: policy)
        ])
    }
    
    /// Check if data should be retained
    public func shouldRetainData(_ metadata: DataMetadata) -> Bool {
        return complianceManager.shouldRetain(metadata, policy: dataRetentionPolicy)
    }
    
    /// Execute data retention cleanup
    public func executeRetentionCleanup() async throws -> RetentionCleanupResult {
        let result = try await complianceManager.executeCleanup(policy: dataRetentionPolicy)
        
        await auditLogger.log(.retentionCleanupExecuted, details: [
            "deleted_items": "\(result.deletedItems)",
            "freed_space": "\(result.freedSpace)",
            "execution_time": "\(result.executionTime)"
        ])
        
        return result
    }
    
    // MARK: - Compliance
    
    /// Check GDPR compliance
    public func checkGDPRCompliance() async -> ComplianceStatus {
        return await complianceManager.checkGDPRCompliance()
    }
    
    /// Check CCPA compliance
    public func checkCCPACompliance() async -> ComplianceStatus {
        return await complianceManager.checkCCPACompliance()
    }
    
    /// Generate privacy report
    public func generatePrivacyReport(period: DateInterval) async throws -> PrivacyReport {
        let auditEvents = await auditLogger.getEvents(for: period)
        let complianceStatus = await complianceManager.getComplianceStatus()
        let encryptionMetrics = getEncryptionMetrics()
        
        return PrivacyReport(
            period: period,
            auditEvents: auditEvents,
            complianceStatus: complianceStatus,
            encryptionMetrics: encryptionMetrics,
            generatedAt: Date()
        )
    }
    
    // MARK: - Privacy Controls
    
    /// Enable/disable privacy features
    public func setPrivacyEnabled(_ enabled: Bool) async {
        isPrivacyEnabled = enabled
        
        await auditLogger.log(enabled ? .privacyEnabled : .privacyDisabled, details: [
            "enabled": "\(enabled)"
        ])
        
        logger.info("Privacy features \(enabled ? "enabled" : "disabled")")
    }
    
    /// Get privacy status
    public func getPrivacyStatus() async -> PrivacyStatus {
        return PrivacyStatus(
            isEnabled: isPrivacyEnabled,
            encryptionStatus: encryptionStatus,
            biometricAuthStatus: biometricAuthStatus,
            complianceStatus: await complianceManager.getComplianceStatus(),
            lastAuditDate: await auditLogger.getLastAuditDate(),
            dataRetentionPolicy: dataRetentionPolicy
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func getMasterEncryptionKey() async throws -> SymmetricKey {
        if let existingKey = try await keychain.getKey(identifier: "master_encryption_key") {
            return existingKey
        }
        
        // Generate new master key
        let newKey = SymmetricKey(size: .bits256)
        try await keychain.storeKey(newKey, identifier: "master_encryption_key")
        
        await auditLogger.log(.masterKeyGenerated, details: [
            "key_size": "256",
            "algorithm": "AES-256-GCM"
        ])
        
        return newKey
    }
    
    private func generateDataEncryptionKeys() async throws {
        let contexts: [EncryptionContext] = [.llm, .vision, .speech, .imageGeneration, .personalData]
        
        for context in contexts {
            let contextKey = context.rawValue
            if encryptionKeys[contextKey] == nil {
                let key = SymmetricKey(size: .bits256)
                encryptionKeys[contextKey] = key
                
                // Store in keychain for persistence
                try await keychain.storeKey(key, identifier: "\(contextKey)_encryption_key")
            }
        }
    }
    
    private func updateEncryptionConfiguration(_ config: EncryptionConfiguration) async {
        // Update encryption settings based on new configuration
        if config.keyRotationEnabled {
            await scheduleKeyRotation(interval: config.keyRotationInterval)
        }
    }
    
    private func scheduleKeyRotation(interval: TimeInterval) async {
        // Schedule automatic key rotation
        logger.info("Scheduling key rotation every \(interval) seconds")
    }
    
    private func mapLAError(_ error: LAError) -> PrivacyError {
        switch error.code {
        case .authenticationFailed:
            return .biometricAuthFailed("Authentication failed")
        case .userCancel:
            return .biometricAuthCancelled
        case .userFallback:
            return .biometricAuthFallback
        case .biometryNotAvailable:
            return .biometricUnavailable
        case .biometryNotEnrolled:
            return .biometricNotEnrolled
        case .biometryLockout:
            return .biometricLockout
        default:
            return .biometricAuthFailed(error.localizedDescription)
        }
    }
    
    private func getEncryptionMetrics() -> EncryptionMetrics {
        return EncryptionMetrics(
            totalEncryptedData: 0, // Would track actual metrics
            encryptionOperations: 0,
            decryptionOperations: 0,
            keyRotations: 0,
            lastKeyRotation: nil
        )
    }
}

// MARK: - Extensions

extension PrivacyEngine {
    
    /// Convenience method for encrypting strings
    public func encryptString(_ string: String, context: EncryptionContext = .general) async throws -> EncryptedData {
        guard let data = string.data(using: .utf8) else {
            throw PrivacyError.invalidData("Cannot convert string to data")
        }
        return try await encryptData(data, context: context)
    }
    
    /// Convenience method for decrypting to strings
    public func decryptToString(_ encryptedData: EncryptedData) async throws -> String {
        let data = try await decryptData(encryptedData)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PrivacyError.invalidData("Cannot convert data to string")
        }
        return string
    }
    
    /// Batch encrypt multiple data items
    public func encryptBatch(_ dataItems: [(Data, EncryptionContext)]) async throws -> [EncryptedData] {
        return try await withThrowingTaskGroup(of: EncryptedData.self) { group in
            var results: [EncryptedData] = []
            
            for (data, context) in dataItems {
                group.addTask {
                    return try await self.encryptData(data, context: context)
                }
            }
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
}
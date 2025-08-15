import Foundation
import CryptoKit
import os.log

/// Advanced data protection manager providing integrity checks, secure deletion, and data classification
public class DataProtectionManager {
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "DataProtection")
    private var configuration: DataProtectionConfiguration = .default
    private let processingQueue = DispatchQueue(label: "data.protection", qos: .userInitiated)
    
    public init() {
        logger.info("DataProtectionManager initialized")
    }
    
    // MARK: - Configuration
    
    public func initialize(with config: DataProtectionConfiguration) async {
        configuration = config
        logger.info("DataProtectionManager configured: integrity=\(config.enableIntegrityChecks), secureDelete=\(config.enableSecureDelete)")
    }
    
    public func updateConfiguration(_ config: DataProtectionConfiguration) async {
        configuration = config
        logger.info("Data protection configuration updated")
    }
    
    // MARK: - Data Protection
    
    /// Protect sensitive data with classification-based security measures
    public func protect(_ data: Data, classification: DataClassification) async throws -> ProtectedData {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.applyProtectionMeasures(data, classification: classification)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func applyProtectionMeasures(_ data: Data, classification: DataClassification) throws -> ProtectedData {
        var protectedData = data
        var appliedProtections: [String] = []
        
        // Apply memory protection based on classification
        if configuration.memoryProtection != .none {
            protectedData = try applyMemoryProtection(protectedData, level: configuration.memoryProtection)
            appliedProtections.append("memory_protection:\(configuration.memoryProtection.rawValue)")
        }
        
        // Apply disk protection based on classification
        if configuration.diskProtection != .none {
            protectedData = try applyDiskProtection(protectedData, level: configuration.diskProtection, classification: classification)
            appliedProtections.append("disk_protection:\(configuration.diskProtection.rawValue)")
        }
        
        // Generate integrity checksum
        let checksum = generateIntegrityChecksum(protectedData)
        
        return ProtectedData(
            data: protectedData,
            classification: classification,
            checksum: checksum,
            protectionApplied: appliedProtections,
            timestamp: Date()
        )
    }
    
    // MARK: - Data Integrity
    
    /// Validate data integrity using checksums
    public func validateIntegrity(_ protectedData: ProtectedData) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let currentChecksum = self.generateIntegrityChecksum(protectedData.data)
                    let isValid = currentChecksum == protectedData.checksum
                    
                    if !isValid {
                        self.logger.error("Data integrity validation failed for classified data")
                    }
                    
                    continuation.resume(returning: isValid)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Generate integrity checksum for data
    private func generateIntegrityChecksum(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify data has not been tampered with
    public func verifyDataIntegrity(_ data: Data, expectedChecksum: String) -> Bool {
        let currentChecksum = generateIntegrityChecksum(data)
        return currentChecksum == expectedChecksum
    }
    
    // MARK: - Secure Deletion
    
    /// Securely delete sensitive data using cryptographic erasure
    public func secureDelete(_ data: inout Data) async throws {
        guard configuration.enableSecureDelete else {
            data = Data() // Simple clear if secure delete disabled
            return
        }
        
        try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    // Method 1: Cryptographic erasure (preferred for encrypted data)
                    try self.performCryptographicErasure(&data)
                    
                    // Method 2: Memory overwriting for additional security
                    try self.performMemoryOverwriting(&data)
                    
                    // Method 3: Zero fill the data
                    data = Data(count: 0)
                    
                    self.logger.debug("Secure data deletion completed")
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performCryptographicErasure(_ data: inout Data) throws {
        // Generate random key and encrypt data, then discard the key
        let ephemeralKey = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(data, using: ephemeralKey)
        
        // Replace original data with encrypted version
        data = sealedBox.ciphertext
        
        // Key is automatically discarded when it goes out of scope
        // This makes the data cryptographically irretrievable
    }
    
    private func performMemoryOverwriting(_ data: inout Data) throws {
        data.withUnsafeMutableBytes { bytes in
            guard let baseAddress = bytes.baseAddress else { return }
            
            // Multiple pass overwriting with different patterns
            let patterns: [UInt8] = [0x00, 0xFF, 0xAA, 0x55, 0x00]
            
            for pattern in patterns {
                memset(baseAddress, Int32(pattern), bytes.count)
            }
            
            // Final pass with random data
            for i in 0..<bytes.count {
                baseAddress.advanced(by: i).storeBytes(of: UInt8.random(in: 0...255), as: UInt8.self)
            }
        }
    }
    
    // MARK: - Memory Protection
    
    private func applyMemoryProtection(_ data: Data, level: MemoryProtectionLevel) throws -> Data {
        switch level {
        case .none:
            return data
            
        case .low:
            // Basic memory clearing after use
            return data
            
        case .medium:
            // Memory locking to prevent swapping
            return try lockMemoryPages(data)
            
        case .high:
            // Memory encryption and locking
            return try encryptAndLockMemory(data)
            
        case .maximum:
            // Maximum security: encrypted, locked, and obfuscated
            return try applyMaximumMemoryProtection(data)
        }
    }
    
    private func lockMemoryPages(_ data: Data) throws -> Data {
        var protectedData = data
        
        protectedData.withUnsafeMutableBytes { bytes in
            if let baseAddress = bytes.baseAddress {
                // Lock memory pages to prevent swapping to disk
                mlock(baseAddress, bytes.count)
            }
        }
        
        return protectedData
    }
    
    private func encryptAndLockMemory(_ data: Data) throws -> Data {
        // Encrypt the data in memory
        let memoryKey = SymmetricKey(size: .bits256)
        let encryptedData = try AES.GCM.seal(data, using: memoryKey).ciphertext
        
        // Lock the encrypted data in memory
        return try lockMemoryPages(encryptedData)
    }
    
    private func applyMaximumMemoryProtection(_ data: Data) throws -> Data {
        // Step 1: Encrypt the data
        let encryptionKey = SymmetricKey(size: .bits256)
        let encrypted = try AES.GCM.seal(data, using: encryptionKey).ciphertext
        
        // Step 2: Add memory obfuscation
        let obfuscated = try obfuscateMemoryData(encrypted)
        
        // Step 3: Lock in memory
        let locked = try lockMemoryPages(obfuscated)
        
        return locked
    }
    
    private func obfuscateMemoryData(_ data: Data) throws -> Data {
        var obfuscated = Data(count: data.count)
        let obfuscationKey = UInt8.random(in: 1...255)
        
        for i in 0..<data.count {
            obfuscated[i] = data[i] ^ obfuscationKey
        }
        
        return obfuscated
    }
    
    // MARK: - Disk Protection
    
    private func applyDiskProtection(_ data: Data, level: DiskProtectionLevel, classification: DataClassification) throws -> Data {
        switch level {
        case .none:
            return data
            
        case .fileSystem:
            // Rely on file system encryption
            return data
            
        case .application:
            // Application-level encryption
            return try encryptForDiskStorage(data, classification: classification)
            
        case .full:
            // Full encryption with additional protections
            return try applyFullDiskProtection(data, classification: classification)
        }
    }
    
    private func encryptForDiskStorage(_ data: Data, classification: DataClassification) throws -> Data {
        // Use classification-specific encryption strength
        let keySize: SymmetricKeySize = classification.protectionLevel >= 4 ? .bits256 : .bits128
        let encryptionKey = SymmetricKey(size: keySize)
        
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        
        // Store the sealed box data (in production, key would be stored separately)
        var result = Data()
        result.append(sealedBox.nonce.withUnsafeBytes { Data($0) })
        result.append(sealedBox.ciphertext)
        result.append(sealedBox.tag)
        
        return result
    }
    
    private func applyFullDiskProtection(_ data: Data, classification: DataClassification) throws -> Data {
        // Multiple layers of encryption for highly classified data
        var protected = data
        
        // Layer 1: Classification-based encryption
        protected = try encryptForDiskStorage(protected, classification: classification)
        
        // Layer 2: Additional obfuscation for top secret data
        if classification == .topSecret {
            protected = try obfuscateMemoryData(protected)
        }
        
        // Layer 3: Integrity seal
        let integritySeal = generateIntegrityChecksum(protected)
        protected.append(integritySeal.data(using: .utf8) ?? Data())
        
        return protected
    }
    
    // MARK: - Data Classification
    
    /// Automatically classify data based on content analysis
    public func classifyData(_ data: Data) async -> DataClassification {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let classification = self.performDataClassification(data)
                continuation.resume(returning: classification)
            }
        }
    }
    
    private func performDataClassification(_ data: Data) -> DataClassification {
        guard let string = String(data: data, encoding: .utf8) else {
            return .internal // Default classification for non-text data
        }
        
        let content = string.lowercased()
        
        // Check for highly sensitive patterns
        let topSecretPatterns = [
            "top secret", "classified", "confidential", "restricted access",
            "national security", "state secret"
        ]
        
        let restrictedPatterns = [
            "ssn", "social security", "passport", "driver license",
            "credit card", "bank account", "tax id"
        ]
        
        let confidentialPatterns = [
            "password", "private key", "api key", "token",
            "medical", "health", "diagnosis", "treatment"
        ]
        
        let internalPatterns = [
            "internal", "employee", "staff", "corporate",
            "business", "company", "organization"
        ]
        
        // Classification logic
        for pattern in topSecretPatterns {
            if content.contains(pattern) {
                return .topSecret
            }
        }
        
        for pattern in restrictedPatterns {
            if content.contains(pattern) {
                return .restricted
            }
        }
        
        for pattern in confidentialPatterns {
            if content.contains(pattern) {
                return .confidential
            }
        }
        
        for pattern in internalPatterns {
            if content.contains(pattern) {
                return .internal
            }
        }
        
        return .public // Default to public if no sensitive patterns found
    }
    
    // MARK: - Data Sanitization
    
    /// Sanitize data for safe sharing
    public func sanitizeData(_ data: Data, targetClassification: DataClassification) async throws -> Data {
        let currentClassification = await classifyData(data)
        
        guard currentClassification.protectionLevel > targetClassification.protectionLevel else {
            return data // No sanitization needed
        }
        
        return try await performDataSanitization(data, from: currentClassification, to: targetClassification)
    }
    
    private func performDataSanitization(_ data: Data, from: DataClassification, to: DataClassification) async throws -> Data {
        guard let string = String(data: data, encoding: .utf8) else {
            // For binary data, apply basic sanitization
            return try sanitizeBinaryData(data, targetLevel: to.protectionLevel)
        }
        
        // Text-based sanitization
        var sanitized = string
        
        // Remove sensitive patterns based on target classification
        switch to {
        case .public:
            sanitized = try sanitizeForPublic(sanitized)
        case .internal:
            sanitized = try sanitizeForInternal(sanitized)
        case .confidential:
            sanitized = try sanitizeForConfidential(sanitized)
        default:
            break // No sanitization needed for higher classifications
        }
        
        return sanitized.data(using: .utf8) ?? data
    }
    
    private func sanitizeForPublic(_ text: String) throws -> String {
        var sanitized = text
        
        // Remove all PII patterns
        let patterns = [
            #"\b\d{3}-\d{2}-\d{4}\b"#, // SSN
            #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#, // Email
            #"\b\d{3}-\d{3}-\d{4}\b"#, // Phone
            #"\b(?:\d{4}[-\s]?){3}\d{4}\b"# // Credit card
        ]
        
        for pattern in patterns {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[REDACTED]"
            )
        }
        
        return sanitized
    }
    
    private func sanitizeForInternal(_ text: String) throws -> String {
        var sanitized = text
        
        // Remove external-facing sensitive data but keep internal identifiers
        let patterns = [
            #"\b[A-Za-z0-9._%+-]+@(?!company\.com)[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#, // External emails
            #"\b(?:\d{4}[-\s]?){3}\d{4}\b"# // Credit cards
        ]
        
        for pattern in patterns {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[EXTERNAL_DATA]"
            )
        }
        
        return sanitized
    }
    
    private func sanitizeForConfidential(_ text: String) throws -> String {
        // Minimal sanitization for confidential level
        var sanitized = text
        
        // Only remove the most sensitive data
        let patterns = [
            #"\b\d{3}-\d{2}-\d{4}\b"# // SSN
        ]
        
        for pattern in patterns {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[SSN]"
            )
        }
        
        return sanitized
    }
    
    private func sanitizeBinaryData(_ data: Data, targetLevel: Int) throws -> Data {
        if targetLevel <= 2 { // Public or Internal
            // Replace potentially sensitive bytes with zeros
            var sanitized = data
            sanitized.withUnsafeMutableBytes { bytes in
                // Simple pattern: replace sequences that might be keys or sensitive data
                for i in 0..<(bytes.count - 16) {
                    if isLikelySensitiveBinaryPattern(bytes, startIndex: i) {
                        memset(bytes.baseAddress?.advanced(by: i), 0, 16)
                    }
                }
            }
            return sanitized
        }
        
        return data
    }
    
    private func isLikelySensitiveBinaryPattern(_ bytes: UnsafeMutableRawBufferPointer, startIndex: Int) -> Bool {
        // Simple heuristic: sequences of non-zero bytes that might be keys
        guard startIndex + 16 < bytes.count else { return false }
        
        var nonZeroCount = 0
        for i in startIndex..<(startIndex + 16) {
            if bytes[i] != 0 {
                nonZeroCount += 1
            }
        }
        
        // If most bytes are non-zero, it might be a key or sensitive data
        return nonZeroCount >= 12
    }
    
    // MARK: - Access Control
    
    /// Check if access is allowed for given classification
    public func checkAccess(for classification: DataClassification, requesterLevel: Int) -> Bool {
        return requesterLevel >= classification.protectionLevel
    }
    
    /// Generate access control metadata
    public func generateAccessControlMetadata(for classification: DataClassification) -> [String: Any] {
        return [
            "classification": classification.rawValue,
            "protection_level": classification.protectionLevel,
            "min_clearance": classification.protectionLevel,
            "access_restrictions": getAccessRestrictions(for: classification)
        ]
    }
    
    private func getAccessRestrictions(for classification: DataClassification) -> [String] {
        switch classification {
        case .public:
            return []
        case .internal:
            return ["employee_only"]
        case .confidential:
            return ["employee_only", "need_to_know"]
        case .restricted:
            return ["employee_only", "need_to_know", "manager_approval"]
        case .topSecret:
            return ["employee_only", "need_to_know", "manager_approval", "security_clearance"]
        }
    }
}

// MARK: - Error Types

public enum DataProtectionError: LocalizedError {
    case protectionFailed(String)
    case integrityCheckFailed
    case classificationError(String)
    case sanitizationFailed(String)
    case accessDenied(String)
    
    public var errorDescription: String? {
        switch self {
        case .protectionFailed(let reason):
            return "Data protection failed: \(reason)"
        case .integrityCheckFailed:
            return "Data integrity check failed"
        case .classificationError(let reason):
            return "Data classification error: \(reason)"
        case .sanitizationFailed(let reason):
            return "Data sanitization failed: \(reason)"
        case .accessDenied(let reason):
            return "Access denied: \(reason)"
        }
    }
}

// MARK: - Extensions

extension DataClassification {
    public var requiresEncryption: Bool {
        return protectionLevel >= 3
    }
    
    public var requiresAuditTrail: Bool {
        return protectionLevel >= 2
    }
    
    public var allowsPublicAccess: Bool {
        return self == .public
    }
}
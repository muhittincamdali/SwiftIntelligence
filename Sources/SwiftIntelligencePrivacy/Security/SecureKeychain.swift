import Foundation
import Security
import CryptoKit
import os.log

/// Secure keychain manager for SwiftIntelligence Privacy Layer
/// Provides encrypted storage and retrieval of cryptographic keys and sensitive data
public class SecureKeychain {
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "SecureKeychain")
    private let serviceIdentifier = "com.swiftintelligence.privacy"
    private let accessGroup: String?
    
    public init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
        logger.info("SecureKeychain initialized")
    }
    
    // MARK: - Key Storage
    
    /// Store a symmetric key in the keychain
    public func storeKey(_ key: SymmetricKey, identifier: String, accessibility: SecAccessibility = .whenUnlockedThisDeviceOnly) async throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: accessibility
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Delete existing key if present
        try await deleteKey(identifier: identifier)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            logger.error("Failed to store key \(identifier): \(status)")
            throw KeychainError.storageError(status)
        }
        
        logger.info("Key stored successfully: \(identifier)")
    }
    
    /// Retrieve a symmetric key from the keychain
    public func getKey(identifier: String) async throws -> SymmetricKey? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            logger.error("Failed to retrieve key \(identifier): \(status)")
            throw KeychainError.retrievalError(status)
        }
        
        guard let keyData = result as? Data else {
            throw KeychainError.invalidData
        }
        
        logger.debug("Key retrieved successfully: \(identifier)")
        return SymmetricKey(data: keyData)
    }
    
    /// Delete a key from the keychain
    public func deleteKey(identifier: String) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: identifier
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success if item was deleted or didn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete key \(identifier): \(status)")
            throw KeychainError.deletionError(status)
        }
        
        logger.debug("Key deleted: \(identifier)")
    }
    
    // MARK: - Secure Data Storage
    
    /// Store encrypted data in the keychain
    public func storeSecureData(_ data: Data, identifier: String, accessibility: SecAccessibility = .whenUnlockedThisDeviceOnly) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "\(serviceIdentifier).data",
            kSecAttrAccount as String: identifier,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Delete existing data if present
        try await deleteSecureData(identifier: identifier)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            logger.error("Failed to store secure data \(identifier): \(status)")
            throw KeychainError.storageError(status)
        }
        
        logger.info("Secure data stored: \(identifier)")
    }
    
    /// Retrieve encrypted data from the keychain
    public func getSecureData(identifier: String) async throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "\(serviceIdentifier).data",
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            logger.error("Failed to retrieve secure data \(identifier): \(status)")
            throw KeychainError.retrievalError(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        logger.debug("Secure data retrieved: \(identifier)")
        return data
    }
    
    /// Delete secure data from the keychain
    public func deleteSecureData(identifier: String) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "\(serviceIdentifier).data",
            kSecAttrAccount as String: identifier
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success if item was deleted or didn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete secure data \(identifier): \(status)")
            throw KeychainError.deletionError(status)
        }
        
        logger.debug("Secure data deleted: \(identifier)")
    }
    
    // MARK: - Biometric-Protected Storage
    
    /// Store data with biometric protection
    public func storeBiometricProtectedData(
        _ data: Data,
        identifier: String,
        biometricPrompt: String = "Authenticate to access secure data"
    ) async throws {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        
        access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet, .or, .devicePasscode],
            &error
        )
        
        if let error = error?.takeRetainedValue() {
            logger.error("Failed to create access control: \(error)")
            throw KeychainError.accessControlError(error)
        }
        
        guard let accessControl = access else {
            throw KeychainError.accessControlCreationFailed
        }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "\(serviceIdentifier).biometric",
            kSecAttrAccount as String: identifier,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: accessControl,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
            kSecUseAuthenticationContext as String: biometricPrompt
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Delete existing data if present
        try await deleteBiometricProtectedData(identifier: identifier)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            logger.error("Failed to store biometric-protected data \(identifier): \(status)")
            throw KeychainError.storageError(status)
        }
        
        logger.info("Biometric-protected data stored: \(identifier)")
    }
    
    /// Retrieve biometric-protected data
    public func getBiometricProtectedData(
        identifier: String,
        biometricPrompt: String = "Authenticate to access secure data"
    ) async throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "\(serviceIdentifier).biometric",
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
            kSecUseOperationPrompt as String: biometricPrompt
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var result: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
                
                DispatchQueue.main.async {
                    guard status == errSecSuccess else {
                        if status == errSecItemNotFound {
                            continuation.resume(returning: nil)
                        } else {
                            self.logger.error("Failed to retrieve biometric-protected data \(identifier): \(status)")
                            continuation.resume(throwing: KeychainError.retrievalError(status))
                        }
                        return
                    }
                    
                    guard let data = result as? Data else {
                        continuation.resume(throwing: KeychainError.invalidData)
                        return
                    }
                    
                    self.logger.debug("Biometric-protected data retrieved: \(identifier)")
                    continuation.resume(returning: data)
                }
            }
        }
    }
    
    /// Delete biometric-protected data
    public func deleteBiometricProtectedData(identifier: String) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "\(serviceIdentifier).biometric",
            kSecAttrAccount as String: identifier
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success if item was deleted or didn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete biometric-protected data \(identifier): \(status)")
            throw KeychainError.deletionError(status)
        }
        
        logger.debug("Biometric-protected data deleted: \(identifier)")
    }
    
    // MARK: - Key Management
    
    /// List all stored keys
    public func listStoredKeys() async throws -> [String] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return []
            }
            throw KeychainError.retrievalError(status)
        }
        
        guard let items = result as? [[String: Any]] else {
            return []
        }
        
        let keys = items.compactMap { item in
            item[kSecAttrAccount as String] as? String
        }
        
        logger.debug("Found \(keys.count) stored keys")
        return keys
    }
    
    /// Clear all stored keys and data
    public func clearAll() async throws {
        let services = [
            serviceIdentifier,
            "\(serviceIdentifier).data",
            "\(serviceIdentifier).biometric"
        ]
        
        for service in services {
            var query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service
            ]
            
            if let accessGroup = accessGroup {
                query[kSecAttrAccessGroup as String] = accessGroup
            }
            
            let status = SecItemDelete(query as CFDictionary)
            
            // Log only if there were items to delete
            if status == errSecSuccess {
                logger.info("Cleared all items for service: \(service)")
            }
        }
        
        logger.info("Keychain cleared")
    }
    
    // MARK: - Key Rotation
    
    /// Rotate a symmetric key
    public func rotateKey(identifier: String, accessibility: SecAccessibility = .whenUnlockedThisDeviceOnly) async throws -> SymmetricKey {
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        
        // Store the new key
        try await storeKey(newKey, identifier: identifier, accessibility: accessibility)
        
        logger.info("Key rotated: \(identifier)")
        return newKey
    }
    
    /// Check if a key exists
    public func keyExists(identifier: String) async throws -> Bool {
        do {
            let key = try await getKey(identifier: identifier)
            return key != nil
        } catch KeychainError.retrievalError(let status) where status == errSecItemNotFound {
            return false
        }
    }
    
    // MARK: - Backup and Recovery
    
    /// Export keys for backup (encrypted)
    public func exportKeys(with backupKey: SymmetricKey) async throws -> Data {
        let keys = try await listStoredKeys()
        var keyData: [String: Data] = [:]
        
        for keyIdentifier in keys {
            if let key = try await getKey(identifier: keyIdentifier) {
                let keyBytes = key.withUnsafeBytes { Data($0) }
                keyData[keyIdentifier] = keyBytes
            }
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: keyData)
        let sealedBox = try AES.GCM.seal(jsonData, using: backupKey)
        
        let backup = KeyBackup(
            encryptedData: sealedBox.ciphertext,
            nonce: sealedBox.nonce,
            tag: sealedBox.tag,
            timestamp: Date()
        )
        
        logger.info("Keys exported for backup")
        return try JSONEncoder().encode(backup)
    }
    
    /// Import keys from backup
    public func importKeys(from backupData: Data, with backupKey: SymmetricKey) async throws {
        let backup = try JSONDecoder().decode(KeyBackup.self, from: backupData)
        
        let sealedBox = try AES.GCM.SealedBox(
            nonce: backup.nonce,
            ciphertext: backup.encryptedData,
            tag: backup.tag
        )
        
        let decryptedData = try AES.GCM.open(sealedBox, using: backupKey)
        
        guard let keyData = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Data] else {
            throw KeychainError.invalidBackupFormat
        }
        
        for (identifier, data) in keyData {
            let key = SymmetricKey(data: data)
            try await storeKey(key, identifier: identifier)
        }
        
        logger.info("Keys imported from backup")
    }
}

// MARK: - Supporting Types

private struct KeyBackup: Codable {
    let encryptedData: Data
    let nonce: AES.GCM.Nonce
    let tag: Data
    let timestamp: Date
}

// MARK: - Keychain Errors

public enum KeychainError: LocalizedError {
    case storageError(OSStatus)
    case retrievalError(OSStatus)
    case deletionError(OSStatus)
    case invalidData
    case accessControlError(CFError)
    case accessControlCreationFailed
    case invalidBackupFormat
    
    public var errorDescription: String? {
        switch self {
        case .storageError(let status):
            return "Failed to store in keychain: \(SecCopyErrorMessageString(status, nil) ?? "Unknown error")"
        case .retrievalError(let status):
            return "Failed to retrieve from keychain: \(SecCopyErrorMessageString(status, nil) ?? "Unknown error")"
        case .deletionError(let status):
            return "Failed to delete from keychain: \(SecCopyErrorMessageString(status, nil) ?? "Unknown error")"
        case .invalidData:
            return "Invalid data format"
        case .accessControlError(let error):
            return "Access control error: \(CFErrorCopyDescription(error))"
        case .accessControlCreationFailed:
            return "Failed to create access control"
        case .invalidBackupFormat:
            return "Invalid backup format"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .storageError, .retrievalError, .deletionError:
            return "Check keychain permissions and device lock status"
        case .invalidData:
            return "Ensure data is in correct format"
        case .accessControlError, .accessControlCreationFailed:
            return "Check biometric settings and device capabilities"
        case .invalidBackupFormat:
            return "Use a valid backup file"
        }
    }
}

// MARK: - SecAccessibility Extension

extension SecAccessibility {
    public static let whenUnlockedThisDeviceOnly = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    public static let whenUnlocked = kSecAttrAccessibleWhenUnlocked
    public static let afterFirstUnlockThisDeviceOnly = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    public static let afterFirstUnlock = kSecAttrAccessibleAfterFirstUnlock
    public static let whenPasscodeSetThisDeviceOnly = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
}
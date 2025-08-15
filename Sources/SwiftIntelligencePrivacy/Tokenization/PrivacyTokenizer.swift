import Foundation
import CryptoKit
import os.log

/// Privacy-preserving tokenization system for sensitive data
/// Provides secure, reversible tokenization of PII and sensitive information
public class PrivacyTokenizer {
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "PrivacyTokenizer")
    private let processingQueue = DispatchQueue(label: "privacy.tokenization", qos: .userInitiated)
    
    // MARK: - Token Storage
    private var tokenVault: [String: TokenVaultEntry] = [:]
    private let keychain = SecureKeychain()
    private var tokenizationKey: SymmetricKey?
    private let maxTokenLifetime: TimeInterval = 86400 // 24 hours
    
    // MARK: - Token Generation
    private let tokenLength = 32
    private let tokenPrefix = "SI_TKN_"
    
    public init() {
        Task {
            await initializeTokenizer()
        }
        logger.info("PrivacyTokenizer initialized")
    }
    
    // MARK: - Initialization
    
    private func initializeTokenizer() async {
        do {
            // Initialize tokenization key
            if let existingKey = try await keychain.getKey(identifier: "tokenization_key") {
                tokenizationKey = existingKey
            } else {
                let newKey = SymmetricKey(size: .bits256)
                try await keychain.storeKey(newKey, identifier: "tokenization_key")
                tokenizationKey = newKey
            }
            
            // Load existing token vault
            await loadTokenVault()
            
            // Schedule cleanup task
            await scheduleTokenCleanup()
            
            logger.info("PrivacyTokenizer initialization complete")
        } catch {
            logger.error("Failed to initialize tokenizer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Tokenization
    
    /// Tokenize sensitive data
    public func tokenize(_ data: String, context: TokenizationContext) async throws -> TokenizedData {
        guard !data.isEmpty else {
            throw TokenizationError.emptyData
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.performTokenization(data, context: context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performTokenization(_ data: String, context: TokenizationContext) throws -> TokenizedData {
        // Generate unique token
        let token = generateSecureToken()
        
        // Encrypt the original data
        guard let tokenizationKey = tokenizationKey else {
            throw TokenizationError.keyNotAvailable
        }
        
        guard let dataBytes = data.data(using: .utf8) else {
            throw TokenizationError.invalidData
        }
        
        let sealedBox = try AES.GCM.seal(dataBytes, using: tokenizationKey)
        
        // Calculate expiration
        let expiresAt = shouldExpire(for: context) ? Date().addingTimeInterval(maxTokenLifetime) : nil
        
        // Store in vault
        let vaultEntry = TokenVaultEntry(
            encryptedData: sealedBox.ciphertext,
            nonce: sealedBox.nonce,
            tag: sealedBox.tag,
            context: context,
            createdAt: Date(),
            expiresAt: expiresAt,
            accessCount: 0,
            lastAccessedAt: Date()
        )
        
        tokenVault[token] = vaultEntry
        
        // Save to persistent storage
        Task {
            await self.saveTokenVault()
        }
        
        logger.debug("Tokenized data for context: \(context.rawValue)")
        
        return TokenizedData(
            token: token,
            context: context,
            expiresAt: expiresAt,
            reversible: true,
            timestamp: Date()
        )
    }
    
    /// Detokenize previously tokenized data
    public func detokenize(_ tokenizedData: TokenizedData) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.performDetokenization(tokenizedData)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performDetokenization(_ tokenizedData: TokenizedData) throws -> String {
        guard let vaultEntry = tokenVault[tokenizedData.token] else {
            throw TokenizationError.tokenNotFound
        }
        
        // Check expiration
        if let expiresAt = vaultEntry.expiresAt, Date() > expiresAt {
            // Remove expired token
            tokenVault.removeValue(forKey: tokenizedData.token)
            throw TokenizationError.tokenExpired
        }
        
        // Check context match
        guard vaultEntry.context == tokenizedData.context else {
            throw TokenizationError.contextMismatch
        }
        
        // Decrypt the data
        guard let tokenizationKey = tokenizationKey else {
            throw TokenizationError.keyNotAvailable
        }
        
        let sealedBox = try AES.GCM.SealedBox(
            nonce: vaultEntry.nonce,
            ciphertext: vaultEntry.encryptedData,
            tag: vaultEntry.tag
        )
        
        let decryptedData = try AES.GCM.open(sealedBox, using: tokenizationKey)
        
        guard let originalString = String(data: decryptedData, encoding: .utf8) else {
            throw TokenizationError.corruptedData
        }
        
        // Update access tracking
        var updatedEntry = vaultEntry
        updatedEntry.accessCount += 1
        updatedEntry.lastAccessedAt = Date()
        tokenVault[tokenizedData.token] = updatedEntry
        
        logger.debug("Detokenized data for context: \(tokenizedData.context.rawValue)")
        
        return originalString
    }
    
    // MARK: - Batch Operations
    
    /// Tokenize multiple data items
    public func tokenizeBatch(_ items: [(String, TokenizationContext)]) async throws -> [TokenizedData] {
        return try await withThrowingTaskGroup(of: TokenizedData.self) { group in
            var results: [TokenizedData] = []
            
            for (data, context) in items {
                group.addTask {
                    return try await self.tokenize(data, context: context)
                }
            }
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    /// Detokenize multiple tokens
    public func detokenizeBatch(_ tokens: [TokenizedData]) async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self) { group in
            var results: [String] = []
            
            for token in tokens {
                group.addTask {
                    return try await self.detokenize(token)
                }
            }
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    // MARK: - Format-Preserving Tokenization
    
    /// Tokenize data while preserving format (e.g., credit card format)
    public func formatPreservingTokenize(_ data: String, context: TokenizationContext) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try self.performFormatPreservingTokenization(data, context: context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performFormatPreservingTokenization(_ data: String, context: TokenizationContext) throws -> String {
        switch context {
        case .creditCard:
            return try tokenizeCreditCard(data)
        case .phoneNumber:
            return try tokenizePhoneNumber(data)
        case .socialSecurity:
            return try tokenizeSSN(data)
        case .email:
            return try tokenizeEmail(data)
        default:
            // For other contexts, use standard tokenization
            let tokenized = try performTokenization(data, context: context)
            return tokenized.token
        }
    }
    
    private func tokenizeCreditCard(_ cardNumber: String) throws -> String {
        // Preserve format: XXXX-XXXX-XXXX-XXXX or XXXXXXXXXXXXXXXX
        let cleanNumber = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        guard cleanNumber.count >= 13 && cleanNumber.count <= 19 else {
            throw TokenizationError.invalidFormat
        }
        
        // Generate format-preserving token
        let tokenizedNumber = generateNumericToken(length: cleanNumber.count)
        
        // Preserve original formatting
        if cardNumber.contains("-") {
            return formatWithDashes(tokenizedNumber)
        } else if cardNumber.contains(" ") {
            return formatWithSpaces(tokenizedNumber)
        } else {
            return tokenizedNumber
        }
    }
    
    private func tokenizePhoneNumber(_ phoneNumber: String) throws -> String {
        // Preserve format: (XXX) XXX-XXXX or XXX-XXX-XXXX
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        guard cleanNumber.count == 10 else {
            throw TokenizationError.invalidFormat
        }
        
        let tokenizedNumber = generateNumericToken(length: 10)
        
        // Preserve original formatting
        if phoneNumber.contains("(") {
            return "(\(tokenizedNumber.prefix(3))) \(tokenizedNumber.dropFirst(3).prefix(3))-\(tokenizedNumber.suffix(4))"
        } else {
            return "\(tokenizedNumber.prefix(3))-\(tokenizedNumber.dropFirst(3).prefix(3))-\(tokenizedNumber.suffix(4))"
        }
    }
    
    private func tokenizeSSN(_ ssn: String) throws -> String {
        // Preserve format: XXX-XX-XXXX
        let cleanSSN = ssn.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        guard cleanSSN.count == 9 else {
            throw TokenizationError.invalidFormat
        }
        
        let tokenizedSSN = generateNumericToken(length: 9)
        return "\(tokenizedSSN.prefix(3))-\(tokenizedSSN.dropFirst(3).prefix(2))-\(tokenizedSSN.suffix(4))"
    }
    
    private func tokenizeEmail(_ email: String) throws -> String {
        // Preserve email format: user@domain.com
        let components = email.components(separatedBy: "@")
        guard components.count == 2 else {
            throw TokenizationError.invalidFormat
        }
        
        let tokenizedUser = generateAlphanumericToken(length: components[0].count)
        return "\(tokenizedUser)@\(components[1])"
    }
    
    // MARK: - Token Management
    
    /// Check if a token exists and is valid
    public func isValidToken(_ token: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                guard let vaultEntry = self.tokenVault[token] else {
                    continuation.resume(returning: false)
                    return
                }
                
                // Check expiration
                if let expiresAt = vaultEntry.expiresAt, Date() > expiresAt {
                    self.tokenVault.removeValue(forKey: token)
                    continuation.resume(returning: false)
                    return
                }
                
                continuation.resume(returning: true)
            }
        }
    }
    
    /// Revoke a token
    public func revokeToken(_ token: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let existed = self.tokenVault.removeValue(forKey: token) != nil
                
                if existed {
                    Task {
                        await self.saveTokenVault()
                    }
                    self.logger.info("Token revoked: \(token)")
                }
                
                continuation.resume(returning: existed)
            }
        }
    }
    
    /// Get token metadata
    public func getTokenMetadata(_ token: String) async -> TokenMetadata? {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                guard let vaultEntry = self.tokenVault[token] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let metadata = TokenMetadata(
                    token: token,
                    context: vaultEntry.context,
                    createdAt: vaultEntry.createdAt,
                    expiresAt: vaultEntry.expiresAt,
                    accessCount: vaultEntry.accessCount,
                    lastAccessedAt: vaultEntry.lastAccessedAt
                )
                
                continuation.resume(returning: metadata)
            }
        }
    }
    
    /// Clean up expired tokens
    public func cleanupExpiredTokens() async -> Int {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                let now = Date()
                let initialCount = self.tokenVault.count
                
                self.tokenVault = self.tokenVault.filter { _, entry in
                    guard let expiresAt = entry.expiresAt else { return true }
                    return now <= expiresAt
                }
                
                let removedCount = initialCount - self.tokenVault.count
                
                if removedCount > 0 {
                    Task {
                        await self.saveTokenVault()
                    }
                    self.logger.info("Cleaned up \(removedCount) expired tokens")
                }
                
                continuation.resume(returning: removedCount)
            }
        }
    }
    
    // MARK: - Token Vault Persistence
    
    private func saveTokenVault() async {
        do {
            let vaultData = try JSONEncoder().encode(tokenVault)
            try await keychain.storeSecureData(vaultData, identifier: "token_vault")
        } catch {
            logger.error("Failed to save token vault: \(error.localizedDescription)")
        }
    }
    
    private func loadTokenVault() async {
        do {
            guard let vaultData = try await keychain.getSecureData(identifier: "token_vault") else {
                logger.info("No existing token vault found")
                return
            }
            
            tokenVault = try JSONDecoder().decode([String: TokenVaultEntry].self, from: vaultData)
            logger.info("Loaded token vault with \(tokenVault.count) tokens")
        } catch {
            logger.error("Failed to load token vault: \(error.localizedDescription)")
            tokenVault = [:]
        }
    }
    
    // MARK: - Token Generation
    
    private func generateSecureToken() -> String {
        let tokenData = Data((0..<tokenLength).map { _ in UInt8.random(in: 0...255) })
        let base64Token = tokenData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "=", with: "")
        
        return tokenPrefix + String(base64Token.prefix(tokenLength))
    }
    
    private func generateNumericToken(length: Int) -> String {
        return String((0..<length).map { _ in String(Int.random(in: 0...9)) }.joined())
    }
    
    private func generateAlphanumericToken(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    // MARK: - Utility Methods
    
    private func shouldExpire(for context: TokenizationContext) -> Bool {
        switch context {
        case .creditCard, .socialSecurity:
            return true // Highly sensitive data should expire
        case .phoneNumber, .email:
            return false // Contact info can be longer-lived
        case .name, .address:
            return false // Personal info for legitimate use
        case .custom:
            return true // Default to expiring for custom contexts
        }
    }
    
    private func formatWithDashes(_ number: String) -> String {
        guard number.count == 16 else { return number }
        return "\(number.prefix(4))-\(number.dropFirst(4).prefix(4))-\(number.dropFirst(8).prefix(4))-\(number.suffix(4))"
    }
    
    private func formatWithSpaces(_ number: String) -> String {
        guard number.count == 16 else { return number }
        return "\(number.prefix(4)) \(number.dropFirst(4).prefix(4)) \(number.dropFirst(8).prefix(4)) \(number.suffix(4))"
    }
    
    private func scheduleTokenCleanup() async {
        // Schedule periodic cleanup (in production, this would use a timer)
        Task {
            while true {
                try await Task.sleep(nanoseconds: 3600_000_000_000) // 1 hour
                await cleanupExpiredTokens()
            }
        }
    }
}

// MARK: - Supporting Types

private struct TokenVaultEntry: Codable {
    let encryptedData: Data
    let nonce: AES.GCM.Nonce
    let tag: Data
    let context: TokenizationContext
    let createdAt: Date
    let expiresAt: Date?
    var accessCount: Int
    var lastAccessedAt: Date
}

public struct TokenMetadata {
    public let token: String
    public let context: TokenizationContext
    public let createdAt: Date
    public let expiresAt: Date?
    public let accessCount: Int
    public let lastAccessedAt: Date
    
    public init(token: String, context: TokenizationContext, createdAt: Date, expiresAt: Date?, accessCount: Int, lastAccessedAt: Date) {
        self.token = token
        self.context = context
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.accessCount = accessCount
        self.lastAccessedAt = lastAccessedAt
    }
}

// MARK: - Error Types

public enum TokenizationError: LocalizedError {
    case emptyData
    case invalidData
    case invalidFormat
    case keyNotAvailable
    case tokenNotFound
    case tokenExpired
    case contextMismatch
    case corruptedData
    case operationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .emptyData:
            return "Cannot tokenize empty data"
        case .invalidData:
            return "Invalid data format for tokenization"
        case .invalidFormat:
            return "Data format is not valid for format-preserving tokenization"
        case .keyNotAvailable:
            return "Tokenization key is not available"
        case .tokenNotFound:
            return "Token not found in vault"
        case .tokenExpired:
            return "Token has expired"
        case .contextMismatch:
            return "Token context does not match"
        case .corruptedData:
            return "Tokenized data appears to be corrupted"
        case .operationFailed(let reason):
            return "Tokenization operation failed: \(reason)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .emptyData, .invalidData, .invalidFormat:
            return "Provide valid data for tokenization"
        case .keyNotAvailable:
            return "Initialize the tokenization system"
        case .tokenNotFound:
            return "Verify the token is correct and has not been revoked"
        case .tokenExpired:
            return "Re-tokenize the original data"
        case .contextMismatch:
            return "Ensure the token context matches the original tokenization context"
        case .corruptedData:
            return "Re-tokenize the original data or restore from backup"
        case .operationFailed:
            return "Check system logs and retry the operation"
        }
    }
}
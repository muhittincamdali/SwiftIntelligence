import Foundation
import NaturalLanguage
import os.log

/// Advanced data anonymization system for SwiftIntelligence Privacy Layer
/// Removes or masks personally identifiable information (PII) while preserving data utility
public class DataAnonymizer {
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "DataAnonymizer")
    private let nlProcessor = NLLanguageRecognizer()
    
    // MARK: - PII Detection Patterns
    
    private let piiPatterns: [PIIType: [NSRegularExpression]] = {
        var patterns: [PIIType: [NSRegularExpression]] = [:]
        
        // Email addresses
        patterns[.email] = [
            try! NSRegularExpression(pattern: #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#, options: [])
        ]
        
        // Phone numbers (various formats)
        patterns[.phoneNumber] = [
            try! NSRegularExpression(pattern: #"\b(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})\b"#, options: []),
            try! NSRegularExpression(pattern: #"\b\d{3}-\d{3}-\d{4}\b"#, options: []),
            try! NSRegularExpression(pattern: #"\b\(\d{3}\)\s?\d{3}-\d{4}\b"#, options: [])
        ]
        
        // Social Security Numbers
        patterns[.socialSecurityNumber] = [
            try! NSRegularExpression(pattern: #"\b\d{3}-\d{2}-\d{4}\b"#, options: []),
            try! NSRegularExpression(pattern: #"\b\d{9}\b"#, options: [])
        ]
        
        // Credit Card Numbers
        patterns[.creditCardNumber] = [
            try! NSRegularExpression(pattern: #"\b(?:\d{4}[-\s]?){3}\d{4}\b"#, options: []),
            try! NSRegularExpression(pattern: #"\b\d{13,19}\b"#, options: [])
        ]
        
        // IP Addresses
        patterns[.ipAddress] = [
            try! NSRegularExpression(pattern: #"\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"#, options: [])
        ]
        
        // MAC Addresses
        patterns[.macAddress] = [
            try! NSRegularExpression(pattern: #"\b([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\b"#, options: [])
        ]
        
        // URLs
        patterns[.url] = [
            try! NSRegularExpression(pattern: #"\bhttps?://[^\s/$.?#].[^\s]*\b"#, options: [])
        ]
        
        // Geographic Coordinates
        patterns[.coordinates] = [
            try! NSRegularExpression(pattern: #"\b-?\d{1,3}\.\d+,\s*-?\d{1,3}\.\d+\b"#, options: [])
        ]
        
        // Medical Record Numbers
        patterns[.medicalRecord] = [
            try! NSRegularExpression(pattern: #"\b(?:MRN|MR|Medical Record)[-:\s]*\d+\b"#, options: [.caseInsensitive])
        ]
        
        // Financial Account Numbers
        patterns[.accountNumber] = [
            try! NSRegularExpression(pattern: #"\b(?:Account|Acct)[-:\s]*\d{8,}\b"#, options: [.caseInsensitive])
        ]
        
        return patterns
    }()
    
    // MARK: - Name Detection
    
    private let commonFirstNames: Set<String> = Set([
        "james", "robert", "john", "michael", "david", "william", "richard", "charles", "joseph", "thomas",
        "christopher", "daniel", "paul", "mark", "donald", "steven", "matthew", "andrew", "joshua", "kenneth",
        "paul", "kevin", "brian", "george", "timothy", "ronald", "jason", "edward", "jeffrey", "ryan",
        "jacob", "gary", "nicholas", "eric", "jonathan", "stephen", "larry", "justin", "scott", "brandon",
        "mary", "patricia", "jennifer", "linda", "elizabeth", "barbara", "susan", "jessica", "sarah", "karen",
        "nancy", "lisa", "betty", "helen", "sandra", "donna", "carol", "ruth", "sharon", "michelle",
        "laura", "sarah", "kimberly", "deborah", "dorothy", "lisa", "nancy", "karen", "betty", "helen"
    ])
    
    private let commonLastNames: Set<String> = Set([
        "smith", "johnson", "williams", "brown", "jones", "garcia", "miller", "davis", "rodriguez", "martinez",
        "hernandez", "lopez", "gonzalez", "wilson", "anderson", "thomas", "taylor", "moore", "jackson", "martin",
        "lee", "perez", "thompson", "white", "harris", "sanchez", "clark", "ramirez", "lewis", "robinson"
    ])
    
    public init() {
        logger.info("DataAnonymizer initialized")
    }
    
    // MARK: - Text Anonymization
    
    /// Anonymize text data by removing or masking PII
    public func anonymize(_ text: String, level: AnonymizationLevel) async throws -> AnonymizedData {
        let startTime = Date()
        
        var anonymizedText = text
        var detectedPII: [String] = []
        
        // Detect and remove/mask PII based on level
        for (piiType, patterns) in piiPatterns {
            for pattern in patterns {
                let matches = pattern.matches(in: anonymizedText, range: NSRange(anonymizedText.startIndex..., in: anonymizedText))
                
                for match in matches.reversed() { // Reverse to maintain indices
                    let matchRange = Range(match.range, in: anonymizedText)!
                    let matchedText = String(anonymizedText[matchRange])
                    
                    detectedPII.append("\(piiType.rawValue): \(matchedText)")
                    
                    let replacement = generateReplacement(for: piiType, originalText: matchedText, level: level)
                    anonymizedText.replaceSubrange(matchRange, with: replacement)
                }
            }
        }
        
        // Detect and anonymize names using NLP
        anonymizedText = try await anonymizeNames(in: anonymizedText, level: level, detectedPII: &detectedPII)
        
        // Detect and anonymize addresses
        anonymizedText = try await anonymizeAddresses(in: anonymizedText, level: level, detectedPII: &detectedPII)
        
        // Apply additional anonymization based on level
        switch level {
        case .aggressive:
            anonymizedText = try await applyAggressiveAnonymization(anonymizedText, detectedPII: &detectedPII)
        case .maximum:
            anonymizedText = try await applyMaximumAnonymization(anonymizedText, detectedPII: &detectedPII)
        default:
            break
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        logger.info("Text anonymized in \(processingTime)s, detected \(detectedPII.count) PII items")
        
        return AnonymizedData(
            data: anonymizedText,
            level: level,
            piiRemoved: detectedPII,
            reversible: level == .minimal,
            timestamp: Date()
        )
    }
    
    // MARK: - Structured Data Anonymization
    
    /// Anonymize structured data (JSON, Dictionary, etc.)
    public func anonymize<T: Codable>(_ data: T, level: AnonymizationLevel) async throws -> AnonymizedData {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw AnonymizationError.invalidDataFormat
        }
        
        let result = try await anonymize(jsonString, level: level)
        
        // For structured data, we format the result back to JSON if possible
        if let formattedData = result.data.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: formattedData),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            
            return AnonymizedData(
                data: prettyString,
                level: result.level,
                piiRemoved: result.piiRemoved,
                reversible: result.reversible,
                timestamp: result.timestamp
            )
        }
        
        return result
    }
    
    // MARK: - Name Anonymization
    
    private func anonymizeNames(in text: String, level: AnonymizationLevel, detectedPII: inout [String]) async throws -> String {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var anonymizedText = text
        var replacements: [(range: Range<String.Index>, replacement: String)] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let token = String(text[tokenRange])
                
                switch tag {
                case .personalName:
                    detectedPII.append("name: \(token)")
                    let replacement = generateNameReplacement(for: token, level: level)
                    replacements.append((range: tokenRange, replacement: replacement))
                case .organizationName:
                    if level == .aggressive || level == .maximum {
                        detectedPII.append("organization: \(token)")
                        let replacement = generateOrganizationReplacement(for: token, level: level)
                        replacements.append((range: tokenRange, replacement: replacement))
                    }
                case .placeName:
                    if level == .aggressive || level == .maximum {
                        detectedPII.append("place: \(token)")
                        let replacement = generatePlaceReplacement(for: token, level: level)
                        replacements.append((range: tokenRange, replacement: replacement))
                    }
                default:
                    break
                }
            }
            return true
        }
        
        // Apply replacements in reverse order to maintain indices
        for replacement in replacements.reversed() {
            anonymizedText.replaceSubrange(replacement.range, with: replacement.replacement)
        }
        
        return anonymizedText
    }
    
    // MARK: - Address Anonymization
    
    private func anonymizeAddresses(in text: String, level: AnonymizationLevel, detectedPII: inout [String]) async throws -> String {
        let addressPatterns = [
            try! NSRegularExpression(pattern: #"\d+\s+[A-Za-z0-9\s]+(?:Street|St|Avenue|Ave|Road|Rd|Lane|Ln|Drive|Dr|Boulevard|Blvd|Court|Ct|Place|Pl)\b"#, options: [.caseInsensitive]),
            try! NSRegularExpression(pattern: #"\b\d{5}(?:-\d{4})?\b"#, options: []), // ZIP codes
        ]
        
        var anonymizedText = text
        
        for pattern in addressPatterns {
            let matches = pattern.matches(in: anonymizedText, range: NSRange(anonymizedText.startIndex..., in: anonymizedText))
            
            for match in matches.reversed() {
                let matchRange = Range(match.range, in: anonymizedText)!
                let matchedText = String(anonymizedText[matchRange])
                
                detectedPII.append("address: \(matchedText)")
                
                let replacement = generateAddressReplacement(for: matchedText, level: level)
                anonymizedText.replaceSubrange(matchRange, with: replacement)
            }
        }
        
        return anonymizedText
    }
    
    // MARK: - Advanced Anonymization
    
    private func applyAggressiveAnonymization(_ text: String, detectedPII: inout [String]) async throws -> String {
        var anonymizedText = text
        
        // Remove dates
        let datePattern = try! NSRegularExpression(pattern: #"\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b"#, options: [])
        let dateMatches = datePattern.matches(in: anonymizedText, range: NSRange(anonymizedText.startIndex..., in: anonymizedText))
        
        for match in dateMatches.reversed() {
            let matchRange = Range(match.range, in: anonymizedText)!
            let matchedText = String(anonymizedText[matchRange])
            detectedPII.append("date: \(matchedText)")
            anonymizedText.replaceSubrange(matchRange, with: "[DATE]")
        }
        
        // Remove numbers that might be identifiers
        let numberPattern = try! NSRegularExpression(pattern: #"\b\d{4,}\b"#, options: [])
        let numberMatches = numberPattern.matches(in: anonymizedText, range: NSRange(anonymizedText.startIndex..., in: anonymizedText))
        
        for match in numberMatches.reversed() {
            let matchRange = Range(match.range, in: anonymizedText)!
            let matchedText = String(anonymizedText[matchRange])
            
            // Skip years and common numbers
            if !isCommonNumber(matchedText) {
                detectedPII.append("identifier: \(matchedText)")
                anonymizedText.replaceSubrange(matchRange, with: "[ID]")
            }
        }
        
        return anonymizedText
    }
    
    private func applyMaximumAnonymization(_ text: String, detectedPII: inout [String]) async throws -> String {
        var anonymizedText = try await applyAggressiveAnonymization(text, detectedPII: &detectedPII)
        
        // Remove all remaining numbers
        let allNumberPattern = try! NSRegularExpression(pattern: #"\b\d+\b"#, options: [])
        anonymizedText = allNumberPattern.stringByReplacingMatches(
            in: anonymizedText,
            range: NSRange(anonymizedText.startIndex..., in: anonymizedText),
            withTemplate: "[NUM]"
        )
        
        // Remove capitalized words that might be names or places
        let capitalizedPattern = try! NSRegularExpression(pattern: #"\b[A-Z][a-z]{2,}\b"#, options: [])
        let capitalizedMatches = capitalizedPattern.matches(in: anonymizedText, range: NSRange(anonymizedText.startIndex..., in: anonymizedText))
        
        for match in capitalizedMatches.reversed() {
            let matchRange = Range(match.range, in: anonymizedText)!
            let matchedText = String(anonymizedText[matchRange])
            
            // Skip common words
            if !isCommonWord(matchedText) {
                detectedPII.append("capitalized_word: \(matchedText)")
                anonymizedText.replaceSubrange(matchRange, with: "[WORD]")
            }
        }
        
        return anonymizedText
    }
    
    // MARK: - Replacement Generation
    
    private func generateReplacement(for piiType: PIIType, originalText: String, level: AnonymizationLevel) -> String {
        switch level {
        case .minimal:
            // Partial masking
            return partiallyMask(originalText, piiType: piiType)
        case .standard:
            // Generic replacement
            return "[\(piiType.rawValue.uppercased())]"
        case .aggressive, .maximum:
            // Complete removal or generic placeholder
            return "[REDACTED]"
        }
    }
    
    private func generateNameReplacement(for name: String, level: AnonymizationLevel) -> String {
        switch level {
        case .minimal:
            // Keep first letter
            return String(name.prefix(1)) + String(repeating: "*", count: max(1, name.count - 1))
        case .standard:
            return "[NAME]"
        case .aggressive, .maximum:
            return "[PERSON]"
        }
    }
    
    private func generateOrganizationReplacement(for org: String, level: AnonymizationLevel) -> String {
        switch level {
        case .minimal, .standard:
            return "[ORGANIZATION]"
        case .aggressive, .maximum:
            return "[ORG]"
        }
    }
    
    private func generatePlaceReplacement(for place: String, level: AnonymizationLevel) -> String {
        switch level {
        case .minimal, .standard:
            return "[LOCATION]"
        case .aggressive, .maximum:
            return "[PLACE]"
        }
    }
    
    private func generateAddressReplacement(for address: String, level: AnonymizationLevel) -> String {
        switch level {
        case .minimal:
            // Keep general area info
            return "[ADDRESS_AREA]"
        case .standard:
            return "[ADDRESS]"
        case .aggressive, .maximum:
            return "[LOCATION]"
        }
    }
    
    private func partiallyMask(_ text: String, piiType: PIIType) -> String {
        let length = text.count
        
        switch piiType {
        case .email:
            // Mask domain but keep structure
            if let atIndex = text.firstIndex(of: "@") {
                let localPart = String(text[..<atIndex])
                let domainPart = String(text[text.index(after: atIndex)...])
                let maskedLocal = String(localPart.prefix(2)) + String(repeating: "*", count: max(1, localPart.count - 2))
                return "\(maskedLocal)@[DOMAIN]"
            }
            return text
            
        case .phoneNumber:
            // Show area code
            if length >= 10 {
                return String(text.prefix(3)) + String(repeating: "*", count: length - 3)
            }
            return String(repeating: "*", count: length)
            
        case .creditCardNumber:
            // Show last 4 digits
            if length >= 8 {
                let visibleCount = 4
                let maskedCount = length - visibleCount
                return String(repeating: "*", count: maskedCount) + String(text.suffix(visibleCount))
            }
            return String(repeating: "*", count: length)
            
        default:
            // Default partial masking
            let visibleCount = min(2, length / 3)
            let maskedCount = length - visibleCount
            return String(text.prefix(visibleCount)) + String(repeating: "*", count: maskedCount)
        }
    }
    
    // MARK: - Utility Methods
    
    private func isCommonNumber(_ number: String) -> Bool {
        guard let num = Int(number) else { return false }
        
        // Years
        if num >= 1900 && num <= 2100 { return true }
        
        // Common round numbers
        let commonNumbers = [100, 1000, 10000, 100000]
        return commonNumbers.contains(num)
    }
    
    private func isCommonWord(_ word: String) -> Bool {
        let commonWords = Set([
            "The", "This", "That", "These", "Those", "And", "Or", "But", "For", "With",
            "From", "To", "In", "On", "At", "By", "As", "Of", "Is", "Are", "Was", "Were",
            "Been", "Have", "Has", "Had", "Will", "Would", "Could", "Should", "May", "Might"
        ])
        
        return commonWords.contains(word)
    }
    
    // MARK: - Validation
    
    /// Validate anonymization quality
    public func validateAnonymization(_ originalText: String, anonymizedText: String) async -> AnonymizationQuality {
        let originalPII = await detectPII(in: originalText)
        let remainingPII = await detectPII(in: anonymizedText)
        
        let removalRate = originalPII.isEmpty ? 1.0 : Double(originalPII.count - remainingPII.count) / Double(originalPII.count)
        let utilityScore = calculateUtilityScore(original: originalText, anonymized: anonymizedText)
        
        return AnonymizationQuality(
            removalRate: removalRate,
            utilityScore: utilityScore,
            originalPIICount: originalPII.count,
            remainingPIICount: remainingPII.count
        )
    }
    
    private func detectPII(in text: String) async -> [String] {
        var detectedPII: [String] = []
        
        for (piiType, patterns) in piiPatterns {
            for pattern in patterns {
                let matches = pattern.matches(in: text, range: NSRange(text.startIndex..., in: text))
                detectedPII.append(contentsOf: matches.map { _ in piiType.rawValue })
            }
        }
        
        return detectedPII
    }
    
    private func calculateUtilityScore(original: String, anonymized: String) -> Double {
        // Simple utility score based on preserved content
        let originalWords = Set(original.lowercased().components(separatedBy: .whitespacesAndPunctuation))
        let anonymizedWords = Set(anonymized.lowercased().components(separatedBy: .whitespacesAndPunctuation))
        
        let preservedWords = originalWords.intersection(anonymizedWords)
        
        return originalWords.isEmpty ? 0.0 : Double(preservedWords.count) / Double(originalWords.count)
    }
}

// MARK: - Supporting Types

public enum PIIType: String, CaseIterable {
    case email = "email"
    case phoneNumber = "phone_number"
    case socialSecurityNumber = "ssn"
    case creditCardNumber = "credit_card"
    case ipAddress = "ip_address"
    case macAddress = "mac_address"
    case url = "url"
    case coordinates = "coordinates"
    case medicalRecord = "medical_record"
    case accountNumber = "account_number"
}

public struct AnonymizationQuality {
    public let removalRate: Double // 0.0 to 1.0
    public let utilityScore: Double // 0.0 to 1.0
    public let originalPIICount: Int
    public let remainingPIICount: Int
    
    public var qualityGrade: String {
        if removalRate >= 0.95 && utilityScore >= 0.7 {
            return "Excellent"
        } else if removalRate >= 0.85 && utilityScore >= 0.6 {
            return "Good"
        } else if removalRate >= 0.75 && utilityScore >= 0.5 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
}

// MARK: - Anonymization Errors

public enum AnonymizationError: LocalizedError {
    case invalidDataFormat
    case processingFailed(String)
    case patternCompilationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidDataFormat:
            return "Invalid data format for anonymization"
        case .processingFailed(let reason):
            return "Anonymization processing failed: \(reason)"
        case .patternCompilationFailed(let pattern):
            return "Failed to compile regex pattern: \(pattern)"
        }
    }
}
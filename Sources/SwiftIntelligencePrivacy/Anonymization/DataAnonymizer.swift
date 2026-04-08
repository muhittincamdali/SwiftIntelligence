import Foundation
import NaturalLanguage
import os.log

/// Data anonymizer aligned to the canonical privacy contracts.
public final class DataAnonymizer: @unchecked Sendable {
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "DataAnonymizer")
    private let recognizer = NLLanguageRecognizer()

    private let piiPatterns: [PIIType: [NSRegularExpression]] = {
        func regex(_ pattern: String, options: NSRegularExpression.Options = []) -> NSRegularExpression {
            try! NSRegularExpression(pattern: pattern, options: options)
        }

        return [
            .email: [regex(#"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"#)],
            .phoneNumber: [regex(#"\b(?:\+?\d{1,3}[ -]?)?(?:\(?\d{3}\)?[ -]?)?\d{3}[ -]?\d{4}\b"#)],
            .socialSecurityNumber: [regex(#"\b\d{3}-\d{2}-\d{4}\b"#)],
            .creditCardNumber: [regex(#"\b(?:\d{4}[ -]?){3}\d{4}\b"#)],
            .ipAddress: [regex(#"\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"#)],
            .macAddress: [regex(#"\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b"#)],
            .url: [regex(#"\bhttps?://[^\s]+\b"#)],
            .coordinates: [regex(#"\b-?\d{1,3}\.\d+\s*,\s*-?\d{1,3}\.\d+\b"#)],
            .medicalRecord: [regex(#"\b(?:MRN|MR|Medical Record)[-:\s]*\d+\b"#, options: [.caseInsensitive])],
            .accountNumber: [regex(#"\b(?:Account|Acct)[-:\s]*\d{8,}\b"#, options: [.caseInsensitive])],
            .address: [regex(#"\b\d+\s+[A-Za-z0-9\s]+(?:Street|St|Avenue|Ave|Road|Rd|Lane|Ln|Drive|Dr|Boulevard|Blvd|Court|Ct|Place|Pl)\b"#, options: [.caseInsensitive])]
        ]
    }()

    public init() {
        logger.info("DataAnonymizer initialized")
    }

    public func anonymize(_ text: String, level: AnonymizationLevel) async throws -> AnonymizedData {
        let startedAt = Date()
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            return AnonymizedData(
                originalId: UUID().uuidString,
                anonymizedContent: Data(),
                level: level,
                metadata: ["matches": "0", "utility_score": "1.0"]
            )
        }

        if level == .none {
            return AnonymizedData(
                originalId: UUID().uuidString,
                anonymizedContent: Data(normalized.utf8),
                level: level,
                metadata: ["matches": "0", "utility_score": "1.0"]
            )
        }

        var workingText = normalized
        var replacements: [(range: Range<String.Index>, replacement: String)] = []
        var findings: [String] = []

        for (piiType, patterns) in piiPatterns {
            for pattern in patterns {
                let matches = pattern.matches(in: workingText, range: NSRange(workingText.startIndex..., in: workingText))
                for match in matches {
                    guard let range = Range(match.range, in: workingText) else { continue }
                    let originalValue = String(workingText[range])
                    findings.append("\(piiType.rawValue):\(originalValue)")
                    replacements.append((range, replacement(for: piiType, original: originalValue, level: level)))
                }
            }
        }

        replacements.sort { $0.range.lowerBound > $1.range.lowerBound }
        for replacement in replacements {
            workingText.replaceSubrange(replacement.range, with: replacement.replacement)
        }

        workingText = anonymizePotentialNames(in: workingText, level: level)
        let utilityScore = utilityScore(original: normalized, anonymized: workingText)
        let elapsed = Date().timeIntervalSince(startedAt)

        recognizer.processString(workingText)
        let language = recognizer.dominantLanguage?.rawValue ?? "und"

        logger.info("Anonymized text in \(elapsed)s with \(findings.count) matches")

        return AnonymizedData(
            originalId: UUID().uuidString,
            anonymizedContent: Data(workingText.utf8),
            level: level,
            metadata: [
                "matches": String(findings.count),
                "utility_score": String(format: "%.3f", utilityScore),
                "language": language,
                "processing_time": String(format: "%.4f", elapsed),
                "privacy_score": String(level.privacyScore)
            ]
        )
    }

    public func anonymize<T: Codable>(_ data: T, level: AnonymizationLevel) async throws -> AnonymizedData {
        let encoded = try JSONEncoder().encode(data)
        guard let json = String(data: encoded, encoding: .utf8) else {
            throw AnonymizationError.invalidDataFormat
        }

        var result = try await anonymize(json, level: level)
        if let object = try? JSONSerialization.jsonObject(with: result.anonymizedContent),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
            result = AnonymizedData(
                originalId: result.originalId,
                anonymizedContent: prettyData,
                level: result.level,
                timestamp: result.timestamp,
                metadata: result.metadata
            )
        }
        return result
    }

    private func anonymizePotentialNames(in text: String, level: AnonymizationLevel) -> String {
        guard level != .none else { return text }
        let pattern = try! NSRegularExpression(pattern: #"\b[A-Z][a-z]+\s+[A-Z][a-z]+\b"#)
        let matches = pattern.matches(in: text, range: NSRange(text.startIndex..., in: text))
        var redacted = text
        for match in matches.reversed() {
            guard let range = Range(match.range, in: redacted) else { continue }
            let token = String(redacted[range])
            redacted.replaceSubrange(range, with: replacement(for: .name, original: token, level: level))
        }
        return redacted
    }

    private func replacement(for piiType: PIIType, original: String, level: AnonymizationLevel) -> String {
        switch level {
        case .none:
            return original
        case .basic:
            return partiallyMasked(original, piiType: piiType)
        case .standard:
            return "[\(piiType.rawValue.uppercased())]"
        case .strong, .complete:
            return piiType == .url ? "[LINK]" : "[REDACTED]"
        }
    }

    private func partiallyMasked(_ value: String, piiType: PIIType) -> String {
        switch piiType {
        case .email:
            guard let atIndex = value.firstIndex(of: "@") else { return "[EMAIL]" }
            let local = String(value[..<atIndex])
            let prefix = String(local.prefix(2))
            return prefix + String(repeating: "*", count: max(local.count - 2, 1)) + "@***"
        case .phoneNumber, .socialSecurityNumber, .creditCardNumber, .accountNumber:
            let suffix = value.suffix(4)
            return String(repeating: "*", count: max(value.count - 4, 2)) + suffix
        case .ipAddress, .coordinates:
            return "[MASKED_\(piiType.rawValue.uppercased())]"
        case .address:
            return "[ADDRESS_AREA]"
        case .name:
            return String(value.prefix(1)) + String(repeating: "*", count: max(value.count - 1, 1))
        default:
            return "[\(piiType.rawValue.uppercased())]"
        }
    }

    private func utilityScore(original: String, anonymized: String) -> Double {
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let originalWords = Set(original.lowercased().components(separatedBy: separators).filter { !$0.isEmpty })
        let anonymizedWords = Set(anonymized.lowercased().components(separatedBy: separators).filter { !$0.isEmpty })
        guard !originalWords.isEmpty else { return 1.0 }
        let overlap = originalWords.intersection(anonymizedWords).count
        return Double(overlap) / Double(originalWords.count)
    }
}

public enum PIIType: String, CaseIterable {
    case name = "name"
    case email = "email"
    case phoneNumber = "phone_number"
    case socialSecurityNumber = "social_security_number"
    case creditCardNumber = "credit_card_number"
    case ipAddress = "ip_address"
    case macAddress = "mac_address"
    case url = "url"
    case coordinates = "coordinates"
    case medicalRecord = "medical_record"
    case accountNumber = "account_number"
    case address = "address"
}

public enum AnonymizationError: LocalizedError {
    case invalidDataFormat
    case anonymizationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidDataFormat:
            return "Invalid data format for anonymization"
        case .anonymizationFailed(let message):
            return "Anonymization failed: \(message)"
        }
    }
}

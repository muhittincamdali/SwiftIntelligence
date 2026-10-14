import Foundation
import NaturalLanguage

/// Finds and replaces personal data in text: email and postal addresses, phone numbers, links,
/// payment card numbers, IBANs, IP addresses and people's names.
///
/// Card numbers and IBANs must pass their check digits, so order numbers and other long
/// numbers stay readable. Phone numbers, links and postal addresses come from the system data
/// detector; names come from the NaturalLanguage name tagger and are the least reliable kind,
/// especially outside English. Treat redaction as a safety net, not as a guarantee.
///
/// ```swift
/// let redactor = PersonalDataRedactor()
/// let result = redactor.redact("Mail jane@example.com or call +1 415 555 0132.")
/// result.text   // "Mail [EMAIL_1] or call [PHONE_1]."
/// ```
public struct PersonalDataRedactor: Sendable {
    /// How a match is written in the redacted text.
    public enum Replacement: Hashable, Sendable {
        /// The kind's tag, for example `[EMAIL]`.
        case tag
        /// A numbered tag, for example `[EMAIL_2]`. The same value always gets the same
        /// number, and ``RedactedText/restoringOriginals(in:)`` can put the values back.
        case placeholder
        /// The character repeated once per character of the match, for example `•••••`.
        case mask(Character)
    }

    /// The kinds of data to look for.
    public let kinds: Set<PersonalDataKind>
    /// How matches are replaced.
    public let replacement: Replacement

    /// When two matches overlap, the longer one wins; for equal lengths, the earlier kind here.
    private static let priority: [PersonalDataKind] = [
        .paymentCardNumber, .iban, .emailAddress, .ipAddress, .phoneNumber, .link, .postalAddress, .personName
    ]
    private static let minimumPhoneDigits = 7

    public init(kinds: Set<PersonalDataKind> = Set(PersonalDataKind.allCases), replacement: Replacement = .placeholder) {
        self.kinds = kinds
        self.replacement = replacement
    }

    /// The personal data in `text`, in order of appearance, without overlaps.
    public func matches(in text: String) -> [PersonalDataMatch] {
        var candidates = PatternScanner.matches(in: text, kinds: kinds) + detectorMatches(in: text)
        if kinds.contains(.personName) {
            candidates += nameMatches(in: text)
        }
        return Self.withoutOverlaps(candidates)
    }

    /// `text` with every match replaced according to ``replacement``.
    public func redact(_ text: String) -> RedactedText {
        let matches = matches(in: text)
        var output = ""
        var cursor = text.startIndex
        var numbers: [PersonalDataKind: [String: Int]] = [:]
        var originals: [String: String] = [:]
        for match in matches {
            output += text[cursor..<match.range.lowerBound]
            switch replacement {
            case .tag:
                output += "[\(match.kind.tag)]"
            case .mask(let character):
                output += String(repeating: character, count: match.value.count)
            case .placeholder:
                let seen = numbers[match.kind, default: [:]]
                let number = seen[match.value] ?? seen.count + 1
                numbers[match.kind, default: [:]][match.value] = number
                let placeholder = "[\(match.kind.tag)_\(number)]"
                originals[placeholder] = match.value
                output += placeholder
            }
            cursor = match.range.upperBound
        }
        output += text[cursor...]
        return RedactedText(text: output, matches: matches, originals: originals)
    }

    private func detectorMatches(in text: String) -> [PersonalDataMatch] {
        var types: NSTextCheckingResult.CheckingType = []
        if kinds.contains(.phoneNumber) { types.insert(.phoneNumber) }
        if kinds.contains(.link) { types.insert(.link) }
        if kinds.contains(.postalAddress) { types.insert(.address) }
        guard !types.isEmpty, let detector = try? NSDataDetector(types: types.rawValue) else { return [] }
        let all = NSRange(text.startIndex..<text.endIndex, in: text)
        return detector.matches(in: text, range: all).compactMap { result in
            guard let range = Range(result.range, in: text) else { return nil }
            let value = String(text[range])
            switch result.resultType {
            case .phoneNumber where value.filter(\.isNumber).count >= Self.minimumPhoneDigits:
                return PersonalDataMatch(kind: .phoneNumber, value: value, range: range)
            case .link where result.url?.scheme?.lowercased() != "mailto":
                return PersonalDataMatch(kind: .link, value: value, range: range)
            case .address:
                return PersonalDataMatch(kind: .postalAddress, value: value, range: range)
            default:
                return nil
            }
        }
    }

    private func nameMatches(in text: String) -> [PersonalDataMatch] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        var matches: [PersonalDataMatch] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, range in
            if tag == .personalName {
                matches.append(PersonalDataMatch(kind: .personName, value: String(text[range]), range: range))
            }
            return true
        }
        return matches
    }

    /// Keeps the longest of overlapping matches (ties go to the kind earlier in `priority`)
    /// and returns the result in text order.
    static func withoutOverlaps(_ candidates: [PersonalDataMatch]) -> [PersonalDataMatch] {
        let ranked = candidates.sorted { lhs, rhs in
            let (left, right) = (lhs.value.count, rhs.value.count)
            if left != right { return left > right }
            let (leftRank, rightRank) = (priority.firstIndex(of: lhs.kind)!, priority.firstIndex(of: rhs.kind)!)
            if leftRank != rightRank { return leftRank < rightRank }
            return lhs.range.lowerBound < rhs.range.lowerBound
        }
        var kept: [PersonalDataMatch] = []
        for candidate in ranked where !kept.contains(where: { $0.range.overlaps(candidate.range) }) {
            kept.append(candidate)
        }
        return kept.sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
}

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
/// Matching looks through the usual variations of a value:
///
/// - Full-width and other compatibility characters ("４１１１", "ｊａｎｅ＠…") are compared by
///   their NFKC form.
/// - Invisible format characters inside a value (zero-width space, soft hyphen, direction
///   marks) are ignored, and the replacement covers them.
/// - Card numbers may be grouped with spaces, hyphens, typographic dashes, dots, slashes or
///   underscores, or broken over two lines; IBANs with spaces, hyphens or dots, in any case.
/// - Overlapping matches are merged, so no part of any of them stays in the text.
///
/// It does not find data that is spelled out ("jane at example dot com", "four one one one")
/// or split by ordinary words, nor numbers that fail their check digits.
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
    ///
    /// Patterns and the data detector look at a folded copy of the text (see the type's
    /// overview), and the name tagger at a copy without invisible format characters; every
    /// match is reported with the value and range of the original text.
    public func matches(in text: String) -> [PersonalDataMatch] {
        let folded = FoldedText(text, strength: .full)
        var candidates = PatternScanner.matches(in: folded, kinds: kinds) + detectorMatches(in: folded)
        if kinds.contains(.personName) {
            candidates += nameMatches(in: FoldedText(text, strength: .compatibility))
        }
        return Self.merged(candidates, in: text)
    }

    /// `text` with every match replaced according to ``replacement``.
    public func redact(_ text: String) -> RedactedText {
        let matches = matches(in: text)
        var output = ""
        var cursor = text.startIndex
        var numbering = PlaceholderNumbering(reserving: text)
        var originals: [String: String] = [:]
        for match in matches {
            output += text[cursor..<match.range.lowerBound]
            switch replacement {
            case .tag:
                output += "[\(match.kind.tag)]"
            case .mask(let character):
                output += String(repeating: character, count: match.value.count)
            case .placeholder:
                let placeholder = numbering.placeholder(for: match)
                originals[placeholder] = match.value
                output += placeholder
            }
            cursor = match.range.upperBound
        }
        output += text[cursor...]
        return RedactedText(text: output, matches: matches, originals: originals)
    }

    private func detectorMatches(in folded: FoldedText) -> [PersonalDataMatch] {
        var types: NSTextCheckingResult.CheckingType = []
        if kinds.contains(.phoneNumber) { types.insert(.phoneNumber) }
        if kinds.contains(.link) { types.insert(.link) }
        if kinds.contains(.postalAddress) { types.insert(.address) }
        guard !types.isEmpty, let detector = try? NSDataDetector(types: types.rawValue) else { return [] }
        let text = folded.text as NSString
        return detector.matches(in: folded.text, range: NSRange(location: 0, length: text.length)).compactMap { result in
            let value = text.substring(with: result.range)
            switch result.resultType {
            case .phoneNumber where value.filter(\.isNumber).count >= Self.minimumPhoneDigits:
                return folded.match(.phoneNumber, at: result.range)
            case .link where result.url?.scheme?.lowercased() != "mailto":
                return folded.match(.link, at: result.range)
            case .address:
                return folded.match(.postalAddress, at: result.range)
            default:
                return nil
            }
        }
    }

    private func nameMatches(in folded: FoldedText) -> [PersonalDataMatch] {
        let text = folded.text
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        var matches: [PersonalDataMatch] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, range in
            if tag == .personalName, let match = folded.match(.personName, at: NSRange(range, in: text)) {
                matches.append(match)
            }
            return true
        }
        return matches
    }

    /// Merges overlapping matches into one match that covers all of them, so no part of any
    /// match stays visible. The merged match takes the kind of its longest part (ties go to
    /// the kind earlier in `priority`). The result is in text order.
    static func merged(_ candidates: [PersonalDataMatch], in text: String) -> [PersonalDataMatch] {
        let sorted = candidates.sorted { $0.range.lowerBound < $1.range.lowerBound }
        var groups: [[PersonalDataMatch]] = []
        var groupEnd = text.startIndex
        for candidate in sorted {
            if let last = groups.indices.last, candidate.range.lowerBound < groupEnd {
                groups[last].append(candidate)
                groupEnd = max(groupEnd, candidate.range.upperBound)
            } else {
                groups.append([candidate])
                groupEnd = candidate.range.upperBound
            }
        }
        return groups.map { group in
            let range = group.map(\.range.lowerBound).min()!..<group.map(\.range.upperBound).max()!
            let kind = group.min(by: ranksHigher)!.kind
            return PersonalDataMatch(kind: kind, value: String(text[range]), range: range)
        }
    }

    private static func ranksHigher(_ lhs: PersonalDataMatch, _ rhs: PersonalDataMatch) -> Bool {
        let (left, right) = (lhs.value.count, rhs.value.count)
        if left != right { return left > right }
        return priority.firstIndex(of: lhs.kind)! < priority.firstIndex(of: rhs.kind)!
    }
}

/// Numbers placeholders per kind. The same value always gets the same number, and numbers
/// whose placeholder already appears in the input are skipped, so that restoring a model's
/// answer cannot turn text the user wrote, such as "[EMAIL_1]", into someone's address.
private struct PlaceholderNumbering {
    private var assigned: [PersonalDataKind: [String: Int]] = [:]
    private var next: [PersonalDataKind: Int] = [:]
    private let reserved: Set<String>

    init(reserving text: String) {
        reserved = Set(RedactedText.placeholderPattern.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
            .map { (text as NSString).substring(with: $0.range) })
    }

    mutating func placeholder(for match: PersonalDataMatch) -> String {
        if let number = assigned[match.kind]?[match.value] {
            return Self.placeholder(match.kind, number)
        }
        var number = next[match.kind, default: 1]
        while reserved.contains(Self.placeholder(match.kind, number)) { number += 1 }
        next[match.kind] = number + 1
        assigned[match.kind, default: [:]][match.value] = number
        return Self.placeholder(match.kind, number)
    }

    private static func placeholder(_ kind: PersonalDataKind, _ number: Int) -> String {
        "[\(kind.tag)_\(number)]"
    }
}

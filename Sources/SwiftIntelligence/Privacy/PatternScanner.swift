import Foundation

/// The regular-expression half of ``PersonalDataRedactor``: email addresses, card numbers,
/// IBANs and IP addresses, each candidate confirmed by a validity check.
enum PatternScanner {
    private static let email = pattern(#"[A-Z0-9._%+-]+@[A-Z0-9-]+(?:\.[A-Z0-9-]+)*\.[A-Z]{2,}"#)
    /// 13 to 19 digits, optionally grouped with single spaces or hyphens.
    private static let cardNumber = pattern(#"(?<!\d)\d(?:[ -]?\d){12,18}(?!\d)"#)
    /// A country code, two check digits and up to 30 letters or digits, optionally in groups.
    private static let iban = pattern(#"\b[A-Z]{2}\d{2}(?: ?[A-Z0-9]){11,30}\b"#)
    private static let ipv4 = pattern(#"(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?!\d|\.\d)"#)
    private static let ipv6 = pattern(#"(?<![0-9A-F:])(?:[0-9A-F]{0,4}:){2,7}[0-9A-F]{0,4}(?![0-9A-F:])"#)

    static func matches(in text: String, kinds: Set<PersonalDataKind>) -> [PersonalDataMatch] {
        var matches: [PersonalDataMatch] = []
        if kinds.contains(.emailAddress) {
            matches += scan(email, in: text, kind: .emailAddress) { _ in true }
        }
        if kinds.contains(.paymentCardNumber) {
            matches += scan(cardNumber, in: text, kind: .paymentCardNumber) { value in
                Checksums.passesLuhn(value.compactMap(\.wholeNumberValue))
            }
        }
        if kinds.contains(.iban) {
            matches += ibanMatches(in: text)
        }
        if kinds.contains(.ipAddress) {
            matches += scan(ipv4, in: text, kind: .ipAddress) { isAddress($0, family: AF_INET) }
            matches += scan(ipv6, in: text, kind: .ipAddress) { isAddress($0, family: AF_INET6) }
        }
        return matches
    }

    /// The pattern can run past the end of an IBAN into a following code or word ("… 3000 IS
    /// DUE"), so each candidate is shortened group by group until the check digits match.
    private static func ibanMatches(in text: String) -> [PersonalDataMatch] {
        candidates(iban, in: text).compactMap { range in
            var end = range.upperBound
            while end > range.lowerBound {
                let compact = text[range.lowerBound..<end].filter { $0 != " " }
                if Checksums.passesIBAN(compact) {
                    return PersonalDataMatch(kind: .iban, value: String(text[range.lowerBound..<end]), range: range.lowerBound..<end)
                }
                guard let space = text[range.lowerBound..<end].lastIndex(of: " ") else { return nil }
                end = space
            }
            return nil
        }
    }

    private static func scan(
        _ expression: NSRegularExpression,
        in text: String,
        kind: PersonalDataKind,
        isValid: (String) -> Bool
    ) -> [PersonalDataMatch] {
        candidates(expression, in: text).compactMap { range in
            let value = String(text[range])
            return isValid(value) ? PersonalDataMatch(kind: kind, value: value, range: range) : nil
        }
    }

    private static func candidates(_ expression: NSRegularExpression, in text: String) -> [Range<String.Index>] {
        let all = NSRange(text.startIndex..<text.endIndex, in: text)
        return expression.matches(in: text, range: all).compactMap { Range($0.range, in: text) }
    }

    private static func isAddress(_ value: String, family: Int32) -> Bool {
        var buffer = in6_addr()
        return value.withCString { inet_pton(family, $0, &buffer) } == 1
    }

    private static func pattern(_ source: String) -> NSRegularExpression {
        // The patterns are constants; a typo is a programming error caught by the tests.
        try! NSRegularExpression(pattern: source, options: [.caseInsensitive])
    }
}

import Foundation

/// The regular-expression half of ``PersonalDataRedactor``: email addresses, card numbers,
/// IBANs and IP addresses, each candidate confirmed by a validity check.
///
/// The patterns run on a ``FoldedText`` and every quantifier is bounded, so the time per input
/// character is bounded too, whatever the text looks like.
enum PatternScanner {
    /// The part of an email address after the "@", with RFC 5321 label limits.
    private static let emailDomain = pattern(#"@[\p{L}\p{N}\-]{1,63}(?:\.[\p{L}\p{N}\-]{1,63}){0,8}\.\p{L}{2,63}"#)
    /// RFC 5321 allows 64 characters before the "@".
    private static let maximumLocalPartLength = 64
    private static let localPartCharacters = CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "._%+-"))
    /// Up to three spaces, tabs, hyphens, dots, slashes or underscores, or one line break with
    /// up to three spaces or tabs on each side. Shared by card numbers and IBANs, so a value
    /// cannot hide behind a separator that only one of the two patterns knows.
    private static let groupSeparator = #"(?:[ \t\-./_]{1,3}|[ \t]{0,3}\R[ \t]{0,3})"#
    /// Digit groups joined by a group separator. Card numbers are looked for inside each run.
    private static let digitRun = pattern(#"(?<!\d)\d{1,19}(?:"# + groupSeparator + #"\d{1,19}){0,18}(?!\d)"#)
    private static let digitGroup = pattern(#"\d+"#)
    /// A country code, two check digits and up to 30 letters or digits, optionally in groups.
    private static let iban = pattern(#"\b[A-Z]{2}[0-9]{2}(?:"# + groupSeparator + #"?[A-Z0-9]){11,30}"#)
    private static let ipv4 = pattern(#"(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?!\d|\.\d)"#)
    private static let ipv6 = pattern(#"(?<![0-9A-F:])(?:[0-9A-F]{0,4}:){2,7}[0-9A-F]{0,4}(?![0-9A-F:])"#)

    private static let cardDigits = 13...19

    static func matches(in folded: FoldedText, kinds: Set<PersonalDataKind>) -> [PersonalDataMatch] {
        var found: [(PersonalDataKind, NSRange)] = []
        if kinds.contains(.emailAddress) {
            found += emailAddresses(in: folded.text).map { (.emailAddress, $0) }
        }
        if kinds.contains(.paymentCardNumber) {
            found += cardNumbers(in: folded.text).map { (.paymentCardNumber, $0) }
        }
        if kinds.contains(.iban) {
            found += ibans(in: folded.text).map { (.iban, $0) }
        }
        if kinds.contains(.ipAddress) {
            let addresses = candidates(ipv4, in: folded.text).filter { isAddress($0, in: folded.text, family: AF_INET) }
                + candidates(ipv6, in: folded.text).filter { isAddress($0, in: folded.text, family: AF_INET6) }
            found += addresses.map { (.ipAddress, $0) }
        }
        return found.compactMap { kind, range in folded.match(kind, at: range) }
    }

    /// Starts from each "@" instead of from every character, so text without addresses is
    /// read once: the domain is matched forward from the "@", the local part read backward.
    static func emailAddresses(in text: String) -> [NSRange] {
        let string = text as NSString
        var ranges: [NSRange] = []
        var searchStart = 0
        while searchStart < string.length {
            let at = string.range(of: "@", range: NSRange(location: searchStart, length: string.length - searchStart))
            guard at.location != NSNotFound else { break }
            searchStart = at.location + 1
            let domain = emailDomain.firstMatch(in: text, options: .anchored, range: NSRange(location: at.location, length: string.length - at.location))
            guard let domain else { continue }
            var start = at.location
            let earliest = max(ranges.last.map { $0.location + $0.length } ?? 0, at.location - maximumLocalPartLength)
            while start > earliest, let scalar = Unicode.Scalar(string.character(at: start - 1)), localPartCharacters.contains(scalar) {
                start -= 1
            }
            guard start < at.location else { continue }
            ranges.append(NSRange(location: start, length: domain.range.location + domain.range.length - start))
            searchStart = domain.range.location + domain.range.length
        }
        return ranges
    }

    /// Within each run of digit groups, the longest run of whole groups that has 13 to 19
    /// digits and passes the Luhn check, scanning from the left. Whole groups only, so "Order 12
    /// 4111 1111 1111 1111" finds the card after the order number.
    static func cardNumbers(in text: String) -> [NSRange] {
        let string = text as NSString
        var ranges: [NSRange] = []
        for run in candidates(digitRun, in: text) {
            let groups = digitGroup.matches(in: text, range: run).map { group in
                (range: group.range, digits: string.substring(with: group.range).compactMap(\.wholeNumberValue))
            }
            var first = 0
            while first < groups.count {
                var digits: [Int] = []
                var bestLast: Int?
                for last in first..<groups.count {
                    digits += groups[last].digits
                    if digits.count > cardDigits.upperBound { break }
                    if cardDigits.contains(digits.count), Checksums.passesLuhn(digits) { bestLast = last }
                }
                guard let last = bestLast else {
                    first += 1
                    continue
                }
                ranges.append(NSUnionRange(groups[first].range, groups[last].range))
                first = last + 1
            }
        }
        return ranges
    }

    /// A candidate can run past its IBAN into the next one ("DE89 … 00 / GB82 …"), so the
    /// search continues after the valid part of each candidate, or one character after the
    /// start of an invalid one, instead of after the whole candidate.
    static func ibans(in text: String) -> [NSRange] {
        // Bridged once: passing a native String to every firstMatch call would copy it each time.
        let string = NSString(string: text)
        let bridged = string as String
        var ranges: [NSRange] = []
        var searchStart = 0
        while searchStart < string.length,
              let candidate = iban.firstMatch(in: bridged, range: NSRange(location: searchStart, length: string.length - searchStart))?.range {
            if let valid = validIBAN(in: candidate, of: bridged) {
                ranges.append(valid)
                searchStart = valid.location + valid.length
            } else {
                searchStart = candidate.location + 1
            }
        }
        return ranges
    }

    /// The pattern can run past the end of an IBAN into a following code or word ("… 3000 IS
    /// DUE", "…3000REF"), so the candidate is cut to the IBAN length of its country. For a
    /// country missing from the table it is cut to the longest length whose check digits match,
    /// found in one mod-97 pass over the candidate.
    private static func validIBAN(in range: NSRange, of text: String) -> NSRange? {
        let candidate = (text as NSString).substring(with: range)
        // UTF-16 end offset after each letter or digit.
        var ends: [Int] = []
        var characters: [Character] = []
        var offset = 0
        for character in candidate {
            offset += character.utf16.count
            if character.isLetter || character.isNumber {
                characters.append(character)
                ends.append(offset)
            }
        }
        let country = String(characters.prefix(2)).uppercased()
        let passing = Checksums.passingIBANLengths(characters)
        let length: Int?
        if let expected = Checksums.ibanLengths[country] {
            length = passing.contains(expected) ? expected : nil
        } else {
            length = passing.last
        }
        return length.map { NSRange(location: range.location, length: ends[$0 - 1]) }
    }

    private static func candidates(_ expression: NSRegularExpression, in text: String) -> [NSRange] {
        expression.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length)).map(\.range)
    }

    private static func isAddress(_ range: NSRange, in text: String, family: Int32) -> Bool {
        var buffer = in6_addr()
        return (text as NSString).substring(with: range).withCString { inet_pton(family, $0, &buffer) } == 1
    }

    private static func pattern(_ source: String) -> NSRegularExpression {
        // The patterns are constants; a typo is a programming error caught by the tests.
        try! NSRegularExpression(pattern: source, options: [.caseInsensitive])
    }
}

extension FoldedText {
    /// A match at `range` of the folded text, with the value and range of the original text.
    func match(_ kind: PersonalDataKind, at range: NSRange) -> PersonalDataMatch? {
        originalRange(of: range).map { PersonalDataMatch(kind: kind, value: String(originalText[$0]), range: $0) }
    }
}

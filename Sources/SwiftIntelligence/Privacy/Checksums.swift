import Foundation

/// Check-digit tests that tell real card and account numbers from other long digit runs, such
/// as order numbers, so they are redacted without masking every number in a text.
enum Checksums {
    /// The Luhn (mod 10) check used by payment card numbers.
    static func passesLuhn(_ digits: [Int]) -> Bool {
        guard !digits.isEmpty else { return false }
        var sum = 0
        for (offset, digit) in digits.reversed().enumerated() {
            if offset.isMultiple(of: 2) {
                sum += digit
            } else {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            }
        }
        return sum.isMultiple(of: 10)
    }

    /// The ISO 13616 mod-97 check of an IBAN, given without spaces.
    ///
    /// The first four characters move to the end, letters become numbers (A = 10 … Z = 35),
    /// and the result must leave a remainder of 1 when divided by 97.
    static func passesIBAN(_ iban: String) -> Bool {
        let characters = Array(iban)
        return (15...34).contains(characters.count) && passingIBANLengths(characters).last == characters.count
    }

    /// The lengths from 15 to 34 at which the start of `characters` passes ``passesIBAN(_:)``,
    /// in one pass instead of one full check per length.
    ///
    /// The remainder of "rest + first four" is the remainder of "rest", shifted left by the
    /// decimal length of the first four characters, plus the remainder of the first four.
    static func passingIBANLengths(_ characters: [Character]) -> [Int] {
        guard characters.count >= 4,
              characters.prefix(2).allSatisfy({ $0.isASCII && $0.isLetter }),
              characters.dropFirst(2).prefix(2).allSatisfy({ $0.isASCII && $0.isNumber }) else {
            return []
        }
        var headRemainder = 0
        var headShift = 1
        for character in characters.prefix(4) {
            guard let value = ibanValue(character) else { return [] }
            let shift = value >= 10 ? 100 : 10
            headRemainder = (headRemainder * shift + value) % 97
            headShift = headShift * shift % 97
        }
        var lengths: [Int] = []
        var remainder = 0
        for (offset, character) in characters.enumerated().dropFirst(4).prefix(30) {
            guard let value = ibanValue(character) else { break }
            remainder = (remainder * (value >= 10 ? 100 : 10) + value) % 97
            if offset + 1 >= 15, (remainder * headShift + headRemainder) % 97 == 1 {
                lengths.append(offset + 1)
            }
        }
        return lengths
    }

    /// The IBAN length of each country in the ISO 13616 registry.
    static let ibanLengths: [String: Int] = [
        "AD": 24, "AE": 23, "AL": 28, "AT": 20, "AZ": 28, "BA": 20, "BE": 16, "BG": 22, "BH": 22,
        "BI": 27, "BR": 29, "BY": 28, "CH": 21, "CR": 22, "CY": 28, "CZ": 24, "DE": 22, "DJ": 27,
        "DK": 18, "DO": 28, "EE": 20, "EG": 29, "ES": 24, "FI": 18, "FK": 18, "FO": 18, "FR": 27,
        "GB": 22, "GE": 22, "GI": 23, "GL": 18, "GR": 27, "GT": 28, "HN": 28, "HR": 21, "HU": 28,
        "IE": 22, "IL": 23, "IQ": 23, "IS": 26, "IT": 27, "JO": 30, "KW": 30, "KZ": 20, "LB": 28,
        "LC": 32, "LI": 21, "LT": 20, "LU": 20, "LV": 21, "LY": 25, "MC": 27, "MD": 24, "ME": 22,
        "MK": 19, "MN": 20, "MR": 27, "MT": 31, "MU": 30, "NI": 28, "NL": 18, "NO": 15, "OM": 23,
        "PK": 24, "PL": 28, "PS": 29, "PT": 25, "QA": 29, "RO": 24, "RS": 22, "RU": 33, "SA": 24,
        "SC": 31, "SD": 18, "SE": 24, "SI": 19, "SK": 24, "SM": 27, "SO": 23, "ST": 25, "SV": 28,
        "TL": 23, "TN": 24, "TR": 26, "UA": 29, "VA": 22, "VG": 24, "XK": 20, "YE": 30,
    ]

    /// 0–9 for digits and A = 10 … Z = 35 for ASCII letters in either case.
    private static func ibanValue(_ character: Character) -> Int? {
        guard let ascii = character.asciiValue else { return nil }
        switch ascii {
        case UInt8(ascii: "0")...UInt8(ascii: "9"): return Int(ascii - UInt8(ascii: "0"))
        case UInt8(ascii: "A")...UInt8(ascii: "Z"): return Int(ascii - UInt8(ascii: "A")) + 10
        case UInt8(ascii: "a")...UInt8(ascii: "z"): return Int(ascii - UInt8(ascii: "a")) + 10
        default: return nil
        }
    }
}

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
        let characters = Array(iban.uppercased())
        guard (15...34).contains(characters.count),
              characters.prefix(2).allSatisfy({ $0.isASCII && $0.isLetter }),
              characters.dropFirst(2).prefix(2).allSatisfy({ $0.isASCII && $0.isNumber }) else {
            return false
        }
        var remainder = 0
        for character in characters.dropFirst(4) + characters.prefix(4) {
            guard character.isASCII, let value = character.hexDigitValue ?? letterValue(character) else { return false }
            remainder = (remainder * (value >= 10 ? 100 : 10) + value) % 97
        }
        return remainder == 1
    }

    /// A = 10 … Z = 35. `hexDigitValue` already covers A–F.
    private static func letterValue(_ character: Character) -> Int? {
        guard let ascii = character.asciiValue, (UInt8(ascii: "A")...UInt8(ascii: "Z")).contains(ascii) else { return nil }
        return Int(ascii - UInt8(ascii: "A")) + 10
    }
}

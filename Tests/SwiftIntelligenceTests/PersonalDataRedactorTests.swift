import Testing
@testable import SwiftIntelligence

@Suite("PersonalDataRedactor")
struct PersonalDataRedactorTests {
    let redactor = PersonalDataRedactor()

    private func kinds(in text: String, only kinds: Set<PersonalDataKind>? = nil) -> [PersonalDataKind] {
        let redactor = kinds.map { PersonalDataRedactor(kinds: $0) } ?? redactor
        return redactor.matches(in: text).map(\.kind)
    }

    @Test("finds email addresses")
    func email() {
        let matches = redactor.matches(in: "Write to jane.doe+news@mail.example.co.uk today.")
        #expect(matches.map(\.value) == ["jane.doe+news@mail.example.co.uk"])
        #expect(matches.map(\.kind) == [.emailAddress])
    }

    @Test("accepts card numbers that pass the Luhn check", arguments: [
        "4111 1111 1111 1111",
        "4111-1111-1111-1111",
        "5500000000000004",
        "378282246310005",
    ])
    func validCard(number: String) {
        let matches = PersonalDataRedactor(kinds: [.paymentCardNumber]).matches(in: "Card: \(number).")
        #expect(matches.map(\.value) == [number])
    }

    @Test("ignores long numbers that fail the Luhn check")
    func invalidCard() {
        #expect(kinds(in: "Order 4111 1111 1111 1112 shipped.", only: [.paymentCardNumber]).isEmpty)
        #expect(kinds(in: "Tracking 1234567890123", only: [.paymentCardNumber]).isEmpty)
    }

    @Test("accepts IBANs with valid check digits, grouped or not", arguments: [
        "DE89 3704 0044 0532 0130 00",
        "GB82WEST12345698765432",
        "TR33 0006 1005 1978 6457 8413 26",
    ])
    func validIBAN(iban: String) {
        let matches = PersonalDataRedactor(kinds: [.iban]).matches(in: "Pay to \(iban) by Friday.")
        #expect(matches.map(\.value) == [iban])
    }

    @Test("stops an IBAN where the check digits match, before a following code")
    func ibanFollowedByCode() {
        let matches = PersonalDataRedactor(kinds: [.iban]).matches(in: "IBAN DE89 3704 0044 0532 0130 00 REF2024")
        #expect(matches.map(\.value) == ["DE89 3704 0044 0532 0130 00"])
    }

    @Test("ignores IBAN-shaped text with wrong check digits")
    func invalidIBAN() {
        #expect(kinds(in: "DE00 3704 0044 0532 0130 00", only: [.iban]).isEmpty)
    }

    @Test("finds valid IPv4 and IPv6 addresses only")
    func ipAddresses() {
        let text = "Hosts 192.168.1.20 and 2001:db8::8a2e:370:7334 answered; 999.1.1.1 and version 1.2.3 did not."
        let values = PersonalDataRedactor(kinds: [.ipAddress]).matches(in: text).map(\.value)
        #expect(values == ["192.168.1.20", "2001:db8::8a2e:370:7334"])
    }

    @Test("finds an IPv4 address at the end of a sentence")
    func ipAtSentenceEnd() {
        let values = PersonalDataRedactor(kinds: [.ipAddress]).matches(in: "The server is 10.0.0.1.").map(\.value)
        #expect(values == ["10.0.0.1"])
    }

    @Test("finds phone numbers and links, but not a mailto link")
    func detector() {
        let text = "Call +1 (415) 555-0132 or open https://example.com/help. Mail support@example.com."
        let matches = redactor.matches(in: text)
        #expect(matches.contains { $0.kind == .phoneNumber && $0.value.contains("555-0132") })
        #expect(matches.contains { $0.kind == .link && $0.value == "https://example.com/help" })
        #expect(matches.filter { $0.value.contains("support@") }.map(\.kind) == [.emailAddress])
    }

    @Test("does not treat a short number as a phone number")
    func shortNumber() {
        #expect(kinds(in: "Room 4512 on floor 3.", only: [.phoneNumber]).isEmpty)
    }

    @Test("finds people's names")
    func names() {
        let values = PersonalDataRedactor(kinds: [.personName]).matches(in: "Yesterday Maria Garcia met John Smith.").map(\.value)
        #expect(values == ["Maria Garcia", "John Smith"])
    }

    @Test("only looks for the requested kinds")
    func requestedKinds() {
        let text = "jane@example.com, 4111 1111 1111 1111"
        #expect(kinds(in: text, only: [.emailAddress]) == [.emailAddress])
        #expect(kinds(in: text, only: []).isEmpty)
    }

    @Test("numbers placeholders per kind and reuses them for repeated values")
    func placeholders() {
        let result = redactor.redact("a@example.com wrote to b@example.com, then a@example.com again.")
        #expect(result.text == "[EMAIL_1] wrote to [EMAIL_2], then [EMAIL_1] again.")
        #expect(result.originals == ["[EMAIL_1]": "a@example.com", "[EMAIL_2]": "b@example.com"])
        #expect(result.matches.count == 3)
    }

    @Test("puts original values back into a text that quotes placeholders")
    func restore() {
        let result = redactor.redact("Contact a@example.com about card 4111 1111 1111 1111.")
        let answer = "Ask [EMAIL_1]; the card [CARD_1] is on file."
        #expect(result.restoringOriginals(in: answer) == "Ask a@example.com; the card 4111 1111 1111 1111 is on file.")
    }

    @Test("writes tags or masks without keeping originals")
    func otherReplacements() {
        let text = "Mail a@example.com now"
        let tagged = PersonalDataRedactor(kinds: [.emailAddress], replacement: .tag).redact(text)
        #expect(tagged.text == "Mail [EMAIL] now")
        #expect(tagged.originals.isEmpty)
        let masked = PersonalDataRedactor(kinds: [.emailAddress], replacement: .mask("•")).redact(text)
        #expect(masked.text == "Mail ••••••••••••• now")
    }

    @Test("leaves text without personal data unchanged")
    func nothingFound() {
        let text = "The meeting moved to the large room on the third floor."
        let result = redactor.redact(text)
        #expect(result.text == text)
        #expect(result.matches.isEmpty)
    }

    @Test("merges a match inside a longer one into the longer one")
    func overlaps() {
        let text = "x 4111 1111 1111 1111 y"
        let card = text.range(of: "4111 1111 1111 1111")!
        let part = text.range(of: "4111 1111")!
        let kept = PersonalDataRedactor.merged([
            PersonalDataMatch(kind: .phoneNumber, value: "4111 1111", range: part),
            PersonalDataMatch(kind: .paymentCardNumber, value: "4111 1111 1111 1111", range: card),
        ], in: text)
        #expect(kept.map(\.kind) == [.paymentCardNumber])
    }

    @Test("prefers the higher-priority kind for equal ranges")
    func priorityTie() {
        let text = "4111111111111111"
        let range = text.startIndex..<text.endIndex
        let kept = PersonalDataRedactor.merged([
            PersonalDataMatch(kind: .phoneNumber, value: text, range: range),
            PersonalDataMatch(kind: .paymentCardNumber, value: text, range: range),
        ], in: text)
        #expect(kept.map(\.kind) == [.paymentCardNumber])
    }
}

@Suite("Checksums")
struct ChecksumTests {
    @Test("Luhn accepts valid and rejects altered numbers")
    func luhn() {
        #expect(Checksums.passesLuhn([7, 9, 9, 2, 7, 3, 9, 8, 7, 1, 3]))
        #expect(!Checksums.passesLuhn([7, 9, 9, 2, 7, 3, 9, 8, 7, 1, 4]))
        #expect(!Checksums.passesLuhn([]))
    }

    @Test("IBAN mod-97 accepts valid and rejects malformed input", arguments: [
        ("GB82WEST12345698765432", true),
        ("gb82west12345698765432", true),
        ("GB82WEST12345698765433", false),
        ("GB82", false),
        ("1282WEST12345698765432", false),
        ("GB8XWEST12345698765432", false),
        ("GB82WEST1234569876543!", false),
    ])
    func iban(value: String, valid: Bool) {
        #expect(Checksums.passesIBAN(value) == valid)
    }
}

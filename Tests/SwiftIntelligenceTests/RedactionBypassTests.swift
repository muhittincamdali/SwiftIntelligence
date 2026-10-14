import Foundation
import Testing
@testable import SwiftIntelligence

/// Variations of personal data that must still be redacted, and look-alikes that must not be.
@Suite("Redaction bypass")
struct RedactionBypassTests {
    private func redacted(_ text: String, kinds: Set<PersonalDataKind>) -> String {
        PersonalDataRedactor(kinds: kinds, replacement: .tag).redact(text).text
    }

    @Test("finds card numbers written with other digits, separators and line breaks", arguments: [
        "４１１１ １１１１ １１１１ １１１１",          // full-width digits and spaces
        "4111\u{00A0}1111\u{00A0}1111\u{00A0}1111",   // no-break spaces
        "4111\u{2009}1111\u{202F}1111\u{2007}1111",   // thin, narrow and figure spaces
        "4111–1111—1111‑1111",                        // en dash, em dash, non-breaking hyphen
        "4111\u{2212}1111\u{2212}1111\u{2212}1111",   // minus sign
        "4111.1111.1111.1111",
        "4111/1111/1111/1111",
        "4111_1111_1111_1111",
        "4111  1111  1111  1111",
        "4111 1111\n1111 1111",
        "4111 1111\r\n  1111 1111",
        "4\u{200B}1\u{200B}1\u{200B}1111111111111",   // zero-width spaces
        "4111\u{00AD}1111\u{00AD}1111\u{00AD}1111",   // soft hyphens
        "\u{202E}4111\u{202C}111111111111",           // direction controls
        "٤١١١١١١١١١١١١١١١",                           // Arabic-Indic digits
    ])
    func cardVariants(card: String) {
        // A format character before the first digit is outside the card and may stay.
        let visible = redacted("Card: \(card) thanks", kinds: [.paymentCardNumber])
            .filter { !$0.unicodeScalars.allSatisfy { $0.properties.generalCategory == .format } }
        #expect(visible == "Card: [CARD] thanks")
    }

    @Test("finds a card number after other digit groups")
    func cardAfterDigits() {
        #expect(redacted("Order 12 4111 1111 1111 1111 2025", kinds: [.paymentCardNumber]) == "Order 12 [CARD] 2025")
        #expect(redacted("Ref 7-4111-1111-1111-1111", kinds: [.paymentCardNumber]) == "Ref 7-[CARD]")
    }

    @Test("finds two card numbers in one run of digits")
    func twoCards() {
        let text = "4111 1111 1111 1111 5500 0000 0000 0004"
        #expect(redacted(text, kinds: [.paymentCardNumber]) == "[CARD] [CARD]")
    }

    @Test("leaves numbers that fail the Luhn check readable, whatever the separators")
    func cardLookAlikes() {
        for text in ["4111–1111–1111–1112", "Phone 0212 555 01 23", "2024-01-15", "ISBN 978-3-16-148410-0"] {
            #expect(redacted(text, kinds: [.paymentCardNumber]) == text)
        }
    }

    @Test("finds email addresses in full-width, accented, invisible-character and mixed-case forms", arguments: [
        "ｊａｎｅ＠ｅｘａｍｐｌｅ．ｃｏｍ",
        "jane﹫example.com",
        "JANE.DOE@EXAMPLE.COM",
        "ja\u{200B}ne@exa\u{200D}mple.com",
        "jose\u{0301}@example.com",
        "josé@exämple.com",
        "用户@例子.广告",
        "o'brien@example.com",
        "first/last@example.com",
        "a!b#c$d%e&f*g+h=i?j^k_l`m{n|o}p~q@example.com",
        "\"jane doe\"@example.com",
        "\"jane@home\"@example.com",
        "jane @ example.com",
        "jane\t@\texample.com",
        "jane@example。com",
        "jane@example｡co｡uk",
        "jane\n@example.com",
        "jane@\nexample.com",
        "jane \r\n @example.com",
        "jane@example .com",
        "jane@mail\t.example .com",
        "𠀀𠀁@example.com",
        "ab𠀀cd@example.com",
        "jane@[192.0.2.1]",
        "jane@[IPv6:2001:db8::1]",
    ])
    func emailVariants(email: String) {
        #expect(redacted("Mail \(email) now", kinds: [.emailAddress]) == "Mail [EMAIL] now")
        #expect(PersonalDataRedactor(replacement: .tag).redact("Mail \(email) now").text == "Mail [EMAIL] now")
    }

    @Test("leaves quote marks around an address in the text")
    func emailInQuotes() {
        #expect(redacted("Mail 'jane@example.com' or `bob@example.com`", kinds: [.emailAddress]) == "Mail '[EMAIL]' or `[EMAIL]`")
        #expect(redacted("He said \"hi\" to jane@example.com", kinds: [.emailAddress]) == "He said \"hi\" to [EMAIL]")
    }

    @Test("leaves an at sign without an address readable")
    func emailLookAlikes() {
        for text in ["Meet @ noon.", "5 @ 3.99 each", "@ example.com", "x @    example.com", "x\n\n@example.com", "Ping @team. See you"] {
            #expect(redacted(text, kinds: [.emailAddress]) == text)
        }
    }

    @Test("redacts the end of a local part longer than the RFC limit instead of none of it")
    func longLocalPart() {
        let text = String(repeating: "a", count: 100) + "@example.com"
        let result = redacted(text, kinds: [.emailAddress])
        #expect(!result.contains("@example.com"))
        #expect(result.hasSuffix("[EMAIL]"))
    }

    @Test("finds IBANs in lower case, with other separators and before a code", arguments: [
        "de89 3704 0044 0532 0130 00",
        "DE89-3704-0044-0532-0130-00",
        "DE89.3704.0044.0532.0130.00",
        "ＤＥ８９ ３７０４ ００４４ ０５３２ ０１３０ ００",
        "DE89\u{200B}370400440532013000",
        "DE89 3704 0044\n0532 0130 00",
        "DE89 3704\r\n  0044 0532 0130 00",
        "DE89\t3704\t0044\t0532\t0130\t00",
        "DE89  3704  0044  0532  0130  00",
        "DE89_3704_0044_0532_0130_00",
        "DE89/3704/0044/0532/0130/00",
        "DE89 – 3704 – 0044 – 0532 – 0130 – 00",
        "DE89\u{00A0}3704\u{2009}0044\u{202F}0532\u{2007}0130 00",
    ])
    func ibanVariants(iban: String) {
        #expect(redacted("IBAN: \(iban).", kinds: [.iban]) == "IBAN: [IBAN].")
    }

    @Test("finds IBANs that follow each other, whatever separates them", arguments: [" ", "\n", " / ", "\t", "  "])
    func consecutiveIBANs(separator: String) {
        let text = "DE89 3704 0044 0532 0130 00" + separator + "GB82 WEST 1234 5698 7654 32"
        #expect(redacted(text, kinds: [.iban]) == "[IBAN]" + separator + "[IBAN]")
    }

    @Test("finds an IBAN after a code that looks like the start of one")
    func ibanAfterLookAlike() {
        #expect(redacted("Ref AB12 DE89 3704 0044 0532 0130 00", kinds: [.iban]) == "Ref AB12 [IBAN]")
    }

    @Test("stops an IBAN at the check digits when a code follows without a space")
    func ibanFollowedByLetters() {
        #expect(redacted("Pay DE89370400440532013000REF now", kinds: [.iban]) == "Pay [IBAN]REF now")
    }

    @Test("finds IP addresses written with full-width digits")
    func ipVariants() {
        #expect(redacted("Host １９２．１６８．１．２０ is up", kinds: [.ipAddress]) == "Host [IP] is up")
    }

    @Test("finds phone numbers written with full-width digits")
    func phoneVariants() {
        let result = PersonalDataRedactor(kinds: [.phoneNumber]).matches(in: "Call ＋１ (４１５) ５５５-０１３２ today")
        #expect(result.map(\.kind) == [.phoneNumber])
        #expect(result.first?.value.contains("０１３２") == true)
    }

    @Test("finds a name with an invisible character inside", .enabled(if: SystemModels.hasNameTagger, "needs the NaturalLanguage name model"))
    func nameWithFormatCharacter() {
        let matches = PersonalDataRedactor(kinds: [.personName]).matches(in: "Yesterday Ma\u{200B}ria Garcia met John Smith.")
        #expect(matches.map(\.value) == ["Ma\u{200B}ria Garcia", "John Smith"])
    }

    @Test("reports original values and ranges, not folded ones")
    func originalValues() throws {
        let text = "Mail ｊａｎｅ＠ｅｘａｍｐｌｅ．ｃｏｍ today"
        let match = try #require(PersonalDataRedactor(kinds: [.emailAddress]).matches(in: text).first)
        #expect(match.value == "ｊａｎｅ＠ｅｘａｍｐｌｅ．ｃｏｍ")
        #expect(String(text[match.range]) == match.value)
    }

    @Test("merges partly overlapping matches so neither part stays visible")
    func partialOverlap() {
        let text = "abc 1234 5678 xyz"
        let first = text.range(of: "abc 1234")!
        let second = text.range(of: "1234 5678 xyz")!
        let merged = PersonalDataRedactor.merged([
            PersonalDataMatch(kind: .personName, value: "abc 1234", range: first),
            PersonalDataMatch(kind: .phoneNumber, value: "1234 5678 xyz", range: second),
        ], in: text)
        #expect(merged.count == 1)
        #expect(merged.first?.value == "abc 1234 5678 xyz")
        #expect(merged.first?.kind == .phoneNumber)
    }

    @Test("keeps adjacent matches apart")
    func adjacent() {
        let text = "ab"
        let a = text.startIndex..<text.index(after: text.startIndex)
        let b = text.index(after: text.startIndex)..<text.endIndex
        let merged = PersonalDataRedactor.merged([
            PersonalDataMatch(kind: .emailAddress, value: "b", range: b),
            PersonalDataMatch(kind: .emailAddress, value: "a", range: a),
        ], in: text)
        #expect(merged.map(\.value) == ["a", "b"])
    }

    @Test("numbers placeholders past the ones that already appear in the input")
    func reservedPlaceholders() {
        let result = PersonalDataRedactor(kinds: [.emailAddress]).redact("The tag [EMAIL_1] is literal; mail a@example.com.")
        #expect(result.text == "The tag [EMAIL_1] is literal; mail [EMAIL_2].")
        #expect(result.restoringOriginals(in: "[EMAIL_1] and [EMAIL_2]") == "[EMAIL_1] and a@example.com")
    }

    @Test("does not restore a placeholder twice when a value looks like a placeholder")
    func singlePassRestore() {
        let redacted = RedactedText(text: "", matches: [], originals: ["[NAME_1]": "[EMAIL_1]", "[EMAIL_1]": "secret@example.com"])
        #expect(redacted.restoringOriginals(in: "Hi [NAME_1]") == "Hi [EMAIL_1]")
        #expect(redacted.restoringOriginals(in: "[EMAIL_10] stays") == "[EMAIL_10] stays")
    }

    @Test("masks with one character per original character")
    func maskLength() {
        let text = "Card ４１１１ １１１１ １１１１ １１１１."
        let masked = PersonalDataRedactor(kinds: [.paymentCardNumber], replacement: .mask("*")).redact(text).text
        #expect(masked == "Card " + String(repeating: "*", count: 19) + ".")
    }

    @Test("handles text with no matches, only separators, emoji and combining marks")
    func oddText() {
        for text in ["", " ", "\u{200B}\u{200B}", "👩‍👩‍👧‍👦 🇹🇷", "e\u{0301}\u{0301}\u{0301}", "----", "@@@", "1 2 3"] {
            #expect(PersonalDataRedactor().redact(text).text == text)
        }
    }

    @Test("scans long adversarial text in linear time")
    func longInput() {
        let runs = [
            String(repeating: "a", count: 200_000),
            String(repeating: "1 ", count: 100_000),
            String(repeating: "a.", count: 100_000) + "@",
            String(repeating: "DE89 ", count: 40_000),
            String(repeating: "DE89\n", count: 40_000),
            String(repeating: "AB12 / ", count: 30_000),
            String(repeating: "1:", count: 100_000),
            String(repeating: "a\n@b .", count: 40_000),
        ]
        let redactor = PersonalDataRedactor(kinds: [.emailAddress, .paymentCardNumber, .iban, .ipAddress])
        let clock = ContinuousClock()
        for text in runs {
            let elapsed = clock.measure { _ = redactor.matches(in: text) }
            #expect(elapsed < .seconds(10), "took \(elapsed) for \(text.prefix(8))…")
        }
    }
}

@Suite("FoldedText")
struct FoldedTextTests {
    @Test("folds compatibility forms, marks, dashes, spaces and format characters")
    func folding() {
        #expect(FoldedText("４１\u{200B}–ｅ\u{0301}\u{00A0}x", strength: .full).text == "41-e x")
        #expect(FoldedText("Ma\u{200B}ría", strength: .compatibility).text == "María")
        #expect(FoldedText("plain ascii", strength: .full).text == "plain ascii")
        #expect(FoldedText("a。b｡c", strength: .full).text == "a.b.c")
        #expect(FoldedText("a。b", strength: .compatibility).text == "a。b")
    }

    @Test("maps folded ranges back to whole original characters")
    func mapping() throws {
        let original = "x ４１\u{200B}１ y"
        let folded = FoldedText(original, strength: .full)
        #expect(folded.text == "x 411 y")
        let range = try #require(folded.originalRange(of: NSRange(location: 2, length: 3)))
        #expect(String(original[range]) == "４１\u{200B}１")
        #expect(folded.originalRange(of: NSRange(location: 0, length: 0)) == nil)
    }

    @Test("maps ranges after characters that grow or vanish when folded")
    func mappingAfterExpansion() throws {
        let original = "\u{FDFA} \u{200B}\u{200B}ab"
        let folded = FoldedText(original, strength: .full)
        let start = (folded.text as NSString).range(of: "ab")
        let range = try #require(folded.originalRange(of: start))
        #expect(String(original[range]) == "ab")
    }
}

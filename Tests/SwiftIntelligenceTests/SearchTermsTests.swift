import Testing
@testable import SwiftIntelligence

@Suite("SearchTerms")
struct SearchTermsTests {
    @Test("folds case, diacritics and the Turkish dotless i", arguments: [
        ("Café", "cafe"),
        ("CAFÉ", "cafe"),
        ("İstanbul", "istanbul"),
        ("ıstanbul", "istanbul"),
        ("Straße", "strasse"),
        ("Ｆｕｌｌ", "full"),
    ])
    func normalize(input: String, expected: String) {
        #expect(SearchTerms.normalize(input) == expected)
    }

    @Test("drops punctuation and keeps numbers")
    func terms() {
        #expect(SearchTerms.terms(in: "Hello, World! Order #42 — shipped.") == ["hello", "world", "order", "42", "shipped"])
    }

    @Test("splits text written without spaces")
    func japanese() {
        let terms = SearchTerms.terms(in: "東京は日本の首都です")
        #expect(terms.count > 1)
        #expect(terms.contains("東京"))
    }
}

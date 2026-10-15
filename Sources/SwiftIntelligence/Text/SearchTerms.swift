import Foundation
import NaturalLanguage

/// Turns text into the terms that keyword search and the hashing embedder compare.
///
/// Both sides of a search, the indexed text and the query, go through the same steps, so
/// "Café", "cafe" and "CAFE" match each other.
enum SearchTerms {
    /// Lowercases the text and removes diacritics.
    ///
    /// The Turkish dotless "ı" is also mapped to "i": diacritic folding leaves it alone, and
    /// without it "Istanbul" typed on an English keyboard would not find "ıstanbul".
    static func normalize(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
            .replacingOccurrences(of: "ı", with: "i")
    }

    /// The normalized words of `text`, in order, without punctuation.
    ///
    /// Word boundaries come from `NLTokenizer`, which also splits languages written without
    /// spaces, such as Chinese and Japanese.
    static func terms(in text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var terms: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let term = normalize(String(text[range]))
            if term.unicodeScalars.contains(where: CharacterSet.alphanumerics.contains) {
                terms.append(term)
            }
            return true
        }
        return terms
    }
}

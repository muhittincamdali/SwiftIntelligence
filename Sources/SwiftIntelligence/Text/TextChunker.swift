import Foundation
import NaturalLanguage

/// A passage cut from a longer text.
public struct TextChunk: Hashable, Sendable {
    /// The passage, exactly as it appears in the source text.
    public let text: String
    /// Where the passage is in the source text.
    public let range: Range<String.Index>

    public init(text: String, range: Range<String.Index>) {
        self.text = text
        self.range = range
    }
}

/// Splits long text into passages small enough to embed and to quote in a prompt.
///
/// Passages end at sentence boundaries. Consecutive passages can share sentences
/// (`overlap`), so a fact that spans a boundary is still found by a search. A sentence that
/// is longer than `maximumLength` on its own is split between words, and a single word that
/// is longer still is cut.
///
/// ```swift
/// let chunker = TextChunker(maximumLength: 400, overlap: 1)
/// let passages = chunker.chunks(of: handbook).map(\.text)
/// ```
public struct TextChunker: Hashable, Sendable {
    /// The longest passage, in characters.
    public let maximumLength: Int
    /// How many sentences at the end of a passage are repeated at the start of the next.
    public let overlap: Int

    /// Creates a chunker.
    ///
    /// - Parameters:
    ///   - maximumLength: The longest passage, in characters. Values below 1 are treated as 1.
    ///   - overlap: Sentences repeated between consecutive passages. Negative values are
    ///     treated as 0.
    public init(maximumLength: Int = 800, overlap: Int = 1) {
        self.maximumLength = max(1, maximumLength)
        self.overlap = max(0, overlap)
    }

    /// The passages of `text`, in order. Empty or whitespace-only text has none.
    public func chunks(of text: String) -> [TextChunk] {
        let pieces = sentenceRanges(in: text).flatMap { splitIfTooLong($0, in: text) }
        var chunks: [TextChunk] = []
        var start = 0
        while start < pieces.count {
            var end = start
            while end + 1 < pieces.count, length(pieces[start].lowerBound..<pieces[end + 1].upperBound, in: text) <= maximumLength {
                end += 1
            }
            let range = pieces[start].lowerBound..<pieces[end].upperBound
            chunks.append(TextChunk(text: String(text[range]), range: range))
            guard end + 1 < pieces.count else { break }
            start = nextStart(after: end, previousStart: start, pieces: pieces, in: text)
        }
        return chunks
    }

    /// The first piece of the next passage: up to `overlap` pieces back, as long as the
    /// passage still has room for at least one new piece and moves forward.
    private func nextStart(after end: Int, previousStart: Int, pieces: [Range<String.Index>], in text: String) -> Int {
        var start = end + 1
        while start > previousStart + 1, end + 1 - (start - 1) <= overlap,
              length(pieces[start - 1].lowerBound..<pieces[end + 1].upperBound, in: text) <= maximumLength {
            start -= 1
        }
        return start
    }

    /// Sentence ranges with surrounding whitespace removed.
    private func sentenceRanges(in text: String) -> [Range<String.Index>] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        return tokenizer.tokens(for: text.startIndex..<text.endIndex).compactMap { trimmed($0, in: text) }
    }

    private func splitIfTooLong(_ range: Range<String.Index>, in text: String) -> [Range<String.Index>] {
        guard length(range, in: text) > maximumLength else { return [range] }
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        let words = tokenizer.tokens(for: range).flatMap { cutToMaximum($0, in: text) }
        var pieces: [Range<String.Index>] = []
        for word in words {
            if let last = pieces.last, length(last.lowerBound..<word.upperBound, in: text) <= maximumLength {
                pieces[pieces.count - 1] = last.lowerBound..<word.upperBound
            } else {
                pieces.append(word)
            }
        }
        // Word tokens leave out punctuation; give each piece the text up to the next one (the
        // last piece: up to the end of the sentence) when that still fits.
        for index in pieces.indices {
            let end = index + 1 < pieces.count ? pieces[index + 1].lowerBound : range.upperBound
            if let extended = trimmed(pieces[index].lowerBound..<end, in: text), length(extended, in: text) <= maximumLength {
                pieces[index] = extended
            }
        }
        return pieces
    }

    private func cutToMaximum(_ range: Range<String.Index>, in text: String) -> [Range<String.Index>] {
        var pieces: [Range<String.Index>] = []
        var start = range.lowerBound
        while start < range.upperBound {
            let end = text.index(start, offsetBy: maximumLength, limitedBy: range.upperBound) ?? range.upperBound
            pieces.append(start..<end)
            start = end
        }
        return pieces
    }

    private func trimmed(_ range: Range<String.Index>, in text: String) -> Range<String.Index>? {
        var lower = range.lowerBound
        var upper = range.upperBound
        while lower < upper, text[lower].isWhitespace { lower = text.index(after: lower) }
        while upper > lower, text[text.index(before: upper)].isWhitespace { upper = text.index(before: upper) }
        return lower < upper ? lower..<upper : nil
    }

    private func length(_ range: Range<String.Index>, in text: String) -> Int {
        text.distance(from: range.lowerBound, to: range.upperBound)
    }
}

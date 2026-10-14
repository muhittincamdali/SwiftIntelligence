import Foundation

/// A copy of a text with look-alike characters folded together, and a map from the copy back to
/// the original, so that personal data found in the copy is replaced in the original.
///
/// Folding stops the simple ways of slipping a value past a pattern: full-width and other
/// compatibility forms ("４１１１", "＠"), invisible format characters inside a value (zero-width
/// spaces, soft hyphens, direction marks), accents, typographic dashes and unusual spaces
/// between digit groups.
struct FoldedText {
    enum Strength {
        /// Removes format characters and applies NFKC. Letters keep their accents, so the
        /// name tagger still reads the text as written.
        case compatibility
        /// Also removes combining marks and turns every dash into "-" and every space into " ".
        case full
    }

    /// One original character whose folded form differs from it, in UTF-16 offsets.
    private struct Piece {
        let foldedStart: Int
        let foldedEnd: Int
        let originalStart: Int
        let originalEnd: Int
    }

    /// The folded text.
    let text: String
    /// The text that was folded.
    let originalText: String
    /// Only changed characters are recorded; everything between them maps one to one, so the
    /// map stays small for ordinary text.
    private let pieces: [Piece]

    init(_ original: String, strength: Strength) {
        var folded = ""
        var pieces: [Piece] = []
        var foldedOffset = 0
        var originalOffset = 0
        for character in original {
            let originalLength = character.utf16.count
            if let replacement = Self.fold(character, strength: strength) {
                let length = replacement.utf16.count
                pieces.append(Piece(
                    foldedStart: foldedOffset,
                    foldedEnd: foldedOffset + length,
                    originalStart: originalOffset,
                    originalEnd: originalOffset + originalLength
                ))
                folded += replacement
                foldedOffset += length
            } else {
                folded.append(character)
                foldedOffset += originalLength
            }
            originalOffset += originalLength
        }
        self.text = folded
        self.originalText = original
        self.pieces = pieces
    }

    /// The range in the original text that produced `range` of the folded text, widened to
    /// whole characters. `nil` for an empty range.
    func originalRange(of range: NSRange) -> Range<String.Index>? {
        guard range.location != NSNotFound, range.length > 0 else { return nil }
        let start = originalOffset(forFolded: range.location, isEnd: false)
        let end = originalOffset(forFolded: range.location + range.length - 1, isEnd: true)
        guard end > start else { return nil }
        let widened = (originalText as NSString).rangeOfComposedCharacterSequences(for: NSRange(location: start, length: end - start))
        return Range(widened, in: originalText)
    }

    /// The range in the original text for a range of the folded text.
    func originalRange(of range: Range<String.Index>) -> Range<String.Index>? {
        originalRange(of: NSRange(range, in: text))
    }

    /// Maps one UTF-16 unit of the folded text to the start (or, with `isEnd`, the end) of the
    /// original character it belongs to.
    private func originalOffset(forFolded offset: Int, isEnd: Bool) -> Int {
        guard let piece = lastPiece(startingAtOrBefore: offset) else {
            return isEnd ? offset + 1 : offset
        }
        if offset < piece.foldedEnd {
            return isEnd ? piece.originalEnd : piece.originalStart
        }
        let mapped = piece.originalEnd + (offset - piece.foldedEnd)
        return isEnd ? mapped + 1 : mapped
    }

    /// Binary search: the last piece whose folded start is at or before `offset`.
    private func lastPiece(startingAtOrBefore offset: Int) -> Piece? {
        var low = 0
        var high = pieces.count
        while low < high {
            let middle = (low + high) / 2
            if pieces[middle].foldedStart <= offset {
                low = middle + 1
            } else {
                high = middle
            }
        }
        // Among pieces with the same start, a removed character (empty) comes before the
        // character that follows it, so the last one is the one that can contain `offset`.
        return low > 0 ? pieces[low - 1] : nil
    }

    /// The folded form of a character, or `nil` when it stays the same.
    static func fold(_ character: Character, strength: Strength) -> String? {
        if character.isASCII { return nil }
        let visible = String(String.UnicodeScalarView(character.unicodeScalars.filter { $0.properties.generalCategory != .format }))
        let folded: String
        switch strength {
        case .compatibility:
            folded = visible.precomposedStringWithCompatibilityMapping
        case .full:
            var scalars = String.UnicodeScalarView()
            for scalar in visible.decomposedStringWithCompatibilityMapping.unicodeScalars {
                switch scalar.properties.generalCategory {
                case .nonspacingMark, .enclosingMark:
                    continue
                case .dashPunctuation:
                    scalars.append("-")
                case .spaceSeparator:
                    scalars.append(" ")
                case .lineSeparator, .paragraphSeparator:
                    scalars.append("\n")
                default:
                    scalars.append(scalar == minusSign ? "-" : scalar)
                }
            }
            folded = String(scalars)
        }
        return folded == String(character) ? nil : folded
    }

    /// U+2212 is a math symbol, not a dash, but is typed between digit groups all the same.
    private static let minusSign: Unicode.Scalar = "\u{2212}"
}

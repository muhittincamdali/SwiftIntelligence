import Testing
@testable import SwiftIntelligence

@Suite("TextChunker")
struct TextChunkerTests {
    let text = "Alpha is first. Beta is second. Gamma is third. Delta is fourth."

    @Test("keeps short text in one passage")
    func shortText() {
        let chunks = TextChunker(maximumLength: 500).chunks(of: text)
        #expect(chunks.map(\.text) == [text])
    }

    @Test("has no passages for empty or blank text")
    func emptyText() {
        #expect(TextChunker().chunks(of: "").isEmpty)
        #expect(TextChunker().chunks(of: "  \n\t ").isEmpty)
    }

    @Test("ends passages at sentence boundaries without overlap")
    func sentenceBoundaries() {
        let chunks = TextChunker(maximumLength: 32, overlap: 0).chunks(of: text)
        #expect(chunks.map(\.text) == ["Alpha is first. Beta is second.", "Gamma is third. Delta is fourth."])
    }

    @Test("repeats the last sentence of a passage at the start of the next")
    func overlap() {
        let chunks = TextChunker(maximumLength: 32, overlap: 1).chunks(of: text)
        #expect(chunks.map(\.text) == [
            "Alpha is first. Beta is second.",
            "Beta is second. Gamma is third.",
            "Gamma is third. Delta is fourth.",
        ])
    }

    @Test("drops the overlap when it leaves no room for a new sentence")
    func overlapWithoutRoom() {
        let chunks = TextChunker(maximumLength: 16, overlap: 2).chunks(of: text)
        #expect(chunks.map(\.text) == ["Alpha is first.", "Beta is second.", "Gamma is third.", "Delta is fourth."])
    }

    @Test("splits a long sentence between words and cuts a long word")
    func longSentence() {
        let chunks = TextChunker(maximumLength: 10, overlap: 0).chunks(of: "one two three four supercalifragilistic")
        #expect(chunks.map(\.text) == ["one two", "three four", "supercalif", "ragilistic"])
        #expect(chunks.allSatisfy { $0.text.count <= 10 })
    }

    @Test("reports each passage's range in the source text")
    func ranges() {
        let source = "  First part here.\n\nSecond part here.  "
        for chunk in TextChunker(maximumLength: 20, overlap: 0).chunks(of: source) {
            #expect(String(source[chunk.range]) == chunk.text)
        }
    }

    @Test("covers every sentence of a long document", arguments: [0, 1, 2])
    func coverage(overlap: Int) {
        let sentences = (1...40).map { "Sentence number \($0) talks about topic \($0 % 7)." }
        let chunks = TextChunker(maximumLength: 120, overlap: overlap).chunks(of: sentences.joined(separator: " "))
        for sentence in sentences {
            #expect(chunks.contains { $0.text.contains(sentence) })
        }
        #expect(chunks.allSatisfy { $0.text.count <= 120 })
    }

    @Test("clamps invalid settings")
    func clamping() {
        let chunker = TextChunker(maximumLength: 0, overlap: -3)
        #expect(chunker.maximumLength == 1)
        #expect(chunker.overlap == 0)
    }
}

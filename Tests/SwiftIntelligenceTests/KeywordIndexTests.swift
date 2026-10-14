import Foundation
import Testing
@testable import SwiftIntelligence

@Suite("KeywordIndex")
struct KeywordIndexTests {
    private func index(_ texts: [String: String]) -> KeywordIndex {
        var index = KeywordIndex()
        for (id, text) in texts { index.insert(text, for: id) }
        return index
    }

    @Test("finds only texts that contain a query word")
    func matching() {
        let index = index(["a": "Refund policy for damaged items", "b": "Shipping times to Europe", "c": "Refunds take five days"])
        #expect(Set(index.search("refund", limit: 10).map(\.id)) == ["a"])
        #expect(index.search("warranty", limit: 10).isEmpty)
    }

    @Test("ranks rarer words above common ones")
    func idf() {
        let index = index([
            "a": "order status order status",
            "b": "order cancelled",
            "c": "order shipped",
            "d": "order returned",
        ])
        let results = index.search("order cancelled", limit: 4)
        #expect(results.first?.id == "b")
        #expect(results.count == 4)
    }

    @Test("favors the shorter of two texts with the same matches")
    func lengthNormalization() {
        let index = index(["short": "battery replacement", "long": "battery replacement and many other unrelated words about screens and cases"])
        #expect(index.search("battery", limit: 2).map(\.id) == ["short", "long"])
    }

    @Test("ignores case and accents in texts and queries")
    func folding() {
        let index = index(["a": "Le Café de Flore"])
        #expect(index.search("CAFE", limit: 1).map(\.id) == ["a"])
    }

    @Test("replaces and removes texts")
    func updates() {
        var index = index(["a": "red apple", "b": "green pear"])
        index.insert("yellow banana", for: "a")
        #expect(index.search("apple", limit: 5).isEmpty)
        #expect(index.search("banana", limit: 5).map(\.id) == ["a"])
        index.remove("a")
        #expect(index.count == 1)
        #expect(index.search("banana", limit: 5).isEmpty)
        #expect(index.search("pear", limit: 5).map(\.id) == ["b"])
    }

    @Test("applies the filter and the limit")
    func filterAndLimit() {
        let index = index(["a": "tea", "b": "tea time", "c": "green tea"])
        #expect(index.search("tea", limit: 2).count == 2)
        #expect(!index.search("tea", limit: 5) { $0 != "a" }.contains { $0.id == "a" })
        #expect(index.search("tea", limit: 0).isEmpty)
        #expect(KeywordIndex().search("tea", limit: 3).isEmpty)
    }

    @Test("matches the BM25 formula for a single document")
    func formula() {
        let index = index(["a": "alpha beta", "b": "gamma"])
        let score = index.search("alpha", limit: 1).first!.score
        // N = 2, n = 1, tf = 1, |d| = 2, avgdl = 1.5, k1 = 1.2, b = 0.75.
        let idf = log(1 + (2 - 1 + 0.5) / (1 + 0.5))
        let expected = idf * (1 * 2.2) / (1 + 1.2 * (1 - 0.75 + 0.75 * 2 / 1.5))
        #expect(abs(score - expected) < 1e-9)
    }
}

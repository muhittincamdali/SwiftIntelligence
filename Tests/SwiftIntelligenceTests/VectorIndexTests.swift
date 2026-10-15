import Foundation
import Testing
@testable import SwiftIntelligence

@Suite("VectorIndex")
struct VectorIndexTests {
    private func index(_ entries: [(String, [Float])]) throws -> VectorIndex {
        var index = VectorIndex(dimension: 3)
        for (id, vector) in entries { try index.insert(vector, for: id) }
        return index
    }

    @Test("ranks by cosine similarity, ignoring vector length")
    func ranking() throws {
        let index = try index([("x", [10, 0, 0]), ("xy", [1, 1, 0]), ("z", [0, 0, 1])])
        let results = try index.search([1, 0, 0], limit: 3)
        #expect(results.map(\.id) == ["x", "xy", "z"])
        #expect(abs(results[0].score - 1) < 0.0001)
        #expect(abs(results[1].score - 0.7071) < 0.001)
        #expect(abs(results[2].score) < 0.0001)
    }

    @Test("respects the limit and the filter")
    func limitAndFilter() throws {
        let index = try index([("a", [1, 0, 0]), ("b", [0.9, 0.1, 0]), ("c", [0.8, 0.2, 0])])
        #expect(try index.search([1, 0, 0], limit: 2).map(\.id) == ["a", "b"])
        #expect(try index.search([1, 0, 0], limit: 5) { $0 != "a" }.map(\.id) == ["b", "c"])
        #expect(try index.search([1, 0, 0], limit: 0).isEmpty)
    }

    @Test("replaces the vector of an existing identifier")
    func replace() throws {
        var index = try index([("a", [1, 0, 0]), ("b", [0, 1, 0])])
        try index.insert([0, 0, 1], for: "a")
        #expect(index.count == 2)
        #expect(try index.search([0, 0, 1], limit: 1).map(\.id) == ["a"])
    }

    @Test("removes a vector and keeps the others findable")
    func remove() throws {
        var index = try index([("a", [1, 0, 0]), ("b", [0, 1, 0]), ("c", [0, 0, 1])])
        index.remove("a")
        index.remove("missing")
        #expect(index.count == 2)
        #expect(!index.contains("a"))
        #expect(try index.search([0, 0, 1], limit: 1).map(\.id) == ["c"])
        #expect(try index.search([0, 1, 0], limit: 1).map(\.id) == ["b"])
        #expect(index.vector(for: "c") == [0, 0, 1])
    }

    @Test("rejects vectors and queries of the wrong length")
    func dimension() throws {
        var index = VectorIndex(dimension: 3)
        #expect(throws: IndexError.dimensionMismatch(expected: 3, actual: 2)) { try index.insert([1, 0], for: "a") }
        #expect(throws: IndexError.dimensionMismatch(expected: 3, actual: 4)) { try index.search([1, 0, 0, 0], limit: 1) }
    }

    @Test("survives an encode and decode round trip")
    func codable() throws {
        let original = try index([("a", [1, 2, 3]), ("b", [-1, 0, 4])])
        let decoded = try JSONDecoder().decode(VectorIndex.self, from: JSONEncoder().encode(original))
        #expect(decoded == original)
        #expect(try decoded.search([1, 2, 3], limit: 1).map(\.id) == ["a"])
    }

    @Test("rejects vector data of the wrong size")
    func corruptData() throws {
        let json = #"{"dimension":3,"ids":["a"],"vectors":"AAAAAA=="}"#
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(VectorIndex.self, from: Data(json.utf8)) }
    }
}

@Test("VectorIndex rejects duplicate identifiers in saved data")
func vectorIndexDuplicateIDs() {
    let json = #"{"dimension":1,"ids":["a","a"],"vectors":"AACAPwAAgD8="}"#
    #expect(throws: DecodingError.self) { try JSONDecoder().decode(VectorIndex.self, from: Data(json.utf8)) }
}

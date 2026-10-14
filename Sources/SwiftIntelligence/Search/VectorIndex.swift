import Accelerate
import Foundation

/// An identifier with a relevance score; higher is more relevant.
public struct ScoredID: Hashable, Sendable {
    public let id: String
    public let score: Double

    public init(id: String, score: Double) {
        self.id = id
        self.score = score
    }
}

/// Errors from the search indexes.
public enum IndexError: Error, Hashable, Sendable {
    /// A vector's length differs from the index's dimension.
    case dimensionMismatch(expected: Int, actual: Int)
    /// A vector contains NaN or an infinite value, which has no direction to compare.
    case nonFiniteValue
}

/// Exact nearest-neighbor search by cosine similarity over vectors kept in memory.
///
/// Every search compares the query with every stored vector in one matrix multiplication
/// (Accelerate), which takes a few milliseconds for tens of thousands of vectors on current
/// devices. ``KnowledgeBase`` uses it for semantic search; use it directly when you compute
/// vectors yourself.
public struct VectorIndex: Hashable, Sendable {
    /// The length of every vector in the index.
    public let dimension: Int
    private var ids: [String] = []
    /// Unit-length vectors, one row per identifier, stored back to back.
    private var rows: [Float] = []
    private var positions: [String: Int] = [:]

    /// Creates an empty index.
    ///
    /// - Parameter dimension: The length of every vector. Values below 1 are raised to 1.
    public init(dimension: Int) {
        self.dimension = max(1, dimension)
    }

    /// The number of vectors.
    public var count: Int { ids.count }

    /// Whether the index has a vector for `id`.
    public func contains(_ id: String) -> Bool { positions[id] != nil }

    /// Adds `vector` under `id`, replacing any vector stored under it before.
    ///
    /// - Throws: ``IndexError/dimensionMismatch(expected:actual:)`` or
    ///   ``IndexError/nonFiniteValue``.
    public mutating func insert(_ vector: [Float], for id: String) throws {
        try validate(vector)
        let row = VectorMath.normalized(vector)
        if let position = positions[id] {
            rows.replaceSubrange(position * dimension..<(position + 1) * dimension, with: row)
        } else {
            positions[id] = ids.count
            ids.append(id)
            rows.append(contentsOf: row)
        }
    }

    /// Removes the vector stored under `id`, if any.
    public mutating func remove(_ id: String) {
        guard let position = positions.removeValue(forKey: id) else { return }
        let last = ids.count - 1
        if position != last {
            // Move the last row into the gap so removal does not shift every later row.
            ids[position] = ids[last]
            positions[ids[position]] = position
            rows.replaceSubrange(position * dimension..<(position + 1) * dimension, with: rows[last * dimension..<(last + 1) * dimension])
        }
        ids.removeLast()
        rows.removeLast(dimension)
    }

    /// The stored vector for `id`, at unit length.
    public func vector(for id: String) -> [Float]? {
        positions[id].map { Array(rows[$0 * dimension..<($0 + 1) * dimension]) }
    }

    /// The identifiers most similar to `query`, most similar first, with their cosine
    /// similarity (-1 to 1) as the score.
    ///
    /// - Parameters:
    ///   - query: The vector to compare with; any length other than zero.
    ///   - limit: The most results to return.
    ///   - isIncluded: Leaves out identifiers for which it returns `false`.
    /// - Throws: ``IndexError/dimensionMismatch(expected:actual:)`` or
    ///   ``IndexError/nonFiniteValue``.
    public func search(_ query: [Float], limit: Int, where isIncluded: (String) -> Bool = { _ in true }) throws -> [ScoredID] {
        try validate(query)
        guard limit > 0, !ids.isEmpty else { return [] }
        let scores = similarities(to: VectorMath.normalized(query))
        return ids.indices
            .filter { isIncluded(ids[$0]) }
            .sorted { scores[$0] != scores[$1] ? scores[$0] > scores[$1] : $0 < $1 }
            .prefix(limit)
            .map { ScoredID(id: ids[$0], score: Double(scores[$0])) }
    }

    /// Throws when `vector` cannot be stored or searched for: wrong length, NaN or infinity.
    public func validate(_ vector: [Float]) throws {
        guard vector.count == dimension else {
            throw IndexError.dimensionMismatch(expected: dimension, actual: vector.count)
        }
        guard VectorMath.isFinite(vector) else { throw IndexError.nonFiniteValue }
    }

    /// rows (count × dimension) × query (dimension × 1).
    private func similarities(to query: [Float]) -> [Float] {
        var scores = [Float](repeating: 0, count: ids.count)
        vDSP_mmul(rows, 1, query, 1, &scores, 1, vDSP_Length(ids.count), 1, vDSP_Length(dimension))
        return scores
    }
}

extension VectorIndex: Codable {
    private enum CodingKeys: String, CodingKey {
        case dimension, ids, vectors
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dimension = try container.decode(Int.self, forKey: .dimension)
        guard dimension > 0 else {
            throw DecodingError.dataCorruptedError(forKey: .dimension, in: container, debugDescription: "Dimension \(dimension) is not positive.")
        }
        let ids = try container.decode([String].self, forKey: .ids)
        let data = try container.decode(Data.self, forKey: .vectors)
        // Checked arithmetic: a crafted file with a huge dimension must fail, not trap.
        let (floats, floatsOverflow) = ids.count.multipliedReportingOverflow(by: dimension)
        let (bytes, bytesOverflow) = floats.multipliedReportingOverflow(by: MemoryLayout<Float>.size)
        guard !floatsOverflow, !bytesOverflow, data.count == bytes else {
            throw DecodingError.dataCorruptedError(forKey: .vectors, in: container, debugDescription: "Vector data does not match \(ids.count) × \(dimension) floats.")
        }
        let positions = Dictionary(ids.enumerated().map { ($0.element, $0.offset) }, uniquingKeysWith: { first, _ in first })
        guard positions.count == ids.count else {
            throw DecodingError.dataCorruptedError(forKey: .ids, in: container, debugDescription: "Identifiers are not unique.")
        }
        // The rows were normalized when they were inserted; normalizing again would change
        // the last bits of every value.
        let rows = data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
        guard VectorMath.isFinite(rows) else {
            throw DecodingError.dataCorruptedError(forKey: .vectors, in: container, debugDescription: "Vector data contains NaN or infinity.")
        }
        guard Self.rowsHaveUnitLength(rows, dimension: dimension) else {
            throw DecodingError.dataCorruptedError(forKey: .vectors, in: container, debugDescription: "Vector data contains a row that is not unit length.")
        }
        self.rows = rows
        self.ids = ids
        self.positions = positions
    }

    /// How far the squared length of a saved row may be from 1. Rows written by
    /// ``insert(_:for:)`` are within about 1e-6 of it, whatever the dimension.
    private static let unitLengthTolerance: Float = 1e-3

    /// Whether every row has unit length or is all zeros, as ``insert(_:for:)`` leaves it.
    /// Scores assume unit rows: a crafted row of huge values would overflow every similarity
    /// to infinity or NaN and drop out of the results without an error.
    private static func rowsHaveUnitLength(_ rows: [Float], dimension: Int) -> Bool {
        stride(from: 0, to: rows.count, by: dimension).allSatisfy { start in
            let squaredLength = vDSP.sumOfSquares(rows[start..<start + dimension])
            return squaredLength == 0 || abs(squaredLength - 1) <= unitLengthTolerance
        }
    }

    /// Vectors are written as raw 32-bit floats (base64 in JSON), about a third of the size of
    /// a JSON number array.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dimension, forKey: .dimension)
        try container.encode(ids, forKey: .ids)
        try container.encode(rows.withUnsafeBufferPointer { Data(buffer: $0) }, forKey: .vectors)
    }
}

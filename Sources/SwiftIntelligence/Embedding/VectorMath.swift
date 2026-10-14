import Accelerate

/// Vector operations on `[Float]`, through Accelerate.
enum VectorMath {
    /// The dot product. Both vectors must have the same length.
    static func dot(_ lhs: [Float], _ rhs: [Float]) -> Float {
        vDSP.dot(lhs, rhs)
    }

    /// The vector scaled to length 1, or unchanged when it is all zeros.
    ///
    /// The vector is first divided by its largest magnitude, so the sum of squares cannot
    /// overflow to infinity for very large values (which would turn every element into 0).
    static func normalized(_ vector: [Float]) -> [Float] {
        let largest = vDSP.maximumMagnitude(vector)
        guard largest > 0, largest.isFinite else { return vector }
        // Accelerate flushes subnormal numbers to zero, so dividing by a subnormal largest
        // magnitude gives infinity and NaN. Scaling by a power of two first, outside
        // Accelerate, makes every non-zero element normal and keeps the direction exact.
        let input = largest < Float.leastNormalMagnitude ? vector.map { $0 * subnormalScale } : vector
        let scaled = vDSP.divide(input, vDSP.maximumMagnitude(input))
        return vDSP.divide(scaled, sqrt(vDSP.sumOfSquares(scaled)))
    }

    /// 2^64: lifts the smallest subnormal Float (about 1.4e-45) to about 2.6e-26.
    private static let subnormalScale: Float = 0x1p64

    /// Whether every element is a finite number (no NaN, no infinity).
    static func isFinite(_ vector: [Float]) -> Bool {
        vector.allSatisfy(\.isFinite)
    }

    /// The cosine similarity, from -1 to 1; 0 when either vector is all zeros.
    static func cosineSimilarity(_ lhs: [Float], _ rhs: [Float]) -> Float {
        let lengths = sqrt(vDSP.sumOfSquares(lhs) * vDSP.sumOfSquares(rhs))
        return lengths > 0 ? vDSP.dot(lhs, rhs) / lengths : 0
    }

    /// The element-wise mean of equally long vectors, or `nil` for none.
    static func mean(_ vectors: [[Float]]) -> [Float]? {
        guard var sum = vectors.first else { return nil }
        for vector in vectors.dropFirst() {
            sum = vDSP.add(sum, vector)
        }
        return vDSP.divide(sum, Float(vectors.count))
    }
}

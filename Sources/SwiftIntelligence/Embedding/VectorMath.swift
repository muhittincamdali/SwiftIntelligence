import Accelerate

/// Vector operations on `[Float]`, through Accelerate.
enum VectorMath {
    /// The dot product. Both vectors must have the same length.
    static func dot(_ lhs: [Float], _ rhs: [Float]) -> Float {
        vDSP.dot(lhs, rhs)
    }

    /// The vector scaled to length 1, or unchanged when it is all zeros.
    static func normalized(_ vector: [Float]) -> [Float] {
        let length = sqrt(vDSP.sumOfSquares(vector))
        return length > 0 ? vDSP.divide(vector, length) : vector
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

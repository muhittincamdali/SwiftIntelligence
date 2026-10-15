/// Reciprocal rank fusion: merges ranked lists whose scores are not comparable, such as
/// cosine similarities and BM25 scores, using only each item's position.
///
/// An item's fused score is the sum over the lists of `weight / (k + rank)`, with rank
/// starting at 1. Items near the top of several lists rise; an item missing from a list just
/// gets nothing from it.
public enum RankFusion {
    /// The usual smoothing constant from Cormack, Clarke and Büttcher (2009).
    public static let defaultSmoothing = 60.0

    /// One ranked list and how much it counts.
    public struct RankedList: Sendable {
        public let results: [ScoredID]
        public let weight: Double

        public init(_ results: [ScoredID], weight: Double = 1) {
            self.results = results
            self.weight = weight
        }
    }

    /// The fused ranking, best first. Ties keep the order in which items first appear in the
    /// lists.
    ///
    /// - Parameters:
    ///   - lists: The rankings. A list whose weight is NaN or infinite is left out.
    ///   - smoothing: k, 0 or more; NaN, infinite or negative values use ``defaultSmoothing``.
    public static func fuse(_ lists: [RankedList], smoothing: Double = defaultSmoothing) -> [ScoredID] {
        let smoothing = smoothing.isFinite && smoothing >= 0 ? smoothing : defaultSmoothing
        var scores: [String: Double] = [:]
        var firstSeen: [String: Int] = [:]
        for list in lists where list.weight.isFinite {
            for (offset, result) in list.results.enumerated() {
                scores[result.id, default: 0] += list.weight / (smoothing + Double(offset + 1))
                if firstSeen[result.id] == nil { firstSeen[result.id] = firstSeen.count }
            }
        }
        return scores
            .sorted { $0.value != $1.value ? $0.value > $1.value : firstSeen[$0.key]! < firstSeen[$1.key]! }
            .map { ScoredID(id: $0.key, score: $0.value) }
    }
}

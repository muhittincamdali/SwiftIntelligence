import Foundation

/// Full-text search ranked with Okapi BM25, the scoring used by most search engines.
///
/// Words are compared after case and accent folding, so "Café" finds "cafe". A word that
/// appears in few texts weighs more than a common one, and long texts do not win just by
/// being long. ``KnowledgeBase`` uses it for keyword search; it finds exact names, codes and
/// numbers that an embedding can miss.
public struct KeywordIndex: Hashable, Sendable {
    /// How quickly repeated words stop adding to the score.
    public let termSaturation: Double
    /// How much text length is normalized: 0 ignores length, 1 normalizes fully.
    public let lengthNormalization: Double
    /// term → identifier → occurrences.
    private var postings: [String: [String: Int]] = [:]
    /// identifier → term → occurrences, to remove a text without scanning every term.
    private var terms: [String: [String: Int]] = [:]
    private var lengths: [String: Int] = [:]
    private var totalLength = 0

    static let defaultTermSaturation = 1.2
    static let defaultLengthNormalization = 0.75

    /// Creates an empty index with the usual BM25 parameters (k1 = 1.2, b = 0.75).
    ///
    /// - Parameters:
    ///   - termSaturation: k1, 0 or more. NaN, infinite or negative values use 1.2.
    ///   - lengthNormalization: b, from 0 to 1; values outside are clamped, NaN uses 0.75.
    public init(termSaturation: Double = 1.2, lengthNormalization: Double = 0.75) {
        self.termSaturation = termSaturation.isFinite && termSaturation >= 0 ? termSaturation : Self.defaultTermSaturation
        self.lengthNormalization = lengthNormalization.isNaN ? Self.defaultLengthNormalization : min(max(lengthNormalization, 0), 1)
    }

    /// The number of indexed texts.
    public var count: Int { lengths.count }

    /// Indexes `text` under `id`, replacing any text indexed under it before.
    public mutating func insert(_ text: String, for id: String) {
        remove(id)
        let words = SearchTerms.terms(in: text)
        let counts = Dictionary(words.map { ($0, 1) }, uniquingKeysWith: +)
        for (term, occurrences) in counts {
            postings[term, default: [:]][id] = occurrences
        }
        terms[id] = counts
        lengths[id] = words.count
        totalLength += words.count
    }

    /// Removes the text indexed under `id`, if any.
    public mutating func remove(_ id: String) {
        guard let counts = terms.removeValue(forKey: id) else { return }
        for term in counts.keys {
            postings[term]?[id] = nil
            if postings[term]?.isEmpty == true { postings[term] = nil }
        }
        totalLength -= lengths.removeValue(forKey: id) ?? 0
    }

    /// The texts that contain words of `query`, best match first, with their BM25 score.
    ///
    /// - Parameters:
    ///   - limit: The most results to return.
    ///   - isIncluded: Leaves out identifiers for which it returns `false`.
    public func search(_ query: String, limit: Int, where isIncluded: (String) -> Bool = { _ in true }) -> [ScoredID] {
        guard limit > 0, !lengths.isEmpty else { return [] }
        let averageLength = max(1, Double(totalLength) / Double(lengths.count))
        var scores: [String: Double] = [:]
        for term in Set(SearchTerms.terms(in: query)) {
            guard let matches = postings[term] else { continue }
            let weight = inverseDocumentFrequency(matchingCount: matches.count)
            for (id, occurrences) in matches where isIncluded(id) {
                let frequency = Double(occurrences)
                let lengthRatio = Double(lengths[id]!) / averageLength
                let saturation = termSaturation * (1 - lengthNormalization + lengthNormalization * lengthRatio)
                scores[id, default: 0] += weight * frequency * (termSaturation + 1) / (frequency + saturation)
            }
        }
        return scores
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .prefix(limit)
            .map { ScoredID(id: $0.key, score: $0.value) }
    }

    /// The BM25 IDF with the +1 inside the logarithm, which keeps it positive for words that
    /// appear in more than half of the texts.
    private func inverseDocumentFrequency(matchingCount: Int) -> Double {
        let total = Double(lengths.count)
        let matching = Double(matchingCount)
        return log(1 + (total - matching + 0.5) / (matching + 0.5))
    }
}

import Testing
@testable import SwiftIntelligence

@Suite("RankFusion")
struct RankFusionTests {
    private func list(_ ids: [String], weight: Double = 1) -> RankFusion.RankedList {
        RankFusion.RankedList(ids.map { ScoredID(id: $0, score: 0) }, weight: weight)
    }

    @Test("rewards items that rank well in both lists")
    func agreement() {
        let fused = RankFusion.fuse([list(["a", "b", "c"]), list(["b", "c", "a"])])
        #expect(fused.map(\.id) == ["b", "a", "c"])
        #expect(abs(fused[0].score - (1.0 / 62 + 1.0 / 61)) < 1e-12)
    }

    @Test("includes items that appear in only one list")
    func union() {
        let fused = RankFusion.fuse([list(["a"]), list(["b"])])
        #expect(fused.map(\.id) == ["a", "b"])
    }

    @Test("lets a weight favor one list")
    func weights() {
        let fused = RankFusion.fuse([list(["a", "b"], weight: 1), list(["b", "a"], weight: 3)])
        #expect(fused.map(\.id) == ["b", "a"])
    }

    @Test("returns nothing for empty lists")
    func empty() {
        #expect(RankFusion.fuse([]).isEmpty)
        #expect(RankFusion.fuse([list([])]).isEmpty)
    }
}

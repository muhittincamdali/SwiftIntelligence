import SwiftIntelligence
import SwiftUI

/// Shows what TextAnalyzer reads from a text. Values the system has no model for show a dash.
struct AnalyzeScreen: View {
    @State private var text = "Tim Cook presented the new iPhone in Cupertino. The audience loved the camera, and the camera was the main topic of the evening."

    private var analysis: TextAnalysis {
        TextAnalyzer().analyze(text)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Text") {
                    TextField("Text", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                }
                Section("Overview") {
                    LabeledContent("Language", value: analysis.language.map { Locale.current.localizedString(forLanguageCode: $0.rawValue) ?? $0.rawValue } ?? "—")
                    LabeledContent("Sentiment", value: analysis.sentiment.map { $0.formatted(.number.precision(.fractionLength(2))) } ?? "—")
                    LabeledContent("Sentences", value: analysis.sentenceCount.formatted())
                    LabeledContent("Words", value: analysis.wordCount.formatted())
                }
                Section("Names") {
                    if analysis.entities.isEmpty {
                        Text("—").foregroundStyle(.secondary)
                    }
                    ForEach(Array(analysis.entities.enumerated()), id: \.offset) { _, entity in
                        LabeledContent(entity.text, value: entity.kind.rawValue.capitalized)
                    }
                }
                Section("Keywords") {
                    if analysis.keywords.isEmpty {
                        Text("—").foregroundStyle(.secondary)
                    }
                    ForEach(analysis.keywords, id: \.term) { keyword in
                        LabeledContent(keyword.term, value: "\(keyword.count)×")
                    }
                }
            }
            .navigationTitle("Analyze")
        }
    }
}

import SwiftIntelligence
import SwiftUI

/// Searches the help-center articles in the selected mode and shows the matching passages.
struct SearchScreen: View {
    let library: DemoLibrary
    @State private var query = "My laptop shows error E-4012"
    @State private var mode = SearchMode.hybrid
    @State private var results: [SearchResult] = []

    private struct SearchKey: Equatable {
        let query: String
        let mode: SearchMode
        let isReady: Bool
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label {
                        TextField("Search the help center", text: $query)
                            .autocorrectionDisabled()
                    } icon: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                    }
                    Picker("Ranking", selection: $mode) {
                        ForEach(SearchMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    Text(library.embedderName)
                }
                Section(results.isEmpty ? "No matching passage" : "Best passages") {
                    ForEach(results) { result in
                        ResultRow(result: result)
                    }
                }
            }
            .navigationTitle("Search")
            .task(id: SearchKey(query: query, mode: mode, isReady: library.isReady)) {
                guard library.isReady else { return }
                results = (try? await library.knowledge.search(query, limit: 4, mode: mode)) ?? []
            }
        }
    }
}

private struct ResultRow: View {
    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(DemoLibrary.title(of: result.documentID))
                    .font(.headline)
                Spacer()
                Text(result.score, format: .number.precision(.fractionLength(3)))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(result.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

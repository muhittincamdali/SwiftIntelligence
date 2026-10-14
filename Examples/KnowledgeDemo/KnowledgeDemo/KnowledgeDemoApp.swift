import SwiftUI

@main
struct KnowledgeDemoApp: App {
    @State private var library = DemoLibrary()

    var body: some Scene {
        WindowGroup {
            ContentView(library: library)
                .task { await library.load() }
        }
    }
}

/// The screens of the demo. `-screen <name>` on the command line opens one directly, which the
/// screenshot script uses.
enum DemoScreen: String, CaseIterable, Identifiable {
    case search, ask, redact, analyze

    var id: String { rawValue }

    var title: String {
        switch self {
        case .search: "Search"
        case .ask: "Ask"
        case .redact: "Redact"
        case .analyze: "Analyze"
        }
    }

    var symbol: String {
        switch self {
        case .search: "magnifyingglass"
        case .ask: "text.bubble"
        case .redact: "eye.slash"
        case .analyze: "text.magnifyingglass"
        }
    }

    static var launchSelection: DemoScreen {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "-screen"), flag + 1 < arguments.count else { return .search }
        return DemoScreen(rawValue: arguments[flag + 1]) ?? .search
    }
}

struct ContentView: View {
    let library: DemoLibrary
    @State private var selection = DemoScreen.launchSelection

    var body: some View {
        TabView(selection: $selection) {
            Tab(DemoScreen.search.title, systemImage: DemoScreen.search.symbol, value: .search) {
                SearchScreen(library: library)
            }
            Tab(DemoScreen.ask.title, systemImage: DemoScreen.ask.symbol, value: .ask) {
                AskScreen(library: library)
            }
            Tab(DemoScreen.redact.title, systemImage: DemoScreen.redact.symbol, value: .redact) {
                RedactScreen()
            }
            Tab(DemoScreen.analyze.title, systemImage: DemoScreen.analyze.symbol, value: .analyze) {
                AnalyzeScreen()
            }
        }
        .tint(.brandBlue)
    }
}

extension Color {
    /// The blue of the repository's graphics (#0071E3).
    static let brandBlue = Color(red: 0, green: 0x71 / 255, blue: 0xE3 / 255)
}

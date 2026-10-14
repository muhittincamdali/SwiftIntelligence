import SwiftIntelligence
import SwiftUI

/// Redacts personal data while you type and lists what was found.
struct RedactScreen: View {
    private enum Style: String, CaseIterable, Identifiable {
        case placeholder = "Placeholders"
        case tag = "Tags"
        case mask = "Mask"

        var id: String { rawValue }

        var replacement: PersonalDataRedactor.Replacement {
            switch self {
            case .placeholder: .placeholder
            case .tag: .tag
            case .mask: .mask("•")
            }
        }
    }

    @State private var text = """
        Please refund card ４１１１ １１１１ １１１１ １１１１ or IBAN \
        DE89-3704-0044-0532-0130-00. Mail me at maria.garcia@example.com \
        or call +1 415 555 0132. My order number is 2024-118-5521.
        """
    @State private var style = Style.placeholder

    private var redacted: RedactedText {
        PersonalDataRedactor(replacement: style.replacement).redact(text)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Text") {
                    TextField("Text", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                }
                Section {
                    Picker("Replace with", selection: $style) {
                        ForEach(Style.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Text(redacted.text)
                        .textSelection(.enabled)
                } header: {
                    Text("Redacted")
                }
                Section("Found") {
                    ForEach(Array(redacted.matches.enumerated()), id: \.offset) { _, match in
                        LabeledContent(match.kind.tag, value: match.value)
                    }
                }
            }
            .navigationTitle("Redact")
        }
    }
}

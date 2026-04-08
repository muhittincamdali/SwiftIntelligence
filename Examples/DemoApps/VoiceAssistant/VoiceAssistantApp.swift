import SwiftUI
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceSpeech

@main
struct VoiceAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            VoiceAssistantScreen()
        }
    }
}

struct VoiceAssistantScreen: View {
    @StateObject private var model = VoiceAssistantModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                commandCard
                controls
                responseCard
                historyCard
            }
            .padding()
            .navigationTitle("Voice Assistant")
        }
        .alert("Hata", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { _ in model.errorMessage = nil }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var commandCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Command")
                .font(.headline)

            TextEditor(text: $model.commandText)
                .frame(minHeight: 140)
                .padding(8)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Toggle("Privacy redaction", isOn: $model.privacyMode)
                .font(.caption)

            Text("Suggestions: schedule a meeting, summarize this note, remind me tomorrow, call Ahmet")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack {
            Button("Process", action: model.processCommand)
                .buttonStyle(.borderedProminent)
                .disabled(model.isProcessing || model.commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button("Speak", action: model.speakResponse)
                .buttonStyle(.bordered)
                .disabled(model.responseText.isEmpty)

            if model.isProcessing {
                ProgressView()
            }
        }
    }

    private var responseCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assistant Response")
                .font(.headline)

            LabeledContent("Intent", value: model.intentLabel)
            LabeledContent("Detected language", value: model.detectedLanguage)
            LabeledContent("Summary", value: model.summaryText)
            LabeledContent("Redacted", value: model.redactedPreview ?? "-")

            Text(model.responseText.isEmpty ? "No response yet" : model.responseText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(model.speechStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var historyCard: some View {
        List(model.history.reversed()) { item in
            VStack(alignment: .leading, spacing: 4) {
                Text(item.command)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(item.response)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.plain)
    }
}

@MainActor
final class VoiceAssistantModel: ObservableObject {
    @Published var commandText = "Yarin saat 10:30 icin Ahmet ile Istanbul toplantisini hatirlat."
    @Published var privacyMode = true
    @Published var responseText = ""
    @Published var summaryText = "-"
    @Published var intentLabel = "-"
    @Published var detectedLanguage = "-"
    @Published var redactedPreview: String?
    @Published var speechStatus = "Hazir"
    @Published var errorMessage: String?
    @Published var isProcessing = false
    @Published var history: [AssistantHistoryItem] = []

    private let nlp = NLPEngine.shared
    private let speech = SpeechEngine.shared
    private let tokenizer = PrivacyTokenizer()

    init() {
        SwiftIntelligenceCore.shared.configure(with: .production)
    }

    func processCommand() {
        Task { await runCommandPipeline() }
    }

    func speakResponse() {
        Task { await runSpeech() }
    }

    private func runCommandPipeline() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let text = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
            let analysis = try await nlp.analyze(text: text, options: .comprehensive)

            detectedLanguage = analysis.detectedLanguage.rawValue
            let summary = try await nlp.summarizeText(text: text, maxSentences: 1)
            summaryText = summary.summary

            let entities = analysis.analysisResults["entities"] as? [NamedEntity] ?? []
            let keywords = analysis.analysisResults["keywords"] as? [Keyword] ?? []
            intentLabel = inferIntent(from: text, keywords: keywords, entities: entities)

            if privacyMode {
                let tokenized = try await tokenizer.tokenize(
                    text,
                    context: TokenizationContext(
                        purpose: .analytics,
                        sensitivity: .high,
                        retentionPolicy: .temporary
                    )
                )
                redactedPreview = tokenized.tokens.first
            } else {
                redactedPreview = nil
            }

            responseText = buildResponse(
                intent: intentLabel,
                summary: summary.summary,
                entities: entities,
                keywords: keywords
            )

            history.append(AssistantHistoryItem(command: text, response: responseText))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func runSpeech() async {
        do {
            let voice = SpeechEngine.availableVoices(for: languageCodeForSpeech).first
            let result = try await speech.synthesizeSpeech(
                from: responseText,
                voice: voice,
                options: SpeechSynthesisOptions(language: languageCodeForSpeech, speed: 0.5)
            )
            speechStatus = "\(result.originalText.count) karakter seslendirildi"
        } catch {
            errorMessage = error.localizedDescription
            speechStatus = "Basarisiz"
        }
    }

    private var languageCodeForSpeech: String {
        detectedLanguage.hasPrefix("tr") ? "tr-TR" : "en-US"
    }

    private func inferIntent(from text: String, keywords: [Keyword], entities: [NamedEntity]) -> String {
        let lowercased = text.lowercased()
        let keywordSet = Set(keywords.map(\.word))
        let entityTypes = Set(entities.map(\.type))

        if lowercased.contains("hatirlat") || entityTypes.contains(.date) {
            return "Reminder"
        }
        if lowercased.contains("ara") || lowercased.contains("call") {
            return "Call"
        }
        if lowercased.contains("ozet") || lowercased.contains("summarize") {
            return "Summarize"
        }
        if keywordSet.contains("toplanti") || keywordSet.contains("meeting") {
            return "Schedule"
        }
        return "General Assistant"
    }

    private func buildResponse(
        intent: String,
        summary: String,
        entities: [NamedEntity],
        keywords: [Keyword]
    ) -> String {
        let notableEntities = entities.prefix(3).map(\.text).joined(separator: ", ")
        let notableKeywords = keywords.prefix(3).map(\.word).joined(separator: ", ")

        switch intent {
        case "Reminder":
            return "Hatirlatma akisi algilandi. Ozet: \(summary). Kritik varliklar: \(notableEntities.ifEmpty("-"))."
        case "Call":
            return "Iletisim niyeti algilandi. Kisi veya hedef: \(notableEntities.ifEmpty("-")). Komut ozeti: \(summary)"
        case "Summarize":
            return "Ozet modu hazir. Kisaltilmis sonuc: \(summary)"
        case "Schedule":
            return "Takvimleme niyeti algilandi. Ana sinyaller: \(notableKeywords.ifEmpty("-")). Ozet: \(summary)"
        default:
            return "Komut analiz edildi. Ozet: \(summary). Ana kelimeler: \(notableKeywords.ifEmpty("-"))."
        }
    }
}

struct AssistantHistoryItem: Identifiable {
    let id = UUID()
    let command: String
    let response: String
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        isEmpty ? fallback : self
    }
}

import SwiftUI
import NaturalLanguage
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceSpeech

#if !SMARTTRANSLATOR_MEDIA_RENDERER
@main
struct SmartTranslatorApp: App {
    var body: some Scene {
        WindowGroup {
            TranslatorScreen()
        }
    }
}
#endif

struct TranslatorScreen: View {
    @StateObject private var model = SmartTranslatorModel()
    private let panelColor = Color.secondary.opacity(0.08)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    languageControls
                    inputCard
                    actionRow
                    outputCard
                    diagnosticsCard
                }
                .padding()
            }
            .navigationTitle("Smart Translator")
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

    private var languageControls: some View {
        HStack {
            Picker("Kaynak", selection: $model.sourceLanguage) {
                ForEach(AppLanguage.supported) { language in
                    Text(language.label).tag(language)
                }
            }

            Button(action: model.swapLanguages) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.headline)
            }
            .buttonStyle(.bordered)

            Picker("Hedef", selection: $model.targetLanguage) {
                ForEach(AppLanguage.supported) { language in
                    Text(language.label).tag(language)
                }
            }
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Girdi")
                .font(.headline)

            TextEditor(text: $model.sourceText)
                .frame(minHeight: 140)
                .padding(8)
                .background(panelColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let redactedPreview = model.redactedPreview {
                LabeledContent("Server preview", value: redactedPreview)
                    .font(.caption)
            }
        }
    }

    private var actionRow: some View {
        HStack {
            Button("Translate", action: model.translate)
                .buttonStyle(.borderedProminent)
                .disabled(model.isProcessing || model.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button("Speak", action: model.speakTranslation)
                .buttonStyle(.bordered)
                .disabled(model.translatedText.isEmpty)

            if model.isProcessing {
                ProgressView()
            }
        }
    }

    private var outputCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cikti")
                .font(.headline)

            TextEditor(text: .constant(model.translatedText))
                .frame(minHeight: 140)
                .padding(8)
                .background(panelColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let translationNote = model.translationNote {
                Text(translationNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var diagnosticsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Diagnostics")
                .font(.headline)

            LabeledContent("Detected", value: model.detectedLanguage)
            LabeledContent("Summary", value: model.summaryText)
            LabeledContent("Keywords", value: model.keywordsText)
            LabeledContent("Speech", value: model.speechStatus)
        }
        .font(.caption)
    }
}

@MainActor
final class SmartTranslatorModel: ObservableObject {
    @Published var sourceText = "Merhaba, yarin Istanbul'da toplanti yapacagiz."
    @Published var translatedText = ""
    @Published var summaryText = "-"
    @Published var keywordsText = "-"
    @Published var detectedLanguage = "-"
    @Published var speechStatus = "Hazir"
    @Published var redactedPreview: String?
    @Published var translationNote: String?
    @Published var errorMessage: String?
    @Published var isProcessing = false
    @Published var sourceLanguage = AppLanguage.turkish
    @Published var targetLanguage = AppLanguage.english

    private let nlpEngine = NLPEngine.shared
    private let speechEngine = SpeechEngine.shared
    private let tokenizer = PrivacyTokenizer()

    init() {
        SwiftIntelligenceCore.shared.configure(with: .production)
    }

    func swapLanguages() {
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
    }

    func translate() {
        Task { await runTranslation() }
    }

    func speakTranslation() {
        Task { await runSpeech() }
    }

    private func runTranslation() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let text = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
            let tokenized = try await tokenizer.tokenize(
                text,
                context: TokenizationContext(
                    purpose: .analytics,
                    sensitivity: .medium,
                    retentionPolicy: .temporary
                )
            )
            redactedPreview = tokenized.tokens.first

            let analysis = try await nlpEngine.analyze(text: text, options: .basic)
            detectedLanguage = analysis.detectedLanguage.rawValue

            let summary = try await nlpEngine.summarizeText(text: text, maxSentences: 2)
            summaryText = summary.summary

            let keywords = analysis.analysisResults["keywords"] as? [Keyword] ?? []
            keywordsText = keywords.prefix(5).map(\.word).joined(separator: ", ")

            let translation = try await nlpEngine.translateText(
                text: text,
                from: sourceLanguage.nlLanguage,
                to: targetLanguage.nlLanguage
            )
            translatedText = translation.translatedText
            translationNote = translation.confidence == 0
                ? "Mevcut translation API placeholder durumunda; demo gercek modul cagrisi yapiyor ama backend/model entegrasyonu henuz tamamli degil."
                : nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func runSpeech() async {
        do {
            let voice = SpeechEngine.availableVoices(for: targetLanguage.speechCode).first
            let result = try await speechEngine.synthesizeSpeech(
                from: translatedText,
                voice: voice,
                options: SpeechSynthesisOptions(language: targetLanguage.speechCode, speed: 0.48)
            )
            speechStatus = "\(result.originalText.count) karakter seslendirildi"
        } catch {
            errorMessage = error.localizedDescription
            speechStatus = "Basarisiz"
        }
    }
}

struct AppLanguage: Identifiable, Hashable {
    let id: String
    let name: String
    let flag: String
    let nlLanguage: NLLanguage
    let speechCode: String

    var label: String { "\(flag) \(name)" }

    static let turkish = AppLanguage(id: "tr", name: "Turkish", flag: "🇹🇷", nlLanguage: .turkish, speechCode: "tr-TR")
    static let english = AppLanguage(id: "en", name: "English", flag: "🇺🇸", nlLanguage: .english, speechCode: "en-US")
    static let spanish = AppLanguage(id: "es", name: "Spanish", flag: "🇪🇸", nlLanguage: .spanish, speechCode: "es-ES")
    static let french = AppLanguage(id: "fr", name: "French", flag: "🇫🇷", nlLanguage: .french, speechCode: "fr-FR")

    static let supported = [turkish, english, spanish, french]
}

import SwiftUI
import SwiftIntelligence
import SwiftIntelligenceNLP
import SwiftIntelligenceSpeech
import SwiftIntelligenceLLM
import SwiftIntelligencePrivacy
import AVFoundation
import Speech
import os.log

/// Smart Translator App - Advanced AI-powered translation with voice support
/// Features: Real-time translation, voice input/output, context awareness, cultural adaptation
@main
struct SmartTranslatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}

struct ContentView: View {
    @StateObject private var translatorManager = SmartTranslatorManager()
    @StateObject private var aiEngine = IntelligenceEngine()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HeaderView(translatorManager: translatorManager)
                
                // Language selector
                LanguageSelectorView(translatorManager: translatorManager)
                
                // Translation interface
                TranslationInterfaceView(translatorManager: translatorManager)
                
                // Controls
                ControlsView(translatorManager: translatorManager)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await initializeApp()
            }
        }
        .alert("Error", isPresented: .constant(translatorManager.errorMessage != nil)) {
            Button("OK") {
                translatorManager.clearError()
            }
        } message: {
            Text(translatorManager.errorMessage ?? "")
        }
    }
    
    private func initializeApp() async {
        do {
            try await aiEngine.initialize()
            await translatorManager.initialize(aiEngine: aiEngine)
        } catch {
            print("Failed to initialize app: \(error)")
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    @ObservedObject var translatorManager: SmartTranslatorManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Smart Translator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if translatorManager.isProcessing {
                    Text("Processing...")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("AI-Powered Translation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Settings button
            Button(action: { translatorManager.showSettings.toggle() }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Language Selector

struct LanguageSelectorView: View {
    @ObservedObject var translatorManager: SmartTranslatorManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Source language
            LanguageButton(
                language: translatorManager.sourceLanguage,
                isSource: true
            ) {
                translatorManager.showSourceLanguages = true
            }
            
            // Swap button
            Button(action: { translatorManager.swapLanguages() }) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            .disabled(translatorManager.isProcessing)
            
            // Target language
            LanguageButton(
                language: translatorManager.targetLanguage,
                isSource: false
            ) {
                translatorManager.showTargetLanguages = true
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .sheet(isPresented: $translatorManager.showSourceLanguages) {
            LanguagePickerView(
                selectedLanguage: $translatorManager.sourceLanguage,
                availableLanguages: translatorManager.availableLanguages,
                title: "Source Language"
            )
        }
        .sheet(isPresented: $translatorManager.showTargetLanguages) {
            LanguagePickerView(
                selectedLanguage: $translatorManager.targetLanguage,
                availableLanguages: translatorManager.availableLanguages,
                title: "Target Language"
            )
        }
    }
}

struct LanguageButton: View {
    let language: TranslationLanguage
    let isSource: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(language.flag)
                    .font(.title)
                
                Text(language.code.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(language.name)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundColor(.primary)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(.tertiarySystemFill))
            .cornerRadius(12)
        }
    }
}

// MARK: - Translation Interface

struct TranslationInterfaceView: View {
    @ObservedObject var translatorManager: SmartTranslatorManager
    
    var body: some View {
        VStack(spacing: 1) {
            // Input section
            InputSectionView(translatorManager: translatorManager)
            
            // Output section
            OutputSectionView(translatorManager: translatorManager)
        }
        .background(Color(.systemBackground))
    }
}

struct InputSectionView: View {
    @ObservedObject var translatorManager: SmartTranslatorManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("From: \(translatorManager.sourceLanguage.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !translatorManager.inputText.isEmpty {
                    Button("Clear") {
                        translatorManager.clearInput()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $translatorManager.inputText)
                    .font(.body)
                    .frame(minHeight: 100)
                    .onChange(of: translatorManager.inputText) { newValue in
                        translatorManager.onInputChanged(newValue)
                    }
                
                if translatorManager.inputText.isEmpty {
                    Text("Enter text to translate...")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            
            HStack {
                // Voice input button
                Button(action: { translatorManager.startVoiceInput() }) {
                    HStack {
                        Image(systemName: translatorManager.isListening ? "mic.fill" : "mic")
                            .foregroundColor(translatorManager.isListening ? .red : .blue)
                        Text(translatorManager.isListening ? "Listening..." : "Voice")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(translatorManager.isListening ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(translatorManager.isProcessing)
                
                Spacer()
                
                // Character count
                Text("\(translatorManager.inputText.count)/500")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

struct OutputSectionView: View {
    @ObservedObject var translatorManager: SmartTranslatorManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("To: \(translatorManager.targetLanguage.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !translatorManager.translatedText.isEmpty {
                    HStack(spacing: 16) {
                        // Copy button
                        Button(action: { translatorManager.copyTranslation() }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                        
                        // Speak button
                        Button(action: { translatorManager.speakTranslation() }) {
                            Image(systemName: translatorManager.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .foregroundColor(translatorManager.isSpeaking ? .red : .blue)
                        }
                    }
                }
            }
            
            ZStack(alignment: .topLeading) {
                if translatorManager.isProcessing {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Translating...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                } else if translatorManager.translatedText.isEmpty {
                    Text("Translation will appear here...")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                } else {
                    ScrollView {
                        Text(translatorManager.translatedText)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(minHeight: 100)
                }
            }
            
            // Translation quality and alternatives
            if let quality = translatorManager.translationQuality {
                TranslationQualityView(quality: quality)
            }
            
            if !translatorManager.alternativeTranslations.isEmpty {
                AlternativeTranslationsView(
                    alternatives: translatorManager.alternativeTranslations,
                    onSelect: translatorManager.selectAlternativeTranslation
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct TranslationQualityView: View {
    let quality: TranslationQuality
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal")
                .foregroundColor(quality.confidence > 0.8 ? .green : quality.confidence > 0.6 ? .orange : .red)
            
            Text("Quality: \(Int(quality.confidence * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if quality.hasContextualAdaptation {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                    .help("Contextually adapted translation")
            }
            
            if quality.hasCulturalAdaptation {
                Image(systemName: "globe")
                    .foregroundColor(.green)
                    .help("Culturally adapted translation")
            }
        }
    }
}

struct AlternativeTranslationsView: View {
    let alternatives: [AlternativeTranslation]
    let onSelect: (AlternativeTranslation) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Alternative Translations")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ForEach(alternatives) { alternative in
                Button(action: { onSelect(alternative) }) {
                    HStack {
                        Text(alternative.text)
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(alternative.context)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Controls

struct ControlsView: View {
    @ObservedObject var translatorManager: SmartTranslatorManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Translation mode toggle
            HStack {
                Text("Translation Mode")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Picker("Mode", selection: $translatorManager.translationMode) {
                    Text("Standard").tag(TranslationMode.standard)
                    Text("Contextual").tag(TranslationMode.contextual)
                    Text("Cultural").tag(TranslationMode.cultural)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Quick actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(translatorManager.quickPhrases, id: \.id) { phrase in
                        QuickPhraseButton(phrase: phrase) {
                            translatorManager.useQuickPhrase(phrase)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct QuickPhraseButton: View {
    let phrase: QuickPhrase
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: phrase.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(phrase.category)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.tertiarySystemFill))
            .cornerRadius(12)
        }
    }
}

// MARK: - Language Picker

struct LanguagePickerView: View {
    @Binding var selectedLanguage: TranslationLanguage
    let availableLanguages: [TranslationLanguage]
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(availableLanguages) { language in
                Button(action: {
                    selectedLanguage = language
                    dismiss()
                }) {
                    HStack {
                        Text(language.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(language.name)
                                .fontWeight(.medium)
                            Text(language.nativeName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if language.id == selectedLanguage.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Smart Translator Manager

@MainActor
class SmartTranslatorManager: NSObject, ObservableObject {
    
    private let logger = Logger(subsystem: "SmartTranslator", category: "TranslatorManager")
    
    // AI Engines
    private var aiEngine: IntelligenceEngine?
    private var nlpEngine: NLPEngine?
    private var speechEngine: SpeechEngine?
    private var llmEngine: LLMEngine?
    private var privacyEngine: PrivacyEngine?
    
    // Speech recognition
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // UI State
    @Published var sourceLanguage: TranslationLanguage = .english
    @Published var targetLanguage: TranslationLanguage = .turkish
    @Published var inputText: String = ""
    @Published var translatedText: String = ""
    @Published var isProcessing: Bool = false
    @Published var isListening: Bool = false
    @Published var isSpeaking: Bool = false
    @Published var showSettings: Bool = false
    @Published var showSourceLanguages: Bool = false
    @Published var showTargetLanguages: Bool = false
    @Published var translationMode: TranslationMode = .contextual
    @Published var errorMessage: String?
    
    // Translation results
    @Published var translationQuality: TranslationQuality?
    @Published var alternativeTranslations: [AlternativeTranslation] = []
    
    // Available languages
    let availableLanguages: [TranslationLanguage] = [
        .english, .turkish, .spanish, .french, .german, .italian,
        .portuguese, .russian, .chinese, .japanese, .korean, .arabic
    ]
    
    // Quick phrases
    let quickPhrases: [QuickPhrase] = [
        QuickPhrase(id: UUID(), category: "Greetings", icon: "hand.wave", phrases: ["Hello", "Good morning", "How are you?"]),
        QuickPhrase(id: UUID(), category: "Travel", icon: "airplane", phrases: ["Where is the airport?", "I need help", "Thank you"]),
        QuickPhrase(id: UUID(), category: "Food", icon: "fork.knife", phrases: ["I'm hungry", "The menu please", "This is delicious"]),
        QuickPhrase(id: UUID(), category: "Emergency", icon: "exclamationmark.triangle", phrases: ["Help!", "Call the police", "I need a doctor"])
    ]
    
    // Translation history
    private var translationHistory: [TranslationRecord] = []
    private var debounceTimer: Timer?
    
    func initialize(aiEngine: IntelligenceEngine) async {
        self.aiEngine = aiEngine
        
        do {
            // Initialize AI engines
            nlpEngine = try await aiEngine.getNLPEngine()
            speechEngine = try await aiEngine.getSpeechEngine()
            llmEngine = try await aiEngine.getLLMEngine()
            privacyEngine = try await aiEngine.getPrivacyEngine()
            
            // Setup speech recognition
            await setupSpeechRecognition()
            
            logger.info("Smart translator initialized successfully")
            
        } catch {
            logger.error("Failed to initialize translator: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func setupSpeechRecognition() async {
        // Request speech recognition permission
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        
        if authStatus != .authorized {
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status != .authorized {
                        self.errorMessage = "Speech recognition permission required"
                    }
                }
            }
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: sourceLanguage.locale))
    }
    
    // MARK: - Translation
    
    func onInputChanged(_ newValue: String) {
        // Debounce translation requests
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            Task {
                await self.translateText()
            }
        }
    }
    
    private func translateText() async {
        guard !inputText.isEmpty,
              !isProcessing,
              let nlpEngine = nlpEngine else {
            translatedText = ""
            translationQuality = nil
            alternativeTranslations = []
            return
        }
        
        isProcessing = true
        
        do {
            // Detect language if needed
            let detectedLanguage = try await detectLanguage(inputText)
            if detectedLanguage != sourceLanguage.code {
                logger.info("Detected language mismatch: \(detectedLanguage) vs \(sourceLanguage.code)")
            }
            
            // Perform translation based on mode
            let result = try await performTranslation(inputText, from: sourceLanguage, to: targetLanguage, mode: translationMode)
            
            translatedText = result.text
            translationQuality = result.quality
            alternativeTranslations = result.alternatives
            
            // Add to history
            let record = TranslationRecord(
                id: UUID(),
                sourceText: inputText,
                translatedText: result.text,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                timestamp: Date(),
                quality: result.quality
            )
            translationHistory.append(record)
            
            logger.info("Translation completed successfully")
            
        } catch {
            logger.error("Translation failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    private func detectLanguage(_ text: String) async throws -> String {
        guard let nlpEngine = nlpEngine else {
            throw TranslatorError.engineNotAvailable
        }
        
        let request = NLPRequest.languageDetection(text: text)
        let result = try await nlpEngine.processText(text, with: request)
        
        if case .languageDetection(let detectedLanguage) = result {
            return detectedLanguage.code
        }
        
        return sourceLanguage.code
    }
    
    private func performTranslation(_ text: String, from source: TranslationLanguage, to target: TranslationLanguage, mode: TranslationMode) async throws -> TranslationResult {
        
        switch mode {
        case .standard:
            return try await performStandardTranslation(text, from: source, to: target)
        case .contextual:
            return try await performContextualTranslation(text, from: source, to: target)
        case .cultural:
            return try await performCulturalTranslation(text, from: source, to: target)
        }
    }
    
    private func performStandardTranslation(_ text: String, from source: TranslationLanguage, to target: TranslationLanguage) async throws -> TranslationResult {
        guard let nlpEngine = nlpEngine else {
            throw TranslatorError.engineNotAvailable
        }
        
        let request = NLPRequest.translation(
            text: text,
            sourceLanguage: source.code,
            targetLanguage: target.code
        )
        
        let result = try await nlpEngine.processText(text, with: request)
        
        if case .translation(let translationResult) = result {
            let quality = TranslationQuality(
                confidence: translationResult.confidence,
                hasContextualAdaptation: false,
                hasCulturalAdaptation: false
            )
            
            return TranslationResult(
                text: translationResult.translatedText,
                quality: quality,
                alternatives: []
            )
        }
        
        throw TranslatorError.translationFailed
    }
    
    private func performContextualTranslation(_ text: String, from source: TranslationLanguage, to target: TranslationLanguage) async throws -> TranslationResult {
        guard let llmEngine = llmEngine else {
            return try await performStandardTranslation(text, from: source, to: target)
        }
        
        // Analyze context first
        let context = try await analyzeContext(text)
        
        // Generate contextual translation using LLM
        let systemPrompt = """
        You are an expert translator specializing in contextual translations between \(source.name) and \(target.name).
        Consider the context, tone, and nuances of the source text.
        Provide a natural, contextually appropriate translation.
        
        Context analysis: \(context.description)
        """
        
        let request = LLMRequest(
            messages: [
                LLMMessage(role: .system, content: systemPrompt),
                LLMMessage(role: .user, content: "Translate this text: \(text)")
            ],
            model: .gpt4,
            maxTokens: 500,
            temperature: 0.3
        )
        
        let response = try await llmEngine.generateResponse(request)
        
        // Also get standard translation for comparison
        let standardResult = try await performStandardTranslation(text, from: source, to: target)
        
        let quality = TranslationQuality(
            confidence: min(standardResult.quality.confidence + 0.1, 1.0),
            hasContextualAdaptation: true,
            hasCulturalAdaptation: false
        )
        
        let alternatives = [
            AlternativeTranslation(
                id: UUID(),
                text: standardResult.text,
                context: "Standard",
                confidence: standardResult.quality.confidence
            )
        ]
        
        return TranslationResult(
            text: response.content.trimmingCharacters(in: .whitespacesAndNewlines),
            quality: quality,
            alternatives: alternatives
        )
    }
    
    private func performCulturalTranslation(_ text: String, from source: TranslationLanguage, to target: TranslationLanguage) async throws -> TranslationResult {
        guard let llmEngine = llmEngine else {
            return try await performContextualTranslation(text, from: source, to: target)
        }
        
        // Get cultural context
        let culturalContext = getCulturalContext(for: target)
        
        let systemPrompt = """
        You are an expert cultural translator between \(source.name) and \(target.name).
        Consider cultural nuances, idioms, and appropriate expressions for the target culture.
        
        Cultural context for \(target.name): \(culturalContext)
        
        Provide a culturally appropriate translation that respects local customs and expressions.
        """
        
        let request = LLMRequest(
            messages: [
                LLMMessage(role: .system, content: systemPrompt),
                LLMMessage(role: .user, content: "Culturally adapt this translation: \(text)")
            ],
            model: .gpt4,
            maxTokens: 500,
            temperature: 0.4
        )
        
        let response = try await llmEngine.generateResponse(request)
        
        // Get contextual translation for comparison
        let contextualResult = try await performContextualTranslation(text, from: source, to: target)
        
        let quality = TranslationQuality(
            confidence: min(contextualResult.quality.confidence + 0.1, 1.0),
            hasContextualAdaptation: true,
            hasCulturalAdaptation: true
        )
        
        let alternatives = [
            AlternativeTranslation(
                id: UUID(),
                text: contextualResult.text,
                context: "Contextual",
                confidence: contextualResult.quality.confidence
            )
        ]
        
        return TranslationResult(
            text: response.content.trimmingCharacters(in: .whitespacesAndNewlines),
            quality: quality,
            alternatives: alternatives
        )
    }
    
    private func analyzeContext(_ text: String) async throws -> TextContext {
        // Simple context analysis - could be enhanced with NLP
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).count
        let hasQuestionMarks = text.contains("?")
        let hasExclamationMarks = text.contains("!")
        let isFormal = text.contains("please") || text.contains("thank you") || text.contains("sir") || text.contains("madam")
        
        return TextContext(
            wordCount: wordCount,
            isFormal: isFormal,
            isQuestion: hasQuestionMarks,
            isExclamatory: hasExclamationMarks
        )
    }
    
    private func getCulturalContext(for language: TranslationLanguage) -> String {
        switch language {
        case .turkish:
            return "Turkish culture values respect and formality, especially with elders. Use appropriate honorifics."
        case .japanese:
            return "Japanese culture emphasizes politeness levels (keigo). Consider the relationship between speaker and listener."
        case .arabic:
            return "Arabic culture values hospitality and respect. Consider religious and cultural sensitivities."
        case .chinese:
            return "Chinese culture emphasizes face-saving and indirect communication. Avoid direct confrontation."
        default:
            return "Consider local cultural norms and expressions appropriate for the target audience."
        }
    }
    
    // MARK: - Voice Input
    
    func startVoiceInput() {
        guard !isListening else {
            stopVoiceInput()
            return
        }
        
        Task {
            do {
                try await requestMicrophonePermission()
                await startSpeechRecognition()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func requestMicrophonePermission() async throws {
        let status = await AVAudioSession.sharedInstance().requestRecordPermission()
        if !status {
            throw TranslatorError.microphonePermissionDenied
        }
    }
    
    private func startSpeechRecognition() async {
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        isListening = true
        
        // Start recognition
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: sourceLanguage.locale))
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            
            if let result = result {
                DispatchQueue.main.async {
                    self?.inputText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                DispatchQueue.main.async {
                    self?.stopVoiceInput()
                }
            }
        }
    }
    
    private func stopVoiceInput() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
    }
    
    // MARK: - Speech Output
    
    func speakTranslation() {
        guard !translatedText.isEmpty,
              let speechEngine = speechEngine else { return }
        
        if isSpeaking {
            // Stop current speech
            Task {
                await speechEngine.stopSpeaking()
                isSpeaking = false
            }
            return
        }
        
        Task {
            do {
                isSpeaking = true
                
                let request = SpeechRequest.textToSpeech(
                    text: translatedText,
                    language: targetLanguage.code,
                    voice: nil,
                    rate: 0.5,
                    pitch: 1.0,
                    volume: 1.0
                )
                
                try await speechEngine.speak(request)
                isSpeaking = false
                
            } catch {
                isSpeaking = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - UI Actions
    
    func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        // Swap texts
        let tempText = inputText
        inputText = translatedText
        translatedText = tempText
        
        // Update speech recognizer
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: sourceLanguage.locale))
    }
    
    func clearInput() {
        inputText = ""
        translatedText = ""
        translationQuality = nil
        alternativeTranslations = []
    }
    
    func copyTranslation() {
        UIPasteboard.general.string = translatedText
    }
    
    func selectAlternativeTranslation(_ alternative: AlternativeTranslation) {
        translatedText = alternative.text
    }
    
    func useQuickPhrase(_ phrase: QuickPhrase) {
        if let randomPhrase = phrase.phrases.randomElement() {
            inputText = randomPhrase
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types

struct TranslationLanguage: Identifiable, Codable {
    let id = UUID()
    let code: String
    let name: String
    let nativeName: String
    let flag: String
    let locale: String
    
    static let english = TranslationLanguage(code: "en", name: "English", nativeName: "English", flag: "🇺🇸", locale: "en-US")
    static let turkish = TranslationLanguage(code: "tr", name: "Turkish", nativeName: "Türkçe", flag: "🇹🇷", locale: "tr-TR")
    static let spanish = TranslationLanguage(code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸", locale: "es-ES")
    static let french = TranslationLanguage(code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷", locale: "fr-FR")
    static let german = TranslationLanguage(code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪", locale: "de-DE")
    static let italian = TranslationLanguage(code: "it", name: "Italian", nativeName: "Italiano", flag: "🇮🇹", locale: "it-IT")
    static let portuguese = TranslationLanguage(code: "pt", name: "Portuguese", nativeName: "Português", flag: "🇵🇹", locale: "pt-PT")
    static let russian = TranslationLanguage(code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺", locale: "ru-RU")
    static let chinese = TranslationLanguage(code: "zh", name: "Chinese", nativeName: "中文", flag: "🇨🇳", locale: "zh-CN")
    static let japanese = TranslationLanguage(code: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵", locale: "ja-JP")
    static let korean = TranslationLanguage(code: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷", locale: "ko-KR")
    static let arabic = TranslationLanguage(code: "ar", name: "Arabic", nativeName: "العربية", flag: "🇸🇦", locale: "ar-SA")
}

enum TranslationMode: CaseIterable {
    case standard
    case contextual
    case cultural
    
    var title: String {
        switch self {
        case .standard: return "Standard"
        case .contextual: return "Contextual"
        case .cultural: return "Cultural"
        }
    }
}

struct TranslationResult {
    let text: String
    let quality: TranslationQuality
    let alternatives: [AlternativeTranslation]
}

struct TranslationQuality {
    let confidence: Float
    let hasContextualAdaptation: Bool
    let hasCulturalAdaptation: Bool
}

struct AlternativeTranslation: Identifiable {
    let id: UUID
    let text: String
    let context: String
    let confidence: Float
}

struct QuickPhrase: Identifiable {
    let id: UUID
    let category: String
    let icon: String
    let phrases: [String]
}

struct TranslationRecord: Identifiable {
    let id: UUID
    let sourceText: String
    let translatedText: String
    let sourceLanguage: TranslationLanguage
    let targetLanguage: TranslationLanguage
    let timestamp: Date
    let quality: TranslationQuality
}

struct TextContext {
    let wordCount: Int
    let isFormal: Bool
    let isQuestion: Bool
    let isExclamatory: Bool
    
    var description: String {
        var components: [String] = []
        components.append("Length: \(wordCount) words")
        if isFormal { components.append("formal tone") }
        if isQuestion { components.append("interrogative") }
        if isExclamatory { components.append("emphatic") }
        return components.joined(separator: ", ")
    }
}

enum TranslatorError: Error {
    case engineNotAvailable
    case translationFailed
    case microphonePermissionDenied
    case speechRecognitionFailed
}

extension TranslatorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .engineNotAvailable:
            return "Translation engine not available"
        case .translationFailed:
            return "Translation failed"
        case .microphonePermissionDenied:
            return "Microphone permission required for voice input"
        case .speechRecognitionFailed:
            return "Speech recognition failed"
        }
    }
}
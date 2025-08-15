import SwiftUI
import SwiftIntelligence
import SwiftIntelligenceSpeech
import SwiftIntelligenceLLM
import SwiftIntelligencePrivacy
import SwiftIntelligenceNLP
import AVFoundation
import Speech
import os.log

/// Voice Assistant App - Advanced AI-powered voice assistant with contextual understanding
/// Features: Natural conversation, task automation, smart responses, multi-language support
@main
struct VoiceAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @StateObject private var voiceManager = VoiceAssistantManager()
    @StateObject private var aiEngine = IntelligenceEngine()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView(voiceManager: voiceManager)
                    
                    Spacer()
                    
                    // Main voice interface
                    VoiceInterfaceView(voiceManager: voiceManager)
                    
                    Spacer()
                    
                    // Conversation history
                    ConversationHistoryView(voiceManager: voiceManager)
                        .frame(maxHeight: geometry.size.height * 0.4)
                    
                    // Controls
                    VoiceControlsView(voiceManager: voiceManager)
                        .padding(.bottom)
                }
                .padding()
                
                // Status overlay
                if voiceManager.isProcessing {
                    ProcessingOverlay()
                }
                
                // Settings sheet
                if voiceManager.showSettings {
                    SettingsView(voiceManager: voiceManager)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .onAppear {
            Task {
                await initializeApp()
            }
        }
    }
    
    private func initializeApp() async {
        do {
            // Initialize AI engine
            try await aiEngine.initialize()
            
            // Initialize voice assistant
            await voiceManager.initialize(aiEngine: aiEngine)
            
        } catch {
            print("Failed to initialize app: \(error)")
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    @ObservedObject var voiceManager: VoiceAssistantManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Voice Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("AI-powered voice companion")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Status indicators
            HStack(spacing: 16) {
                // Language indicator
                LanguageIndicator(currentLanguage: voiceManager.currentLanguage)
                
                // Settings button
                Button(action: { voiceManager.showSettings.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct LanguageIndicator: View {
    let currentLanguage: VoiceLanguage
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "globe")
                .font(.caption)
            Text(currentLanguage.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .clipShape(Capsule())
    }
}

// MARK: - Voice Interface

struct VoiceInterfaceView: View {
    @ObservedObject var voiceManager: VoiceAssistantManager
    
    var body: some View {
        VStack(spacing: 32) {
            // Assistant avatar
            AssistantAvatarView(
                isListening: voiceManager.isListening,
                isSpeaking: voiceManager.isSpeaking,
                voiceLevel: voiceManager.voiceLevel
            )
            
            // Status text
            VStack(spacing: 8) {
                Text(voiceManager.statusText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if !voiceManager.currentTranscription.isEmpty {
                    Text(""\(voiceManager.currentTranscription)"")
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct AssistantAvatarView: View {
    let isListening: Bool
    let isSpeaking: Bool
    let voiceLevel: Float
    
    @State private var pulseAnimation = false
    @State private var waveAnimation = false
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 200, height: 200)
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .opacity(pulseAnimation ? 0.3 : 0.8)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
            
            // Voice level visualization
            if isListening {
                VoiceLevelVisualization(level: voiceLevel)
                    .frame(width: 180, height: 180)
            }
            
            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
            
            // Icon
            Group {
                if isListening {
                    Image(systemName: "waveform")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .scaleEffect(waveAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: waveAnimation)
                } else if isSpeaking {
                    Image(systemName: "speaker.wave.3")
                        .font(.system(size: 48))
                        .foregroundColor(.purple)
                        .scaleEffect(waveAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: waveAnimation)
                } else {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            pulseAnimation = true
        }
        .onChange(of: isListening) { listening in
            waveAnimation = listening
        }
        .onChange(of: isSpeaking) { speaking in
            waveAnimation = speaking
        }
    }
}

struct VoiceLevelVisualization: View {
    let level: Float
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.6))
                    .frame(
                        width: 4,
                        height: CGFloat(level * 60 + 10)
                    )
                    .offset(
                        x: cos(Double(index) * .pi / 6) * 60,
                        y: sin(Double(index) * .pi / 6) * 60
                    )
                    .animation(.easeInOut(duration: 0.1), value: level)
            }
        }
    }
}

// MARK: - Conversation History

struct ConversationHistoryView: View {
    @ObservedObject var voiceManager: VoiceAssistantManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Conversation")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !voiceManager.conversationHistory.isEmpty {
                    Button("Clear") {
                        voiceManager.clearHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(voiceManager.conversationHistory) { message in
                        ConversationMessageView(message: message)
                    }
                }
                .padding(.horizontal, 4)
            }
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct ConversationMessageView: View {
    let message: ConversationMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            Image(systemName: message.isUser ? "person.circle.fill" : "brain.head.profile")
                .font(.title3)
                .foregroundColor(message.isUser ? .blue : .purple)
                .frame(width: 32, height: 32)
            
            // Message content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.isUser ? "You" : "Assistant")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(message.isUser ? .blue : .purple)
                    
                    Spacer()
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Show additional info if available
                if let intent = message.detectedIntent {
                    Label(intent, systemImage: "lightbulb.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow.opacity(0.8))
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Voice Controls

struct VoiceControlsView: View {
    @ObservedObject var voiceManager: VoiceAssistantManager
    
    var body: some View {
        HStack(spacing: 24) {
            // Mute button
            Button(action: { voiceManager.toggleMute() }) {
                Image(systemName: voiceManager.isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.title2)
                    .foregroundColor(voiceManager.isMuted ? .red : .white)
                    .padding(16)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Main voice button
            Button(action: { voiceManager.toggleListening() }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: voiceManager.isListening ? [.red, .orange] : [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: voiceManager.isListening ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .scaleEffect(voiceManager.isListening ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: voiceManager.isListening)
            }
            .disabled(voiceManager.isProcessing)
            
            Spacer()
            
            // Stop speaking button
            Button(action: { voiceManager.stopSpeaking() }) {
                Image(systemName: "speaker.slash.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(voiceManager.isSpeaking ? 0.2 : 0.05))
                    .clipShape(Circle())
            }
            .opacity(voiceManager.isSpeaking ? 1.0 : 0.5)
        }
    }
}

// MARK: - Processing Overlay

struct ProcessingOverlay: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0.0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(Angle(degrees: rotation))
                        .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotation)
                }
                
                Text("Processing...")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .onAppear {
            rotation = 360
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var voiceManager: VoiceAssistantManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    voiceManager.showSettings = false
                }
            
            VStack(spacing: 24) {
                HStack {
                    Text("Voice Assistant Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        voiceManager.showSettings = false
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(spacing: 16) {
                    // Language selection
                    SettingRow(
                        title: "Language",
                        value: voiceManager.currentLanguage.displayName
                    ) {
                        // Language picker would go here
                    }
                    
                    // Voice settings
                    SettingRow(
                        title: "Voice Speed",
                        value: String(format: "%.1fx", voiceManager.speechRate)
                    ) {
                        // Speed slider would go here
                    }
                    
                    // Privacy settings
                    SettingRow(
                        title: "Privacy Mode",
                        value: voiceManager.privacyMode ? "On" : "Off"
                    ) {
                        voiceManager.privacyMode.toggle()
                    }
                    
                    // Wake word
                    SettingRow(
                        title: "Wake Word",
                        value: voiceManager.wakeWordEnabled ? "Enabled" : "Disabled"
                    ) {
                        voiceManager.wakeWordEnabled.toggle()
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: 400)
            .background(Color.black.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SettingRow: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(value)
                    .foregroundColor(.blue)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Voice Assistant Manager

@MainActor
class VoiceAssistantManager: NSObject, ObservableObject {
    
    private let logger = Logger(subsystem: "VoiceAssistant", category: "Manager")
    
    // AI Engines
    private var aiEngine: IntelligenceEngine?
    private var speechEngine: SpeechEngine?
    private var llmEngine: LLMEngine?
    private var nlpEngine: NaturalLanguageEngine?
    private var privacyEngine: PrivacyEngine?
    
    // Speech Recognition and Synthesis
    private var speechRecognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var speechTask: SFSpeechRecognitionTask?
    private var speechSynthesizer: AVSpeechSynthesizer?
    
    // State
    @Published var isListening: Bool = false
    @Published var isSpeaking: Bool = false
    @Published var isProcessing: Bool = false
    @Published var isMuted: Bool = false
    @Published var showSettings: Bool = false
    
    // Voice input/output
    @Published var currentTranscription: String = ""
    @Published var voiceLevel: Float = 0.0
    @Published var statusText: String = "Press the button to start talking"
    
    // Conversation
    @Published var conversationHistory: [ConversationMessage] = []
    
    // Settings
    @Published var currentLanguage: VoiceLanguage = .english
    @Published var speechRate: Float = 1.0
    @Published var privacyMode: Bool = false
    @Published var wakeWordEnabled: Bool = false
    
    // Context management
    private var conversationContext: ConversationContext = ConversationContext()
    private var lastInteractionTime: Date = Date()
    
    func initialize(aiEngine: IntelligenceEngine) async {
        self.aiEngine = aiEngine
        
        do {
            // Initialize AI engines
            speechEngine = try await aiEngine.getSpeechEngine()
            llmEngine = try await aiEngine.getLLMEngine()
            nlpEngine = try await aiEngine.getNaturalLanguageEngine()
            privacyEngine = try await aiEngine.getPrivacyEngine()
            
            // Setup speech recognition
            await setupSpeechRecognition()
            
            // Setup speech synthesis
            await setupSpeechSynthesis()
            
            // Request permissions
            await requestPermissions()
            
            logger.info("Voice assistant initialized successfully")
            
        } catch {
            logger.error("Failed to initialize voice assistant: \(error.localizedDescription)")
        }
    }
    
    private func setupSpeechRecognition() async {
        speechRecognizer = SFSpeechRecognizer(locale: currentLanguage.locale)
        audioEngine = AVAudioEngine()
        
        guard let recognizer = speechRecognizer else {
            logger.error("Speech recognizer not available for locale: \(currentLanguage.locale)")
            return
        }
        
        guard recognizer.isAvailable else {
            logger.error("Speech recognizer not available")
            return
        }
        
        logger.info("Speech recognition setup complete")
    }
    
    private func setupSpeechSynthesis() async {
        speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer?.delegate = self
        
        logger.info("Speech synthesis setup complete")
    }
    
    private func requestPermissions() async {
        // Request speech recognition permission
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                self.logger.info("Speech recognition permission: \(status.rawValue)")
                continuation.resume()
            }
        }
        
        // Request microphone permission
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                self.logger.info("Microphone permission: \(granted)")
                continuation.resume()
            }
        }
    }
    
    // MARK: - Voice Control
    
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    private func startListening() {
        guard !isListening && !isMuted else { return }
        
        logger.info("Starting voice input")
        
        isListening = true
        currentTranscription = ""
        statusText = "Listening..."
        
        Task {
            await performSpeechRecognition()
        }
    }
    
    private func stopListening() {
        guard isListening else { return }
        
        logger.info("Stopping voice input")
        
        isListening = false
        statusText = "Processing..."
        
        // Stop speech recognition
        speechTask?.cancel()
        speechTask = nil
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // Process the transcription
        if !currentTranscription.isEmpty {
            Task {
                await processUserInput(currentTranscription)
            }
        }
    }
    
    private func performSpeechRecognition() async {
        guard let recognizer = speechRecognizer,
              let audioEngine = audioEngine else { return }
        
        do {
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Create recognition request
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // Install audio tap
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
                
                // Update voice level
                let level = self.calculateAudioLevel(from: buffer)
                DispatchQueue.main.async {
                    self.voiceLevel = level
                }
            }
            
            // Start audio engine
            audioEngine.prepare()
            try audioEngine.start()
            
            // Start speech recognition
            speechTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    DispatchQueue.main.async {
                        self.currentTranscription = result.bestTranscription.formattedString
                    }
                }
                
                if let error = error {
                    self.logger.error("Speech recognition error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.stopListening()
                    }
                }
            }
            
        } catch {
            logger.error("Failed to start speech recognition: \(error.localizedDescription)")
            await MainActor.run {
                isListening = false
                statusText = "Failed to start listening"
            }
        }
    }
    
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0.0 }
        
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0.0
        
        for i in 0..<frameLength {
            sum += abs(channelData[i])
        }
        
        let average = sum / Float(frameLength)
        return min(average * 10, 1.0) // Scale and cap at 1.0
    }
    
    func toggleMute() {
        isMuted.toggle()
        
        if isMuted && isListening {
            stopListening()
        }
        
        statusText = isMuted ? "Microphone muted" : "Ready to listen"
        logger.info("Microphone \(isMuted ? "muted" : "unmuted")")
    }
    
    func stopSpeaking() {
        guard isSpeaking else { return }
        
        speechSynthesizer?.stopSpeaking(at: .immediate)
        isSpeaking = false
        statusText = "Ready to listen"
        
        logger.info("Speech synthesis stopped")
    }
    
    // MARK: - AI Processing
    
    private func processUserInput(_ input: String) async {
        isProcessing = true
        
        do {
            // Apply privacy protection if enabled
            let processedInput = privacyMode ? await applyPrivacyProtection(input) : input
            
            // Add user message to history
            let userMessage = ConversationMessage(
                id: UUID(),
                content: input,
                isUser: true,
                timestamp: Date(),
                detectedIntent: nil
            )
            conversationHistory.append(userMessage)
            
            // Perform natural language understanding
            let nlpAnalysis = try await performNLPAnalysis(processedInput)
            
            // Update conversation context
            updateConversationContext(with: nlpAnalysis)
            
            // Generate AI response
            let aiResponse = try await generateAIResponse(
                input: processedInput,
                context: conversationContext,
                nlpAnalysis: nlpAnalysis
            )
            
            // Add AI message to history
            let aiMessage = ConversationMessage(
                id: UUID(),
                content: aiResponse.content,
                isUser: false,
                timestamp: Date(),
                detectedIntent: nlpAnalysis.intent
            )
            conversationHistory.append(aiMessage)
            
            // Speak the response
            await speakResponse(aiResponse.content)
            
            lastInteractionTime = Date()
            
        } catch {
            logger.error("Failed to process user input: \(error.localizedDescription)")
            
            let errorMessage = "I'm sorry, I couldn't process that. Could you try again?"
            await speakResponse(errorMessage)
        }
        
        isProcessing = false
        statusText = "Ready to listen"
    }
    
    private func applyPrivacyProtection(_ input: String) async -> String {
        guard let privacyEngine = privacyEngine else { return input }
        
        do {
            let protectedText = try await privacyEngine.protectSensitiveText(input)
            return protectedText
        } catch {
            logger.error("Privacy protection failed: \(error.localizedDescription)")
            return input
        }
    }
    
    private func performNLPAnalysis(_ input: String) async throws -> NLPAnalysis {
        guard let nlpEngine = nlpEngine else {
            throw VoiceAssistantError.nlpEngineNotAvailable
        }
        
        // Perform intent classification
        let intentRequest = NLPRequest.intentClassification(
            text: input,
            language: currentLanguage.nlpLanguage
        )
        let intentResult = try await nlpEngine.processText(intentRequest)
        
        // Extract entities
        let entityRequest = NLPRequest.entityRecognition(
            text: input,
            language: currentLanguage.nlpLanguage
        )
        let entityResult = try await nlpEngine.processText(entityRequest)
        
        // Sentiment analysis
        let sentimentRequest = NLPRequest.sentimentAnalysis(
            text: input,
            language: currentLanguage.nlpLanguage
        )
        let sentimentResult = try await nlpEngine.processText(sentimentRequest)
        
        var intent: String?
        var entities: [String] = []
        var sentiment: String?
        
        if case .intentClassification(let intents) = intentResult, let topIntent = intents.first {
            intent = topIntent.label
        }
        
        if case .entityRecognition(let recognizedEntities) = entityResult {
            entities = recognizedEntities.map { $0.text }
        }
        
        if case .sentimentAnalysis(let sentiments) = sentimentResult, let topSentiment = sentiments.first {
            sentiment = topSentiment.label
        }
        
        return NLPAnalysis(
            intent: intent,
            entities: entities,
            sentiment: sentiment,
            confidence: 0.8
        )
    }
    
    private func updateConversationContext(with analysis: NLPAnalysis) {
        conversationContext.addInteraction(
            userInput: currentTranscription,
            intent: analysis.intent,
            entities: analysis.entities,
            timestamp: Date()
        )
        
        // Keep context window manageable
        conversationContext.pruneOldInteractions(maxAge: 30 * 60) // 30 minutes
    }
    
    private func generateAIResponse(input: String, context: ConversationContext, nlpAnalysis: NLPAnalysis) async throws -> AIResponse {
        guard let llmEngine = llmEngine else {
            throw VoiceAssistantError.llmEngineNotAvailable
        }
        
        // Build context for LLM
        let systemPrompt = """
        You are a helpful AI voice assistant. You provide concise, natural, and conversational responses.
        The user is speaking to you through voice, so keep responses brief and easy to understand when spoken.
        
        Current context:
        - User's intent: \(nlpAnalysis.intent ?? "unknown")
        - Detected entities: \(nlpAnalysis.entities.joined(separator: ", "))
        - User's sentiment: \(nlpAnalysis.sentiment ?? "neutral")
        - Conversation history: \(context.getRecentInteractions(count: 3))
        
        Respond in a natural, conversational way as if speaking aloud.
        """
        
        let request = LLMRequest(
            messages: [
                LLMMessage(role: .system, content: systemPrompt),
                LLMMessage(role: .user, content: input)
            ],
            model: .gpt4,
            maxTokens: 150,
            temperature: 0.7
        )
        
        let response = try await llmEngine.generateResponse(request)
        
        return AIResponse(
            content: response.content,
            intent: nlpAnalysis.intent,
            confidence: 0.9
        )
    }
    
    private func speakResponse(_ text: String) async {
        guard let synthesizer = speechSynthesizer else { return }
        
        isSpeaking = true
        statusText = "Speaking..."
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: currentLanguage.speechLanguage)
        utterance.rate = speechRate * 0.5 // Adjust base rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - Conversation Management
    
    func clearHistory() {
        conversationHistory.removeAll()
        conversationContext = ConversationContext()
        logger.info("Conversation history cleared")
    }
}

// MARK: - Speech Synthesizer Delegate

extension VoiceAssistantManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        statusText = "Ready to listen"
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        statusText = "Ready to listen"
    }
}

// MARK: - Supporting Types

struct ConversationMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let detectedIntent: String?
}

struct NLPAnalysis {
    let intent: String?
    let entities: [String]
    let sentiment: String?
    let confidence: Float
}

struct AIResponse {
    let content: String
    let intent: String?
    let confidence: Float
}

class ConversationContext {
    private var interactions: [ConversationInteraction] = []
    
    func addInteraction(userInput: String, intent: String?, entities: [String], timestamp: Date) {
        let interaction = ConversationInteraction(
            userInput: userInput,
            intent: intent,
            entities: entities,
            timestamp: timestamp
        )
        interactions.append(interaction)
    }
    
    func getRecentInteractions(count: Int) -> String {
        let recentInteractions = interactions.suffix(count)
        return recentInteractions.map { interaction in
            "User: \(interaction.userInput) (Intent: \(interaction.intent ?? "unknown"))"
        }.joined(separator: "\n")
    }
    
    func pruneOldInteractions(maxAge: TimeInterval) {
        let cutoffTime = Date().addingTimeInterval(-maxAge)
        interactions.removeAll { $0.timestamp < cutoffTime }
    }
}

struct ConversationInteraction {
    let userInput: String
    let intent: String?
    let entities: [String]
    let timestamp: Date
}

enum VoiceLanguage: String, CaseIterable {
    case english = "en-US"
    case spanish = "es-ES"
    case french = "fr-FR"
    case german = "de-DE"
    case italian = "it-IT"
    case turkish = "tr-TR"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .turkish: return "Türkçe"
        }
    }
    
    var locale: Locale {
        return Locale(identifier: rawValue)
    }
    
    var speechLanguage: String {
        return rawValue
    }
    
    var nlpLanguage: NLPLanguage {
        switch self {
        case .english: return .english
        case .spanish: return .spanish
        case .french: return .french
        case .german: return .german
        case .italian: return .italian
        case .turkish: return .turkish
        }
    }
}

enum VoiceAssistantError: Error {
    case speechEngineNotAvailable
    case llmEngineNotAvailable
    case nlpEngineNotAvailable
    case privacyEngineNotAvailable
    case speechRecognitionFailed
    case speechSynthesisFailed
    case processingFailed
}
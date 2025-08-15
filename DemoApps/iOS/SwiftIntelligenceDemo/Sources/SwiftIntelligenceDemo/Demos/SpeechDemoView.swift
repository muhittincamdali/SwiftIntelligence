import SwiftUI
import SwiftIntelligenceSpeech
import SwiftIntelligenceCore

struct SpeechDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var isRecording = false
    @State private var isProcessing = false
    @State private var isSpeaking = false
    @State private var recognizedText: String = ""
    @State private var textToSpeak: String = "Welcome to SwiftIntelligence Speech Engine. This is a demonstration of text-to-speech capabilities."
    @State private var selectedVoice: VoiceType = .natural
    @State private var selectedRecognitionLanguage: RecognitionLanguage = .english
    @State private var speechResults: [SpeechResult] = []
    @State private var recordingLevel: Float = 0.0
    @State private var recordingTimer: Timer?
    
    enum VoiceType: String, CaseIterable {
        case natural = "Natural Voice"
        case robotic = "Robotic Voice"
        case whispering = "Whispering Voice"
        case enhanced = "Enhanced Voice"
        
        var icon: String {
            switch self {
            case .natural: return "speaker.wave.2"
            case .robotic: return "gearshape.2"
            case .whispering: return "speaker.wave.1"
            case .enhanced: return "speaker.wave.3"
            }
        }
        
        var description: String {
            switch self {
            case .natural: return "Human-like natural voice synthesis"
            case .robotic: return "Synthetic robotic voice tone"
            case .whispering: return "Soft whispering voice effect"
            case .enhanced: return "Enhanced quality with emotion"
            }
        }
    }
    
    enum RecognitionLanguage: String, CaseIterable {
        case english = "English (US)"
        case spanish = "Español"
        case french = "Français"
        case german = "Deutsch"
        case turkish = "Türkçe"
        
        var code: String {
            switch self {
            case .english: return "en-US"
            case .spanish: return "es-ES"
            case .french: return "fr-FR"
            case .german: return "de-DE"
            case .turkish: return "tr-TR"
            }
        }
        
        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            case .spanish: return "🇪🇸"
            case .french: return "🇫🇷"
            case .german: return "🇩🇪"
            case .turkish: return "🇹🇷"
            }
        }
    }
    
    struct SpeechResult: Identifiable {
        let id = UUID()
        let type: ResultType
        let text: String
        let confidence: Float
        let timestamp: Date
        let duration: TimeInterval?
        
        enum ResultType: String {
            case recognition = "Speech Recognition"
            case synthesis = "Text-to-Speech"
            
            var icon: String {
                switch self {
                case .recognition: return "mic"
                case .synthesis: return "speaker.wave.2"
                }
            }
            
            var color: Color {
                switch self {
                case .recognition: return .blue
                case .synthesis: return .green
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.orange)
                            .font(.title)
                        Text("Speech Processing Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Advanced speech recognition and text-to-speech synthesis")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Speech Recognition Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Speech Recognition")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Language Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recognition Language:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(RecognitionLanguage.allCases, id: \.rawValue) { language in
                                        Button(action: {
                                            selectedRecognitionLanguage = language
                                        }) {
                                            HStack {
                                                Text(language.flag)
                                                Text(language.rawValue)
                                                    .font(.caption)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedRecognitionLanguage == language ? Color.blue : Color.blue.opacity(0.1))
                                            .foregroundColor(selectedRecognitionLanguage == language ? .white : .primary)
                                            .cornerRadius(15)
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                        
                        // Recording Interface
                        VStack(spacing: 12) {
                            // Audio Level Indicator
                            if isRecording {
                                VStack {
                                    HStack {
                                        ForEach(0..<10, id: \.self) { index in
                                            Rectangle()
                                                .fill(Color.blue.opacity(recordingLevel > Float(index) * 0.1 ? 0.8 : 0.2))
                                                .frame(width: 4, height: CGFloat(10 + index * 3))
                                                .animation(.easeInOut(duration: 0.1), value: recordingLevel)
                                        }
                                    }
                                    Text("Recording...")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // Recording Button
                            Button(action: {
                                Task {
                                    if isRecording {
                                        await stopRecording()
                                    } else {
                                        await startRecording()
                                    }
                                }
                            }) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(isRecording ? Color.red : Color.blue)
                                            .frame(width: 80, height: 80)
                                            .scaleEffect(isRecording ? 1.1 : 1.0)
                                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isRecording)
                                        
                                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                            .foregroundColor(.white)
                                            .font(.title)
                                    }
                                    
                                    Text(isRecording ? "Stop Recording" : "Start Recording")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                            .disabled(isProcessing)
                            
                            // Recognized Text Display
                            if !recognizedText.isEmpty || isProcessing {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Recognized Text:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if isProcessing {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Processing speech...")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                    } else {
                                        Text(recognizedText)
                                            .padding()
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                            .contextMenu {
                                                Button("Copy") {
                                                    UIPasteboard.general.string = recognizedText
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Text-to-Speech Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Text-to-Speech Synthesis")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Voice Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Voice Type:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(VoiceType.allCases, id: \.rawValue) { voice in
                                    Button(action: {
                                        selectedVoice = voice
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: voice.icon)
                                                .font(.title3)
                                                .foregroundColor(selectedVoice == voice ? .white : .green)
                                            Text(voice.rawValue)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedVoice == voice ? .white : .primary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(height: 60)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedVoice == voice ? Color.green : Color.green.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            
                            Text(selectedVoice.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        }
                        
                        // Text Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Text to Speak:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $textToSpeak)
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            
                            HStack {
                                Text("\(textToSpeak.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Clear") {
                                    textToSpeak = ""
                                }
                                .font(.caption)
                                .foregroundColor(.green)
                            }
                            
                            // Sample texts
                            Text("Quick samples:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(sampleTexts, id: \.self) { sample in
                                        Button(action: {
                                            textToSpeak = sample
                                        }) {
                                            Text(sample.prefix(25) + "...")
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                        
                        // Speak Button
                        Button(action: {
                            Task {
                                if isSpeaking {
                                    await stopSpeaking()
                                } else {
                                    await startSpeaking()
                                }
                            }
                        }) {
                            HStack {
                                if isSpeaking {
                                    Image(systemName: "stop.fill")
                                } else {
                                    Image(systemName: "play.fill")
                                }
                                Text(isSpeaking ? "Stop Speaking" : "Speak Text")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isSpeaking ? Color.red : (textToSpeak.isEmpty ? Color.gray : Color.green))
                            .cornerRadius(10)
                        }
                        .disabled(textToSpeak.isEmpty || isProcessing)
                    }
                }
                
                Divider()
                
                // Results History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Speech Processing History")
                        .font(.headline)
                    
                    if speechResults.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "waveform.badge.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No speech processing performed yet")
                                .foregroundColor(.secondary)
                            Text("Try recording speech or synthesizing text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(speechResults.reversed()) { result in
                            SpeechResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Speech Engine")
        .onDisappear {
            // Cleanup when view disappears
            recordingTimer?.invalidate()
            Task {
                if isSpeaking {
                    await stopSpeaking()
                }
                if isRecording {
                    await stopRecording()
                }
            }
        }
    }
    
    private var sampleTexts: [String] {
        [
            "Hello! Welcome to SwiftIntelligence Speech Engine.",
            "Artificial intelligence is transforming the world of technology.",
            "Speech recognition and synthesis are powerful tools for accessibility.",
            "The future of human-computer interaction is voice-driven interfaces."
        ]
    }
    
    // MARK: - Speech Recognition Methods
    
    @MainActor
    private func startRecording() async {
        guard let speechEngine = appManager.getSpeechEngine() else { return }
        
        isRecording = true
        isProcessing = false
        recognizedText = ""
        
        // Start audio level simulation
        startRecordingAnimation()
        
        do {
            let recognitionRequest = SpeechRecognitionRequest(
                languageCode: selectedRecognitionLanguage.code,
                continuous: true,
                enablePartialResults: true
            )
            
            let result = try await speechEngine.recognizeSpeech(request: recognitionRequest)
            
            recognizedText = result.transcript
            let speechResult = SpeechResult(
                type: .recognition,
                text: result.transcript,
                confidence: result.confidence,
                timestamp: Date(),
                duration: result.duration
            )
            speechResults.append(speechResult)
            
        } catch {
            recognizedText = "Recognition failed: \(error.localizedDescription)"
        }
        
        isRecording = false
        isProcessing = false
        recordingTimer?.invalidate()
    }
    
    @MainActor
    private func stopRecording() async {
        guard let speechEngine = appManager.getSpeechEngine() else { return }
        
        isProcessing = true
        recordingTimer?.invalidate()
        
        do {
            try await speechEngine.stopRecording()
        } catch {
            print("Failed to stop recording: \(error)")
        }
        
        // Processing will complete in startRecording() method
    }
    
    private func startRecordingAnimation() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation {
                recordingLevel = Float.random(in: 0.2...1.0)
            }
        }
    }
    
    // MARK: - Text-to-Speech Methods
    
    @MainActor
    private func startSpeaking() async {
        guard let speechEngine = appManager.getSpeechEngine() else { return }
        
        isSpeaking = true
        
        do {
            let synthesisRequest = TextToSpeechRequest(
                text: textToSpeak,
                voiceID: getVoiceID(for: selectedVoice),
                rate: 0.5,
                pitch: 1.0,
                volume: 1.0
            )
            
            let startTime = Date()
            let result = try await speechEngine.synthesizeSpeech(request: synthesisRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let speechResult = SpeechResult(
                type: .synthesis,
                text: textToSpeak,
                confidence: result.quality,
                timestamp: Date(),
                duration: duration
            )
            speechResults.append(speechResult)
            
        } catch {
            let errorResult = SpeechResult(
                type: .synthesis,
                text: "Synthesis failed: \(error.localizedDescription)",
                confidence: 0.0,
                timestamp: Date(),
                duration: nil
            )
            speechResults.append(errorResult)
        }
        
        isSpeaking = false
    }
    
    @MainActor
    private func stopSpeaking() async {
        guard let speechEngine = appManager.getSpeechEngine() else { return }
        
        do {
            try await speechEngine.stopSpeaking()
        } catch {
            print("Failed to stop speaking: \(error)")
        }
        
        isSpeaking = false
    }
    
    private func getVoiceID(for voice: VoiceType) -> String {
        switch voice {
        case .natural:
            return "natural_voice"
        case .robotic:
            return "robotic_voice"
        case .whispering:
            return "whisper_voice"
        case .enhanced:
            return "enhanced_voice"
        }
    }
}

struct SpeechResultCard: View {
    let result: SpeechDemoView.SpeechResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.type.icon)
                    .foregroundColor(result.type.color)
                Text(result.type.rawValue)
                    .font(.headline)
                Spacer()
                Text(timeAgoString(from: result.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(result.text)
                .font(.body)
                .padding(10)
                .background(result.type.color.opacity(0.1))
                .cornerRadius(8)
            
            HStack {
                if result.confidence > 0 {
                    HStack {
                        Text("Confidence:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(result.confidence * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(result.type.color.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                if let duration = result.duration {
                    Spacer()
                    HStack {
                        Text("Duration:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2fs", duration))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
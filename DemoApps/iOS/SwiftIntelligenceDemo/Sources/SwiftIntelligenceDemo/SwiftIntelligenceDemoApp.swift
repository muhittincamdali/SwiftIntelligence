import SwiftUI
import SwiftIntelligence
import SwiftIntelligenceML
import SwiftIntelligenceNLP
import SwiftIntelligenceVision
import SwiftIntelligenceSpeech
import SwiftIntelligenceReasoning
import SwiftIntelligenceImageGeneration
import SwiftIntelligencePrivacy
import SwiftIntelligenceNetwork
import SwiftIntelligenceCache
import SwiftIntelligenceMetrics

@main
struct SwiftIntelligenceDemoApp: App {
    @StateObject private var appManager = DemoAppManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appManager)
                .task {
                    await appManager.initialize()
                }
        }
    }
}

@MainActor
class DemoAppManager: ObservableObject {
    @Published var isInitialized = false
    @Published var isLoading = false
    @Published var error: String?
    
    // SwiftIntelligence Engines
    private var swiftIntelligence: SwiftIntelligence?
    private var mlEngine: SwiftIntelligenceML?
    private var nlpEngine: SwiftIntelligenceNLP?
    private var visionEngine: SwiftIntelligenceVision?
    private var speechEngine: SwiftIntelligenceSpeech?
    private var reasoningEngine: SwiftIntelligenceReasoning?
    private var imageGenEngine: SwiftIntelligenceImageGeneration?
    private var privacyEngine: SwiftIntelligencePrivacy?
    private var networkEngine: SwiftIntelligenceNetwork?
    private var cacheEngine: SwiftIntelligenceCache?
    private var metricsEngine: SwiftIntelligenceMetrics?
    
    func initialize() async {
        isLoading = true
        error = nil
        
        do {
            // Initialize all engines
            swiftIntelligence = SwiftIntelligence()
            mlEngine = try await SwiftIntelligenceML()
            nlpEngine = try await SwiftIntelligenceNLP()
            visionEngine = try await SwiftIntelligenceVision()
            speechEngine = try await SwiftIntelligenceSpeech()
            reasoningEngine = try await SwiftIntelligenceReasoning()
            imageGenEngine = try await SwiftIntelligenceImageGeneration()
            privacyEngine = try await SwiftIntelligencePrivacy()
            networkEngine = try await SwiftIntelligenceNetwork()
            cacheEngine = try await SwiftIntelligenceCache()
            metricsEngine = SwiftIntelligenceMetrics()
            
            isInitialized = true
            print("✅ SwiftIntelligence Demo App initialized successfully!")
            
        } catch {
            self.error = "Failed to initialize: \(error.localizedDescription)"
            print("❌ Demo App initialization failed: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Engine Access Methods
    
    func getMLEngine() -> SwiftIntelligenceML? { mlEngine }
    func getNLPEngine() -> SwiftIntelligenceNLP? { nlpEngine }
    func getVisionEngine() -> SwiftIntelligenceVision? { visionEngine }
    func getSpeechEngine() -> SwiftIntelligenceSpeech? { speechEngine }
    func getReasoningEngine() -> SwiftIntelligenceReasoning? { reasoningEngine }
    func getImageGenEngine() -> SwiftIntelligenceImageGeneration? { imageGenEngine }
    func getPrivacyEngine() -> SwiftIntelligencePrivacy? { privacyEngine }
    func getNetworkEngine() -> SwiftIntelligenceNetwork? { networkEngine }
    func getCacheEngine() -> SwiftIntelligenceCache? { cacheEngine }
    func getMetricsEngine() -> SwiftIntelligenceMetrics? { metricsEngine }
}

struct ContentView: View {
    @EnvironmentObject var appManager: DemoAppManager
    
    var body: some View {
        NavigationView {
            VStack {
                if appManager.isLoading {
                    ProgressView("Initializing SwiftIntelligence...")
                        .padding()
                } else if let error = appManager.error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await appManager.initialize()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else if appManager.isInitialized {
                    DemoMainView()
                } else {
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("SwiftIntelligence")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("AI/ML Framework Demo")
                            .foregroundColor(.secondary)
                        
                        Button("Initialize") {
                            Task {
                                await appManager.initialize()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("SwiftIntelligence Demo")
        }
    }
}

struct DemoMainView: View {
    var body: some View {
        List {
            Section("AI/ML Engines") {
                NavigationLink("🧠 Machine Learning", destination: MLDemoView())
                NavigationLink("💬 Natural Language Processing", destination: NLPDemoView())
                NavigationLink("👁 Computer Vision", destination: VisionDemoView())
                NavigationLink("🎤 Speech Recognition & TTS", destination: SpeechDemoView())
                NavigationLink("⚡ Reasoning Engine", destination: ReasoningDemoView())
            }
            
            Section("Advanced Features") {
                NavigationLink("🎨 Image Generation", destination: ImageGenDemoView())
                NavigationLink("🔒 Privacy & Security", destination: PrivacyDemoView())
                NavigationLink("🌐 Network & API", destination: NetworkDemoView())
                NavigationLink("💾 Intelligent Caching", destination: CacheDemoView())
                NavigationLink("📊 Performance Metrics", destination: MetricsDemoView())
            }
        }
    }
}

// ML Demo view is now in separate file
// NLP Demo view is now in separate file
// Speech Demo view is now in separate file
// Vision Demo view is now in separate file
// Reasoning Demo view is now in separate file
// ImageGeneration Demo view is now in separate file
// Privacy Demo view is now in separate file
// Network Demo view is now in separate file
// Cache Demo view is now in separate file
// Metrics Demo view is now in separate file
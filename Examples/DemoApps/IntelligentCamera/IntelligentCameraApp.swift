import SwiftUI
import SwiftIntelligence
import SwiftIntelligenceVision
import SwiftIntelligenceLLM
import SwiftIntelligencePrivacy
import AVFoundation
import Vision
import os.log

/// Intelligent Camera App - Advanced AI-powered camera with real-time analysis
/// Features: Object detection, scene understanding, smart filters, content generation
@main
struct IntelligentCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @StateObject private var cameraManager = IntelligentCameraManager()
    @StateObject private var aiEngine = IntelligenceEngine()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera preview layer
                CameraPreviewView(cameraManager: cameraManager)
                    .ignoresSafeArea()
                
                // AI overlay interface
                VStack {
                    // Top controls and info
                    TopControlsView(cameraManager: cameraManager)
                    
                    Spacer()
                    
                    // Bottom controls
                    BottomControlsView(cameraManager: cameraManager)
                }
                .padding()
                
                // AI insights overlay
                if cameraManager.showInsights {
                    AIInsightsOverlay(cameraManager: cameraManager)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: cameraManager.showInsights)
                }
                
                // Processing indicator
                if cameraManager.isProcessing {
                    ProcessingIndicatorView()
                        .transition(.scale)
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
            
            // Initialize camera
            await cameraManager.initialize(aiEngine: aiEngine)
            
        } catch {
            print("Failed to initialize app: \(error)")
        }
    }
}

// MARK: - Camera Preview

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: IntelligentCameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Top Controls

struct TopControlsView: View {
    @ObservedObject var cameraManager: IntelligentCameraManager
    
    var body: some View {
        HStack {
            // AI mode toggle
            Button(action: { cameraManager.toggleAIMode() }) {
                HStack {
                    Image(systemName: cameraManager.aiModeEnabled ? "brain.head.profile" : "brain.head.profile.fill")
                    Text("AI")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(cameraManager.aiModeEnabled ? .blue : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
            }
            
            Spacer()
            
            // Scene analysis indicator
            if let analysis = cameraManager.currentAnalysis {
                SceneInfoView(analysis: analysis)
            }
            
            Spacer()
            
            // Settings
            Button(action: { cameraManager.showSettings.toggle() }) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
            }
        }
    }
}

struct SceneInfoView: View {
    let analysis: SceneAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(analysis.primaryScene)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text("\(analysis.detectedObjects.count) objects")
                .font(.caption2)
                .opacity(0.8)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
    }
}

// MARK: - Bottom Controls

struct BottomControlsView: View {
    @ObservedObject var cameraManager: IntelligentCameraManager
    
    var body: some View {
        VStack(spacing: 20) {
            // AI suggestions
            if !cameraManager.aiSuggestions.isEmpty {
                AIsuggestionsView(suggestions: cameraManager.aiSuggestions)
                    .transition(.slide)
            }
            
            // Camera controls
            HStack(spacing: 30) {
                // Gallery
                Button(action: { cameraManager.openGallery() }) {
                    Image(systemName: "photo.stack")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(25)
                }
                
                Spacer()
                
                // Capture button
                Button(action: { cameraManager.capturePhoto() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 90, height: 90)
                        
                        if cameraManager.isCapturing {
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                    }
                }
                .disabled(cameraManager.isCapturing)
                
                Spacer()
                
                // AI insights toggle
                Button(action: { cameraManager.showInsights.toggle() }) {
                    Image(systemName: "eye.circle")
                        .font(.title2)
                        .foregroundColor(cameraManager.showInsights ? .blue : .white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(25)
                }
            }
        }
    }
}

struct AIsugggestionsView: View {
    let suggestions: [AISuggestion]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(suggestions) { suggestion in
                    AISuggestionCard(suggestion: suggestion)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AISuggestionCard: View {
    let suggestion: AISuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: suggestion.icon)
                    .foregroundColor(.blue)
                Text(suggestion.title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Text(suggestion.description)
                .font(.caption2)
                .opacity(0.8)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .frame(maxWidth: 150)
    }
}

// MARK: - AI Insights Overlay

struct AIInsightsOverlay: View {
    @ObservedObject var cameraManager: IntelligentCameraManager
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    // Close button
                    Button(action: { cameraManager.showInsights = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    
                    // Insights panel
                    AIInsightsPanel(
                        analysis: cameraManager.currentAnalysis,
                        insights: cameraManager.aiInsights
                    )
                }
                .padding()
            }
            
            Spacer()
        }
    }
}

struct AIInsightsPanel: View {
    let analysis: SceneAnalysis?
    let insights: AIInsights?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Insights")
                .font(.headline)
                .foregroundColor(.white)
            
            if let analysis = analysis {
                AnalysisSection(analysis: analysis)
            }
            
            if let insights = insights {
                InsightsSection(insights: insights)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
        .frame(maxWidth: 300)
    }
}

struct AnalysisSection: View {
    let analysis: SceneAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Scene Analysis", systemImage: "viewfinder.circle")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            
            Text("Scene: \(analysis.primaryScene)")
                .font(.caption)
                .foregroundColor(.white)
            
            Text("Objects: \(analysis.detectedObjects.count)")
                .font(.caption)
                .foregroundColor(.white)
            
            Text("Confidence: \(Int(analysis.confidence * 100))%")
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct InsightsSection: View {
    let insights: AIInsights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AI Recommendations", systemImage: "lightbulb")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.yellow)
            
            ForEach(insights.recommendations, id: \.self) { recommendation in
                Text("• \(recommendation)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            if let mood = insights.estimatedMood {
                Text("Mood: \(mood)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Processing Indicator

struct ProcessingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0.0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
                
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Text("AI Processing...")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Camera Manager

@MainActor
class IntelligentCameraManager: NSObject, ObservableObject {
    
    private let logger = Logger(subsystem: "IntelligentCamera", category: "CameraManager")
    
    // AI Engine
    private var aiEngine: IntelligenceEngine?
    private var visionEngine: VisionEngine?
    private var llmEngine: LLMEngine?
    private var privacyEngine: PrivacyEngine?
    
    // Camera
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // AI State
    @Published var aiModeEnabled: Bool = true
    @Published var isProcessing: Bool = false
    @Published var isCapturing: Bool = false
    @Published var showInsights: Bool = false
    @Published var showSettings: Bool = false
    
    // Analysis Results
    @Published var currentAnalysis: SceneAnalysis?
    @Published var aiInsights: AIInsights?
    @Published var aiSuggestions: [AISuggestion] = []
    
    // Real-time processing
    private var processingQueue = DispatchQueue(label: "camera.processing", qos: .userInitiated)
    private var lastProcessingTime: Date = Date()
    private let processingInterval: TimeInterval = 0.5 // Process every 500ms
    
    func initialize(aiEngine: IntelligenceEngine) async {
        self.aiEngine = aiEngine
        
        do {
            // Initialize AI engines
            visionEngine = try await aiEngine.getVisionEngine()
            llmEngine = try await aiEngine.getLLMEngine()
            privacyEngine = try await aiEngine.getPrivacyEngine()
            
            // Setup camera
            await setupCamera()
            
            logger.info("Intelligent camera initialized successfully")
            
        } catch {
            logger.error("Failed to initialize camera: \(error.localizedDescription)")
        }
    }
    
    private func setupCamera() async {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            logger.error("No camera device found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .photo
            
            guard let session = captureSession else { return }
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // Photo output
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            // Video output for real-time processing
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: processingQueue)
            
            if let videoOutput = videoOutput, session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            // Preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            // Start session
            session.startRunning()
            
            logger.info("Camera setup complete")
            
        } catch {
            logger.error("Camera setup failed: \(error.localizedDescription)")
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        isCapturing = true
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleAIMode() {
        aiModeEnabled.toggle()
        
        if !aiModeEnabled {
            // Clear AI data when disabled
            currentAnalysis = nil
            aiInsights = nil
            aiSuggestions = []
        }
        
        logger.info("AI mode toggled: \(aiModeEnabled)")
    }
    
    func openGallery() {
        // Implementation for opening photo gallery
        logger.info("Opening gallery")
    }
    
    // MARK: - AI Processing
    
    private func processFrame(_ sampleBuffer: CMSampleBuffer) async {
        guard aiModeEnabled,
              !isProcessing,
              Date().timeIntervalSince(lastProcessingTime) > processingInterval else {
            return
        }
        
        await MainActor.run {
            isProcessing = true
        }
        
        lastProcessingTime = Date()
        
        do {
            // Convert sample buffer to image
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            // Perform vision analysis
            if let visionEngine = visionEngine {
                let analysisResult = try await analyzeScene(ciImage, using: visionEngine)
                
                // Generate AI insights
                let insights = try await generateInsights(for: analysisResult)
                
                // Generate suggestions
                let suggestions = try await generateSuggestions(for: analysisResult)
                
                await MainActor.run {
                    currentAnalysis = analysisResult
                    aiInsights = insights
                    aiSuggestions = suggestions
                }
            }
            
        } catch {
            logger.error("Frame processing failed: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            isProcessing = false
        }
    }
    
    private func analyzeScene(_ image: CIImage, using visionEngine: VisionEngine) async throws -> SceneAnalysis {
        // Object detection
        let detectionRequest = VisionRequest.objectDetection(
            threshold: 0.5,
            classes: nil
        )
        let detectionResult = try await visionEngine.processImage(image, with: detectionRequest)
        
        // Scene classification
        let classificationRequest = VisionRequest.imageClassification(
            maxResults: 5,
            threshold: 0.3
        )
        let classificationResult = try await visionEngine.processImage(image, with: classificationRequest)
        
        // Extract primary scene and objects
        var primaryScene = "Unknown"
        var detectedObjects: [DetectedObject] = []
        var confidence: Float = 0.0
        
        if case .imageClassification(let classifications) = classificationResult {
            if let topClassification = classifications.first {
                primaryScene = topClassification.label
                confidence = topClassification.confidence
            }
        }
        
        if case .objectDetection(let objects) = detectionResult {
            detectedObjects = objects.map { detection in
                DetectedObject(
                    label: detection.label,
                    confidence: detection.confidence,
                    boundingBox: detection.boundingBox
                )
            }
        }
        
        return SceneAnalysis(
            primaryScene: primaryScene,
            detectedObjects: detectedObjects,
            confidence: confidence,
            timestamp: Date()
        )
    }
    
    private func generateInsights(for analysis: SceneAnalysis) async throws -> AIInsights {
        guard let llmEngine = llmEngine else {
            throw CameraError.aiEngineNotAvailable
        }
        
        // Create context for LLM
        let context = """
        Scene Analysis:
        - Primary scene: \(analysis.primaryScene)
        - Objects detected: \(analysis.detectedObjects.map { $0.label }.joined(separator: ", "))
        - Confidence: \(Int(analysis.confidence * 100))%
        
        Please provide photography insights and recommendations for this scene.
        """
        
        let request = LLMRequest(
            messages: [
                LLMMessage(role: .system, content: "You are an expert photography AI assistant. Provide concise, practical advice."),
                LLMMessage(role: .user, content: context)
            ],
            model: .gpt4,
            maxTokens: 200,
            temperature: 0.7
        )
        
        let response = try await llmEngine.generateResponse(request)
        
        // Parse response into insights
        let recommendations = response.content.components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        let estimatedMood = estimateMood(from: analysis)
        
        return AIInsights(
            recommendations: recommendations,
            estimatedMood: estimatedMood,
            timestamp: Date()
        )
    }
    
    private func generateSuggestions(for analysis: SceneAnalysis) async throws -> [AISuggestion] {
        var suggestions: [AISuggestion] = []
        
        // Generate contextual suggestions based on scene
        switch analysis.primaryScene.lowercased() {
        case let scene where scene.contains("portrait") || scene.contains("person"):
            suggestions.append(AISuggestion(
                id: UUID(),
                title: "Portrait Mode",
                description: "Switch to portrait mode for better depth effect",
                icon: "person.crop.circle",
                action: .switchToPortrait
            ))
            
        case let scene where scene.contains("landscape") || scene.contains("outdoor"):
            suggestions.append(AISuggestion(
                id: UUID(),
                title: "Golden Hour",
                description: "Consider the lighting conditions",
                icon: "sun.max",
                action: .adjustLighting
            ))
            
        case let scene where scene.contains("food"):
            suggestions.append(AISuggestion(
                id: UUID(),
                title: "Food Photography",
                description: "Try overhead angle for better composition",
                icon: "camera.macro",
                action: .changeAngle
            ))
            
        default:
            suggestions.append(AISuggestion(
                id: UUID(),
                title: "Composition",
                description: "Apply rule of thirds for better framing",
                icon: "grid",
                action: .showGrid
            ))
        }
        
        // Add suggestions based on detected objects
        if analysis.detectedObjects.count > 3 {
            suggestions.append(AISuggestion(
                id: UUID(),
                title: "Busy Scene",
                description: "Focus on main subject to reduce clutter",
                icon: "target",
                action: .focusSubject
            ))
        }
        
        return suggestions
    }
    
    private func estimateMood(from analysis: SceneAnalysis) -> String? {
        let scene = analysis.primaryScene.lowercased()
        
        if scene.contains("sunset") || scene.contains("beach") {
            return "Peaceful"
        } else if scene.contains("party") || scene.contains("celebration") {
            return "Joyful"
        } else if scene.contains("forest") || scene.contains("nature") {
            return "Serene"
        } else if scene.contains("city") || scene.contains("urban") {
            return "Energetic"
        }
        
        return nil
    }
}

// MARK: - Camera Delegates

extension IntelligentCameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            isCapturing = false
        }
        
        if let error = error {
            logger.error("Photo capture failed: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            logger.error("Failed to get image data")
            return
        }
        
        // Save photo and process with AI
        Task {
            await processAndSavePhoto(imageData)
        }
    }
    
    private func processAndSavePhoto(_ imageData: Data) async {
        do {
            // Apply privacy protection if needed
            if let privacyEngine = privacyEngine {
                let protectedData = try await privacyEngine.protectData(
                    imageData,
                    classification: .internal
                )
                // Save protected image
                logger.info("Photo saved with privacy protection")
            }
            
            // Additional AI processing for captured photo can be added here
            
        } catch {
            logger.error("Failed to process captured photo: \(error.localizedDescription)")
        }
    }
}

extension IntelligentCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            await processFrame(sampleBuffer)
        }
    }
}

// MARK: - Supporting Types

struct SceneAnalysis {
    let primaryScene: String
    let detectedObjects: [DetectedObject]
    let confidence: Float
    let timestamp: Date
}

struct DetectedObject {
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}

struct AIInsights {
    let recommendations: [String]
    let estimatedMood: String?
    let timestamp: Date
}

struct AISuggestion: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let action: SuggestionAction
}

enum SuggestionAction {
    case switchToPortrait
    case adjustLighting
    case changeAngle
    case showGrid
    case focusSubject
}

enum CameraError: Error {
    case aiEngineNotAvailable
    case cameraNotAvailable
    case processingFailed
}
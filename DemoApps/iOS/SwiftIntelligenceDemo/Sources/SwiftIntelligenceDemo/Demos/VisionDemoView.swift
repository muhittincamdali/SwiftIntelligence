import SwiftUI
import SwiftIntelligenceVision
import SwiftIntelligenceCore
import PhotosUI

struct VisionDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var selectedFeature: VisionFeature = .objectDetection
    @State private var analysisResults: [VisionAnalysisResult] = []
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var processingProgress: Float = 0.0
    
    enum VisionFeature: String, CaseIterable {
        case objectDetection = "Object Detection"
        case faceRecognition = "Face Recognition"
        case textRecognition = "Text Recognition (OCR)"
        case imageClassification = "Image Classification"
        case colorAnalysis = "Color Analysis"
        case edgeDetection = "Edge Detection"
        
        var icon: String {
            switch self {
            case .objectDetection: return "viewfinder"
            case .faceRecognition: return "person.crop.circle"
            case .textRecognition: return "doc.text.viewfinder"
            case .imageClassification: return "tag"
            case .colorAnalysis: return "paintpalette"
            case .edgeDetection: return "grid"
            }
        }
        
        var description: String {
            switch self {
            case .objectDetection: return "Detect and locate objects in images"
            case .faceRecognition: return "Identify and analyze faces"
            case .textRecognition: return "Extract text from images using OCR"
            case .imageClassification: return "Classify image content and scenes"
            case .colorAnalysis: return "Analyze dominant colors and palettes"
            case .edgeDetection: return "Detect edges and contours in images"
            }
        }
        
        var color: Color {
            switch self {
            case .objectDetection: return .blue
            case .faceRecognition: return .green
            case .textRecognition: return .orange
            case .imageClassification: return .purple
            case .colorAnalysis: return .pink
            case .edgeDetection: return .red
            }
        }
    }
    
    struct VisionAnalysisResult: Identifiable {
        let id = UUID()
        let feature: VisionFeature
        let result: String
        let confidence: Float
        let details: [String: String]
        let processingTime: TimeInterval
        let timestamp: Date
        let originalImage: UIImage?
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.indigo)
                            .font(.title)
                        Text("Computer Vision Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Advanced image analysis and computer vision capabilities")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Image Selection Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Image Input")
                        .font(.headline)
                    
                    if let selectedImage = selectedImage {
                        VStack(spacing: 12) {
                            // Display Selected Image
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            
                            // Image Actions
                            HStack {
                                Button("Change Image") {
                                    showImageSourceSelector()
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button("Remove") {
                                    selectedImage = nil
                                    analysisResults.removeAll()
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            // Image Selection Placeholder
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Select an image to analyze")
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1, lineCap: .round, dash: [5])
                            )
                            
                            // Image Source Buttons
                            HStack {
                                Button("Camera") {
                                    showingCamera = true
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Spacer()
                                
                                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                                    Text("Photo Library")
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Spacer()
                                
                                Button("Sample Images") {
                                    selectedImage = getSampleImage()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                if selectedImage != nil {
                    Divider()
                    
                    // Vision Feature Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Vision Features")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(VisionFeature.allCases, id: \.rawValue) { feature in
                                Button(action: {
                                    selectedFeature = feature
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: feature.icon)
                                            .font(.title2)
                                            .foregroundColor(selectedFeature == feature ? .white : feature.color)
                                        Text(feature.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedFeature == feature ? .white : .primary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(height: 70)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedFeature == feature ? feature.color : feature.color.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Text(selectedFeature.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                    
                    // Analysis Button
                    Button(action: {
                        Task {
                            await performVisionAnalysis()
                        }
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "eye.fill")
                            }
                            Text(isProcessing ? "Analyzing..." : "Analyze Image")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isProcessing ? Color.gray : selectedFeature.color)
                        .cornerRadius(10)
                    }
                    .disabled(isProcessing)
                    
                    // Processing Progress
                    if isProcessing {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Processing...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(processingProgress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            ProgressView(value: processingProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .accentColor(selectedFeature.color)
                        }
                        .padding()
                        .background(selectedFeature.color.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                if !analysisResults.isEmpty {
                    Divider()
                    
                    // Analysis Results
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Analysis Results")
                            .font(.headline)
                        
                        ForEach(analysisResults) { result in
                            VisionResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Vision Engine")
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                selectedImage = image
                showingCamera = false
            }
        }
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
    
    // MARK: - Vision Analysis Methods
    
    @MainActor
    private func performVisionAnalysis() async {
        guard let visionEngine = appManager.getVisionEngine(),
              let image = selectedImage else { return }
        
        isProcessing = true
        processingProgress = 0.0
        
        do {
            let startTime = Date()
            let result = try await analyzeImage(visionEngine: visionEngine, image: image)
            let processingTime = Date().timeIntervalSince(startTime)
            
            let analysisResult = VisionAnalysisResult(
                feature: selectedFeature,
                result: result.summary,
                confidence: result.confidence,
                details: result.details,
                processingTime: processingTime,
                timestamp: Date(),
                originalImage: image
            )
            
            analysisResults.insert(analysisResult, at: 0)
            
        } catch {
            let errorResult = VisionAnalysisResult(
                feature: selectedFeature,
                result: "Analysis failed: \(error.localizedDescription)",
                confidence: 0.0,
                details: [:],
                processingTime: 0.0,
                timestamp: Date(),
                originalImage: image
            )
            analysisResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
        processingProgress = 0.0
    }
    
    private func analyzeImage(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        // Simulate processing progress
        await simulateProgress()
        
        switch selectedFeature {
        case .objectDetection:
            return try await performObjectDetection(visionEngine: visionEngine, image: image)
        case .faceRecognition:
            return try await performFaceRecognition(visionEngine: visionEngine, image: image)
        case .textRecognition:
            return try await performTextRecognition(visionEngine: visionEngine, image: image)
        case .imageClassification:
            return try await performImageClassification(visionEngine: visionEngine, image: image)
        case .colorAnalysis:
            return try await performColorAnalysis(visionEngine: visionEngine, image: image)
        case .edgeDetection:
            return try await performEdgeDetection(visionEngine: visionEngine, image: image)
        }
    }
    
    private struct AnalysisResult {
        let summary: String
        let confidence: Float
        let details: [String: String]
    }
    
    private func performObjectDetection(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        let objects = try await visionEngine.detectObjects(image)
        
        let summary = objects.isEmpty ? "No objects detected" : "Found \(objects.count) objects"
        var details: [String: String] = [:]
        
        for (index, object) in objects.enumerated() {
            details["Object \(index + 1)"] = "\(object.label) (\(String(format: "%.1f%%", object.confidence * 100)))"
        }
        
        return AnalysisResult(
            summary: summary,
            confidence: objects.first?.confidence ?? 0.0,
            details: details
        )
    }
    
    private func performFaceRecognition(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        let faces = try await visionEngine.detectFaces(image)
        
        let summary = faces.isEmpty ? "No faces detected" : "Found \(faces.count) face(s)"
        var details: [String: String] = [:]
        
        for (index, face) in faces.enumerated() {
            let emotions = face.emotions.map { "\($0.type.rawValue): \(String(format: "%.1f%%", $0.confidence * 100))" }.joined(separator: ", ")
            details["Face \(index + 1)"] = emotions
            details["Age Range"] = "\(face.estimatedAge.lowerBound)-\(face.estimatedAge.upperBound) years"
        }
        
        return AnalysisResult(
            summary: summary,
            confidence: faces.first?.confidence ?? 0.0,
            details: details
        )
    }
    
    private func performTextRecognition(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        let textResults = try await visionEngine.recognizeText(image)
        
        let summary = textResults.isEmpty ? "No text found" : "Found \(textResults.count) text regions"
        var details: [String: String] = [:]
        
        for (index, textResult) in textResults.enumerated() {
            details["Text \(index + 1)"] = "\(textResult.text) (\(String(format: "%.1f%%", textResult.confidence * 100)))"
        }
        
        if !textResults.isEmpty {
            let allText = textResults.map { $0.text }.joined(separator: " ")
            details["Full Text"] = allText
        }
        
        return AnalysisResult(
            summary: summary,
            confidence: textResults.first?.confidence ?? 0.0,
            details: details
        )
    }
    
    private func performImageClassification(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        let classifications = try await visionEngine.classifyImage(image, maxResults: 5)
        
        let summary = classifications.isEmpty ? "Unable to classify image" : "Top classification: \(classifications.first?.label ?? "Unknown")"
        var details: [String: String] = [:]
        
        for (index, classification) in classifications.enumerated() {
            details["Classification \(index + 1)"] = "\(classification.label) (\(String(format: "%.1f%%", classification.confidence * 100)))"
        }
        
        return AnalysisResult(
            summary: summary,
            confidence: classifications.first?.confidence ?? 0.0,
            details: details
        )
    }
    
    private func performColorAnalysis(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        let colorAnalysis = try await visionEngine.analyzeColors(image, maxColors: 5)
        
        let summary = "Analyzed \(colorAnalysis.dominantColors.count) dominant colors"
        var details: [String: String] = [:]
        
        for (index, color) in colorAnalysis.dominantColors.enumerated() {
            let percentage = String(format: "%.1f%%", color.percentage * 100)
            details["Color \(index + 1)"] = "\(color.name) (\(percentage))"
        }
        
        details["Color Palette"] = colorAnalysis.palette.rawValue
        details["Brightness"] = String(format: "%.1f%%", colorAnalysis.averageBrightness * 100)
        
        return AnalysisResult(
            summary: summary,
            confidence: 1.0,
            details: details
        )
    }
    
    private func performEdgeDetection(visionEngine: SwiftIntelligenceVision, image: UIImage) async throws -> AnalysisResult {
        let edges = try await visionEngine.detectEdges(image)
        
        let summary = "Detected \(edges.edgeCount) edge pixels"
        let details: [String: String] = [
            "Edge Density": String(format: "%.2f%%", edges.density * 100),
            "Strong Edges": "\(edges.strongEdges)",
            "Weak Edges": "\(edges.weakEdges)",
            "Processing Method": edges.method.rawValue
        ]
        
        return AnalysisResult(
            summary: summary,
            confidence: edges.quality,
            details: details
        )
    }
    
    private func simulateProgress() async {
        for i in 1...10 {
            await MainActor.run {
                processingProgress = Float(i) / 10.0
            }
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        }
    }
    
    private func showImageSourceSelector() {
        // In a real app, you would show an action sheet here
        // For now, just show the photo picker
        photoPickerItem = nil
        // This will trigger the photo picker
    }
    
    private func getSampleImage() -> UIImage? {
        // Return a sample image - in a real app, you might have bundled sample images
        // For now, return a simple colored image
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add some simple shapes for testing
            UIColor.white.setFill()
            let rect1 = CGRect(x: 50, y: 50, width: 80, height: 60)
            context.fill(rect1)
            
            UIColor.red.setFill()
            let rect2 = CGRect(x: 170, y: 80, width: 60, height: 60)
            context.fill(rect2)
        }
    }
}

struct VisionResultCard: View {
    let result: VisionDemoView.VisionAnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.feature.icon)
                    .foregroundColor(result.feature.color)
                Text(result.feature.rawValue)
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    if result.confidence > 0 {
                        Text("\(Int(result.confidence * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(result.feature.color.opacity(0.2))
                            .cornerRadius(8)
                    }
                    Text(String(format: "%.2fs", result.processingTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(result.result)
                .font(.body)
                .padding(10)
                .background(result.feature.color.opacity(0.1))
                .cornerRadius(8)
            
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Details:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack(alignment: .top) {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// Simple camera view for demo purposes
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
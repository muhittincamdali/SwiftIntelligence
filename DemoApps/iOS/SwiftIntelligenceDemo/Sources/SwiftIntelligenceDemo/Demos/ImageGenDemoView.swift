import SwiftUI
import SwiftIntelligenceImageGeneration
import SwiftIntelligenceCore

struct ImageGenDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var promptText: String = "A beautiful sunset over a mountain landscape with vibrant colors"
    @State private var isGenerating = false
    @State private var generatedImages: [GeneratedImageResult] = []
    @State private var selectedStyle: ImageStyle = .realistic
    @State private var selectedSize: ImageSize = .square
    @State private var generationProgress: Float = 0.0
    @State private var selectedModel: AIModel = .stable
    @State private var showingFullScreenImage = false
    @State private var fullScreenImage: UIImage?
    
    enum ImageStyle: String, CaseIterable {
        case realistic = "Realistic"
        case artistic = "Artistic"
        case cartoon = "Cartoon"
        case abstract = "Abstract"
        case photographic = "Photographic"
        case digital = "Digital Art"
        
        var icon: String {
            switch self {
            case .realistic: return "camera"
            case .artistic: return "paintbrush"
            case .cartoon: return "face.smiling"
            case .abstract: return "scribble.variable"
            case .photographic: return "camera.aperture"
            case .digital: return "laptopcomputer"
            }
        }
        
        var description: String {
            switch self {
            case .realistic: return "Photorealistic images with natural details"
            case .artistic: return "Creative artistic interpretations"
            case .cartoon: return "Fun cartoon-style illustrations"
            case .abstract: return "Abstract and conceptual designs"
            case .photographic: return "Professional photography style"
            case .digital: return "Modern digital art aesthetics"
            }
        }
        
        var color: Color {
            switch self {
            case .realistic: return .blue
            case .artistic: return .purple
            case .cartoon: return .orange
            case .abstract: return .pink
            case .photographic: return .green
            case .digital: return .cyan
            }
        }
    }
    
    enum ImageSize: String, CaseIterable {
        case square = "Square (512×512)"
        case portrait = "Portrait (512×768)"
        case landscape = "Landscape (768×512)"
        case widescreen = "Widescreen (1024×576)"
        
        var dimensions: (width: Int, height: Int) {
            switch self {
            case .square: return (512, 512)
            case .portrait: return (512, 768)
            case .landscape: return (768, 512)
            case .widescreen: return (1024, 576)
            }
        }
        
        var icon: String {
            switch self {
            case .square: return "square"
            case .portrait: return "rectangle.portrait"
            case .landscape: return "rectangle"
            case .widescreen: return "rectangle.ratio.16.to.9"
            }
        }
    }
    
    enum AIModel: String, CaseIterable {
        case stable = "Stable Diffusion"
        case enhanced = "Enhanced Quality"
        case fast = "Fast Generation"
        case artistic = "Artistic Focus"
        
        var icon: String {
            switch self {
            case .stable: return "gear"
            case .enhanced: return "sparkles"
            case .fast: return "bolt"
            case .artistic: return "paintpalette"
            }
        }
        
        var description: String {
            switch self {
            case .stable: return "Balanced quality and speed"
            case .enhanced: return "Highest quality, slower generation"
            case .fast: return "Quick results, good quality"
            case .artistic: return "Optimized for creative art"
            }
        }
    }
    
    struct GeneratedImageResult: Identifiable {
        let id = UUID()
        let image: UIImage
        let prompt: String
        let style: ImageStyle
        let size: ImageSize
        let model: AIModel
        let generationTime: TimeInterval
        let timestamp: Date
        let seed: Int
        let steps: Int
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "photo.artframe")
                            .foregroundColor(.cyan)
                            .font(.title)
                        Text("AI Image Generation")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Create stunning images from text descriptions using advanced AI models")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Prompt Input Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Image Prompt")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe the image you want to create:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $promptText)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                            
                            HStack {
                                Text("\(promptText.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Clear") {
                                    promptText = ""
                                }
                                .font(.caption)
                                .foregroundColor(.cyan)
                            }
                        }
                        
                        // Sample Prompts
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sample prompts:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(samplePrompts, id: \.self) { prompt in
                                        Button(action: {
                                            promptText = prompt
                                        }) {
                                            Text(prompt.prefix(40) + "...")
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.cyan.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Generation Settings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Generation Settings")
                        .font(.headline)
                    
                    // AI Model Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Model:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(AIModel.allCases, id: \.rawValue) { model in
                                Button(action: {
                                    selectedModel = model
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: model.icon)
                                            .font(.title3)
                                            .foregroundColor(selectedModel == model ? .white : .cyan)
                                        Text(model.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedModel == model ? .white : .primary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedModel == model ? Color.cyan : Color.cyan.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        Text(selectedModel.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                    
                    // Style Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Art Style:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(ImageStyle.allCases, id: \.rawValue) { style in
                                Button(action: {
                                    selectedStyle = style
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: style.icon)
                                            .font(.title3)
                                            .foregroundColor(selectedStyle == style ? .white : style.color)
                                        Text(style.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedStyle == style ? .white : .primary)
                                    }
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedStyle == style ? style.color : style.color.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        Text(selectedStyle.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                    
                    // Size Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Image Size:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(ImageSize.allCases, id: \.rawValue) { size in
                                    Button(action: {
                                        selectedSize = size
                                    }) {
                                        HStack {
                                            Image(systemName: size.icon)
                                            Text(size.rawValue)
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedSize == size ? Color.cyan : Color.cyan.opacity(0.1))
                                        .foregroundColor(selectedSize == size ? .white : .primary)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                }
                
                // Generate Button
                Button(action: {
                    Task {
                        await generateImage()
                    }
                }) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isGenerating ? "Generating..." : "Generate Image")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isGenerating ? Color.gray : (promptText.isEmpty ? Color.gray : Color.cyan))
                    .cornerRadius(10)
                }
                .disabled(isGenerating || promptText.isEmpty)
                
                // Generation Progress
                if isGenerating {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Processing with \(selectedModel.rawValue)...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(generationProgress * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        ProgressView(value: generationProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.cyan)
                        
                        Text("Estimated time: \(estimatedTimeRemaining()) seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(10)
                }
                
                if !generatedImages.isEmpty {
                    Divider()
                    
                    // Generated Images
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Generated Images")
                                .font(.headline)
                            Spacer()
                            Text("\(generatedImages.count) images")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(generatedImages.reversed()) { result in
                                GeneratedImageCard(result: result) {
                                    fullScreenImage = result.image
                                    showingFullScreenImage = true
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Image Generation")
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            if let image = fullScreenImage {
                FullScreenImageView(image: image) {
                    showingFullScreenImage = false
                }
            }
        }
    }
    
    private var samplePrompts: [String] {
        [
            "A futuristic city with flying cars and neon lights at night",
            "A serene Japanese garden with cherry blossoms and a traditional bridge",
            "A majestic dragon soaring through stormy clouds",
            "An astronaut exploring an alien planet with purple vegetation",
            "A cozy cabin in a snowy forest with warm light in the windows",
            "Abstract geometric patterns in vibrant blue and gold colors"
        ]
    }
    
    // MARK: - Image Generation Methods
    
    @MainActor
    private func generateImage() async {
        guard let imageGenEngine = appManager.getImageGenEngine() else { return }
        
        isGenerating = true
        generationProgress = 0.0
        
        do {
            let startTime = Date()
            
            // Simulate generation progress
            await simulateGenerationProgress()
            
            let request = ImageGenerationRequest(
                prompt: promptText,
                style: getStyleID(for: selectedStyle),
                size: selectedSize.dimensions,
                model: getModelID(for: selectedModel),
                quality: .high,
                steps: 50
            )
            
            let result = try await imageGenEngine.generateImage(request: request)
            let generationTime = Date().timeIntervalSince(startTime)
            
            let generatedResult = GeneratedImageResult(
                image: result.image,
                prompt: promptText,
                style: selectedStyle,
                size: selectedSize,
                model: selectedModel,
                generationTime: generationTime,
                timestamp: Date(),
                seed: result.seed,
                steps: result.steps
            )
            
            generatedImages.insert(generatedResult, at: 0)
            
        } catch {
            // Handle error - in a real app you'd show an error message
            print("Image generation failed: \(error)")
        }
        
        isGenerating = false
        generationProgress = 0.0
    }
    
    private func simulateGenerationProgress() async {
        for i in 1...20 {
            await MainActor.run {
                generationProgress = Float(i) / 20.0
            }
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        }
    }
    
    private func estimatedTimeRemaining() -> Int {
        let baseTime = 30 // Base generation time in seconds
        let progressRemaining = 1.0 - generationProgress
        return Int(Float(baseTime) * progressRemaining)
    }
    
    private func getStyleID(for style: ImageStyle) -> String {
        switch style {
        case .realistic: return "realistic"
        case .artistic: return "artistic"
        case .cartoon: return "cartoon"
        case .abstract: return "abstract"
        case .photographic: return "photographic"
        case .digital: return "digital_art"
        }
    }
    
    private func getModelID(for model: AIModel) -> String {
        switch model {
        case .stable: return "stable_diffusion"
        case .enhanced: return "enhanced_quality"
        case .fast: return "fast_generation"
        case .artistic: return "artistic_focus"
        }
    }
}

struct GeneratedImageCard: View {
    let result: ImageGenDemoView.GeneratedImageResult
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                Image(uiImage: result.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(result.style.color.opacity(0.3), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: result.style.icon)
                        .foregroundColor(result.style.color)
                        .font(.caption)
                    Text(result.style.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text(timeAgoString(from: result.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(result.prompt)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(result.size.rawValue.components(separatedBy: " ").first ?? "")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(result.style.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(String(format: "%.1fs", result.generationTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct FullScreenImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZoomableImageView(image: image)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            onDismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }
        }
    }
}

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let imageView = UIImageView(image: image)
        
        scrollView.addSubview(imageView)
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.subviews.first
        }
    }
}
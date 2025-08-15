import SwiftUI
import SwiftIntelligenceNLP
import SwiftIntelligenceCore

struct NLPDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var inputText: String = "Swift is a powerful programming language developed by Apple."
    @State private var isProcessing = false
    @State private var selectedFeature: NLPFeature = .sentimentAnalysis
    @State private var analysisResults: [AnalysisResult] = []
    
    enum NLPFeature: String, CaseIterable {
        case sentimentAnalysis = "Sentiment Analysis"
        case entityRecognition = "Entity Recognition" 
        case languageDetection = "Language Detection"
        case textSummarization = "Text Summarization"
        case tokenization = "Tokenization"
        case keywordExtraction = "Keyword Extraction"
        
        var icon: String {
            switch self {
            case .sentimentAnalysis: return "heart"
            case .entityRecognition: return "person.crop.circle.badge.checkmark"
            case .languageDetection: return "globe"
            case .textSummarization: return "doc.text"
            case .tokenization: return "textformat.abc"
            case .keywordExtraction: return "key"
            }
        }
        
        var description: String {
            switch self {
            case .sentimentAnalysis: return "Analyze emotional tone and sentiment"
            case .entityRecognition: return "Identify people, places, organizations"
            case .languageDetection: return "Detect text language automatically"
            case .textSummarization: return "Generate concise text summaries"
            case .tokenization: return "Break text into tokens and components"
            case .keywordExtraction: return "Extract key terms and phrases"
            }
        }
    }
    
    struct AnalysisResult: Identifiable {
        let id = UUID()
        let feature: NLPFeature
        let result: String
        let confidence: Float
        let details: [String: String]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.purple)
                            .font(.title)
                        Text("Natural Language Processing")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Comprehensive text analysis and language understanding")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Text Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Input Text")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $inputText)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        HStack {
                            Text("\(inputText.count) characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Clear") {
                                inputText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        // Sample texts
                        Text("Sample texts:")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(sampleTexts, id: \.self) { sample in
                                    Button(action: {
                                        inputText = sample
                                    }) {
                                        Text(sample.prefix(30) + "...")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                }
                
                Divider()
                
                // NLP Feature Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("NLP Features")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(NLPFeature.allCases, id: \.rawValue) { feature in
                            Button(action: {
                                selectedFeature = feature
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: feature.icon)
                                        .font(.title3)
                                        .foregroundColor(selectedFeature == feature ? .white : .purple)
                                    Text(feature.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedFeature == feature ? .white : .primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(selectedFeature == feature ? Color.purple : Color.purple.opacity(0.1))
                                .cornerRadius(10)
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
                        await performNLPAnalysis()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text(isProcessing ? "Analyzing..." : "Analyze Text")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isProcessing ? Color.gray : Color.purple)
                    .cornerRadius(10)
                }
                .disabled(isProcessing || inputText.isEmpty)
                
                Divider()
                
                // Results
                VStack(alignment: .leading, spacing: 12) {
                    Text("Analysis Results")
                        .font(.headline)
                    
                    if analysisResults.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No analysis performed yet")
                                .foregroundColor(.secondary)
                            Text("Select a feature and analyze your text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(analysisResults) { result in
                            AnalysisResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("NLP Engine")
    }
    
    private var sampleTexts: [String] {
        [
            "I absolutely love this new iPhone! The camera quality is amazing and the battery life is incredible.",
            "Apple Inc. is an American multinational technology company headquartered in Cupertino, California.",
            "Machine learning is a subset of artificial intelligence that focuses on algorithms and statistical models.",
            "The weather today is absolutely terrible. It's been raining all day and I'm feeling quite sad about it."
        ]
    }
    
    @MainActor
    private func performNLPAnalysis() async {
        guard let nlpEngine = appManager.getNLPEngine() else { return }
        
        isProcessing = true
        
        do {
            let result = try await analyzeText(nlpEngine: nlpEngine)
            analysisResults = [result]
        } catch {
            let errorResult = AnalysisResult(
                feature: selectedFeature,
                result: "Analysis failed: \(error.localizedDescription)",
                confidence: 0.0,
                details: [:]
            )
            analysisResults = [errorResult]
        }
        
        isProcessing = false
    }
    
    private func analyzeText(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        switch selectedFeature {
        case .sentimentAnalysis:
            return try await performSentimentAnalysis(nlpEngine: nlpEngine)
        case .entityRecognition:
            return try await performEntityRecognition(nlpEngine: nlpEngine)
        case .languageDetection:
            return try await performLanguageDetection(nlpEngine: nlpEngine)
        case .textSummarization:
            return try await performTextSummarization(nlpEngine: nlpEngine)
        case .tokenization:
            return try await performTokenization(nlpEngine: nlpEngine)
        case .keywordExtraction:
            return try await performKeywordExtraction(nlpEngine: nlpEngine)
        }
    }
    
    private func performSentimentAnalysis(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        let analysis = try await nlpEngine.analyzeSentiment(inputText)
        
        let sentimentLabel = analysis.sentiment.rawValue.capitalized
        let details = [
            "Positive Score": String(format: "%.3f", analysis.positiveScore),
            "Negative Score": String(format: "%.3f", analysis.negativeScore),
            "Neutral Score": String(format: "%.3f", analysis.neutralScore)
        ]
        
        return AnalysisResult(
            feature: .sentimentAnalysis,
            result: "\(sentimentLabel) sentiment detected",
            confidence: analysis.confidence,
            details: details
        )
    }
    
    private func performEntityRecognition(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        let entities = try await nlpEngine.recognizeEntities(inputText)
        
        let entityStrings = entities.map { "\($0.text) (\($0.type.rawValue))" }
        let result = entities.isEmpty ? "No entities found" : "Found \(entities.count) entities"
        
        var details: [String: String] = [:]
        for (index, entity) in entities.enumerated() {
            details["Entity \(index + 1)"] = "\(entity.text) - \(entity.type.rawValue)"
        }
        
        return AnalysisResult(
            feature: .entityRecognition,
            result: result,
            confidence: entities.first?.confidence ?? 0.0,
            details: details
        )
    }
    
    private func performLanguageDetection(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        let language = try await nlpEngine.detectLanguage(inputText)
        
        let details = [
            "Language Code": language.languageCode,
            "Language Name": language.languageName
        ]
        
        return AnalysisResult(
            feature: .languageDetection,
            result: "Detected language: \(language.languageName)",
            confidence: language.confidence,
            details: details
        )
    }
    
    private func performTextSummarization(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        let summary = try await nlpEngine.summarizeText(inputText, maxLength: 100)
        
        let details = [
            "Original Length": "\(inputText.count) characters",
            "Summary Length": "\(summary.summary.count) characters",
            "Compression": String(format: "%.1f%%", Float(summary.summary.count) / Float(inputText.count) * 100)
        ]
        
        return AnalysisResult(
            feature: .textSummarization,
            result: summary.summary,
            confidence: summary.confidence,
            details: details
        )
    }
    
    private func performTokenization(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        let tokens = try await nlpEngine.tokenize(inputText)
        
        let details = [
            "Total Tokens": "\(tokens.tokens.count)",
            "Sentences": "\(tokens.sentences.count)",
            "Words": "\(tokens.words.count)"
        ]
        
        return AnalysisResult(
            feature: .tokenization,
            result: "Text tokenized into \(tokens.tokens.count) tokens",
            confidence: 1.0,
            details: details
        )
    }
    
    private func performKeywordExtraction(nlpEngine: SwiftIntelligenceNLP) async throws -> AnalysisResult {
        let keywords = try await nlpEngine.extractKeywords(inputText, maxCount: 10)
        
        let keywordStrings = keywords.map { "\($0.keyword) (\(String(format: "%.2f", $0.score)))" }
        let result = keywords.isEmpty ? "No keywords found" : "Found \(keywords.count) keywords"
        
        var details: [String: String] = [:]
        for (index, keyword) in keywords.enumerated() {
            details["Keyword \(index + 1)"] = "\(keyword.keyword) - Score: \(String(format: "%.3f", keyword.score))"
        }
        
        return AnalysisResult(
            feature: .keywordExtraction,
            result: result,
            confidence: keywords.first?.score ?? 0.0,
            details: details
        )
    }
}

struct AnalysisResultCard: View {
    let result: NLPDemoView.AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.feature.icon)
                    .foregroundColor(.purple)
                Text(result.feature.rawValue)
                    .font(.headline)
                Spacer()
                if result.confidence > 0 {
                    Text("\(Int(result.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            
            Text(result.result)
                .font(.body)
                .padding(10)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Details:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
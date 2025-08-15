import SwiftUI
import SwiftIntelligenceReasoning
import SwiftIntelligenceCore

struct ReasoningDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var selectedFeature: ReasoningFeature = .logicalInference
    @State private var isProcessing = false
    @State private var reasoningResults: [ReasoningResult] = []
    
    // Logical Inference states
    @State private var premises: String = """
    All humans are mortal.
    Socrates is human.
    """
    @State private var inferenceQuery: String = "Is Socrates mortal?"
    
    // Decision Making states
    @State private var decisionContext: String = """
    Budget: $10,000
    Requirements: Fast delivery, High quality, Low cost
    Options: Option A (Fast, Expensive), Option B (Slow, Cheap), Option C (Balanced)
    """
    
    // Knowledge Graph states
    @State private var knowledgeEntities: String = "Apple, iPhone, Tim Cook, Technology, Cupertino"
    
    enum ReasoningFeature: String, CaseIterable {
        case logicalInference = "Logical Inference"
        case decisionMaking = "Decision Making"
        case knowledgeGraph = "Knowledge Graph"
        case problemSolving = "Problem Solving"
        case patternRecognition = "Pattern Recognition"
        case causalReasoning = "Causal Reasoning"
        
        var icon: String {
            switch self {
            case .logicalInference: return "brain"
            case .decisionMaking: return "flowchart"
            case .knowledgeGraph: return "network"
            case .problemSolving: return "puzzlepiece"
            case .patternRecognition: return "eye.trianglebadge.exclamationmark"
            case .causalReasoning: return "arrow.triangle.branch"
            }
        }
        
        var description: String {
            switch self {
            case .logicalInference: return "Deduce conclusions from premises using formal logic"
            case .decisionMaking: return "Make optimal decisions based on multiple criteria"
            case .knowledgeGraph: return "Build and query knowledge relationships"
            case .problemSolving: return "Solve complex problems step by step"
            case .patternRecognition: return "Identify patterns and regularities in data"
            case .causalReasoning: return "Determine cause-and-effect relationships"
            }
        }
        
        var color: Color {
            switch self {
            case .logicalInference: return .purple
            case .decisionMaking: return .blue
            case .knowledgeGraph: return .green
            case .problemSolving: return .orange
            case .patternRecognition: return .red
            case .causalReasoning: return .indigo
            }
        }
    }
    
    struct ReasoningResult: Identifiable {
        let id = UUID()
        let feature: ReasoningFeature
        let operation: String
        let result: String
        let confidence: Float
        let reasoning: [String]
        let details: [String: String]
        let timestamp: Date
        let duration: TimeInterval
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                            .font(.title)
                        Text("Reasoning Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Advanced logical reasoning, decision making, and knowledge representation")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Feature Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reasoning Features")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(ReasoningFeature.allCases, id: \.rawValue) { feature in
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
                
                Divider()
                
                // Feature-Specific UI
                switch selectedFeature {
                case .logicalInference:
                    logicalInferenceSection
                case .decisionMaking:
                    decisionMakingSection
                case .knowledgeGraph:
                    knowledgeGraphSection
                case .problemSolving:
                    problemSolvingSection
                case .patternRecognition:
                    patternRecognitionSection
                case .causalReasoning:
                    causalReasoningSection
                }
                
                if !reasoningResults.isEmpty {
                    Divider()
                    
                    // Results
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reasoning Results")
                            .font(.headline)
                        
                        ForEach(reasoningResults.reversed()) { result in
                            ReasoningResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Reasoning Engine")
    }
    
    // MARK: - Feature Sections
    
    private var logicalInferenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Logical Inference")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Premises Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Premises (one per line):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $premises)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Query Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Query:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your logical query", text: $inferenceQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Sample Logic Problems
                Text("Sample problems:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sampleLogicProblems, id: \.title) { problem in
                            Button(problem.title) {
                                premises = problem.premises
                                inferenceQuery = problem.query
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 1)
                }
                
                // Inference Button
                Button(action: {
                    Task {
                        await performLogicalInference()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "brain")
                        }
                        Text(isProcessing ? "Reasoning..." : "Perform Inference")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isProcessing ? Color.gray : Color.purple)
                    .cornerRadius(10)
                }
                .disabled(isProcessing || premises.isEmpty || inferenceQuery.isEmpty)
            }
        }
    }
    
    private var decisionMakingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Decision Making")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Decision Context Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Decision Context:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $decisionContext)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Decision Criteria
                VStack(alignment: .leading, spacing: 8) {
                    Text("Decision Criteria:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(["Cost", "Quality", "Time", "Risk", "ROI", "Feasibility"], id: \.self) { criterion in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text(criterion)
                                    .font(.caption)
                            }
                            .padding(4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                
                // Make Decision Button
                Button(action: {
                    Task {
                        await performDecisionMaking()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "flowchart")
                        }
                        Text(isProcessing ? "Analyzing..." : "Make Decision")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isProcessing ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isProcessing || decisionContext.isEmpty)
            }
        }
    }
    
    private var knowledgeGraphSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Knowledge Graph")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Entities Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entities (comma separated):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter entities", text: $knowledgeEntities)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Example: Apple, iPhone, Technology, Steve Jobs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Operations
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Build Graph") {
                        Task {
                            await buildKnowledgeGraph()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing || knowledgeEntities.isEmpty)
                    
                    Button("Find Relations") {
                        Task {
                            await findRelations()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Query Graph") {
                        Task {
                            await queryKnowledgeGraph()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Visualize") {
                        Task {
                            await visualizeGraph()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var problemSolvingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Problem Solving")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Solve complex problems using step-by-step reasoning")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("8-Puzzle Solver") {
                        Task {
                            await solvePuzzle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Path Finding") {
                        Task {
                            await findOptimalPath()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Constraint Solver") {
                        Task {
                            await solveConstraints()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Planning") {
                        Task {
                            await createPlan()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var patternRecognitionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pattern Recognition")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Identify patterns and regularities in data sequences")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Number Sequence") {
                        Task {
                            await analyzeNumberSequence()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Text Patterns") {
                        Task {
                            await findTextPatterns()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Behavioral Patterns") {
                        Task {
                            await analyzeBehavior()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Anomaly Detection") {
                        Task {
                            await detectAnomalies()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var causalReasoningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Causal Reasoning")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Determine cause-and-effect relationships between events")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Causal Analysis") {
                        Task {
                            await performCausalAnalysis()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Root Cause") {
                        Task {
                            await findRootCause()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Impact Analysis") {
                        Task {
                            await analyzeImpact()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Predict Effects") {
                        Task {
                            await predictEffects()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    // MARK: - Sample Data
    
    private var sampleLogicProblems: [(title: String, premises: String, query: String)] {
        [
            (
                "Classic Syllogism",
                """
                All humans are mortal.
                Socrates is human.
                """,
                "Is Socrates mortal?"
            ),
            (
                "Modus Ponens",
                """
                If it rains, the ground gets wet.
                It is raining.
                """,
                "Is the ground wet?"
            ),
            (
                "Transitive Property",
                """
                A is greater than B.
                B is greater than C.
                """,
                "Is A greater than C?"
            )
        ]
    }
    
    // MARK: - Reasoning Operations
    
    @MainActor
    private func performLogicalInference() async {
        guard let reasoningEngine = appManager.getReasoningEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let request = LogicalInferenceRequest(
                premises: premises.components(separatedBy: .newlines).filter { !$0.isEmpty },
                query: inferenceQuery,
                reasoningMethod: .deductive
            )
            
            let result = try await reasoningEngine.performInference(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            let reasoningResult = ReasoningResult(
                feature: .logicalInference,
                operation: "Logical Inference",
                result: result.conclusion,
                confidence: result.confidence,
                reasoning: result.reasoningSteps,
                details: [
                    "Method": "Deductive Reasoning",
                    "Validity": result.isValid ? "Valid" : "Invalid",
                    "Steps": "\(result.reasoningSteps.count)"
                ],
                timestamp: Date(),
                duration: duration
            )
            
            reasoningResults.insert(reasoningResult, at: 0)
            
        } catch {
            let errorResult = ReasoningResult(
                feature: .logicalInference,
                operation: "Logical Inference",
                result: "Inference failed: \(error.localizedDescription)",
                confidence: 0.0,
                reasoning: [],
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime)
            )
            reasoningResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performDecisionMaking() async {
        guard let reasoningEngine = appManager.getReasoningEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let request = DecisionMakingRequest(
                context: decisionContext,
                criteria: ["Cost", "Quality", "Time", "Risk"],
                weights: [0.3, 0.3, 0.2, 0.2],
                alternatives: parseAlternatives(from: decisionContext)
            )
            
            let result = try await reasoningEngine.makeDecision(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            let reasoningResult = ReasoningResult(
                feature: .decisionMaking,
                operation: "Multi-Criteria Decision",
                result: "Recommended: \(result.recommendation)",
                confidence: result.confidence,
                reasoning: result.analysis,
                details: [
                    "Best Option": result.recommendation,
                    "Score": String(format: "%.2f", result.score),
                    "Alternatives": "\(result.alternatives.count)"
                ],
                timestamp: Date(),
                duration: duration
            )
            
            reasoningResults.insert(reasoningResult, at: 0)
            
        } catch {
            let errorResult = ReasoningResult(
                feature: .decisionMaking,
                operation: "Multi-Criteria Decision",
                result: "Decision failed: \(error.localizedDescription)",
                confidence: 0.0,
                reasoning: [],
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime)
            )
            reasoningResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func buildKnowledgeGraph() async {
        await simulateReasoningOperation(
            feature: .knowledgeGraph,
            operation: "Build Knowledge Graph",
            result: "Knowledge graph built with \(knowledgeEntities.split(separator: ",").count) entities",
            confidence: 0.95,
            reasoning: [
                "Parsed entities from input",
                "Identified entity types and categories",
                "Established relationships based on domain knowledge",
                "Created graph structure with nodes and edges"
            ]
        )
    }
    
    @MainActor
    private func findRelations() async {
        await simulateReasoningOperation(
            feature: .knowledgeGraph,
            operation: "Find Relations",
            result: "Found 12 relationships between entities",
            confidence: 0.88,
            reasoning: [
                "Apple -> manufactures -> iPhone",
                "Tim Cook -> CEO of -> Apple",
                "Apple -> located in -> Cupertino",
                "iPhone -> is a -> Technology product"
            ]
        )
    }
    
    @MainActor
    private func queryKnowledgeGraph() async {
        await simulateReasoningOperation(
            feature: .knowledgeGraph,
            operation: "Query Knowledge Graph",
            result: "Query executed successfully",
            confidence: 0.92,
            reasoning: [
                "Parsed query intent",
                "Traversed graph to find matching patterns",
                "Retrieved relevant subgraph",
                "Ranked results by relevance"
            ]
        )
    }
    
    @MainActor
    private func visualizeGraph() async {
        await simulateReasoningOperation(
            feature: .knowledgeGraph,
            operation: "Visualize Graph",
            result: "Graph visualization generated",
            confidence: 1.0,
            reasoning: [
                "Calculated node positions using force-directed layout",
                "Applied clustering for related entities",
                "Rendered edges with relationship labels",
                "Generated interactive visualization"
            ]
        )
    }
    
    @MainActor
    private func solvePuzzle() async {
        await simulateReasoningOperation(
            feature: .problemSolving,
            operation: "8-Puzzle Solver",
            result: "Puzzle solved in 24 moves",
            confidence: 1.0,
            reasoning: [
                "Initial state analyzed",
                "Applied A* search algorithm",
                "Used Manhattan distance heuristic",
                "Found optimal solution path"
            ]
        )
    }
    
    @MainActor
    private func findOptimalPath() async {
        await simulateReasoningOperation(
            feature: .problemSolving,
            operation: "Path Finding",
            result: "Optimal path found with cost 42",
            confidence: 0.96,
            reasoning: [
                "Mapped search space",
                "Applied Dijkstra's algorithm",
                "Evaluated path costs",
                "Selected minimum cost path"
            ]
        )
    }
    
    @MainActor
    private func solveConstraints() async {
        await simulateReasoningOperation(
            feature: .problemSolving,
            operation: "Constraint Solver",
            result: "Solution found satisfying all constraints",
            confidence: 0.91,
            reasoning: [
                "Identified constraint variables",
                "Applied constraint propagation",
                "Used backtracking search",
                "Verified solution validity"
            ]
        )
    }
    
    @MainActor
    private func createPlan() async {
        await simulateReasoningOperation(
            feature: .problemSolving,
            operation: "Planning",
            result: "Generated 5-step plan to achieve goal",
            confidence: 0.87,
            reasoning: [
                "Analyzed initial and goal states",
                "Identified required actions",
                "Ordered actions by dependencies",
                "Optimized plan for efficiency"
            ]
        )
    }
    
    @MainActor
    private func analyzeNumberSequence() async {
        await simulateReasoningOperation(
            feature: .patternRecognition,
            operation: "Number Sequence Analysis",
            result: "Pattern identified: Fibonacci sequence",
            confidence: 0.98,
            reasoning: [
                "Analyzed differences between consecutive terms",
                "Checked for arithmetic progression",
                "Tested geometric progression",
                "Identified Fibonacci pattern"
            ]
        )
    }
    
    @MainActor
    private func findTextPatterns() async {
        await simulateReasoningOperation(
            feature: .patternRecognition,
            operation: "Text Pattern Analysis",
            result: "Found 3 recurring patterns",
            confidence: 0.85,
            reasoning: [
                "Tokenized text into n-grams",
                "Calculated frequency distributions",
                "Identified repeated patterns",
                "Extracted pattern rules"
            ]
        )
    }
    
    @MainActor
    private func analyzeBehavior() async {
        await simulateReasoningOperation(
            feature: .patternRecognition,
            operation: "Behavioral Pattern Analysis",
            result: "Identified cyclic behavior pattern",
            confidence: 0.82,
            reasoning: [
                "Collected behavioral data points",
                "Applied time series analysis",
                "Detected periodic patterns",
                "Predicted future behavior"
            ]
        )
    }
    
    @MainActor
    private func detectAnomalies() async {
        await simulateReasoningOperation(
            feature: .patternRecognition,
            operation: "Anomaly Detection",
            result: "Detected 2 anomalies in dataset",
            confidence: 0.89,
            reasoning: [
                "Established baseline patterns",
                "Calculated statistical thresholds",
                "Identified outliers",
                "Classified anomaly types"
            ]
        )
    }
    
    @MainActor
    private func performCausalAnalysis() async {
        await simulateReasoningOperation(
            feature: .causalReasoning,
            operation: "Causal Analysis",
            result: "Identified 3 causal relationships",
            confidence: 0.86,
            reasoning: [
                "Analyzed temporal sequences",
                "Applied causal inference methods",
                "Tested for confounding variables",
                "Established causal chains"
            ]
        )
    }
    
    @MainActor
    private func findRootCause() async {
        await simulateReasoningOperation(
            feature: .causalReasoning,
            operation: "Root Cause Analysis",
            result: "Root cause: Configuration error",
            confidence: 0.93,
            reasoning: [
                "Traced error propagation path",
                "Applied 5-why analysis",
                "Eliminated intermediate causes",
                "Identified fundamental cause"
            ]
        )
    }
    
    @MainActor
    private func analyzeImpact() async {
        await simulateReasoningOperation(
            feature: .causalReasoning,
            operation: "Impact Analysis",
            result: "High impact on 3 dependent systems",
            confidence: 0.88,
            reasoning: [
                "Mapped dependency graph",
                "Simulated change propagation",
                "Calculated impact scores",
                "Prioritized affected components"
            ]
        )
    }
    
    @MainActor
    private func predictEffects() async {
        await simulateReasoningOperation(
            feature: .causalReasoning,
            operation: "Effect Prediction",
            result: "Predicted 5 downstream effects",
            confidence: 0.79,
            reasoning: [
                "Built causal model",
                "Applied forward chaining",
                "Calculated probability distributions",
                "Generated effect predictions"
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func simulateReasoningOperation(
        feature: ReasoningFeature,
        operation: String,
        result: String,
        confidence: Float,
        reasoning: [String]
    ) async {
        isProcessing = true
        let startTime = Date()
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
        
        let duration = Date().timeIntervalSince(startTime)
        
        let reasoningResult = ReasoningResult(
            feature: feature,
            operation: operation,
            result: result,
            confidence: confidence,
            reasoning: reasoning,
            details: [
                "Confidence": String(format: "%.1f%%", confidence * 100),
                "Steps": "\(reasoning.count)",
                "Duration": String(format: "%.2fs", duration)
            ],
            timestamp: Date(),
            duration: duration
        )
        
        reasoningResults.insert(reasoningResult, at: 0)
        
        isProcessing = false
    }
    
    private func parseAlternatives(from context: String) -> [String] {
        // Simple parsing for demo purposes
        return ["Option A", "Option B", "Option C"]
    }
}

struct ReasoningResultCard: View {
    let result: ReasoningDemoView.ReasoningResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.feature.icon)
                    .foregroundColor(result.feature.color)
                VStack(alignment: .leading) {
                    Text(result.operation)
                        .font(.headline)
                    Text(timeAgoString(from: result.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if result.confidence > 0 {
                    Text("\(Int(result.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(result.feature.color.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Text(result.result)
                .font(.body)
                .padding(10)
                .background(result.feature.color.opacity(0.1))
                .cornerRadius(8)
            
            if !result.reasoning.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reasoning Steps:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(result.reasoning.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            Text(step)
                                .font(.caption)
                            Spacer()
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(6)
            }
            
            if !result.details.isEmpty {
                HStack {
                    ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        if key != result.details.sorted(by: { $0.key < $1.key }).last?.key {
                            Divider()
                                .frame(height: 12)
                        }
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
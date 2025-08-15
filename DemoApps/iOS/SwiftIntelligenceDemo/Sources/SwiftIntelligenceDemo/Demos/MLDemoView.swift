import SwiftUI
import SwiftIntelligenceML
import SwiftIntelligenceCore

struct MLDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var isTraining = false
    @State private var isPredicting = false
    @State private var trainingResult: String = ""
    @State private var predictionResult: String = ""
    @State private var inputFeatures: String = "2.5, 1.8, 3.2"
    @State private var selectedModel: ModelType = .linearRegression
    @State private var trainingAccuracy: Float = 0.0
    
    enum ModelType: String, CaseIterable {
        case linearRegression = "Linear Regression"
        case classification = "Classification"
        case neuralNetwork = "Neural Network"
        
        var icon: String {
            switch self {
            case .linearRegression: return "chart.line.uptrend.xyaxis"
            case .classification: return "rectangle.3.group"
            case .neuralNetwork: return "brain.head.profile"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                            .font(.title)
                        Text("Machine Learning Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Advanced ML capabilities with on-device training and inference")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Model Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Model Type")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 10) {
                        ForEach(ModelType.allCases, id: \.rawValue) { model in
                            Button(action: {
                                selectedModel = model
                            }) {
                                HStack {
                                    Image(systemName: model.icon)
                                        .foregroundColor(selectedModel == model ? .white : .blue)
                                    Text(model.rawValue)
                                        .foregroundColor(selectedModel == model ? .white : .primary)
                                    Spacer()
                                    if selectedModel == model {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(selectedModel == model ? Color.blue : Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Training Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Model Training")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Train the \(selectedModel.rawValue) model with sample data:")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                await trainModel()
                            }
                        }) {
                            HStack {
                                if isTraining {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "play.fill")
                                }
                                Text(isTraining ? "Training..." : "Start Training")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(isTraining ? Color.gray : Color.green)
                            .cornerRadius(10)
                        }
                        .disabled(isTraining)
                        
                        if !trainingResult.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Training Results:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(trainingResult)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                                
                                if trainingAccuracy > 0 {
                                    HStack {
                                        Text("Accuracy:")
                                            .font(.caption)
                                        ProgressView(value: trainingAccuracy, total: 1.0)
                                            .progressViewStyle(LinearProgressViewStyle())
                                        Text("\(Int(trainingAccuracy * 100))%")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Prediction Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Model Prediction")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Input Features:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter features (comma separated)", text: $inputFeatures)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        Text("Example: 2.5, 1.8, 3.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                await makePrediction()
                            }
                        }) {
                            HStack {
                                if isPredicting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wand.and.rays")
                                }
                                Text(isPredicting ? "Predicting..." : "Make Prediction")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(isPredicting ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(isPredicting || inputFeatures.isEmpty)
                        
                        if !predictionResult.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Prediction Results:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(predictionResult)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Model Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Model Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        InfoRow(title: "Selected Model", value: selectedModel.rawValue)
                        InfoRow(title: "Status", value: trainingResult.isEmpty ? "Not Trained" : "Trained")
                        InfoRow(title: "Accuracy", value: trainingAccuracy > 0 ? "\(Int(trainingAccuracy * 100))%" : "N/A")
                        InfoRow(title: "Framework", value: "SwiftIntelligenceML")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("ML Engine")
    }
    
    @MainActor
    private func trainModel() async {
        guard let mlEngine = appManager.getMLEngine() else { return }
        
        isTraining = true
        trainingResult = ""
        
        do {
            // Create sample training data based on model type
            let trainingData = createSampleTrainingData()
            
            // Get model ID based on selected type
            let modelID = getModelID(for: selectedModel)
            
            // Train the model
            let result = try await mlEngine.train(modelID: modelID, with: trainingData)
            
            trainingAccuracy = result.accuracy
            trainingResult = """
            ✅ Training Completed!
            Accuracy: \(String(format: "%.2f%%", result.accuracy * 100))
            Loss: \(String(format: "%.4f", result.loss))
            Duration: \(String(format: "%.2f", result.duration))s
            Epochs: \(result.epochs)
            """
            
        } catch {
            trainingResult = "❌ Training failed: \(error.localizedDescription)"
        }
        
        isTraining = false
    }
    
    @MainActor
    private func makePrediction() async {
        guard let mlEngine = appManager.getMLEngine() else { return }
        
        isPredicting = true
        predictionResult = ""
        
        do {
            // Parse input features
            let features = parseInputFeatures()
            let input = MLInput(features: features)
            
            // Get model ID
            let modelID = getModelID(for: selectedModel)
            
            // Make prediction
            let output = try await mlEngine.predict(modelID: modelID, input: input)
            
            let predictionValue = output.prediction.first ?? 0.0
            let confidence = output.confidence
            
            predictionResult = """
            🎯 Prediction Result:
            Value: \(String(format: "%.4f", predictionValue))
            Confidence: \(String(format: "%.2f%%", confidence * 100))
            \(selectedModel == .classification ? "Class: \(output.classificationResult ?? "Unknown")" : "")
            """
            
        } catch {
            predictionResult = "❌ Prediction failed: \(error.localizedDescription)"
        }
        
        isPredicting = false
    }
    
    private func createSampleTrainingData() -> MLTrainingData {
        switch selectedModel {
        case .linearRegression:
            return createLinearRegressionData()
        case .classification:
            return createClassificationData()
        case .neuralNetwork:
            return createNeuralNetworkData()
        }
    }
    
    private func createLinearRegressionData() -> MLTrainingData {
        let inputs = [
            MLInput(features: [1.0, 2.0]),
            MLInput(features: [2.0, 3.0]),
            MLInput(features: [3.0, 4.0]),
            MLInput(features: [4.0, 5.0]),
            MLInput(features: [5.0, 6.0])
        ]
        
        let outputs = [
            MLOutput(prediction: [3.0]),
            MLOutput(prediction: [5.0]),
            MLOutput(prediction: [7.0]),
            MLOutput(prediction: [9.0]),
            MLOutput(prediction: [11.0])
        ]
        
        return MLTrainingData(inputs: inputs, expectedOutputs: outputs)
    }
    
    private func createClassificationData() -> MLTrainingData {
        let inputs = [
            MLInput(features: [1.0, 2.0]),
            MLInput(features: [2.0, 3.0]),
            MLInput(features: [8.0, 9.0]),
            MLInput(features: [9.0, 8.0]),
            MLInput(features: [1.5, 2.5])
        ]
        
        let outputs = [
            MLOutput(prediction: [0.0], classificationResult: "class_0"),
            MLOutput(prediction: [0.0], classificationResult: "class_0"),
            MLOutput(prediction: [1.0], classificationResult: "class_1"),
            MLOutput(prediction: [1.0], classificationResult: "class_1"),
            MLOutput(prediction: [0.0], classificationResult: "class_0")
        ]
        
        return MLTrainingData(inputs: inputs, expectedOutputs: outputs)
    }
    
    private func createNeuralNetworkData() -> MLTrainingData {
        let inputs = [
            MLInput(features: [0.1, 0.2]),
            MLInput(features: [0.3, 0.4]),
            MLInput(features: [0.5, 0.6]),
            MLInput(features: [0.7, 0.8]),
            MLInput(features: [0.9, 1.0])
        ]
        
        let outputs = [
            MLOutput(prediction: [0.15]),
            MLOutput(prediction: [0.35]),
            MLOutput(prediction: [0.55]),
            MLOutput(prediction: [0.75]),
            MLOutput(prediction: [0.95])
        ]
        
        return MLTrainingData(inputs: inputs, expectedOutputs: outputs)
    }
    
    private func parseInputFeatures() -> [Double] {
        return inputFeatures
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }
    
    private func getModelID(for type: ModelType) -> String {
        switch type {
        case .linearRegression:
            return "linear_regression"
        case .classification:
            return "classification"
        case .neuralNetwork:
            return "neural_network"
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.caption)
    }
}
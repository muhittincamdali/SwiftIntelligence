import Foundation
import CoreML
import Combine
import os.log

/// Manages all ML models - downloading, caching, loading, and optimization
public class ModelManager: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = ModelManager()
    
    // MARK: - Published Properties
    @Published public var status: Status = .idle
    @Published public var downloadProgress: [String: Double] = [:]
    @Published public var loadedModels: [String: MLModel] = [:]
    
    // MARK: - Core Properties
    public var loadedModelCount: Int { loadedModels.count }
    
    // MARK: - Private Properties
    private let fileManager = FileManager.default
    private let urlSession = URLSession.shared
    private let modelCache = NSCache<NSString, MLModel>()
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "ModelManager")
    
    // Directories
    private let modelsDirectory: URL
    private let tempDirectory: URL
    
    // Model registry
    private var modelRegistry: [String: ModelInfo] = [:]
    private var downloadTasks: [String: URLSessionDownloadTask] = [:]
    
    // MARK: - Initialization
    private init() {
        // Setup directories
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.modelsDirectory = documentsPath.appendingPathComponent("SwiftIntelligence/Models")
        self.tempDirectory = fileManager.temporaryDirectory.appendingPathComponent("SwiftIntelligence")
        
        createDirectoriesIfNeeded()
        setupModelCache()
        loadModelRegistry()
    }
    
    // MARK: - Setup
    private func createDirectoriesIfNeeded() {
        do {
            try fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create directories: \(error)")
        }
    }
    
    private func setupModelCache() {
        modelCache.totalCostLimit = 1024 * 1024 * 512 // 512MB cache limit
        modelCache.countLimit = 10 // Maximum 10 models in memory
    }
    
    private func loadModelRegistry() {
        // Register built-in models
        registerBuiltInModels()
        
        // Load custom models from disk
        loadCustomModels()
    }
    
    // MARK: - Public API
    
    /// Initialize the model manager
    public func initialize() async throws {
        logger.info("Initializing ModelManager...")
        status = .initializing
        
        do {
            // Verify model directory integrity
            try verifyModelDirectory()
            
            // Load cached models
            await loadCachedModels()
            
            status = .ready
            logger.info("ModelManager initialized successfully")
            
        } catch {
            status = .error(error)
            logger.error("Failed to initialize ModelManager: \(error)")
            throw error
        }
    }
    
    /// Get available models for specific task type
    public func availableModels(for taskType: TaskType) -> [ModelInfo] {
        return modelRegistry.values.filter { $0.taskType == taskType }
    }
    
    /// Download a model from remote URL
    public func downloadModel(_ modelInfo: ModelInfo) async throws {
        guard !isModelDownloaded(modelInfo) else {
            logger.info("Model \(modelInfo.name) already downloaded")
            return
        }
        
        logger.info("Starting download for model: \(modelInfo.name)")
        
        let downloadURL = modelInfo.downloadURL
        let destinationURL = modelsDirectory.appendingPathComponent("\(modelInfo.id).mlmodel")
        
        do {
            // Create download task
            let (tempFileURL, response) = try await urlSession.download(from: downloadURL)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ModelError.downloadFailed
            }
            
            // Move to permanent location
            try fileManager.moveItem(at: tempFileURL, to: destinationURL)
            
            // Verify model integrity
            try await verifyModelIntegrity(at: destinationURL)
            
            // Update registry
            var updatedModelInfo = modelInfo
            updatedModelInfo.localPath = destinationURL
            modelRegistry[modelInfo.id] = updatedModelInfo
            
            logger.info("Successfully downloaded model: \(modelInfo.name)")
            
        } catch {
            logger.error("Failed to download model \(modelInfo.name): \(error)")
            throw ModelError.downloadFailed
        }
    }
    
    /// Load a model into memory
    public func loadModel(_ modelInfo: ModelInfo) async throws -> MLModel {
        // Check if model is already loaded
        if let cachedModel = modelCache.object(forKey: modelInfo.id as NSString) {
            logger.debug("Using cached model: \(modelInfo.name)")
            return cachedModel
        }
        
        // Check if model exists locally
        guard isModelDownloaded(modelInfo) else {
            throw ModelError.modelNotFound
        }
        
        guard let localPath = modelInfo.localPath else {
            throw ModelError.invalidPath
        }
        
        logger.info("Loading model: \(modelInfo.name)")
        status = .loading
        
        do {
            // Configure ML model
            let configuration = MLModelConfiguration()
            configuration.computeUnits = determineOptimalComputeUnits()
            configuration.allowLowPrecisionAccumulationOnGPU = true
            
            // Load model
            let model = try MLModel(contentsOf: localPath, configuration: configuration)
            
            // Cache the model
            modelCache.setObject(model, forKey: modelInfo.id as NSString)
            loadedModels[modelInfo.id] = model
            
            status = .ready
            logger.info("Successfully loaded model: \(modelInfo.name)")
            
            return model
            
        } catch {
            status = .error(error)
            logger.error("Failed to load model \(modelInfo.name): \(error)")
            throw ModelError.loadingFailed(error)
        }
    }
    
    /// Preload multiple models for better performance
    public func preloadModels(_ modelInfos: [ModelInfo]) async throws {
        logger.info("Preloading \(modelInfos.count) models...")
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for modelInfo in modelInfos {
                group.addTask {
                    _ = try await self.loadModel(modelInfo)
                }
            }
            
            for try await _ in group {
                // Wait for all models to load
            }
        }
        
        logger.info("Successfully preloaded \(modelInfos.count) models")
    }
    
    /// Release unused models from memory
    public func releaseUnusedModels() async {
        let beforeCount = loadedModels.count
        
        // Remove models not accessed recently
        let cutoffTime = Date().addingTimeInterval(-300) // 5 minutes
        loadedModels = loadedModels.filter { _, model in
            // This is a simplified check - in practice, you'd track access times
            return true // Keep all for now
        }
        
        // Clear cache of old entries
        modelCache.removeAllObjects()
        
        let releasedCount = beforeCount - loadedModels.count
        if releasedCount > 0 {
            logger.info("Released \(releasedCount) unused models from memory")
        }
    }
    
    /// Get model information by ID
    public func getModelInfo(id: String) -> ModelInfo? {
        return modelRegistry[id]
    }
    
    /// Check if model is downloaded locally
    public func isModelDownloaded(_ modelInfo: ModelInfo) -> Bool {
        guard let localPath = modelInfo.localPath else { return false }
        return fileManager.fileExists(atPath: localPath.path)
    }
    
    /// Get total size of downloaded models
    public func getTotalModelSize() -> UInt64 {
        var totalSize: UInt64 = 0
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: modelsDirectory, includingPropertiesForKeys: [.fileSizeKey])
            
            for fileURL in contents {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? UInt64 {
                    totalSize += fileSize
                }
            }
        } catch {
            logger.error("Failed to calculate total model size: \(error)")
        }
        
        return totalSize
    }
    
    /// Delete a downloaded model
    public func deleteModel(_ modelInfo: ModelInfo) throws {
        guard let localPath = modelInfo.localPath else { return }
        
        // Remove from memory
        modelCache.removeObject(forKey: modelInfo.id as NSString)
        loadedModels.removeValue(forKey: modelInfo.id)
        
        // Remove from disk
        try fileManager.removeItem(at: localPath)
        
        // Update registry
        var updatedModelInfo = modelInfo
        updatedModelInfo.localPath = nil
        modelRegistry[modelInfo.id] = updatedModelInfo
        
        logger.info("Deleted model: \(modelInfo.name)")
    }
    
    /// Optimize memory usage
    public func optimizeMemoryUsage() async {
        // Release models not used recently
        await releaseUnusedModels()
        
        // Trigger garbage collection
        modelCache.removeAllObjects()
        
        logger.info("Optimized model manager memory usage")
    }
    
    /// Cleanup all resources
    public func cleanup() async {
        // Cancel active downloads
        for task in downloadTasks.values {
            task.cancel()
        }
        downloadTasks.removeAll()
        
        // Clear memory
        modelCache.removeAllObjects()
        loadedModels.removeAll()
        
        status = .idle
        logger.info("ModelManager cleanup complete")
    }
    
    // MARK: - Private Methods
    
    private func verifyModelDirectory() throws {
        let isDirectory = (try modelsDirectory.resourceValues(forKeys: [.isDirectoryKey])).isDirectory
        guard isDirectory == true else {
            throw ModelError.invalidDirectory
        }
    }
    
    private func loadCachedModels() async {
        do {
            let contents = try fileManager.contentsOfDirectory(at: modelsDirectory, includingPropertiesForKeys: nil)
            
            logger.info("Found \(contents.count) cached models")
            
            // Update registry with local paths
            for fileURL in contents {
                let filename = fileURL.lastPathComponent
                let modelId = String(filename.dropLast(8)) // Remove .mlmodel
                
                if var modelInfo = modelRegistry[modelId] {
                    modelInfo.localPath = fileURL
                    modelRegistry[modelId] = modelInfo
                }
            }
            
        } catch {
            logger.error("Failed to load cached models: \(error)")
        }
    }
    
    private func verifyModelIntegrity(at url: URL) async throws {
        // Basic integrity check - try to load the model
        do {
            let configuration = MLModelConfiguration()
            _ = try MLModel(contentsOf: url, configuration: configuration)
        } catch {
            throw ModelError.corruptedModel
        }
    }
    
    private func determineOptimalComputeUnits() -> MLComputeUnits {
        let device = UIDevice.current
        
        // Use Neural Engine if available (A12+ chips)
        if device.userInterfaceIdiom == .phone || device.userInterfaceIdiom == .pad {
            return .all
        }
        
        return .cpuAndGPU
    }
    
    private func registerBuiltInModels() {
        // Image Classification
        modelRegistry[ModelInfo.imageClassification.id] = ModelInfo.imageClassification
        
        // Object Detection
        modelRegistry[ModelInfo.objectDetection.id] = ModelInfo.objectDetection
        
        // Text Sentiment
        modelRegistry[ModelInfo.textSentiment.id] = ModelInfo.textSentiment
        
        // Face Recognition
        modelRegistry[ModelInfo.faceRecognition.id] = ModelInfo.faceRecognition
        
        // Text Recognition (OCR)
        modelRegistry[ModelInfo.textRecognition.id] = ModelInfo.textRecognition
        
        // Speech Recognition
        modelRegistry[ModelInfo.speechRecognition.id] = ModelInfo.speechRecognition
        
        // Image Generation
        modelRegistry[ModelInfo.imageGeneration.id] = ModelInfo.imageGeneration
        
        // Turkish NLP
        modelRegistry[ModelInfo.turkishNLP.id] = ModelInfo.turkishNLP
    }
    
    private func loadCustomModels() {
        // Load user-added custom models
        // This would scan for additional model files and register them
    }
}

// MARK: - Supporting Types

extension ModelManager {
    public enum Status: Equatable {
        case idle
        case initializing
        case loading
        case downloading
        case ready
        case error(Error)
        
        public static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.initializing, .initializing),
                 (.loading, .loading), (.downloading, .downloading),
                 (.ready, .ready):
                return true
            case (.error, .error):
                return true
            default:
                return false
            }
        }
    }
}

public enum ModelError: LocalizedError {
    case downloadFailed
    case modelNotFound
    case invalidPath
    case loadingFailed(Error)
    case corruptedModel
    case invalidDirectory
    case insufficientSpace
    
    public var errorDescription: String? {
        switch self {
        case .downloadFailed:
            return "Failed to download model"
        case .modelNotFound:
            return "Model not found locally"
        case .invalidPath:
            return "Invalid model path"
        case .loadingFailed(let error):
            return "Model loading failed: \(error.localizedDescription)"
        case .corruptedModel:
            return "Model file is corrupted"
        case .invalidDirectory:
            return "Invalid models directory"
        case .insufficientSpace:
            return "Insufficient storage space"
        }
    }
}
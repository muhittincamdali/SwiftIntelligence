import Foundation

/// Comprehensive configuration system for visionOS Engine
/// Provides optimized presets and fine-grained control over all visionOS features
public extension VisionOSConfiguration {
    
    // MARK: - Predefined Configurations
    
    /// Development configuration with debugging features enabled
    static let development = VisionOSConfiguration(
        spatialConfig: .development,
        immersiveConfig: .development,
        realityKitConfig: .development,
        windowConfig: .development,
        gestureConfig: .development,
        arConfig: .development,
        enableImmersiveSpaces: true,
        enableEyeTracking: true,
        enableWorldAnchors: true,
        enableSceneReconstruction: true,
        enableHandTracking: true,
        enableSpatialAudio: true
    )
    
    /// Production configuration optimized for performance
    static let production = VisionOSConfiguration(
        spatialConfig: .production,
        immersiveConfig: .production,
        realityKitConfig: .production,
        windowConfig: .production,
        gestureConfig: .production,
        arConfig: .production,
        enableImmersiveSpaces: true,
        enableEyeTracking: true,
        enableWorldAnchors: true,
        enableSceneReconstruction: true,
        enableHandTracking: true,
        enableSpatialAudio: true
    )
    
    /// Demo configuration for showcasing capabilities
    static let demo = VisionOSConfiguration(
        spatialConfig: .demo,
        immersiveConfig: .demo,
        realityKitConfig: .demo,
        windowConfig: .demo,
        gestureConfig: .demo,
        arConfig: .demo,
        enableImmersiveSpaces: true,
        enableEyeTracking: true,
        enableWorldAnchors: true,
        enableSceneReconstruction: true,
        enableHandTracking: true,
        enableSpatialAudio: true
    )
    
    /// Minimal configuration for basic functionality
    static let minimal = VisionOSConfiguration(
        spatialConfig: .minimal,
        immersiveConfig: .minimal,
        realityKitConfig: .minimal,
        windowConfig: .minimal,
        gestureConfig: .minimal,
        arConfig: .minimal,
        enableImmersiveSpaces: false,
        enableEyeTracking: false,
        enableWorldAnchors: false,
        enableSceneReconstruction: false,
        enableHandTracking: false,
        enableSpatialAudio: false
    )
    
    /// Performance-focused configuration
    static let performance = VisionOSConfiguration(
        spatialConfig: .performance,
        immersiveConfig: .performance,
        realityKitConfig: .performance,
        windowConfig: .performance,
        gestureConfig: .performance,
        arConfig: .performance,
        enableImmersiveSpaces: true,
        enableEyeTracking: false,
        enableWorldAnchors: true,
        enableSceneReconstruction: false,
        enableHandTracking: true,
        enableSpatialAudio: true
    )
    
    /// Quality-focused configuration
    static let quality = VisionOSConfiguration(
        spatialConfig: .quality,
        immersiveConfig: .quality,
        realityKitConfig: .quality,
        windowConfig: .quality,
        gestureConfig: .quality,
        arConfig: .quality,
        enableImmersiveSpaces: true,
        enableEyeTracking: true,
        enableWorldAnchors: true,
        enableSceneReconstruction: true,
        enableHandTracking: true,
        enableSpatialAudio: true
    )
}

// MARK: - Spatial Computing Configurations

public extension SpatialComputingConfiguration {
    
    static let development = SpatialComputingConfiguration(
        trackingQuality: .high,
        anchorPersistence: true,
        worldMappingEnabled: true,
        planeDetection: .all,
        meshGeneration: true,
        lightEstimation: true
    )
    
    static let production = SpatialComputingConfiguration(
        trackingQuality: .ultra,
        anchorPersistence: true,
        worldMappingEnabled: true,
        planeDetection: .all,
        meshGeneration: true,
        lightEstimation: true
    )
    
    static let demo = SpatialComputingConfiguration(
        trackingQuality: .high,
        anchorPersistence: false,
        worldMappingEnabled: true,
        planeDetection: .all,
        meshGeneration: true,
        lightEstimation: true
    )
    
    static let minimal = SpatialComputingConfiguration(
        trackingQuality: .low,
        anchorPersistence: false,
        worldMappingEnabled: false,
        planeDetection: .none,
        meshGeneration: false,
        lightEstimation: false
    )
    
    static let performance = SpatialComputingConfiguration(
        trackingQuality: .medium,
        anchorPersistence: true,
        worldMappingEnabled: true,
        planeDetection: .horizontal,
        meshGeneration: false,
        lightEstimation: false
    )
    
    static let quality = SpatialComputingConfiguration(
        trackingQuality: .ultra,
        anchorPersistence: true,
        worldMappingEnabled: true,
        planeDetection: .all,
        meshGeneration: true,
        lightEstimation: true
    )
}

// MARK: - Immersive Space Configurations

public extension ImmersiveSpaceConfiguration {
    
    static let development = ImmersiveSpaceConfiguration(
        defaultStyle: .mixed,
        supportedStyles: [.mixed, .progressive, .full],
        transitionDuration: 1.0,
        enableGradualTransitions: true,
        ambientLighting: .adaptive
    )
    
    static let production = ImmersiveSpaceConfiguration(
        defaultStyle: .progressive,
        supportedStyles: [.mixed, .progressive, .full],
        transitionDuration: 0.5,
        enableGradualTransitions: true,
        ambientLighting: .adaptive
    )
    
    static let demo = ImmersiveSpaceConfiguration(
        defaultStyle: .full,
        supportedStyles: [.mixed, .progressive, .full],
        transitionDuration: 1.5,
        enableGradualTransitions: true,
        ambientLighting: .natural
    )
    
    static let minimal = ImmersiveSpaceConfiguration(
        defaultStyle: .mixed,
        supportedStyles: [.mixed],
        transitionDuration: 0.2,
        enableGradualTransitions: false,
        ambientLighting: .minimal
    )
    
    static let performance = ImmersiveSpaceConfiguration(
        defaultStyle: .mixed,
        supportedStyles: [.mixed, .progressive],
        transitionDuration: 0.3,
        enableGradualTransitions: false,
        ambientLighting: .minimal
    )
    
    static let quality = ImmersiveSpaceConfiguration(
        defaultStyle: .progressive,
        supportedStyles: [.mixed, .progressive, .full],
        transitionDuration: 1.0,
        enableGradualTransitions: true,
        ambientLighting: .natural
    )
}

// MARK: - RealityKit Configurations

public extension RealityKitConfiguration {
    
    static let development = RealityKitConfiguration(
        renderingQuality: .medium,
        enablePhysics: true,
        enableOcclusion: true,
        enableShadows: true,
        enableReflections: true,
        maxEntitiesPerScene: 500,
        optimizationMode: .balanced
    )
    
    static let production = RealityKitConfiguration(
        renderingQuality: .high,
        enablePhysics: true,
        enableOcclusion: true,
        enableShadows: true,
        enableReflections: true,
        maxEntitiesPerScene: 1000,
        optimizationMode: .balanced
    )
    
    static let demo = RealityKitConfiguration(
        renderingQuality: .ultra,
        enablePhysics: true,
        enableOcclusion: true,
        enableShadows: true,
        enableReflections: true,
        maxEntitiesPerScene: 2000,
        optimizationMode: .quality
    )
    
    static let minimal = RealityKitConfiguration(
        renderingQuality: .low,
        enablePhysics: false,
        enableOcclusion: false,
        enableShadows: false,
        enableReflections: false,
        maxEntitiesPerScene: 100,
        optimizationMode: .performance
    )
    
    static let performance = RealityKitConfiguration(
        renderingQuality: .medium,
        enablePhysics: true,
        enableOcclusion: false,
        enableShadows: false,
        enableReflections: false,
        maxEntitiesPerScene: 750,
        optimizationMode: .performance
    )
    
    static let quality = RealityKitConfiguration(
        renderingQuality: .ultra,
        enablePhysics: true,
        enableOcclusion: true,
        enableShadows: true,
        enableReflections: true,
        maxEntitiesPerScene: 1500,
        optimizationMode: .quality
    )
}

// MARK: - Window Configurations

public extension WindowConfiguration {
    
    static let development = WindowConfiguration(
        id: "development",
        content: AnyView(EmptyView()),
        size: CGSize(width: 800, height: 600),
        position: .center,
        style: .bordered,
        level: .normal,
        allowsMultipleInstances: true
    )
    
    static let production = WindowConfiguration(
        id: "production",
        content: AnyView(EmptyView()),
        size: nil,
        position: .automatic,
        style: .plain,
        level: .normal,
        allowsMultipleInstances: false
    )
    
    static let demo = WindowConfiguration(
        id: "demo",
        content: AnyView(EmptyView()),
        size: CGSize(width: 1200, height: 800),
        position: .center,
        style: .floating,
        level: .floating,
        allowsMultipleInstances: true
    )
    
    static let minimal = WindowConfiguration(
        id: "minimal",
        content: AnyView(EmptyView()),
        size: CGSize(width: 400, height: 300),
        position: .automatic,
        style: .plain,
        level: .normal,
        allowsMultipleInstances: false
    )
    
    static let performance = WindowConfiguration(
        id: "performance",
        content: AnyView(EmptyView()),
        size: CGSize(width: 600, height: 400),
        position: .automatic,
        style: .plain,
        level: .normal,
        allowsMultipleInstances: false
    )
    
    static let quality = WindowConfiguration(
        id: "quality",
        content: AnyView(EmptyView()),
        size: CGSize(width: 1000, height: 700),
        position: .center,
        style: .floating,
        level: .floating,
        allowsMultipleInstances: true
    )
}

// MARK: - Gesture Configurations

public extension GestureConfiguration {
    
    static let development = GestureConfiguration(
        enableHandTracking: true,
        enableEyeTracking: true,
        enableVoiceCommands: true,
        gestureRecognitionThreshold: 0.7,
        trackingFrequency: 30.0,
        enableHapticFeedback: true
    )
    
    static let production = GestureConfiguration(
        enableHandTracking: true,
        enableEyeTracking: true,
        enableVoiceCommands: true,
        gestureRecognitionThreshold: 0.8,
        trackingFrequency: 60.0,
        enableHapticFeedback: true
    )
    
    static let demo = GestureConfiguration(
        enableHandTracking: true,
        enableEyeTracking: true,
        enableVoiceCommands: true,
        gestureRecognitionThreshold: 0.6,
        trackingFrequency: 60.0,
        enableHapticFeedback: true
    )
    
    static let minimal = GestureConfiguration(
        enableHandTracking: false,
        enableEyeTracking: false,
        enableVoiceCommands: false,
        gestureRecognitionThreshold: 0.9,
        trackingFrequency: 15.0,
        enableHapticFeedback: false
    )
    
    static let performance = GestureConfiguration(
        enableHandTracking: true,
        enableEyeTracking: false,
        enableVoiceCommands: true,
        gestureRecognitionThreshold: 0.8,
        trackingFrequency: 30.0,
        enableHapticFeedback: false
    )
    
    static let quality = GestureConfiguration(
        enableHandTracking: true,
        enableEyeTracking: true,
        enableVoiceCommands: true,
        gestureRecognitionThreshold: 0.7,
        trackingFrequency: 90.0,
        enableHapticFeedback: true
    )
}

// MARK: - AR Configurations

public extension ARConfiguration {
    
    static let development = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: true,
        enableImageTracking: true,
        enableObjectDetection: true,
        enableFaceTracking: false,
        enableBodyTracking: false,
        worldAlignment: .gravity
    )
    
    static let production = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: true,
        enableImageTracking: true,
        enableObjectDetection: true,
        enableFaceTracking: false,
        enableBodyTracking: false,
        worldAlignment: .gravityAndHeading
    )
    
    static let demo = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: true,
        enableImageTracking: true,
        enableObjectDetection: true,
        enableFaceTracking: true,
        enableBodyTracking: true,
        worldAlignment: .gravityAndHeading
    )
    
    static let minimal = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: false,
        enableImageTracking: false,
        enableObjectDetection: false,
        enableFaceTracking: false,
        enableBodyTracking: false,
        worldAlignment: .gravity
    )
    
    static let performance = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: true,
        enableImageTracking: false,
        enableObjectDetection: false,
        enableFaceTracking: false,
        enableBodyTracking: false,
        worldAlignment: .gravity
    )
    
    static let quality = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: true,
        enableImageTracking: true,
        enableObjectDetection: true,
        enableFaceTracking: true,
        enableBodyTracking: false,
        worldAlignment: .gravityAndHeading
    )
}

// MARK: - Configuration Validation

public extension VisionOSConfiguration {
    
    /// Validate configuration for compatibility and performance
    func validate() throws {
        // Check for incompatible combinations
        if !enableImmersiveSpaces && immersiveConfig.defaultStyle == .full {
            throw VisionOSConfigurationError.incompatibleSettings("Immersive spaces disabled but full immersion style specified")
        }
        
        if !enableHandTracking && gestureConfig.enableHandTracking {
            throw VisionOSConfigurationError.incompatibleSettings("Hand tracking disabled but gesture config enables it")
        }
        
        if !enableEyeTracking && gestureConfig.enableEyeTracking {
            throw VisionOSConfigurationError.incompatibleSettings("Eye tracking disabled but gesture config enables it")
        }
        
        // Check performance constraints
        if realityKitConfig.renderingQuality == .ultra && realityKitConfig.maxEntitiesPerScene > 1000 {
            throw VisionOSConfigurationError.performanceWarning("Ultra quality with high entity count may cause performance issues")
        }
        
        // Validate spatial computing settings
        if spatialConfig.trackingQuality == .ultra && spatialConfig.meshGeneration && spatialConfig.lightEstimation {
            throw VisionOSConfigurationError.performanceWarning("Maximum spatial computing features may impact performance")
        }
    }
    
    /// Get estimated performance impact score (0.0 to 1.0)
    func getPerformanceImpact() -> Float {
        var score: Float = 0.0
        
        // Spatial computing impact
        switch spatialConfig.trackingQuality {
        case .low: score += 0.1
        case .medium: score += 0.2
        case .high: score += 0.3
        case .ultra: score += 0.4
        }
        
        if spatialConfig.meshGeneration { score += 0.1 }
        if spatialConfig.lightEstimation { score += 0.05 }
        if spatialConfig.planeDetection == .all { score += 0.05 }
        
        // RealityKit impact
        switch realityKitConfig.renderingQuality {
        case .low: score += 0.05
        case .medium: score += 0.1
        case .high: score += 0.2
        case .ultra: score += 0.3
        }
        
        if realityKitConfig.enablePhysics { score += 0.05 }
        if realityKitConfig.enableOcclusion { score += 0.05 }
        if realityKitConfig.enableShadows { score += 0.05 }
        if realityKitConfig.enableReflections { score += 0.05 }
        
        // Gesture tracking impact
        if gestureConfig.enableHandTracking { score += 0.05 }
        if gestureConfig.enableEyeTracking { score += 0.05 }
        
        return min(score, 1.0)
    }
    
    /// Get memory usage estimate in MB
    func getEstimatedMemoryUsage() -> Int {
        var memoryMB: Int = 100 // Base memory
        
        // Spatial computing memory
        switch spatialConfig.trackingQuality {
        case .low: memoryMB += 50
        case .medium: memoryMB += 100
        case .high: memoryMB += 200
        case .ultra: memoryMB += 400
        }
        
        if spatialConfig.meshGeneration { memoryMB += 100 }
        if spatialConfig.worldMappingEnabled { memoryMB += 150 }
        
        // RealityKit memory
        switch realityKitConfig.renderingQuality {
        case .low: memoryMB += 50
        case .medium: memoryMB += 100
        case .high: memoryMB += 200
        case .ultra: memoryMB += 400
        }
        
        memoryMB += realityKitConfig.maxEntitiesPerScene / 10 // Rough estimate
        
        // Immersive spaces memory
        if enableImmersiveSpaces {
            memoryMB += 100
            
            switch immersiveConfig.defaultStyle {
            case .mixed: memoryMB += 50
            case .progressive: memoryMB += 100
            case .full: memoryMB += 200
            }
        }
        
        return memoryMB
    }
}

// MARK: - Configuration Builder

public class VisionOSConfigurationBuilder {
    private var config = VisionOSConfiguration.default
    
    public init() {}
    
    public func withSpatialConfig(_ spatialConfig: SpatialComputingConfiguration) -> VisionOSConfigurationBuilder {
        config = VisionOSConfiguration(
            spatialConfig: spatialConfig,
            immersiveConfig: config.immersiveConfig,
            realityKitConfig: config.realityKitConfig,
            windowConfig: config.windowConfig,
            gestureConfig: config.gestureConfig,
            arConfig: config.arConfig,
            enableImmersiveSpaces: config.enableImmersiveSpaces,
            enableEyeTracking: config.enableEyeTracking,
            enableWorldAnchors: config.enableWorldAnchors,
            enableSceneReconstruction: config.enableSceneReconstruction,
            enableHandTracking: config.enableHandTracking,
            enableSpatialAudio: config.enableSpatialAudio
        )
        return self
    }
    
    public func withImmersiveConfig(_ immersiveConfig: ImmersiveSpaceConfiguration) -> VisionOSConfigurationBuilder {
        config = VisionOSConfiguration(
            spatialConfig: config.spatialConfig,
            immersiveConfig: immersiveConfig,
            realityKitConfig: config.realityKitConfig,
            windowConfig: config.windowConfig,
            gestureConfig: config.gestureConfig,
            arConfig: config.arConfig,
            enableImmersiveSpaces: config.enableImmersiveSpaces,
            enableEyeTracking: config.enableEyeTracking,
            enableWorldAnchors: config.enableWorldAnchors,
            enableSceneReconstruction: config.enableSceneReconstruction,
            enableHandTracking: config.enableHandTracking,
            enableSpatialAudio: config.enableSpatialAudio
        )
        return self
    }
    
    public func withRealityKitConfig(_ realityKitConfig: RealityKitConfiguration) -> VisionOSConfigurationBuilder {
        config = VisionOSConfiguration(
            spatialConfig: config.spatialConfig,
            immersiveConfig: config.immersiveConfig,
            realityKitConfig: realityKitConfig,
            windowConfig: config.windowConfig,
            gestureConfig: config.gestureConfig,
            arConfig: config.arConfig,
            enableImmersiveSpaces: config.enableImmersiveSpaces,
            enableEyeTracking: config.enableEyeTracking,
            enableWorldAnchors: config.enableWorldAnchors,
            enableSceneReconstruction: config.enableSceneReconstruction,
            enableHandTracking: config.enableHandTracking,
            enableSpatialAudio: config.enableSpatialAudio
        )
        return self
    }
    
    public func enableFeatures(_ features: VisionOSCapabilities) -> VisionOSConfigurationBuilder {
        config = VisionOSConfiguration(
            spatialConfig: config.spatialConfig,
            immersiveConfig: config.immersiveConfig,
            realityKitConfig: config.realityKitConfig,
            windowConfig: config.windowConfig,
            gestureConfig: config.gestureConfig,
            arConfig: config.arConfig,
            enableImmersiveSpaces: features.contains(.immersiveSpaces),
            enableEyeTracking: features.contains(.eyeTracking),
            enableWorldAnchors: features.contains(.worldAnchors),
            enableSceneReconstruction: features.contains(.sceneReconstruction),
            enableHandTracking: features.contains(.handTracking),
            enableSpatialAudio: features.contains(.spatialAudio)
        )
        return self
    }
    
    public func build() throws -> VisionOSConfiguration {
        try config.validate()
        return config
    }
}

// MARK: - Error Types

public enum VisionOSConfigurationError: LocalizedError {
    case incompatibleSettings(String)
    case performanceWarning(String)
    case validationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .incompatibleSettings(let message):
            return "Incompatible configuration settings: \(message)"
        case .performanceWarning(let message):
            return "Performance warning: \(message)"
        case .validationFailed(let message):
            return "Configuration validation failed: \(message)"
        }
    }
}
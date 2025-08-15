import SwiftUI
import RealityKit
import ARKit
import AVFoundation

// MARK: - Core Configuration Types

public struct VisionOSConfiguration {
    public let spatialConfig: SpatialComputingConfiguration
    public let immersiveConfig: ImmersiveSpaceConfiguration
    public let realityKitConfig: RealityKitConfiguration
    public let windowConfig: WindowConfiguration
    public let gestureConfig: GestureConfiguration
    public let arConfig: ARConfiguration
    
    // Feature flags
    public let enableImmersiveSpaces: Bool
    public let enableEyeTracking: Bool
    public let enableWorldAnchors: Bool
    public let enableSceneReconstruction: Bool
    public let enableHandTracking: Bool
    public let enableSpatialAudio: Bool
    
    public static let `default` = VisionOSConfiguration(
        spatialConfig: .default,
        immersiveConfig: .default,
        realityKitConfig: .default,
        windowConfig: .default,
        gestureConfig: .default,
        arConfig: .default,
        enableImmersiveSpaces: true,
        enableEyeTracking: true,
        enableWorldAnchors: true,
        enableSceneReconstruction: true,
        enableHandTracking: true,
        enableSpatialAudio: true
    )
    
    public init(
        spatialConfig: SpatialComputingConfiguration = .default,
        immersiveConfig: ImmersiveSpaceConfiguration = .default,
        realityKitConfig: RealityKitConfiguration = .default,
        windowConfig: WindowConfiguration = .default,
        gestureConfig: GestureConfiguration = .default,
        arConfig: ARConfiguration = .default,
        enableImmersiveSpaces: Bool = true,
        enableEyeTracking: Bool = true,
        enableWorldAnchors: Bool = true,
        enableSceneReconstruction: Bool = true,
        enableHandTracking: Bool = true,
        enableSpatialAudio: Bool = true
    ) {
        self.spatialConfig = spatialConfig
        self.immersiveConfig = immersiveConfig
        self.realityKitConfig = realityKitConfig
        self.windowConfig = windowConfig
        self.gestureConfig = gestureConfig
        self.arConfig = arConfig
        self.enableImmersiveSpaces = enableImmersiveSpaces
        self.enableEyeTracking = enableEyeTracking
        self.enableWorldAnchors = enableWorldAnchors
        self.enableSceneReconstruction = enableSceneReconstruction
        self.enableHandTracking = enableHandTracking
        self.enableSpatialAudio = enableSpatialAudio
    }
}

// MARK: - Spatial Computing Types

public struct SpatialComputingConfiguration {
    public let trackingQuality: SpatialTrackingQuality
    public let anchorPersistence: Bool
    public let worldMappingEnabled: Bool
    public let planeDetection: PlaneDetectionMode
    public let meshGeneration: Bool
    public let lightEstimation: Bool
    
    public static let `default` = SpatialComputingConfiguration(
        trackingQuality: .high,
        anchorPersistence: true,
        worldMappingEnabled: true,
        planeDetection: .all,
        meshGeneration: true,
        lightEstimation: true
    )
    
    public init(
        trackingQuality: SpatialTrackingQuality = .high,
        anchorPersistence: Bool = true,
        worldMappingEnabled: Bool = true,
        planeDetection: PlaneDetectionMode = .all,
        meshGeneration: Bool = true,
        lightEstimation: Bool = true
    ) {
        self.trackingQuality = trackingQuality
        self.anchorPersistence = anchorPersistence
        self.worldMappingEnabled = worldMappingEnabled
        self.planeDetection = planeDetection
        self.meshGeneration = meshGeneration
        self.lightEstimation = lightEstimation
    }
}

public enum SpatialTrackingQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case ultra = "ultra"
    
    public var description: String {
        switch self {
        case .low: return "Low quality tracking for basic experiences"
        case .medium: return "Medium quality tracking for standard experiences"
        case .high: return "High quality tracking for premium experiences"
        case .ultra: return "Ultra quality tracking for professional experiences"
        }
    }
}

public enum SpatialTrackingState: String, CaseIterable {
    case unavailable = "unavailable"
    case initializing = "initializing"
    case tracking = "tracking"
    case limited = "limited"
    case lost = "lost"
    case error = "error"
}

public enum PlaneDetectionMode: String, CaseIterable {
    case none = "none"
    case horizontal = "horizontal"
    case vertical = "vertical"
    case all = "all"
}

public struct SpatialAnchor: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let transform: simd_float4x4
    public let createdAt: Date
    public let isPersistent: Bool
    public let metadata: [String: String]
    
    public init(
        id: UUID = UUID(),
        name: String,
        transform: simd_float4x4,
        createdAt: Date = Date(),
        isPersistent: Bool = true,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.transform = transform
        self.createdAt = createdAt
        self.isPersistent = isPersistent
        self.metadata = metadata
    }
}

// MARK: - Immersive Space Types

public struct ImmersiveSpaceConfiguration {
    public let defaultStyle: ImmersiveSpaceStyle
    public let supportedStyles: [ImmersiveSpaceStyle]
    public let transitionDuration: TimeInterval
    public let enableGradualTransitions: Bool
    public let ambientLighting: AmbientLightingMode
    
    public static let `default` = ImmersiveSpaceConfiguration(
        defaultStyle: .mixed,
        supportedStyles: [.mixed, .progressive, .full],
        transitionDuration: 0.5,
        enableGradualTransitions: true,
        ambientLighting: .adaptive
    )
    
    public init(
        defaultStyle: ImmersiveSpaceStyle = .mixed,
        supportedStyles: [ImmersiveSpaceStyle] = [.mixed, .progressive, .full],
        transitionDuration: TimeInterval = 0.5,
        enableGradualTransitions: Bool = true,
        ambientLighting: AmbientLightingMode = .adaptive
    ) {
        self.defaultStyle = defaultStyle
        self.supportedStyles = supportedStyles
        self.transitionDuration = transitionDuration
        self.enableGradualTransitions = enableGradualTransitions
        self.ambientLighting = ambientLighting
    }
}

public enum ImmersiveSpaceStyle: String, CaseIterable {
    case mixed = "mixed"
    case progressive = "progressive"
    case full = "full"
    
    public var description: String {
        switch self {
        case .mixed: return "Mixed reality with passthrough"
        case .progressive: return "Progressive immersion"
        case .full: return "Full immersive experience"
        }
    }
}

public enum AmbientLightingMode: String, CaseIterable {
    case none = "none"
    case minimal = "minimal"
    case adaptive = "adaptive"
    case natural = "natural"
}

public enum ImmersiveSpaceIdentifier: String, CaseIterable {
    case main = "main"
    case gallery = "gallery"
    case workspace = "workspace"
    case entertainment = "entertainment"
    case education = "education"
    case social = "social"
    case custom = "custom"
}

public struct ImmersiveContent {
    public let entities: [Entity]
    public let environments: [EnvironmentResource]
    public let lighting: LightingConfiguration
    public let audio: SpatialAudioConfiguration?
    
    public init(
        entities: [Entity] = [],
        environments: [EnvironmentResource] = [],
        lighting: LightingConfiguration = .default,
        audio: SpatialAudioConfiguration? = nil
    ) {
        self.entities = entities
        self.environments = environments
        self.lighting = lighting
        self.audio = audio
    }
}

// MARK: - RealityKit Types

public struct RealityKitConfiguration {
    public let renderingQuality: RenderingQuality
    public let enablePhysics: Bool
    public let enableOcclusion: Bool
    public let enableShadows: Bool
    public let enableReflections: Bool
    public let maxEntitiesPerScene: Int
    public let optimizationMode: OptimizationMode
    
    public static let `default` = RealityKitConfiguration(
        renderingQuality: .high,
        enablePhysics: true,
        enableOcclusion: true,
        enableShadows: true,
        enableReflections: true,
        maxEntitiesPerScene: 1000,
        optimizationMode: .balanced
    )
    
    public init(
        renderingQuality: RenderingQuality = .high,
        enablePhysics: Bool = true,
        enableOcclusion: Bool = true,
        enableShadows: Bool = true,
        enableReflections: Bool = true,
        maxEntitiesPerScene: Int = 1000,
        optimizationMode: OptimizationMode = .balanced
    ) {
        self.renderingQuality = renderingQuality
        self.enablePhysics = enablePhysics
        self.enableOcclusion = enableOcclusion
        self.enableShadows = enableShadows
        self.enableReflections = enableReflections
        self.maxEntitiesPerScene = maxEntitiesPerScene
        self.optimizationMode = optimizationMode
    }
}

public enum RenderingQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case ultra = "ultra"
}

public enum OptimizationMode: String, CaseIterable {
    case performance = "performance"
    case balanced = "balanced"
    case quality = "quality"
}

public enum RealityKitScene: String, CaseIterable {
    case main = "main"
    case ui = "ui"
    case background = "background"
    case overlay = "overlay"
}

public enum ModelFormat: String, CaseIterable {
    case usd = "usd"
    case usda = "usda"
    case usdc = "usdc"
    case reality = "reality"
    case obj = "obj"
    case dae = "dae"
}

public struct LightingConfiguration {
    public let ambientIntensity: Float
    public let directionalIntensity: Float
    public let enableImageBasedLighting: Bool
    public let enableDynamicLighting: Bool
    public let lightTemperature: Float
    
    public static let `default` = LightingConfiguration(
        ambientIntensity: 0.3,
        directionalIntensity: 1.0,
        enableImageBasedLighting: true,
        enableDynamicLighting: true,
        lightTemperature: 6500.0
    )
    
    public init(
        ambientIntensity: Float = 0.3,
        directionalIntensity: Float = 1.0,
        enableImageBasedLighting: Bool = true,
        enableDynamicLighting: Bool = true,
        lightTemperature: Float = 6500.0
    ) {
        self.ambientIntensity = ambientIntensity
        self.directionalIntensity = directionalIntensity
        self.enableImageBasedLighting = enableImageBasedLighting
        self.enableDynamicLighting = enableDynamicLighting
        self.lightTemperature = lightTemperature
    }
}

// MARK: - Window Management Types

public struct WindowConfiguration {
    public let id: String
    public let content: AnyView
    public let size: CGSize?
    public let position: WindowPosition
    public let style: WindowStyle
    public let level: WindowLevel
    public let allowsMultipleInstances: Bool
    
    public static let `default` = WindowConfiguration(
        id: "default",
        content: AnyView(EmptyView()),
        size: nil,
        position: .automatic,
        style: .plain,
        level: .normal,
        allowsMultipleInstances: false
    )
    
    public init(
        id: String,
        content: AnyView,
        size: CGSize? = nil,
        position: WindowPosition = .automatic,
        style: WindowStyle = .plain,
        level: WindowLevel = .normal,
        allowsMultipleInstances: Bool = false
    ) {
        self.id = id
        self.content = content
        self.size = size
        self.position = position
        self.style = style
        self.level = level
        self.allowsMultipleInstances = allowsMultipleInstances
    }
}

public enum WindowPosition: Equatable {
    case automatic
    case center
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    case custom(CGPoint)
}

public enum WindowStyle: String, CaseIterable {
    case plain = "plain"
    case bordered = "bordered"
    case floating = "floating"
    case panel = "panel"
}

public enum WindowLevel: Int, CaseIterable {
    case background = 0
    case normal = 1
    case floating = 2
    case overlay = 3
    case modal = 4
}

// MARK: - Gesture Types

public struct GestureConfiguration {
    public let enableHandTracking: Bool
    public let enableEyeTracking: Bool
    public let enableVoiceCommands: Bool
    public let gestureRecognitionThreshold: Float
    public let trackingFrequency: Double
    public let enableHapticFeedback: Bool
    
    public static let `default` = GestureConfiguration(
        enableHandTracking: true,
        enableEyeTracking: true,
        enableVoiceCommands: true,
        gestureRecognitionThreshold: 0.8,
        trackingFrequency: 60.0,
        enableHapticFeedback: true
    )
    
    public init(
        enableHandTracking: Bool = true,
        enableEyeTracking: Bool = true,
        enableVoiceCommands: Bool = true,
        gestureRecognitionThreshold: Float = 0.8,
        trackingFrequency: Double = 60.0,
        enableHapticFeedback: Bool = true
    ) {
        self.enableHandTracking = enableHandTracking
        self.enableEyeTracking = enableEyeTracking
        self.enableVoiceCommands = enableVoiceCommands
        self.gestureRecognitionThreshold = gestureRecognitionThreshold
        self.trackingFrequency = trackingFrequency
        self.enableHapticFeedback = enableHapticFeedback
    }
}

public struct GestureEvent {
    public let type: GestureType
    public let position: SIMD3<Float>
    public let confidence: Float
    public let timestamp: Date
    public let metadata: [String: Any]
    
    public init(
        type: GestureType,
        position: SIMD3<Float>,
        confidence: Float,
        timestamp: Date = Date(),
        metadata: [String: Any] = [:]
    ) {
        self.type = type
        self.position = position
        self.confidence = confidence
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

public enum GestureType: String, CaseIterable {
    case tap = "tap"
    case pinch = "pinch"
    case grab = "grab"
    case point = "point"
    case swipe = "swipe"
    case rotate = "rotate"
    case scale = "scale"
    case longPress = "long_press"
    case eyeGaze = "eye_gaze"
    case voiceCommand = "voice_command"
}

// MARK: - AR Types

public struct ARConfiguration {
    public let sessionConfiguration: ARSessionConfiguration
    public let enablePlaneDetection: Bool
    public let enableImageTracking: Bool
    public let enableObjectDetection: Bool
    public let enableFaceTracking: Bool
    public let enableBodyTracking: Bool
    public let worldAlignment: WorldAlignment
    
    public static let `default` = ARConfiguration(
        sessionConfiguration: .worldTracking,
        enablePlaneDetection: true,
        enableImageTracking: true,
        enableObjectDetection: true,
        enableFaceTracking: false,
        enableBodyTracking: false,
        worldAlignment: .gravity
    )
    
    public init(
        sessionConfiguration: ARSessionConfiguration = .worldTracking,
        enablePlaneDetection: Bool = true,
        enableImageTracking: Bool = true,
        enableObjectDetection: Bool = true,
        enableFaceTracking: Bool = false,
        enableBodyTracking: Bool = false,
        worldAlignment: WorldAlignment = .gravity
    ) {
        self.sessionConfiguration = sessionConfiguration
        self.enablePlaneDetection = enablePlaneDetection
        self.enableImageTracking = enableImageTracking
        self.enableObjectDetection = enableObjectDetection
        self.enableFaceTracking = enableFaceTracking
        self.enableBodyTracking = enableBodyTracking
        self.worldAlignment = worldAlignment
    }
}

public enum ARSessionConfiguration: String, CaseIterable {
    case worldTracking = "world_tracking"
    case faceTracking = "face_tracking"
    case imageTracking = "image_tracking"
    case objectDetection = "object_detection"
    case bodyTracking = "body_tracking"
}

public enum WorldAlignment: String, CaseIterable {
    case gravity = "gravity"
    case gravityAndHeading = "gravity_and_heading"
    case camera = "camera"
}

// MARK: - Audio Types

public struct SpatialAudioConfiguration {
    public let enableSpatialAudio: Bool
    public let reverbEnvironment: ReverbEnvironment
    public let distanceModel: AudioDistanceModel
    public let maxDistance: Float
    public let rolloffFactor: Float
    
    public static let `default` = SpatialAudioConfiguration(
        enableSpatialAudio: true,
        reverbEnvironment: .room,
        distanceModel: .inverse,
        maxDistance: 100.0,
        rolloffFactor: 1.0
    )
    
    public init(
        enableSpatialAudio: Bool = true,
        reverbEnvironment: ReverbEnvironment = .room,
        distanceModel: AudioDistanceModel = .inverse,
        maxDistance: Float = 100.0,
        rolloffFactor: Float = 1.0
    ) {
        self.enableSpatialAudio = enableSpatialAudio
        self.reverbEnvironment = reverbEnvironment
        self.distanceModel = distanceModel
        self.maxDistance = maxDistance
        self.rolloffFactor = rolloffFactor
    }
}

public enum ReverbEnvironment: String, CaseIterable {
    case none = "none"
    case room = "room"
    case hall = "hall"
    case cathedral = "cathedral"
    case outdoor = "outdoor"
}

public enum AudioDistanceModel: String, CaseIterable {
    case linear = "linear"
    case inverse = "inverse"
    case exponential = "exponential"
}

// MARK: - Capabilities and Features

public struct VisionOSCapabilities: OptionSet, Codable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let spatialComputing = VisionOSCapabilities(rawValue: 1 << 0)
    public static let immersiveSpaces = VisionOSCapabilities(rawValue: 1 << 1)
    public static let handTracking = VisionOSCapabilities(rawValue: 1 << 2)
    public static let eyeTracking = VisionOSCapabilities(rawValue: 1 << 3)
    public static let worldAnchors = VisionOSCapabilities(rawValue: 1 << 4)
    public static let sceneReconstruction = VisionOSCapabilities(rawValue: 1 << 5)
    public static let planeDetection = VisionOSCapabilities(rawValue: 1 << 6)
    public static let imageTracking = VisionOSCapabilities(rawValue: 1 << 7)
    public static let objectDetection = VisionOSCapabilities(rawValue: 1 << 8)
    public static let spatialAudio = VisionOSCapabilities(rawValue: 1 << 9)
    public static let hapticFeedback = VisionOSCapabilities(rawValue: 1 << 10)
    public static let voiceCommands = VisionOSCapabilities(rawValue: 1 << 11)
    
    public var description: String {
        var features: [String] = []
        if contains(.spatialComputing) { features.append("Spatial Computing") }
        if contains(.immersiveSpaces) { features.append("Immersive Spaces") }
        if contains(.handTracking) { features.append("Hand Tracking") }
        if contains(.eyeTracking) { features.append("Eye Tracking") }
        if contains(.worldAnchors) { features.append("World Anchors") }
        if contains(.sceneReconstruction) { features.append("Scene Reconstruction") }
        if contains(.planeDetection) { features.append("Plane Detection") }
        if contains(.imageTracking) { features.append("Image Tracking") }
        if contains(.objectDetection) { features.append("Object Detection") }
        if contains(.spatialAudio) { features.append("Spatial Audio") }
        if contains(.hapticFeedback) { features.append("Haptic Feedback") }
        if contains(.voiceCommands) { features.append("Voice Commands") }
        return features.joined(separator: ", ")
    }
}

// MARK: - Performance Monitoring

public struct VisionOSPerformanceMetrics {
    public let frameRate: Double
    public let latency: Double
    public let thermalState: ProcessInfo.ThermalState
    public let batteryLevel: Double
    public let memoryUsage: Double
    public let timestamp: Date
    
    public init(
        frameRate: Double,
        latency: Double,
        thermalState: ProcessInfo.ThermalState,
        batteryLevel: Double,
        memoryUsage: Double,
        timestamp: Date = Date()
    ) {
        self.frameRate = frameRate
        self.latency = latency
        self.thermalState = thermalState
        self.batteryLevel = batteryLevel
        self.memoryUsage = memoryUsage
        self.timestamp = timestamp
    }
    
    public var performanceScore: Double {
        let frameRateScore = min(frameRate / 90.0, 1.0) * 0.4
        let latencyScore = max(0.0, 1.0 - (latency / 20.0)) * 0.3
        let thermalScore = thermalState == .nominal ? 1.0 : 0.5
        let memoryScore = max(0.0, 1.0 - memoryUsage) * 0.3
        
        return frameRateScore + latencyScore + (thermalScore * 0.2) + memoryScore
    }
}

// MARK: - AI Integration Types

public struct SpatialAnalysisResult {
    public let roomDimensions: SIMD3<Float>
    public let detectedObjects: [DetectedObject]
    public let surfaceTypes: [SurfaceType]
    public let lightingConditions: LightingCondition
    public let recommendedPlacements: [PlacementRecommendation]
    public let confidence: Float
    
    public init(
        roomDimensions: SIMD3<Float>,
        detectedObjects: [DetectedObject],
        surfaceTypes: [SurfaceType],
        lightingConditions: LightingCondition,
        recommendedPlacements: [PlacementRecommendation],
        confidence: Float
    ) {
        self.roomDimensions = roomDimensions
        self.detectedObjects = detectedObjects
        self.surfaceTypes = surfaceTypes
        self.lightingConditions = lightingConditions
        self.recommendedPlacements = recommendedPlacements
        self.confidence = confidence
    }
}

public struct DetectedObject {
    public let id: UUID
    public let type: ObjectType
    public let position: SIMD3<Float>
    public let bounds: BoundingBox
    public let confidence: Float
    
    public init(id: UUID = UUID(), type: ObjectType, position: SIMD3<Float>, bounds: BoundingBox, confidence: Float) {
        self.id = id
        self.type = type
        self.position = position
        self.bounds = bounds
        self.confidence = confidence
    }
}

public enum ObjectType: String, CaseIterable {
    case furniture = "furniture"
    case electronics = "electronics"
    case artwork = "artwork"
    case plants = "plants"
    case person = "person"
    case vehicle = "vehicle"
    case unknown = "unknown"
}

public struct BoundingBox {
    public let center: SIMD3<Float>
    public let extent: SIMD3<Float>
    
    public init(center: SIMD3<Float>, extent: SIMD3<Float>) {
        self.center = center
        self.extent = extent
    }
}

public enum SurfaceType: String, CaseIterable {
    case floor = "floor"
    case wall = "wall"
    case ceiling = "ceiling"
    case table = "table"
    case unknown = "unknown"
}

public enum LightingCondition: String, CaseIterable {
    case dark = "dark"
    case dim = "dim"
    case moderate = "moderate"
    case bright = "bright"
    case veryBright = "very_bright"
}

public struct PlacementRecommendation {
    public let position: SIMD3<Float>
    public let orientation: SIMD4<Float>
    public let type: ContentType
    public let suitabilityScore: Float
    public let reason: String
    
    public init(position: SIMD3<Float>, orientation: SIMD4<Float>, type: ContentType, suitabilityScore: Float, reason: String) {
        self.position = position
        self.orientation = orientation
        self.type = type
        self.suitabilityScore = suitabilityScore
        self.reason = reason
    }
}

public enum ContentType: String, CaseIterable {
    case informational = "informational"
    case interactive = "interactive"
    case decorative = "decorative"
    case functional = "functional"
}

public struct ContextualContent {
    public let id: String
    public let position: SIMD3<Float>
    public let type: ContentType
    public let content: String
    public let relevanceScore: Float
    public let adaptiveProperties: AdaptiveProperties
    
    public init(id: String, position: SIMD3<Float>, type: ContentType, content: String, relevanceScore: Float, adaptiveProperties: AdaptiveProperties) {
        self.id = id
        self.position = position
        self.type = type
        self.content = content
        self.relevanceScore = relevanceScore
        self.adaptiveProperties = adaptiveProperties
    }
}

public struct AdaptiveProperties {
    public let scaleFactor: Float
    public let opacityLevel: Float
    public let interactionDistance: Float
    
    public init(scaleFactor: Float, opacityLevel: Float, interactionDistance: Float) {
        self.scaleFactor = scaleFactor
        self.opacityLevel = opacityLevel
        self.interactionDistance = interactionDistance
    }
}

// MARK: - Environment Resource

public protocol EnvironmentResource {
    var name: String { get }
    var resourceURL: URL? { get }
    var previewImage: URL? { get }
}

// MARK: - Extensions

extension ProcessInfo.ThermalState: CaseIterable {
    public static let allCases: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]
}

extension SIMD3: Codable where Scalar: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Scalar.self)
        let y = try container.decode(Scalar.self)
        let z = try container.decode(Scalar.self)
        self.init(x, y, z)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(z)
    }
}

extension SIMD4: Codable where Scalar: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Scalar.self)
        let y = try container.decode(Scalar.self)
        let z = try container.decode(Scalar.self)
        let w = try container.decode(Scalar.self)
        self.init(x, y, z, w)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(z)
        try container.encode(w)
    }
}
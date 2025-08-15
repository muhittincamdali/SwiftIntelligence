import ARKit
import RealityKit
import SwiftUI
import Combine
import os.log

/// Advanced spatial computing manager for visionOS
/// Handles world tracking, anchor management, and spatial understanding
public class SpatialComputingManager: NSObject, ObservableObject {
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "SpatialComputing")
    private var configuration: SpatialComputingConfiguration
    
    // AR Session management
    private var arSession: ARSession?
    private var worldTrackingConfig: ARWorldTrackingConfiguration?
    
    // Anchor management
    private var spatialAnchors: [UUID: SpatialAnchor] = [:]
    private var anchorEntities: [UUID: AnchoredEntity] = [:]
    
    // World mapping
    private var currentWorldMap: ARWorldMap?
    private var worldMappingStatus: ARFrame.WorldMappingStatus = .notAvailable
    
    // Tracking state
    @Published public private(set) var trackingState: ARCamera.TrackingState = .notAvailable
    @Published public private(set) var sessionState: ARSessionState = .initializing
    
    // Plane detection
    private var detectedPlanes: [UUID: ARPlaneAnchor] = [:]
    
    // Scene understanding
    private var sceneReconstruction: ARSceneReconstruction?
    
    public init(configuration: SpatialComputingConfiguration) {
        self.configuration = configuration
        super.init()
        logger.info("SpatialComputingManager initialized")
    }
    
    // MARK: - Initialization
    
    public func initialize() async throws {
        logger.info("Initializing spatial computing system")
        
        // Check AR availability
        guard ARWorldTrackingConfiguration.isSupported else {
            throw SpatialComputingError.unsupportedDevice("ARKit World Tracking not supported")
        }
        
        // Initialize AR session
        arSession = ARSession()
        arSession?.delegate = self
        
        // Setup world tracking configuration
        worldTrackingConfig = ARWorldTrackingConfiguration()
        
        if let config = worldTrackingConfig {
            // Configure plane detection
            switch configuration.planeDetection {
            case .none:
                config.planeDetection = []
            case .horizontal:
                config.planeDetection = .horizontal
            case .vertical:
                config.planeDetection = .vertical
            case .all:
                config.planeDetection = [.horizontal, .vertical]
            }
            
            // Configure scene reconstruction
            if configuration.meshGeneration && ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                config.sceneReconstruction = .mesh
            }
            
            // Configure light estimation
            if configuration.lightEstimation {
                config.environmentTexturing = .automatic
            }
            
            // Configure world mapping
            if configuration.worldMappingEnabled {
                config.isCollaborationEnabled = true
            }
        }
        
        logger.info("Spatial computing system initialized")
    }
    
    // MARK: - Session Management
    
    public func startTracking(stateHandler: @escaping (SpatialTrackingState) async -> Void) async throws {
        guard let session = arSession, let config = worldTrackingConfig else {
            throw SpatialComputingError.initializationFailed("AR session not initialized")
        }
        
        logger.info("Starting spatial tracking")
        
        // Store state handler for updates
        Task {
            while arSession != nil {
                let state = mapTrackingState(trackingState)
                await stateHandler(state)
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            }
        }
        
        // Start AR session
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        logger.info("Spatial tracking started")
    }
    
    public func stopTracking() async {
        logger.info("Stopping spatial tracking")
        arSession?.pause()
        logger.info("Spatial tracking stopped")
    }
    
    public func resetTracking() async throws {
        guard let session = arSession, let config = worldTrackingConfig else {
            throw SpatialComputingError.sessionNotAvailable("AR session not available")
        }
        
        logger.info("Resetting spatial tracking")
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // Clear existing data
        spatialAnchors.removeAll()
        anchorEntities.removeAll()
        detectedPlanes.removeAll()
        currentWorldMap = nil
        
        logger.info("Spatial tracking reset complete")
    }
    
    // MARK: - Anchor Management
    
    public func createAnchor(at position: SIMD3<Float>, name: String) async throws -> SpatialAnchor {
        guard let session = arSession else {
            throw SpatialComputingError.sessionNotAvailable("AR session not available")
        }
        
        logger.info("Creating spatial anchor '\(name)' at position \(position)")
        
        // Create transform matrix from position
        var transform = simd_float4x4(1.0)
        transform.columns.3 = SIMD4<Float>(position.x, position.y, position.z, 1.0)
        
        // Create AR anchor
        let arAnchor = ARAnchor(name: name, transform: transform)
        
        // Add to AR session
        session.add(anchor: arAnchor)
        
        // Create spatial anchor wrapper
        let spatialAnchor = SpatialAnchor(
            id: arAnchor.identifier,
            name: name,
            transform: transform,
            isPersistent: configuration.anchorPersistence
        )
        
        // Store anchor
        spatialAnchors[spatialAnchor.id] = spatialAnchor
        
        // Create entity for anchor if needed
        if configuration.anchorPersistence {
            await createAnchorEntity(for: spatialAnchor)
        }
        
        logger.info("Spatial anchor '\(name)' created successfully")
        return spatialAnchor
    }
    
    public func removeAnchor(_ anchor: SpatialAnchor) async throws {
        guard let session = arSession else {
            throw SpatialComputingError.sessionNotAvailable("AR session not available")
        }
        
        logger.info("Removing spatial anchor '\(anchor.name)'")
        
        // Find AR anchor
        if let arAnchor = session.currentFrame?.anchors.first(where: { $0.identifier == anchor.id }) {
            session.remove(anchor: arAnchor)
        }
        
        // Remove from storage
        spatialAnchors.removeValue(forKey: anchor.id)
        anchorEntities.removeValue(forKey: anchor.id)
        
        logger.info("Spatial anchor '\(anchor.name)' removed")
    }
    
    public func getAllAnchors() async -> [SpatialAnchor] {
        return Array(spatialAnchors.values)
    }
    
    public func getAnchor(withName name: String) async -> SpatialAnchor? {
        return spatialAnchors.values.first { $0.name == name }
    }
    
    public func getAnchorCount() async -> Int {
        return spatialAnchors.count
    }
    
    // MARK: - World Mapping
    
    public func saveWorldMap() async throws -> Data {
        guard let session = arSession else {
            throw SpatialComputingError.sessionNotAvailable("AR session not available")
        }
        
        logger.info("Saving world map")
        
        return try await withCheckedThrowingContinuation { continuation in
            session.getCurrentWorldMap { [weak self] worldMap, error in
                if let error = error {
                    self?.logger.error("Failed to save world map: \(error.localizedDescription)")
                    continuation.resume(throwing: SpatialComputingError.worldMappingFailed("Failed to get current world map: \(error.localizedDescription)"))
                    return
                }
                
                guard let worldMap = worldMap else {
                    continuation.resume(throwing: SpatialComputingError.worldMappingFailed("World map is nil"))
                    return
                }
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                    self?.currentWorldMap = worldMap
                    self?.logger.info("World map saved successfully")
                    continuation.resume(returning: data)
                } catch {
                    self?.logger.error("Failed to archive world map: \(error.localizedDescription)")
                    continuation.resume(throwing: SpatialComputingError.worldMappingFailed("Failed to archive world map: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    public func loadWorldMap(from data: Data) async throws {
        guard let session = arSession, let config = worldTrackingConfig else {
            throw SpatialComputingError.sessionNotAvailable("AR session not available")
        }
        
        logger.info("Loading world map")
        
        do {
            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
                throw SpatialComputingError.worldMappingFailed("Failed to unarchive world map")
            }
            
            config.initialWorldMap = worldMap
            session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
            currentWorldMap = worldMap
            logger.info("World map loaded successfully")
            
        } catch {
            logger.error("Failed to load world map: \(error.localizedDescription)")
            throw SpatialComputingError.worldMappingFailed("Failed to load world map: \(error.localizedDescription)")
        }
    }
    
    public func getWorldMappingStatus() async -> ARFrame.WorldMappingStatus {
        return worldMappingStatus
    }
    
    // MARK: - Plane Detection
    
    public func getDetectedPlanes() async -> [PlaneInfo] {
        return detectedPlanes.values.map { anchor in
            PlaneInfo(
                id: anchor.identifier,
                type: anchor.alignment == .horizontal ? .horizontal : .vertical,
                center: anchor.center,
                extent: anchor.extent,
                transform: anchor.transform,
                geometry: anchor.geometry
            )
        }
    }
    
    public func getPlane(at position: SIMD3<Float>, tolerance: Float = 0.1) async -> PlaneInfo? {
        let targetPosition = position
        
        for anchor in detectedPlanes.values {
            let planeCenter = SIMD3<Float>(anchor.center.x, anchor.center.y, anchor.center.z)
            let distance = simd_distance(targetPosition, planeCenter)
            
            if distance <= tolerance {
                return PlaneInfo(
                    id: anchor.identifier,
                    type: anchor.alignment == .horizontal ? .horizontal : .vertical,
                    center: anchor.center,
                    extent: anchor.extent,
                    transform: anchor.transform,
                    geometry: anchor.geometry
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Scene Understanding
    
    public func getSceneMesh() async throws -> ARMeshGeometry? {
        guard let session = arSession else {
            throw SpatialComputingError.sessionNotAvailable("AR session not available")
        }
        
        guard configuration.meshGeneration else {
            throw SpatialComputingError.featureNotEnabled("Scene mesh generation not enabled")
        }
        
        // Get current frame's mesh anchors
        if let frame = session.currentFrame {
            let meshAnchors = frame.anchors.compactMap { $0 as? ARMeshAnchor }
            
            if let firstMesh = meshAnchors.first {
                return firstMesh.geometry
            }
        }
        
        return nil
    }
    
    public func analyzeScene() async throws -> SceneAnalysis {
        logger.info("Analyzing spatial scene")
        
        let planes = await getDetectedPlanes()
        let anchors = await getAllAnchors()
        let sceneMesh = try? await getSceneMesh()
        
        // Calculate room bounds
        let roomBounds = calculateRoomBounds(from: planes)
        
        // Detect surfaces
        let surfaces = detectSurfaces(from: planes)
        
        // Analyze lighting
        let lightingInfo = await analyzeLighting()
        
        let analysis = SceneAnalysis(
            roomBounds: roomBounds,
            detectedSurfaces: surfaces,
            anchorCount: anchors.count,
            planeCount: planes.count,
            hasMeshData: sceneMesh != nil,
            lightingInfo: lightingInfo,
            confidence: calculateSceneConfidence(planes: planes.count, anchors: anchors.count)
        )
        
        logger.info("Scene analysis complete: \(planes.count) planes, \(anchors.count) anchors")
        return analysis
    }
    
    // MARK: - Utility Methods
    
    public func updateConfiguration(_ config: SpatialComputingConfiguration) async {
        configuration = config
        logger.info("Spatial computing configuration updated")
        
        // Update AR configuration if session is running
        if let session = arSession, let arConfig = worldTrackingConfig {
            // Update plane detection
            switch config.planeDetection {
            case .none:
                arConfig.planeDetection = []
            case .horizontal:
                arConfig.planeDetection = .horizontal
            case .vertical:
                arConfig.planeDetection = .vertical
            case .all:
                arConfig.planeDetection = [.horizontal, .vertical]
            }
            
            // Update scene reconstruction
            if config.meshGeneration && ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                arConfig.sceneReconstruction = .mesh
            } else {
                arConfig.sceneReconstruction = []
            }
            
            session.run(arConfig)
        }
    }
    
    // MARK: - Private Implementation
    
    private func createAnchorEntity(for anchor: SpatialAnchor) async {
        // Create a simple entity to represent the anchor
        let entity = AnchoredEntity(anchor: ARAnchor(transform: anchor.transform))
        anchorEntities[anchor.id] = entity
    }
    
    private func mapTrackingState(_ arState: ARCamera.TrackingState) -> SpatialTrackingState {
        switch arState {
        case .notAvailable:
            return .unavailable
        case .limited(.initializing):
            return .initializing
        case .limited:
            return .limited
        case .normal:
            return .tracking
        }
    }
    
    private func calculateRoomBounds(from planes: [PlaneInfo]) -> SIMD3<Float> {
        guard !planes.isEmpty else {
            return SIMD3<Float>(4.0, 3.0, 4.0) // Default room size
        }
        
        var minPoint = SIMD3<Float>(Float.greatestFiniteMagnitude)
        var maxPoint = SIMD3<Float>(-Float.greatestFiniteMagnitude)
        
        for plane in planes {
            let center = SIMD3<Float>(plane.center.x, plane.center.y, plane.center.z)
            let extent = SIMD3<Float>(plane.extent.x, 0, plane.extent.z)
            
            minPoint = simd_min(minPoint, center - extent)
            maxPoint = simd_max(maxPoint, center + extent)
        }
        
        return maxPoint - minPoint
    }
    
    private func detectSurfaces(from planes: [PlaneInfo]) -> [SurfaceInfo] {
        return planes.map { plane in
            let surfaceType: SurfaceType
            switch plane.type {
            case .horizontal:
                // Determine if floor, table, or ceiling based on height
                if plane.center.y < -0.5 {
                    surfaceType = .floor
                } else if plane.center.y > 2.0 {
                    surfaceType = .ceiling
                } else {
                    surfaceType = .table
                }
            case .vertical:
                surfaceType = .wall
            }
            
            return SurfaceInfo(
                id: plane.id,
                type: surfaceType,
                area: plane.extent.x * plane.extent.z,
                position: plane.center,
                normal: calculateSurfaceNormal(from: plane.transform)
            )
        }
    }
    
    private func calculateSurfaceNormal(from transform: simd_float4x4) -> SIMD3<Float> {
        // Extract the up vector (Y axis) from the transform matrix
        return SIMD3<Float>(transform.columns.1.x, transform.columns.1.y, transform.columns.1.z)
    }
    
    private func analyzeLighting() async -> LightingInfo {
        guard let session = arSession,
              let frame = session.currentFrame,
              let lightEstimate = frame.lightEstimate else {
            return LightingInfo(intensity: 0.5, temperature: 6500.0, direction: SIMD3<Float>(0, -1, 0))
        }
        
        return LightingInfo(
            intensity: Float(lightEstimate.ambientIntensity / 1000.0), // Convert to 0-1 range
            temperature: 6500.0, // Default temperature
            direction: SIMD3<Float>(0, -1, 0) // Default downward direction
        )
    }
    
    private func calculateSceneConfidence(planes: Int, anchors: Int) -> Float {
        let planeScore = min(Float(planes) / 5.0, 1.0) * 0.6 // Up to 5 planes for full score
        let anchorScore = min(Float(anchors) / 3.0, 1.0) * 0.4 // Up to 3 anchors for full score
        return planeScore + anchorScore
    }
}

// MARK: - ARSessionDelegate

extension SpatialComputingManager: ARSessionDelegate {
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Update tracking state
        DispatchQueue.main.async { [weak self] in
            self?.trackingState = frame.camera.trackingState
        }
        
        // Update world mapping status
        worldMappingStatus = frame.worldMappingStatus
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                detectedPlanes[anchor.identifier] = planeAnchor
                logger.debug("Plane detected: \(anchor.identifier)")
            }
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                detectedPlanes[anchor.identifier] = planeAnchor
            }
        }
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            detectedPlanes.removeValue(forKey: anchor.identifier)
            spatialAnchors.removeValue(forKey: anchor.identifier)
            anchorEntities.removeValue(forKey: anchor.identifier)
        }
    }
    
    public func session(_ session: ARSession, wasInterrupted: Bool) {
        logger.warning("AR session was interrupted")
        DispatchQueue.main.async { [weak self] in
            self?.sessionState = .interrupted
        }
    }
    
    public func sessionWasResumed(_ session: ARSession) {
        logger.info("AR session was resumed")
        DispatchQueue.main.async { [weak self] in
            self?.sessionState = .running
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        logger.error("AR session failed with error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.sessionState = .failed
        }
    }
}

// MARK: - Supporting Types

public struct PlaneInfo {
    public let id: UUID
    public let type: PlaneType
    public let center: SIMD3<Float>
    public let extent: SIMD3<Float>
    public let transform: simd_float4x4
    public let geometry: ARPlaneGeometry
    
    public init(id: UUID, type: PlaneType, center: SIMD3<Float>, extent: SIMD3<Float>, transform: simd_float4x4, geometry: ARPlaneGeometry) {
        self.id = id
        self.type = type
        self.center = center
        self.extent = extent
        self.transform = transform
        self.geometry = geometry
    }
}

public enum PlaneType {
    case horizontal
    case vertical
}

public struct SurfaceInfo {
    public let id: UUID
    public let type: SurfaceType
    public let area: Float
    public let position: SIMD3<Float>
    public let normal: SIMD3<Float>
    
    public init(id: UUID, type: SurfaceType, area: Float, position: SIMD3<Float>, normal: SIMD3<Float>) {
        self.id = id
        self.type = type
        self.area = area
        self.position = position
        self.normal = normal
    }
}

public struct LightingInfo {
    public let intensity: Float
    public let temperature: Float
    public let direction: SIMD3<Float>
    
    public init(intensity: Float, temperature: Float, direction: SIMD3<Float>) {
        self.intensity = intensity
        self.temperature = temperature
        self.direction = direction
    }
}

public struct SceneAnalysis {
    public let roomBounds: SIMD3<Float>
    public let detectedSurfaces: [SurfaceInfo]
    public let anchorCount: Int
    public let planeCount: Int
    public let hasMeshData: Bool
    public let lightingInfo: LightingInfo
    public let confidence: Float
    
    public init(roomBounds: SIMD3<Float>, detectedSurfaces: [SurfaceInfo], anchorCount: Int, planeCount: Int, hasMeshData: Bool, lightingInfo: LightingInfo, confidence: Float) {
        self.roomBounds = roomBounds
        self.detectedSurfaces = detectedSurfaces
        self.anchorCount = anchorCount
        self.planeCount = planeCount
        self.hasMeshData = hasMeshData
        self.lightingInfo = lightingInfo
        self.confidence = confidence
    }
}

public enum ARSessionState {
    case initializing
    case running
    case interrupted
    case failed
}

// MARK: - Error Types

public enum SpatialComputingError: LocalizedError {
    case unsupportedDevice(String)
    case initializationFailed(String)
    case sessionNotAvailable(String)
    case worldMappingFailed(String)
    case anchorCreationFailed(String)
    case featureNotEnabled(String)
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedDevice(let reason):
            return "Unsupported device: \(reason)"
        case .initializationFailed(let reason):
            return "Initialization failed: \(reason)"
        case .sessionNotAvailable(let reason):
            return "AR session not available: \(reason)"
        case .worldMappingFailed(let reason):
            return "World mapping failed: \(reason)"
        case .anchorCreationFailed(let reason):
            return "Anchor creation failed: \(reason)"
        case .featureNotEnabled(let reason):
            return "Feature not enabled: \(reason)"
        }
    }
}
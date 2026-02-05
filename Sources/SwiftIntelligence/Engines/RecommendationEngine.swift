// RecommendationEngine.swift
// SwiftIntelligence - AI-Powered Recommendations
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import Accelerate

/// Privacy-first, on-device recommendation engine
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public actor RecommendationEngine {
    
    // MARK: - Singleton
    
    public static let shared = RecommendationEngine()
    
    // MARK: - Properties
    
    private var userProfiles: [String: UserProfile] = [:]
    private var itemVectors: [String: [Float]] = [:]
    private var interactionMatrix: [String: [String: Float]] = [:]
    private let vectorDimension = 128
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - User Profile Management
    
    /// Record user interaction with an item
    public func recordInteraction(
        userId: String,
        itemId: String,
        type: InteractionType,
        value: Float = 1.0
    ) async {
        // Update interaction matrix
        if interactionMatrix[userId] == nil {
            interactionMatrix[userId] = [:]
        }
        
        let currentValue = interactionMatrix[userId]?[itemId] ?? 0
        let weight = type.weight
        interactionMatrix[userId]?[itemId] = currentValue + (value * weight)
        
        // Update user profile
        await updateUserProfile(userId: userId, itemId: itemId, weight: weight * value)
    }
    
    /// Update item features
    public func updateItem(
        itemId: String,
        features: [String: Float]
    ) async {
        // Convert features to vector
        var vector = [Float](repeating: 0, count: vectorDimension)
        
        for (i, (_, value)) in features.enumerated() {
            if i < vectorDimension {
                vector[i] = value
            }
        }
        
        // Normalize vector
        let norm = sqrt(vector.reduce(0) { $0 + $1 * $1 })
        if norm > 0 {
            vector = vector.map { $0 / norm }
        }
        
        itemVectors[itemId] = vector
    }
    
    // MARK: - Recommendations
    
    /// Get personalized recommendations for a user
    public func recommend(
        for userId: String,
        context: [String: Any]? = nil,
        limit: Int = 10
    ) async throws -> [Recommendation] {
        
        guard let userProfile = userProfiles[userId] else {
            // Cold start: return popular items
            return await getPopularItems(limit: limit)
        }
        
        var scores: [(String, Float, String)] = []
        
        for (itemId, itemVector) in itemVectors {
            // Skip items user already interacted with heavily
            let existingScore = interactionMatrix[userId]?[itemId] ?? 0
            if existingScore > 5.0 { continue }
            
            // Calculate recommendation score
            let similarity = cosineSimilarity(userProfile.preferenceVector, itemVector)
            
            // Apply context boost if available
            var contextBoost: Float = 1.0
            if let context = context {
                contextBoost = calculateContextBoost(itemId: itemId, context: context)
            }
            
            let finalScore = similarity * contextBoost
            let reason = generateReason(similarity: similarity, contextBoost: contextBoost)
            
            scores.append((itemId, finalScore, reason))
        }
        
        // Sort by score and return top items
        let recommendations = scores
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { Recommendation(itemId: $0.0, score: $0.1, reason: $0.2) }
        
        return Array(recommendations)
    }
    
    /// Find similar items
    public func findSimilar(
        to itemId: String,
        count: Int = 10
    ) async throws -> [SimilarItem] {
        
        guard let targetVector = itemVectors[itemId] else {
            throw RecommendationError.itemNotFound
        }
        
        var similarities: [(String, Float)] = []
        
        for (otherId, otherVector) in itemVectors {
            if otherId == itemId { continue }
            
            let similarity = cosineSimilarity(targetVector, otherVector)
            similarities.append((otherId, similarity))
        }
        
        let similar = similarities
            .sorted { $0.1 > $1.1 }
            .prefix(count)
            .map { SimilarItem(itemId: $0.0, similarity: $0.1) }
        
        return Array(similar)
    }
    
    // MARK: - Collaborative Filtering
    
    /// Get recommendations using collaborative filtering
    public func collaborativeRecommend(
        for userId: String,
        limit: Int = 10
    ) async throws -> [Recommendation] {
        
        guard let userInteractions = interactionMatrix[userId] else {
            return await getPopularItems(limit: limit)
        }
        
        // Find similar users
        var userSimilarities: [(String, Float)] = []
        
        for (otherUserId, otherInteractions) in interactionMatrix {
            if otherUserId == userId { continue }
            
            let similarity = calculateUserSimilarity(userInteractions, otherInteractions)
            if similarity > 0.1 {
                userSimilarities.append((otherUserId, similarity))
            }
        }
        
        // Get items from similar users
        var itemScores: [String: Float] = [:]
        
        for (similarUserId, userSimilarity) in userSimilarities.prefix(10) {
            guard let similarInteractions = interactionMatrix[similarUserId] else { continue }
            
            for (itemId, itemScore) in similarInteractions {
                // Skip items user already knows
                if userInteractions[itemId] != nil { continue }
                
                let contributedScore = itemScore * userSimilarity
                itemScores[itemId, default: 0] += contributedScore
            }
        }
        
        let recommendations = itemScores
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { Recommendation(itemId: $0.key, score: $0.value, reason: "Users like you enjoyed this") }
        
        return Array(recommendations)
    }
    
    // MARK: - Reset
    
    public func reset() async {
        userProfiles.removeAll()
        itemVectors.removeAll()
        interactionMatrix.removeAll()
    }
    
    // MARK: - Private Helpers
    
    private func updateUserProfile(userId: String, itemId: String, weight: Float) async {
        guard let itemVector = itemVectors[itemId] else { return }
        
        if userProfiles[userId] == nil {
            userProfiles[userId] = UserProfile(
                userId: userId,
                preferenceVector: [Float](repeating: 0, count: vectorDimension)
            )
        }
        
        // Update preference vector with exponential moving average
        let alpha: Float = 0.1
        for i in 0..<vectorDimension {
            let currentPref = userProfiles[userId]?.preferenceVector[i] ?? 0
            let newPref = currentPref + alpha * weight * (itemVector[i] - currentPref)
            userProfiles[userId]?.preferenceVector[i] = newPref
        }
    }
    
    private func getPopularItems(limit: Int) async -> [Recommendation] {
        var itemPopularity: [String: Float] = [:]
        
        for (_, interactions) in interactionMatrix {
            for (itemId, score) in interactions {
                itemPopularity[itemId, default: 0] += score
            }
        }
        
        return itemPopularity
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { Recommendation(itemId: $0.key, score: $0.value, reason: "Popular choice") }
    }
    
    private func cosineSimilarity(_ v1: [Float], _ v2: [Float]) -> Float {
        guard v1.count == v2.count else { return 0 }
        
        var dotProduct: Float = 0
        var norm1: Float = 0
        var norm2: Float = 0
        
        vDSP_dotpr(v1, 1, v2, 1, &dotProduct, vDSP_Length(v1.count))
        vDSP_svesq(v1, 1, &norm1, vDSP_Length(v1.count))
        vDSP_svesq(v2, 1, &norm2, vDSP_Length(v2.count))
        
        let denominator = sqrt(norm1) * sqrt(norm2)
        return denominator > 0 ? dotProduct / denominator : 0
    }
    
    private func calculateUserSimilarity(
        _ user1: [String: Float],
        _ user2: [String: Float]
    ) -> Float {
        let commonItems = Set(user1.keys).intersection(Set(user2.keys))
        guard !commonItems.isEmpty else { return 0 }
        
        var dotProduct: Float = 0
        var norm1: Float = 0
        var norm2: Float = 0
        
        for item in commonItems {
            let score1 = user1[item] ?? 0
            let score2 = user2[item] ?? 0
            
            dotProduct += score1 * score2
            norm1 += score1 * score1
            norm2 += score2 * score2
        }
        
        let denominator = sqrt(norm1) * sqrt(norm2)
        return denominator > 0 ? dotProduct / denominator : 0
    }
    
    private func calculateContextBoost(itemId: String, context: [String: Any]) -> Float {
        // Apply context-based boosting
        var boost: Float = 1.0
        
        if let timeOfDay = context["timeOfDay"] as? String {
            // Boost certain items based on time
            boost *= timeOfDay == "morning" ? 1.1 : 1.0
        }
        
        if let location = context["location"] as? String {
            // Location-based boost
            boost *= location == "home" ? 1.05 : 1.0
        }
        
        return boost
    }
    
    private func generateReason(similarity: Float, contextBoost: Float) -> String? {
        if similarity > 0.8 {
            return "Highly relevant to your interests"
        } else if similarity > 0.5 {
            return "Based on your preferences"
        } else if contextBoost > 1.0 {
            return "Perfect for right now"
        }
        return nil
    }
}

// MARK: - Supporting Types

/// User interaction type
public enum InteractionType: String, Sendable {
    case view
    case like
    case purchase
    case share
    case bookmark
    case rating
    
    var weight: Float {
        switch self {
        case .view: return 0.1
        case .like: return 0.5
        case .purchase: return 1.0
        case .share: return 0.7
        case .bookmark: return 0.6
        case .rating: return 0.8
        }
    }
}

/// User profile for recommendations
private struct UserProfile {
    let userId: String
    var preferenceVector: [Float]
}

/// Recommendation errors
public enum RecommendationError: LocalizedError {
    case userNotFound
    case itemNotFound
    case insufficientData
    
    public var errorDescription: String? {
        switch self {
        case .userNotFound: return "User not found"
        case .itemNotFound: return "Item not found"
        case .insufficientData: return "Insufficient data for recommendations"
        }
    }
}

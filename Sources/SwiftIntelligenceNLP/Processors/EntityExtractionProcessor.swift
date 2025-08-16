import Foundation
import NaturalLanguage
import CoreML
import Vision
import os.log

// Cache wrapper for NSCache
private class CacheWrapper {
    let entities: [NamedEntity]
    init(entities: [NamedEntity]) {
        self.entities = entities
    }
}

/// Advanced named entity recognition and extraction processor
public class EntityExtractionProcessor {
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "EntityExtraction")
    private let processingQueue = DispatchQueue(label: "entity.extraction", qos: .userInitiated)
    
    // MARK: - NL Framework Components
    private let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
    
    // MARK: - Custom Models
    private var customEntityModels: [String: VNCoreMLModel] = [:]
    private var turkishEntityModel: VNCoreMLModel?
    
    // MARK: - Entity Pattern Matchers
    private var patternMatchers: [EntityPatternMatcher] = []
    
    // MARK: - Cache
    private let cache = NSCache<NSString, CacheWrapper>()
    
    // MARK: - Initialization
    public init() async throws {
        cache.countLimit = 300
        cache.totalCostLimit = 5_000_000 // 5MB
        
        try await initializeModels()
        setupPatternMatchers()
    }
    
    // MARK: - Model Initialization
    private func initializeModels() async throws {
        logger.info("Initializing entity extraction models...")
        
        // Load Turkish entity recognition model
        await loadTurkishEntityModel()
        
        // Load custom entity models
        await loadCustomEntityModels()
        
        logger.info("Entity extraction models initialized successfully")
    }
    
    private func loadTurkishEntityModel() async {
        do {
            let bundle = Bundle(for: type(of: self))
            if let modelURL = bundle.url(forResource: "TurkishEntityModel", withExtension: "mlmodel") {
                let mlModel = try MLModel(contentsOf: modelURL)
                turkishEntityModel = try VNCoreMLModel(for: mlModel)
                logger.info("Turkish entity model loaded successfully")
            }
        } catch {
            logger.error("Failed to load Turkish entity model: \(error.localizedDescription)")
        }
    }
    
    private func loadCustomEntityModels() async {
        let modelNames = ["PersonModel", "LocationModel", "OrganizationModel", "ProductModel"]
        
        for modelName in modelNames {
            do {
                let bundle = Bundle(for: type(of: self))
                if let modelURL = bundle.url(forResource: modelName, withExtension: "mlmodel") {
                    let mlModel = try MLModel(contentsOf: modelURL)
                    let visionModel = try VNCoreMLModel(for: mlModel)
                    customEntityModels[modelName] = visionModel
                    logger.info("Loaded custom entity model: \(modelName)")
                }
            } catch {
                logger.warning("Failed to load custom entity model \(modelName): \(error.localizedDescription)")
            }
        }
    }
    
    private func setupPatternMatchers() {
        patternMatchers = [
            EmailPatternMatcher(),
            PhonePatternMatcher(),
            URLPatternMatcher(),
            DatePatternMatcher(),
            MoneyPatternMatcher(),
            IPAddressPatternMatcher(),
            CreditCardPatternMatcher(),
            IBANPatternMatcher(),
            TurkishIDPatternMatcher(),
            PostalCodePatternMatcher()
        ]
        
        logger.info("Pattern matchers initialized")
    }
    
    // MARK: - Entity Extraction
    
    /// Extract named entities from text
    public func extractEntities(
        from text: String,
        language: NLLanguage? = nil,
        options: EntityExtractionOptions = .default
    ) async throws -> EntityExtractionResult {
        
        let startTime = Date()
        
        // Validate input
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NLPError.invalidText
        }
        
        // Check cache
        let cacheKey = NSString(string: "\(text.hashValue)_\(language?.rawValue ?? "auto")_\(options.hashValue)")
        if let cachedWrapper = cache.object(forKey: cacheKey) {
            return EntityExtractionResult(
                entities: cachedWrapper.entities,
                entityCount: cachedWrapper.entities.count,
                processingTime: 0
            )
        }
        
        // Detect language if not provided
        let detectedLanguage = language ?? detectLanguage(text: text)
        
        // Extract entities using multiple approaches
        let entities = try await performEntityExtraction(
            text: text,
            language: detectedLanguage,
            options: options
        )
        
        // Merge and deduplicate entities
        let mergedEntities = mergeAndDeduplicateEntities(entities)
        
        // Filter by confidence threshold
        let filteredEntities = filterEntitiesByConfidence(mergedEntities, threshold: options.confidenceThreshold)
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = calculateAverageConfidence(filteredEntities)
        
        let result = EntityExtractionResult(
            entities: filteredEntities,
            entityCount: filteredEntities.count,
            processingTime: processingTime
        )
        
        // Cache result
        cache.setObject(CacheWrapper(entities: filteredEntities), forKey: cacheKey, cost: text.count)
        
        return result
    }
    
    /// Batch entity extraction for multiple texts
    public func batchExtractEntities(
        from texts: [String],
        language: NLLanguage? = nil,
        options: EntityExtractionOptions = .default
    ) async throws -> [EntityExtractionResult] {
        
        return try await withThrowingTaskGroup(of: EntityExtractionResult.self) { group in
            for text in texts {
                group.addTask {
                    try await self.extractEntities(from: text, language: language, options: options)
                }
            }
            
            var results: [EntityExtractionResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    /// Extract specific entity types
    public func extractEntitiesOfType(
        _ entityType: NamedEntity.EntityType,
        from text: String,
        language: NLLanguage? = nil
    ) async throws -> [NamedEntity] {
        
        let options = EntityExtractionOptions(
            includeBuiltInEntities: true,
            includePatternEntities: true,
            includeCustomEntities: true,
            confidenceThreshold: 0.5,
            entityTypes: [entityType]
        )
        
        let result = try await extractEntities(from: text, language: language, options: options)
        return result.entities.filter { $0.type == entityType }
    }
    
    // MARK: - Private Extraction Methods
    
    private func performEntityExtraction(
        text: String,
        language: NLLanguage,
        options: EntityExtractionOptions
    ) async throws -> [NamedEntity] {
        
        var allEntities: [NamedEntity] = []
        
        // Built-in NL framework entities
        if options.includeBuiltInEntities {
            let builtInEntities = extractBuiltInEntities(text: text, language: language)
            allEntities.append(contentsOf: builtInEntities)
        }
        
        // Pattern-based entities
        if options.includePatternEntities {
            let patternEntities = extractPatternBasedEntities(text: text, language: language)
            allEntities.append(contentsOf: patternEntities)
        }
        
        // Custom model entities
        if options.includeCustomEntities {
            let customEntities = try await extractCustomModelEntities(text: text, language: language)
            allEntities.append(contentsOf: customEntities)
        }
        
        // Turkish-specific entities
        if language == .turkish && turkishEntityModel != nil {
            let turkishEntities = try await extractTurkishEntities(text: text)
            allEntities.append(contentsOf: turkishEntities)
        }
        
        return allEntities
    }
    
    private func extractBuiltInEntities(text: String, language: NLLanguage) -> [NamedEntity] {
        tagger.string = text
        tagger.setLanguage(language, range: text.startIndex..<text.endIndex)
        
        var entities: [NamedEntity] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let entityText = String(text[tokenRange])
                let entityType = mapNLTagToEntityType(tag)
                let confidence = calculateBuiltInEntityConfidence(tag, text: entityText, language: language)
                
                let entity = NamedEntity(
                    text: entityText,
                    type: entityType,
                    range: tokenRange,
                    confidence: confidence
                )
                
                entities.append(entity)
            }
            return true
        }
        
        return entities
    }
    
    private func extractPatternBasedEntities(text: String, language: NLLanguage) -> [NamedEntity] {
        var entities: [NamedEntity] = []
        
        for matcher in patternMatchers {
            let matchedEntities = matcher.findEntities(in: text, language: language)
            entities.append(contentsOf: matchedEntities)
        }
        
        return entities
    }
    
    private func extractCustomModelEntities(text: String, language: NLLanguage) async throws -> [NamedEntity] {
        var entities: [NamedEntity] = []
        
        // Use custom models for enhanced entity recognition
        for (modelName, model) in customEntityModels {
            do {
                let modelEntities = try await extractEntitiesWithCustomModel(
                    text: text,
                    model: model,
                    modelName: modelName,
                    language: language
                )
                entities.append(contentsOf: modelEntities)
            } catch {
                logger.warning("Custom model \(modelName) failed: \(error.localizedDescription)")
            }
        }
        
        return entities
    }
    
    private func extractTurkishEntities(text: String) async throws -> [NamedEntity] {
        guard let model = turkishEntityModel else {
            return []
        }
        
        return try await extractEntitiesWithCustomModel(
            text: text,
            model: model,
            modelName: "Turkish",
            language: .turkish
        )
    }
    
    private func extractEntitiesWithCustomModel(
        text: String,
        model: VNCoreMLModel,
        modelName: String,
        language: NLLanguage
    ) async throws -> [NamedEntity] {
        
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                // In a real implementation, this would process the text through the ML model
                // For now, return empty array as placeholder
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - Entity Processing
    
    private func mergeAndDeduplicateEntities(_ entities: [NamedEntity]) -> [NamedEntity] {
        var mergedEntities: [NamedEntity] = []
        var processedRanges: [String] = []
        
        let sortedEntities = entities.sorted { entity1, entity2 in
            // Sort by position first, then by confidence
            if entity1.range != entity2.range {
                return entity1.range < entity2.range
            }
            return entity1.confidence > entity2.confidence
        }
        
        for entity in sortedEntities {
            // Check for overlapping entities
            if !hasOverlappingRange(entity.range, in: processedRanges) {
                mergedEntities.append(entity)
                processedRanges.append(entity.range)
            }
        }
        
        return mergedEntities
    }
    
    private func filterEntitiesByConfidence(_ entities: [NamedEntity], threshold: Float) -> [NamedEntity] {
        return entities.filter { $0.confidence >= threshold }
    }
    
    private func hasOverlappingRange(_ range: String, in processedRanges: [String]) -> Bool {
        // Simplified overlap detection
        // In a real implementation, this would properly parse and compare ranges
        return processedRanges.contains(range)
    }
    
    // MARK: - Helper Methods
    
    private func detectLanguage(text: String) -> NLLanguage {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage ?? .english
    }
    
    private func mapNLTagToEntityType(_ tag: NLTag) -> NamedEntity.EntityType {
        switch tag.rawValue {
        case "PersonalName": return .person
        case "PlaceName": return .location
        case "OrganizationName": return .organization
        default: return .other
        }
    }
    
    private func calculateBuiltInEntityConfidence(_ tag: NLTag, text: String, language: NLLanguage) -> Float {
        // Confidence heuristics based on entity type and text characteristics
        switch tag.rawValue {
        case "PersonalName":
            return text.capitalizationStyle == .titleCase ? 0.9 : 0.7
        case "PlaceName":
            return text.capitalizationStyle == .titleCase ? 0.85 : 0.65
        case "OrganizationName":
            return text.contains(" ") ? 0.8 : 0.6
        default:
            return 0.5
        }
    }
    
    private func calculateAverageConfidence(_ entities: [NamedEntity]) -> Float {
        guard !entities.isEmpty else { return 0.0 }
        let totalConfidence = entities.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Float(entities.count)
    }
}

// MARK: - Supporting Types

public struct EntityExtractionOptions: Hashable, Codable {
    public let includeBuiltInEntities: Bool
    public let includePatternEntities: Bool
    public let includeCustomEntities: Bool
    public let confidenceThreshold: Float
    public let entityTypes: Set<NamedEntity.EntityType>?
    
    public init(
        includeBuiltInEntities: Bool = true,
        includePatternEntities: Bool = true,
        includeCustomEntities: Bool = false,
        confidenceThreshold: Float = 0.6,
        entityTypes: Set<NamedEntity.EntityType>? = nil
    ) {
        self.includeBuiltInEntities = includeBuiltInEntities
        self.includePatternEntities = includePatternEntities
        self.includeCustomEntities = includeCustomEntities
        self.confidenceThreshold = confidenceThreshold
        self.entityTypes = entityTypes
    }
    
    public static let `default` = EntityExtractionOptions()
    
    public static let comprehensive = EntityExtractionOptions(
        includeBuiltInEntities: true,
        includePatternEntities: true,
        includeCustomEntities: true,
        confidenceThreshold: 0.5
    )
    
    public static let patternOnly = EntityExtractionOptions(
        includeBuiltInEntities: false,
        includePatternEntities: true,
        includeCustomEntities: false,
        confidenceThreshold: 0.8
    )
}

// EntityExtractionResult is now defined in NLPTypes.swift

// MARK: - Pattern Matchers

protocol EntityPatternMatcher {
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity]
}

struct EmailPatternMatcher: EntityPatternMatcher {
    private let emailRegex = try! NSRegularExpression(pattern: #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = emailRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let emailText = String(text[range])
            
            return NamedEntity(
                text: emailText,
                type: .email,
                range: range,
                confidence: 0.95
            )
        }
    }
}

struct PhonePatternMatcher: EntityPatternMatcher {
    private let phoneRegex = try! NSRegularExpression(pattern: #"(\+\d{1,3}\s?)?(\(?\d{3}\)?[\s.-]?)?\d{3}[\s.-]?\d{4}"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = phoneRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let phoneText = String(text[range])
            
            return NamedEntity(
                text: phoneText,
                type: .phoneNumber,
                range: range,
                confidence: 0.9
            )
        }
    }
}

struct URLPatternMatcher: EntityPatternMatcher {
    private let urlRegex = try! NSRegularExpression(pattern: #"https?://(?:[-\w.])+(?::[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:#(?:[\w.])*)?)?|www\.(?:[-\w.])+(?::[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:#(?:[\w.])*)?)?"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = urlRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let urlText = String(text[range])
            
            return NamedEntity(
                text: urlText,
                type: .url,
                range: range,
                confidence: 0.92
            )
        }
    }
}

struct DatePatternMatcher: EntityPatternMatcher {
    private let dateRegex = try! NSRegularExpression(pattern: #"\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b|\b\d{4}[/-]\d{1,2}[/-]\d{1,2}\b"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = dateRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let dateText = String(text[range])
            
            return NamedEntity(
                text: dateText,
                type: .date,
                range: range,
                confidence: 0.8
            )
        }
    }
}

struct MoneyPatternMatcher: EntityPatternMatcher {
    private let moneyRegex = try! NSRegularExpression(pattern: #"[$€£¥₺]\s?\d+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?\s?(?:USD|EUR|GBP|TRY|TL)"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = moneyRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let moneyText = String(text[range])
            
            return NamedEntity(
                text: moneyText,
                type: .money,
                range: range,
                confidence: 0.88
            )
        }
    }
}

struct IPAddressPatternMatcher: EntityPatternMatcher {
    private let ipRegex = try! NSRegularExpression(pattern: #"\b(?:\d{1,3}\.){3}\d{1,3}\b"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = ipRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let ipText = String(text[range])
            
            return NamedEntity(
                text: ipText,
                type: .other,
                range: range,
                confidence: 0.95
            )
        }
    }
}

struct CreditCardPatternMatcher: EntityPatternMatcher {
    private let ccRegex = try! NSRegularExpression(pattern: #"\b(?:\d{4}[\s-]?){3}\d{4}\b"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = ccRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let ccText = String(text[range])
            
            return NamedEntity(
                text: ccText,
                type: .other,
                range: range,
                confidence: 0.85
            )
        }
    }
}

struct IBANPatternMatcher: EntityPatternMatcher {
    private let ibanRegex = try! NSRegularExpression(pattern: #"\b[A-Z]{2}\d{2}[A-Z0-9]{4}\d{7}([A-Z0-9]?){0,16}\b"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let matches = ibanRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let ibanText = String(text[range])
            
            return NamedEntity(
                text: ibanText,
                type: .other,
                range: range,
                confidence: 0.9
            )
        }
    }
}

struct TurkishIDPatternMatcher: EntityPatternMatcher {
    private let turkishIDRegex = try! NSRegularExpression(pattern: #"\b\d{11}\b"#)
    
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        // Only apply for Turkish language
        guard language == .turkish else { return [] }
        
        let matches = turkishIDRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let idText = String(text[range])
            
            // Validate Turkish ID number algorithm
            if isValidTurkishID(idText) {
                return NamedEntity(
                    text: idText,
                    type: .other,
                    range: range,
                    confidence: 0.95
                )
            }
            
            return nil
        }
    }
    
    private func isValidTurkishID(_ id: String) -> Bool {
        guard id.count == 11, let _ = Int(id) else { return false }
        
        let digits = id.compactMap { Int(String($0)) }
        guard digits.count == 11 && digits[0] != 0 else { return false }
        
        // Turkish ID validation algorithm
        let oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
        let evenSum = digits[1] + digits[3] + digits[5] + digits[7]
        let checkDigit1 = (oddSum * 7 - evenSum) % 10
        let checkDigit2 = (oddSum + evenSum + digits[9]) % 10
        
        return digits[9] == checkDigit1 && digits[10] == checkDigit2
    }
}

struct PostalCodePatternMatcher: EntityPatternMatcher {
    func findEntities(in text: String, language: NLLanguage) -> [NamedEntity] {
        let pattern: String
        
        switch language {
        case .turkish:
            pattern = #"\b\d{5}\b"# // Turkish postal codes
        case .english:
            pattern = #"\b\d{5}(?:-\d{4})?\b"# // US ZIP codes
        default:
            pattern = #"\b\d{4,6}\b"# // Generic postal codes
        }
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let postalText = String(text[range])
            
            return NamedEntity(
                text: postalText,
                type: .other,
                range: range,
                confidence: 0.7
            )
        }
    }
}

// MARK: - Extensions

extension String {
    var capitalizationStyle: CapitalizationStyle {
        if self == self.uppercased() {
            return .allCaps
        } else if self == self.lowercased() {
            return .lowercase
        } else if self == self.capitalized {
            return .titleCase
        } else {
            return .mixed
        }
    }
}

enum CapitalizationStyle {
    case allCaps
    case lowercase
    case titleCase
    case mixed
}
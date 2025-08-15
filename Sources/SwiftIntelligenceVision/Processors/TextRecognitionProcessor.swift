import Foundation
import CoreML
import Vision
import UIKit
import NaturalLanguage
import os.log

/// Advanced text recognition processor with multi-language support and document analysis
public class TextRecognitionProcessor {
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "TextRecognition")
    private let processingQueue = DispatchQueue(label: "text.recognition", qos: .userInitiated)
    
    // MARK: - Language Support
    private let supportedLanguages = [
        "en-US": "English (US)",
        "en-GB": "English (UK)",
        "tr-TR": "Turkish",
        "de-DE": "German",
        "fr-FR": "French",
        "es-ES": "Spanish",
        "it-IT": "Italian",
        "pt-PT": "Portuguese",
        "ru-RU": "Russian",
        "zh-Hans": "Chinese (Simplified)",
        "zh-Hant": "Chinese (Traditional)",
        "ja-JP": "Japanese",
        "ko-KR": "Korean",
        "ar-SA": "Arabic"
    ]
    
    // MARK: - Models
    private var textRecognitionRequest: VNRecognizeTextRequest?
    private var documentAnalysisRequest: VNDetectDocumentSegmentationRequest?
    private var languageDetector: NLLanguageRecognizer?
    
    // MARK: - Initialization
    public init() async throws {
        try await initializeModels()
        setupLanguageDetector()
    }
    
    // MARK: - Model Initialization
    private func initializeModels() async throws {
        // Initialize text recognition
        textRecognitionRequest = VNRecognizeTextRequest()
        textRecognitionRequest?.recognitionLevel = .accurate
        textRecognitionRequest?.usesLanguageCorrection = true
        textRecognitionRequest?.automaticallyDetectsLanguage = true
        
        // Initialize document segmentation
        documentAnalysisRequest = VNDetectDocumentSegmentationRequest()
        
        logger.info("Text recognition models initialized")
    }
    
    private func setupLanguageDetector() {
        languageDetector = NLLanguageRecognizer()
    }
    
    // MARK: - Text Recognition
    
    /// Recognize text in an image
    public func recognize(
        in image: UIImage,
        options: TextRecognitionOptions
    ) async throws -> TextRecognitionResult {
        
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw TextRecognitionError.invalidImage
        }
        
        // Configure recognition request
        try configureRecognitionRequest(with: options)
        
        // Perform text recognition
        let textBlocks = try await performTextRecognition(cgImage: cgImage)
        
        // Combine all recognized text
        let recognizedText = textBlocks.map { $0.text }.joined(separator: "\n")
        
        // Detect languages
        let detectedLanguages = detectLanguages(in: recognizedText)
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = calculateOverallConfidence(textBlocks)
        
        return TextRecognitionResult(
            processingTime: processingTime,
            confidence: confidence,
            recognizedText: recognizedText,
            textBlocks: textBlocks,
            detectedLanguages: detectedLanguages,
            imageSize: image.size
        )
    }
    
    /// Analyze document structure and extract text
    public func analyzeDocument(
        _ image: UIImage,
        options: DocumentAnalysisOptions
    ) async throws -> DocumentAnalysisResult {
        
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw TextRecognitionError.invalidImage
        }
        
        // Perform document segmentation if enabled
        var documentLayout: DocumentLayout
        if options.enableLayoutAnalysis {
            documentLayout = try await analyzeDocumentLayout(cgImage: cgImage)
        } else {
            documentLayout = DocumentLayout(paragraphs: [], headings: [], readingOrder: [])
        }
        
        // Detect tables if enabled
        var tables: [DocumentTable] = []
        if options.enableTableDetection {
            tables = try await detectTables(cgImage: cgImage)
        }
        
        // Detect form fields if enabled
        var formFields: [FormField] = []
        if options.enableFormFieldDetection {
            formFields = try await detectFormFields(cgImage: cgImage)
        }
        
        // Extract all text
        let textOptions = TextRecognitionOptions(
            recognitionLevel: .accurate,
            enableAutomaticTextNormalization: true
        )
        let textResult = try await recognize(in: image, options: textOptions)
        
        // Format output based on requested format
        let documentText = formatDocumentText(
            textResult: textResult,
            layout: documentLayout,
            format: options.outputFormat
        )
        
        let processingTime = Date().timeIntervalSince(startTime)
        let confidence = textResult.confidence
        
        return DocumentAnalysisResult(
            processingTime: processingTime,
            confidence: confidence,
            documentText: documentText,
            layout: documentLayout,
            tables: tables,
            formFields: formFields
        )
    }
    
    /// Batch process multiple images
    public func batchRecognize(
        _ images: [UIImage],
        options: TextRecognitionOptions
    ) async throws -> [TextRecognitionResult] {
        
        return try await withThrowingTaskGroup(of: TextRecognitionResult.self) { group in
            for image in images {
                group.addTask {
                    try await self.recognize(in: image, options: options)
                }
            }
            
            var results: [TextRecognitionResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    // MARK: - Specialized Recognition
    
    /// Extract text from Turkish documents with optimized settings
    public func recognizeTurkishText(
        in image: UIImage,
        enableDiacritics: Bool = true
    ) async throws -> TextRecognitionResult {
        
        let options = TextRecognitionOptions(
            recognitionLanguages: ["tr-TR"],
            recognitionLevel: .accurate,
            enableAutomaticTextNormalization: enableDiacritics,
            customWordsToRecognize: turkishCommonWords
        )
        
        return try await recognize(in: image, options: options)
    }
    
    /// Extract text from business cards
    public func recognizeBusinessCard(
        _ image: UIImage
    ) async throws -> BusinessCardResult {
        
        let options = TextRecognitionOptions(
            recognitionLevel: .accurate,
            enableAutomaticTextNormalization: true,
            minimumTextHeight: 0.01 // Allow smaller text for business cards
        )
        
        let textResult = try await recognize(in: image, options: options)
        
        // Parse business card information
        let businessCardInfo = parseBusinessCardInfo(from: textResult.textBlocks)
        
        return BusinessCardResult(
            recognizedText: textResult.recognizedText,
            textBlocks: textResult.textBlocks,
            extractedInfo: businessCardInfo,
            confidence: textResult.confidence
        )
    }
    
    /// Extract text from license plates
    public func recognizeLicensePlate(
        _ image: UIImage,
        country: String = "US"
    ) async throws -> LicensePlateResult {
        
        let options = TextRecognitionOptions(
            recognitionLevel: .fast, // License plates are usually clear
            enableAutomaticTextNormalization: false, // Keep original format
            minimumTextHeight: 0.02
        )
        
        let textResult = try await recognize(in: image, options: options)
        
        // Filter and validate license plate patterns
        let licensePlateText = filterLicensePlateText(
            textBlocks: textResult.textBlocks,
            country: country
        )
        
        return LicensePlateResult(
            licensePlateNumber: licensePlateText,
            confidence: textResult.confidence,
            country: country,
            allDetectedText: textResult.recognizedText
        )
    }
    
    // MARK: - Private Methods
    
    private func configureRecognitionRequest(with options: TextRecognitionOptions) throws {
        guard let request = textRecognitionRequest else {
            throw TextRecognitionError.modelNotInitialized
        }
        
        // Set recognition languages
        request.recognitionLanguages = options.recognitionLanguages
        
        // Set recognition level
        request.recognitionLevel = options.recognitionLevel
        
        // Set text correction
        request.usesLanguageCorrection = options.enableAutomaticTextNormalization
        
        // Set custom vocabulary
        if !options.customWordsToRecognize.isEmpty {
            request.customWords = options.customWordsToRecognize
        }
        
        // Set minimum text height
        request.minimumTextHeight = options.minimumTextHeight
    }
    
    private func performTextRecognition(cgImage: CGImage) async throws -> [TextBlock] {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    guard let request = self.textRecognitionRequest else {
                        continuation.resume(throwing: TextRecognitionError.modelNotInitialized)
                        return
                    }
                    
                    request.results = nil
                    
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                    
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    let textBlocks = self.processTextObservations(
                        observations,
                        imageSize: CGSize(width: cgImage.width, height: cgImage.height)
                    )
                    
                    continuation.resume(returning: textBlocks)
                    
                } catch {
                    continuation.resume(throwing: TextRecognitionError.recognitionFailed(error))
                }
            }
        }
    }
    
    private func processTextObservations(
        _ observations: [VNRecognizedTextObservation],
        imageSize: CGSize
    ) -> [TextBlock] {
        
        return observations.compactMap { observation in
            guard let topCandidate = observation.topCandidates(1).first else { return nil }
            
            let boundingBox = convertBoundingBox(observation.boundingBox, imageSize: imageSize)
            
            // Extract character-level bounding boxes if available
            let characterBoxes = extractCharacterBoxes(
                from: observation,
                text: topCandidate.string,
                imageSize: imageSize
            )
            
            // Detect language for this text block
            let detectedLanguage = detectLanguage(for: topCandidate.string)
            
            return TextBlock(
                text: topCandidate.string,
                boundingBox: boundingBox,
                confidence: topCandidate.confidence,
                language: detectedLanguage,
                characterBoxes: characterBoxes
            )
        }
    }
    
    private func extractCharacterBoxes(
        from observation: VNRecognizedTextObservation,
        text: String,
        imageSize: CGSize
    ) -> [CharacterBox] {
        
        var characterBoxes: [CharacterBox] = []
        
        // Try to get character-level bounding boxes
        do {
            let range = text.startIndex..<text.endIndex
            let boundingBoxes = try observation.boundingBox(for: range)
            
            if let boxes = boundingBoxes {
                for (index, character) in text.enumerated() {
                    if index < boxes.count {
                        let charBoundingBox = convertBoundingBox(boxes[index], imageSize: imageSize)
                        let characterBox = CharacterBox(
                            character: String(character),
                            boundingBox: charBoundingBox,
                            confidence: observation.confidence
                        )
                        characterBoxes.append(characterBox)
                    }
                }
            }
        } catch {
            // Character-level boxes not available, skip
        }
        
        return characterBoxes
    }
    
    private func analyzeDocumentLayout(cgImage: CGImage) async throws -> DocumentLayout {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    guard let request = self.documentAnalysisRequest else {
                        continuation.resume(throwing: TextRecognitionError.modelNotInitialized)
                        return
                    }
                    
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                    
                    // Process document segmentation results
                    let layout = self.processDocumentSegmentation(
                        request.results,
                        imageSize: CGSize(width: cgImage.width, height: cgImage.height)
                    )
                    
                    continuation.resume(returning: layout)
                    
                } catch {
                    continuation.resume(throwing: TextRecognitionError.layoutAnalysisFailed(error))
                }
            }
        }
    }
    
    private func processDocumentSegmentation(
        _ results: [Any]?,
        imageSize: CGSize
    ) -> DocumentLayout {
        
        // Simplified document layout analysis
        // In a real implementation, this would be more sophisticated
        
        var paragraphs: [DocumentLayout.DocumentParagraph] = []
        var headings: [DocumentLayout.DocumentHeading] = []
        var readingOrder: [String] = []
        
        if let observations = results as? [VNDocumentSegmentationObservation] {
            for (index, observation) in observations.enumerated() {
                let id = "segment_\(index)"
                let boundingBox = convertBoundingBox(observation.boundingBox, imageSize: imageSize)
                
                // Classify as heading or paragraph based on position and size
                if boundingBox.width > imageSize.width * 0.8 && boundingBox.height < 50 {
                    // Likely a heading
                    let heading = DocumentLayout.DocumentHeading(
                        id: id,
                        text: "Heading \(headings.count + 1)",
                        level: 1,
                        boundingBox: boundingBox,
                        confidence: observation.confidence
                    )
                    headings.append(heading)
                } else {
                    // Likely a paragraph
                    let paragraph = DocumentLayout.DocumentParagraph(
                        id: id,
                        text: "Paragraph \(paragraphs.count + 1)",
                        boundingBox: boundingBox,
                        confidence: observation.confidence
                    )
                    paragraphs.append(paragraph)
                }
                
                readingOrder.append(id)
            }
        }
        
        return DocumentLayout(
            paragraphs: paragraphs,
            headings: headings,
            readingOrder: readingOrder
        )
    }
    
    private func detectTables(cgImage: CGImage) async throws -> [DocumentTable] {
        // Simplified table detection
        // In a real implementation, this would use specialized table detection models
        return []
    }
    
    private func detectFormFields(cgImage: CGImage) async throws -> [FormField] {
        // Simplified form field detection
        // In a real implementation, this would use specialized form analysis models
        return []
    }
    
    private func formatDocumentText(
        textResult: TextRecognitionResult,
        layout: DocumentLayout,
        format: DocumentOutputFormat
    ) -> String {
        
        switch format {
        case .plainText:
            return textResult.recognizedText
            
        case .structured:
            var structured = ""
            
            // Add headings
            for heading in layout.headings {
                structured += String(repeating: "#", count: heading.level)
                structured += " \(heading.text)\n\n"
            }
            
            // Add paragraphs
            for paragraph in layout.paragraphs {
                structured += "\(paragraph.text)\n\n"
            }
            
            return structured
            
        case .markdown:
            var markdown = ""
            
            // Convert to markdown format
            for heading in layout.headings {
                markdown += String(repeating: "#", count: heading.level)
                markdown += " \(heading.text)\n\n"
            }
            
            for paragraph in layout.paragraphs {
                markdown += "\(paragraph.text)\n\n"
            }
            
            return markdown
            
        case .json:
            let documentData = [
                "headings": layout.headings.map { ["text": $0.text, "level": $0.level] },
                "paragraphs": layout.paragraphs.map { ["text": $0.text] },
                "full_text": textResult.recognizedText
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: documentData, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            
            return textResult.recognizedText
        }
    }
    
    private func detectLanguages(in text: String) -> [String] {
        guard let detector = languageDetector else { return [] }
        
        detector.processString(text)
        
        let dominantLanguage = detector.dominantLanguage
        let languageHypotheses = detector.languageHypotheses(withMaximum: 3)
        
        var detectedLanguages: [String] = []
        
        if let dominant = dominantLanguage {
            detectedLanguages.append(dominant.rawValue)
        }
        
        for (language, _) in languageHypotheses {
            if !detectedLanguages.contains(language.rawValue) {
                detectedLanguages.append(language.rawValue)
            }
        }
        
        return detectedLanguages
    }
    
    private func detectLanguage(for text: String) -> String? {
        guard let detector = languageDetector else { return nil }
        
        detector.processString(text)
        return detector.dominantLanguage?.rawValue
    }
    
    private func parseBusinessCardInfo(from textBlocks: [TextBlock]) -> BusinessCardInfo {
        var name: String?
        var title: String?
        var company: String?
        var email: String?
        var phone: String?
        var address: String?
        var website: String?
        
        for block in textBlocks {
            let text = block.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Email detection
            if text.contains("@") && text.contains(".") {
                email = text
                continue
            }
            
            // Phone detection
            if text.range(of: #"[\+]?[\d\s\-\(\)]{10,}"#, options: .regularExpression) != nil {
                phone = text
                continue
            }
            
            // Website detection
            if text.lowercased().contains("www.") || text.lowercased().contains("http") {
                website = text
                continue
            }
            
            // Title detection (contains common title words)
            let titleKeywords = ["CEO", "CTO", "Manager", "Director", "President", "VP", "Engineer", "Developer"]
            if titleKeywords.contains(where: { text.contains($0) }) {
                title = text
                continue
            }
            
            // Company detection (usually appears after title)
            if title != nil && company == nil {
                company = text
                continue
            }
            
            // Name detection (usually the first readable text)
            if name == nil && text.count > 2 && !text.contains("@") {
                name = text
            }
        }
        
        return BusinessCardInfo(
            name: name,
            title: title,
            company: company,
            email: email,
            phone: phone,
            address: address,
            website: website
        )
    }
    
    private func filterLicensePlateText(
        textBlocks: [TextBlock],
        country: String
    ) -> String? {
        
        let licensePlatePatterns: [String: String] = [
            "US": #"[A-Z0-9]{2,8}"#,
            "EU": #"[A-Z]{1,3}[-\s]?[0-9]{1,4}[-\s]?[A-Z]{0,3}"#,
            "TR": #"[0-9]{2}[\s]?[A-Z]{1,3}[\s]?[0-9]{2,4}"#
        ]
        
        guard let pattern = licensePlatePatterns[country] else {
            return textBlocks.first?.text
        }
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        for block in textBlocks {
            let text = block.text.replacingOccurrences(of: " ", with: "")
            let range = NSRange(location: 0, length: text.utf16.count)
            
            if let match = regex?.firstMatch(in: text, options: [], range: range) {
                let matchRange = Range(match.range, in: text)!
                return String(text[matchRange])
            }
        }
        
        return nil
    }
    
    private func convertBoundingBox(_ normalizedBox: CGRect, imageSize: CGSize) -> CGRect {
        let x = normalizedBox.origin.x * imageSize.width
        let y = (1 - normalizedBox.origin.y - normalizedBox.height) * imageSize.height
        let width = normalizedBox.width * imageSize.width
        let height = normalizedBox.height * imageSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func calculateOverallConfidence(_ textBlocks: [TextBlock]) -> Float {
        guard !textBlocks.isEmpty else { return 0.0 }
        
        let totalConfidence = textBlocks.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Float(textBlocks.count)
    }
    
    // MARK: - Turkish Language Support
    
    private let turkishCommonWords = [
        "Türkiye", "Cumhuriyet", "Atatürk", "İstanbul", "Ankara", "İzmir",
        "şehir", "ülke", "millet", "devlet", "cumhuriyet", "demokrasi",
        "özgürlük", "barış", "adalet", "eğitim", "bilim", "teknoloji"
    ]
}

// MARK: - Supporting Types

public struct BusinessCardInfo: Codable {
    public let name: String?
    public let title: String?
    public let company: String?
    public let email: String?
    public let phone: String?
    public let address: String?
    public let website: String?
}

public struct BusinessCardResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let recognizedText: String
    public let textBlocks: [TextBlock]
    public let extractedInfo: BusinessCardInfo
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval = 0,
        recognizedText: String,
        textBlocks: [TextBlock],
        extractedInfo: BusinessCardInfo,
        confidence: Float
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = [:]
        self.recognizedText = recognizedText
        self.textBlocks = textBlocks
        self.extractedInfo = extractedInfo
    }
}

public struct LicensePlateResult: VisionResult {
    public let id: String
    public let timestamp: Date
    public let processingTime: TimeInterval
    public let confidence: Float
    public let metadata: [String: Any]
    
    public let licensePlateNumber: String?
    public let country: String
    public let allDetectedText: String
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        processingTime: TimeInterval = 0,
        licensePlateNumber: String?,
        confidence: Float,
        country: String,
        allDetectedText: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.confidence = confidence
        self.metadata = ["country": country]
        self.licensePlateNumber = licensePlateNumber
        self.country = country
        self.allDetectedText = allDetectedText
    }
}

public enum TextRecognitionError: LocalizedError {
    case invalidImage
    case modelNotInitialized
    case recognitionFailed(Error)
    case layoutAnalysisFailed(Error)
    case languageNotSupported(String)
    case processingTimeout
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided for text recognition"
        case .modelNotInitialized:
            return "Text recognition model not initialized"
        case .recognitionFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        case .layoutAnalysisFailed(let error):
            return "Document layout analysis failed: \(error.localizedDescription)"
        case .languageNotSupported(let language):
            return "Language '\(language)' is not supported"
        case .processingTimeout:
            return "Text recognition processing timed out"
        }
    }
}
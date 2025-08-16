//
// Localization.swift
// SwiftIntelligence
//
// Created by SwiftIntelligence Framework on 16/08/2024.
//

import Foundation

/// Localization utility for SwiftIntelligence Framework
/// Provides easy access to localized strings across all modules
public enum Localization {
    
    // MARK: - Bundle Management
    
    private static var frameworkBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleReference.self)
        #endif
    }
    
    // MARK: - Localization Methods
    
    /// Get localized string for given key
    /// - Parameters:
    ///   - key: Localization key
    ///   - defaultValue: Default value if localization not found
    ///   - bundle: Bundle to search in (defaults to framework bundle)
    ///   - locale: Specific locale to use (defaults to current)
    /// - Returns: Localized string
    public static func string(
        for key: String,
        defaultValue: String? = nil,
        bundle: Bundle? = nil,
        locale: Locale? = nil
    ) -> String {
        let targetBundle = bundle ?? frameworkBundle
        let fallback = defaultValue ?? key
        
        if let locale = locale {
            guard let path = targetBundle.path(forResource: locale.identifier, ofType: "lproj"),
                  let localeBundle = Bundle(path: path) else {
                return NSLocalizedString(key, bundle: targetBundle, comment: fallback)
            }
            return NSLocalizedString(key, bundle: localeBundle, comment: fallback)
        }
        
        return NSLocalizedString(key, bundle: targetBundle, comment: fallback)
    }
    
    /// Get localized string with format arguments
    /// - Parameters:
    ///   - key: Localization key
    ///   - arguments: Format arguments
    ///   - defaultValue: Default value if localization not found
    /// - Returns: Formatted localized string
    public static func string(
        for key: String,
        arguments: CVarArg...,
        defaultValue: String? = nil
    ) -> String {
        let format = string(for: key, defaultValue: defaultValue)
        return String(format: format, arguments: arguments)
    }
    
    // MARK: - Framework Localization
    
    /// Framework specific localized strings
    public enum Framework {
        public static var name: String {
            string(for: "framework.name", defaultValue: "SwiftIntelligence")
        }
        
        public static var description: String {
            string(for: "framework.description", defaultValue: "Advanced AI/ML Framework for Apple Platforms")
        }
        
        public static func version(_ version: String) -> String {
            string(for: "framework.version", arguments: version, defaultValue: "Version \(version)")
        }
    }
    
    // MARK: - Engine Status
    
    /// Engine status localized strings
    public enum Engine {
        public static var ready: String {
            string(for: "engine.ready", defaultValue: "Engine Ready")
        }
        
        public static var initializing: String {
            string(for: "engine.initializing", defaultValue: "Initializing Engine")
        }
        
        public static var error: String {
            string(for: "engine.error", defaultValue: "Engine Error")
        }
        
        public static var shutdown: String {
            string(for: "engine.shutdown", defaultValue: "Engine Shutdown")
        }
        
        public static var unavailable: String {
            string(for: "engine.unavailable", defaultValue: "Engine Unavailable")
        }
    }
    
    // MARK: - Error Messages
    
    /// Error message localized strings
    public enum Errors {
        public static var general: String {
            string(for: "error.general", defaultValue: "An error occurred")
        }
        
        public static var network: String {
            string(for: "error.network", defaultValue: "Network error")
        }
        
        public static var permissionDenied: String {
            string(for: "error.permission.denied", defaultValue: "Permission denied")
        }
        
        public static var invalidInput: String {
            string(for: "error.invalid.input", defaultValue: "Invalid input")
        }
        
        public static var processingFailed: String {
            string(for: "error.processing.failed", defaultValue: "Processing failed")
        }
        
        public static var modelUnavailable: String {
            string(for: "error.model.unavailable", defaultValue: "Model unavailable")
        }
        
        public static var unsupportedPlatform: String {
            string(for: "error.unsupported.platform", defaultValue: "Unsupported platform")
        }
    }
    
    // MARK: - NLP Module
    
    /// NLP module localized strings
    public enum NLP {
        public static var analyzing: String {
            string(for: "nlp.analyzing", defaultValue: "Analyzing text...")
        }
        
        public static var processingComplete: String {
            string(for: "nlp.processing.complete", defaultValue: "Text processing complete")
        }
        
        public static func entitiesFound(_ count: Int) -> String {
            string(for: "nlp.entities.found", arguments: count, defaultValue: "\(count) entities found")
        }
        
        public enum Sentiment {
            public static var positive: String {
                string(for: "nlp.sentiment.positive", defaultValue: "Positive")
            }
            
            public static var negative: String {
                string(for: "nlp.sentiment.negative", defaultValue: "Negative")
            }
            
            public static var neutral: String {
                string(for: "nlp.sentiment.neutral", defaultValue: "Neutral")
            }
        }
    }
    
    // MARK: - Vision Module
    
    /// Vision module localized strings
    public enum Vision {
        public static var processing: String {
            string(for: "vision.processing", defaultValue: "Processing image...")
        }
        
        public static var classificationComplete: String {
            string(for: "vision.classification.complete", defaultValue: "Image classification complete")
        }
        
        public static func objectsDetected(_ count: Int) -> String {
            string(for: "vision.objects.detected", arguments: count, defaultValue: "\(count) objects detected")
        }
        
        public static func facesDetected(_ count: Int) -> String {
            string(for: "vision.faces.detected", arguments: count, defaultValue: "\(count) faces detected")
        }
    }
    
    // MARK: - Speech Module
    
    /// Speech module localized strings
    public enum Speech {
        public static var listening: String {
            string(for: "speech.listening", defaultValue: "Listening...")
        }
        
        public static var recognitionStarting: String {
            string(for: "speech.recognition.starting", defaultValue: "Starting speech recognition")
        }
        
        public static var recognitionStopped: String {
            string(for: "speech.recognition.stopped", defaultValue: "Speech recognition stopped")
        }
        
        public static var synthesisStarting: String {
            string(for: "speech.synthesis.starting", defaultValue: "Starting text-to-speech")
        }
        
        public static var synthesisComplete: String {
            string(for: "speech.synthesis.complete", defaultValue: "Speech synthesis complete")
        }
        
        public static var permissionRequired: String {
            string(for: "speech.permission.required", defaultValue: "Speech recognition permission required")
        }
    }
    
    // MARK: - Performance
    
    /// Performance localized strings
    public enum Performance {
        public static var measuring: String {
            string(for: "performance.measuring", defaultValue: "Measuring performance...")
        }
        
        public static var excellent: String {
            string(for: "performance.excellent", defaultValue: "Excellent")
        }
        
        public static var good: String {
            string(for: "performance.good", defaultValue: "Good")
        }
        
        public static var average: String {
            string(for: "performance.average", defaultValue: "Average")
        }
        
        public static var poor: String {
            string(for: "performance.poor", defaultValue: "Poor")
        }
    }
    
    // MARK: - User Interface
    
    /// UI localized strings
    public enum UI {
        public static var loading: String {
            string(for: "ui.loading", defaultValue: "Loading...")
        }
        
        public static var processing: String {
            string(for: "ui.processing", defaultValue: "Processing...")
        }
        
        public static var complete: String {
            string(for: "ui.complete", defaultValue: "Complete")
        }
        
        public static var cancel: String {
            string(for: "ui.cancel", defaultValue: "Cancel")
        }
        
        public static var retry: String {
            string(for: "ui.retry", defaultValue: "Retry")
        }
        
        public static var settings: String {
            string(for: "ui.settings", defaultValue: "Settings")
        }
    }
}

// MARK: - Bundle Reference

/// Helper class for bundle access in non-SPM environments
private final class BundleReference {}

// MARK: - Localization Extensions

extension String {
    /// Get localized version of this string
    public var localized: String {
        Localization.string(for: self)
    }
    
    /// Get localized version with format arguments
    public func localized(arguments: CVarArg...) -> String {
        Localization.string(for: self, arguments: arguments)
    }
}

// MARK: - Language Support

extension Localization {
    
    /// Supported languages in SwiftIntelligence
    public enum SupportedLanguage: String, CaseIterable {
        case english = "en"
        case turkish = "tr" 
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case japanese = "ja"
        case chinese = "zh"
        
        public var displayName: String {
            switch self {
            case .english: return "English"
            case .turkish: return "Türkçe"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .japanese: return "日本語"
            case .chinese: return "中文"
            }
        }
        
        public var locale: Locale {
            return Locale(identifier: rawValue)
        }
    }
    
    /// Get current preferred language
    public static var currentLanguage: SupportedLanguage {
        guard let languageCode = Locale.current.language.languageCode?.identifier,
              let language = SupportedLanguage(rawValue: languageCode) else {
            return .english
        }
        return language
    }
    
    /// Check if a language is supported
    public static func isLanguageSupported(_ languageCode: String) -> Bool {
        return SupportedLanguage(rawValue: languageCode) != nil
    }
}
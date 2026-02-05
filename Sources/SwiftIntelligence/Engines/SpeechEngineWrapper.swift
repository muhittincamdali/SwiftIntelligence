// SpeechEngineWrapper.swift
// SwiftIntelligence - Speech Processing
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import Speech
import AVFoundation

/// Unified speech engine wrapper for SwiftIntelligence API
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension SpeechEngine {
    
    /// Transcribe audio file to text
    public func transcribe(
        _ audioURL: URL,
        language: String
    ) async throws -> TranscriptionResult {
        
        // Check authorization
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            // Request authorization
            await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { _ in
                    continuation.resume()
                }
            }
        }
        
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language)),
              recognizer.isAvailable else {
            throw SpeechEngineError.recognizerNotAvailable
        }
        
        let startTime = Date()
        
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result, result.isFinal else { return }
                
                let transcription = result.bestTranscription
                
                let segments = transcription.segments.map { segment in
                    TranscriptionResult.TranscriptionSegment(
                        text: segment.substring,
                        startTime: segment.timestamp,
                        endTime: segment.timestamp + segment.duration,
                        confidence: segment.confidence
                    )
                }
                
                let avgConfidence = transcription.segments.isEmpty ? 0 :
                    transcription.segments.map { $0.confidence }.reduce(0, +) / Float(transcription.segments.count)
                
                let duration = transcription.segments.last.map { $0.timestamp + $0.duration } ?? 0
                
                let transcriptionResult = TranscriptionResult(
                    text: transcription.formattedString,
                    segments: segments,
                    confidence: avgConfidence,
                    duration: duration
                )
                
                continuation.resume(returning: transcriptionResult)
            }
        }
    }
    
    /// Synthesize text to speech audio
    public func synthesize(
        _ text: String,
        voice: String?
    ) async throws -> Data {
        
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        
        if let voiceId = voice {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voiceId)
        }
        
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // For actual audio data capture, we need to write to a file
        // This is a simplified implementation
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = SpeechSynthesizerDelegateHandler(
                onComplete: { data in
                    continuation.resume(returning: data)
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
            
            // Store delegate to prevent deallocation
            objc_setAssociatedObject(synthesizer, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            
            synthesizer.delegate = delegate
            synthesizer.speak(utterance)
        }
    }
    
    /// Reset speech engine
    public func reset() async {
        // Reset any state
    }
}

// MARK: - Speech Synthesizer Delegate Handler

private final class SpeechSynthesizerDelegateHandler: NSObject, AVSpeechSynthesizerDelegate {
    private let onComplete: (Data) -> Void
    private let onError: (Error) -> Void
    
    init(onComplete: @escaping (Data) -> Void, onError: @escaping (Error) -> Void) {
        self.onComplete = onComplete
        self.onError = onError
        super.init()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Return empty data as placeholder (actual implementation would capture audio)
        onComplete(Data())
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onError(SpeechEngineError.cancelled)
    }
}

// MARK: - Speech Engine Errors

public enum SpeechEngineError: LocalizedError {
    case recognizerNotAvailable
    case authorizationDenied
    case audioEngineError
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .recognizerNotAvailable: return "Speech recognizer not available"
        case .authorizationDenied: return "Speech recognition authorization denied"
        case .audioEngineError: return "Audio engine error"
        case .cancelled: return "Speech operation cancelled"
        }
    }
}

# Swift Test Blockers

Last validated: 2026-04-01

This document tracks the current blockers preventing `swift test` from going green across the full SwiftIntelligence package.

## Current Status

- `swift run -c release Benchmarks --profile smoke` works
- benchmark artifacts are generated under `Benchmarks/Results/latest`
- `swift test` still fails due to contract drift across several older modules

## Resolved In This Sprint

- added `defaultLocalization` to `Package.swift`
- added executable benchmark runner `Benchmarks`
- added reproducible benchmark script `Scripts/run-benchmarks.sh`
- generated real benchmark artifacts
- fixed `Localization` overload ambiguity
- fixed benchmark module Codable/rethrows issues
- aligned `DataProtectionManager` with `PrivacyTypes`
- fixed `PrivacyTokenizer` explicit `self` capture
- fixed several speech API mismatches and cache type issues
- fixed AppKit `cgImage` usage in `FaceRecognitionProcessor`
- fixed document segmentation bounding-box casting in `TextRecognitionProcessor`

## Remaining Blocker Clusters

### 1. Speech Contract Drift

Files:

- `Sources/SwiftIntelligenceSpeech/SpeechEngine.swift`
- `Sources/SwiftIntelligenceSpeech/SwiftIntelligenceSpeech.swift`
- `Sources/SwiftIntelligenceSpeech/Types/SpeechTypes.swift`

Examples:

- `SpeechSynthesisOptions` usage does not match actual fields (`rate`, `preDelay`, `postDelay`, `hashValue`)
- `SwiftIntelligenceSpeech.swift` still has result-shape mismatches when constructing `SpeechRecognitionResult`
- `Data` vs `NSData` cache writes are inconsistent

### 2. Privacy Engine Type Drift

Files:

- `Sources/SwiftIntelligencePrivacy/PrivacyEngine.swift`
- `Sources/SwiftIntelligencePrivacy/Types/PrivacyTypes.swift`

Examples:

- `EncryptionStatus` and `BiometricAuthStatus` are structs, but engine uses enum-style cases
- `PrivacyConfiguration` shape no longer matches engine expectations (`encryption`, `dataProtection`, `auditLogging`, `compliance`, `validate()`)
- `EncryptionContext` and `EncryptedData` contracts appear to have diverged
- `PrivacyError` call sites assume associated-value cases that do not exist in the current type definition

### 3. Audit Logging Drift

Files:

- `Sources/SwiftIntelligencePrivacy/Audit/PrivacyAuditLogger.swift`
- `Sources/SwiftIntelligencePrivacy/Types/PrivacyTypes.swift`

Examples:

- duplicate or ambiguous `AuditEntry` definitions
- missing `AuditEvent` references
- `AuditLoggingConfiguration` fields used by logger do not match the current type
- `AuditSealedBox` Codable conformance is broken

### 4. Additional Warning Debt

These are not the immediate blockers, but they are widespread and should be addressed after compile health is restored:

- strict concurrency warnings across Privacy, Vision, and SecureKeychain modules
- deprecated Security API usage in `SecureKeychain`
- stale placeholder implementations in some speech/vision flows

## Recommended Next Order

1. Normalize speech type contracts until `SwiftIntelligenceSpeech` compiles cleanly.
2. Choose a source of truth for privacy types, then rewrite `PrivacyEngine` to that contract instead of patching call sites piecemeal.
3. Collapse `PrivacyAuditLogger` to a single canonical `AuditEntry` model and restore Codable support.
4. Re-run `swift test`, then handle the next wave of platform and concurrency warnings.

# SwiftIntelligencePrivacy vs CryptoKit + Security

Last updated: 2026-04-07

This page answers one adoption question:

**When should an Apple developer stay on raw `CryptoKit` and `Security`, and when is `SwiftIntelligencePrivacy` the better application-facing layer?**

## Short Answer

Choose raw `CryptoKit` and `Security` when:

- you only need encryption, hashing, key storage, or biometric access as isolated primitives
- you want zero abstraction above Apple security APIs
- your privacy needs are narrow and app-specific

Choose `SwiftIntelligencePrivacy` when:

- you need tokenization, anonymization, audit, retention, and secure storage together
- privacy sits in front of NLP, Vision, or network transport
- your team wants one maintained privacy workflow surface instead of multiple low-level integrations

## Side-by-Side

| Concern | Raw `CryptoKit` + `Security` | `SwiftIntelligencePrivacy` |
| --- | --- | --- |
| Encryption primitives | direct and strongest | built on top of Apple primitives |
| Key storage | direct Keychain control | wrapped through the privacy layer |
| Tokenization | app-specific implementation | maintained tokenizer included |
| Audit/compliance flow | app-specific | first-class part of the module |
| Data-retention flow | app-specific | built into the privacy surface |
| Lowest-level control | stronger | weaker |

## Code Shape

Raw Apple security code often starts like this:

```swift
import CryptoKit
import Security

let key = SymmetricKey(size: .bits256)
let sealed = try AES.GCM.seal(data, using: key)
```

`SwiftIntelligencePrivacy` compresses the app-facing workflow:

```swift
import SwiftIntelligencePrivacy

let tokenized = try await PrivacyTokenizer().tokenize(
    "john.doe@example.com",
    context: TokenizationContext(
        purpose: .email,
        sensitivity: .high,
        retentionPolicy: .temporary
    )
)
```

## Migration Heuristic

Stay on raw Apple security APIs if your codebase looks like this:

- one narrow crypto or keychain need
- no need for shared tokenization/anonymization flows
- no desire for audit or compliance helpers in the same layer

Move to `SwiftIntelligencePrivacy` if your codebase is accumulating:

- repeated tokenization or anonymization code
- repeated secure-storage wrappers
- privacy logic that must plug into AI preprocessing flows
- audit and retention logic scattered across the app

## Current Proof

What is proven today:

- repo-level proof posture is `release-grade` at the `Mac + iPhone` policy floor
- privacy flows exist in the maintained modular graph
- tokenizer and privacy components are exercised by tests/examples and showcased composition

What is not yet proven:

- public benchmark leadership over raw `CryptoKit` + `Security`
- a stronger public guarantee language for every privacy boundary

## Best-Fit Decision

Use raw `CryptoKit` and `Security` if you want primitive control and minimal abstraction.

Use `SwiftIntelligencePrivacy` if you want a maintained privacy workflow layer that reduces glue code around tokenization, retention, audit, and AI-adjacent preprocessing.

## Sources

- [Apple CryptoKit docs](https://developer.apple.com/documentation/cryptokit)
- [Apple Security Keys docs](https://developer.apple.com/documentation/security/keys)
- [Storing CryptoKit Keys in the Keychain](https://developer.apple.com/documentation/CryptoKit/storing-cryptokit-keys-in-the-keychain)
- [Privacy Comparison](Privacy.md)

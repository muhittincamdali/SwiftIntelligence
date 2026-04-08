# Privacy Comparison

Last updated: 2026-04-07

## Category

`SwiftIntelligencePrivacy` competes as an application-facing privacy utility layer for Apple-platform AI workflows, not as a full security platform.

## Primary Alternatives

| Alternative | Why Developers Use It |
| --- | --- |
| [Apple CryptoKit](https://developer.apple.com/documentation/cryptokit) | native hashing, key generation, encryption primitives |
| [Apple Security / Keys](https://developer.apple.com/documentation/security/keys) | key handling, trust, and lower-level security services |
| [Storing CryptoKit Keys in the Keychain](https://developer.apple.com/documentation/CryptoKit/storing-cryptokit-keys-in-the-keychain) | official Apple guidance for key storage |
| app-specific custom redaction or tokenization code | simplest possible narrow implementation |

## Where SwiftIntelligencePrivacy Wins

- combines tokenization, anonymization, audit, compliance, and secure-storage helpers in one maintained surface
- better fit for AI apps that need privacy-aware pre-processing before NLP, Vision, or network transport
- easier to adopt than rebuilding tokenization and anonymization workflows around raw primitives

## Where It Loses

- not a replacement for full application security architecture
- not the best choice if all you need is one direct CryptoKit or Keychain operation
- public proof is still more architectural than ecosystem-leading

## Decision Table

| Choose | When |
| --- | --- |
| `SwiftIntelligencePrivacy` | you need tokenization, anonymization, audit, and storage helpers in one AI workflow layer |
| `CryptoKit` and `Security` directly | you need the lowest-level native crypto/key APIs with no extra abstraction |
| app-specific custom code | your privacy logic is extremely narrow and does not justify a shared abstraction |

## Best-Fit User

Choose `SwiftIntelligencePrivacy` if you want:

- privacy-aware AI pre-processing inside the same package graph
- reversible tokenization and irreversible anonymization in one place
- a cleaner bridge between app logic and Apple security primitives

Choose the alternatives if you want:

- the lowest-level native crypto and key APIs directly
- zero abstraction above CryptoKit/Keychain
- a complete end-to-end security platform, which this module is not

## Brutal Gap List

- no public comparison examples against raw CryptoKit + Keychain integration
- privacy guarantees are not yet expressed through stronger module-level benchmark or adoption proof
- the module still needs sharper public guidance on what it does not guarantee

## Current Proof Posture

- repo-level release proof is now `release-grade` at the `Mac + iPhone` policy floor
- privacy value is currently proven more by composition and architecture than by isolated public benchmarks
- use [../Generated/Public-Proof-Status.md](../Generated/Public-Proof-Status.md) and [../Showcase.md](../Showcase.md) as the current trust surface
- detailed raw-API adoption guide: [Privacy-vs-CryptoKit-Security.md](Privacy-vs-CryptoKit-Security.md)

## Win Condition

`SwiftIntelligencePrivacy` wins when it becomes the default companion layer for Apple developers who need to reduce sensitive-data exposure before AI processing, without inventing their own tokenization and anonymization stack from scratch.

## Sources

- [Apple CryptoKit docs](https://developer.apple.com/documentation/cryptokit)
- [Apple Security Keys docs](https://developer.apple.com/documentation/security/keys)
- [Storing CryptoKit Keys in the Keychain](https://developer.apple.com/documentation/CryptoKit/storing-cryptokit-keys-in-the-keychain)

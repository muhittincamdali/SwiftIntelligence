# Security Guide

This document describes the current security posture of the active `SwiftIntelligence` package graph.

It is intentionally narrower and more honest than older repository narratives. If a claim here is not enforced by code, tests, or workflow gates, treat it as guidance rather than a guarantee.

## Scope

Security maintenance is focused on the active public products in [Package.swift](../Package.swift):

- `SwiftIntelligenceCore`
- `SwiftIntelligenceML`
- `SwiftIntelligenceNLP`
- `SwiftIntelligenceVision`
- `SwiftIntelligenceSpeech`
- `SwiftIntelligenceReasoning`
- `SwiftIntelligencePrivacy`
- `SwiftIntelligenceNetwork`
- `SwiftIntelligenceCache`
- `SwiftIntelligenceMetrics`
- `SwiftIntelligenceBenchmarks`

Historical umbrella APIs and inactive products are out of scope unless they are restored to the package graph.

## Repository-Enforced Controls

The repository currently enforces or validates these controls:

- pull requests are reviewed with dependency diff scanning
- code scanning is covered by a dedicated CodeQL workflow
- repository posture is checked by OpenSSF Scorecard automation
- examples are compile-validated through `bash Scripts/validate-examples.sh`
- release preparation is gated by `bash Scripts/prepare-release.sh`
- benchmark-backed performance claims are validated by `bash Scripts/validate-benchmarks.sh`
- benchmark artifacts and generated docs are treated as release surface, not throwaway files

## Threat Model

The main security risks for this repository are:

- leaking secrets or credentials through examples, CI, or generated artifacts
- treating stale documentation as a supported security contract
- introducing unsafe concurrency or state-sharing bugs in active modules
- shipping network-facing helpers without validating trust boundaries
- publishing performance or privacy claims without reproducible evidence

This repository is not a complete application. Integrators still own:

- authentication and authorization
- server-side access control
- API abuse protection
- production key management outside the library
- app-specific privacy disclosures and legal compliance

## Current Security Building Blocks

### Privacy

`SwiftIntelligencePrivacy` provides the main security-sensitive primitives in the active graph:

- `PrivacyTokenizer` for reversible tokenization of sensitive values
- `DataAnonymizer` for irreversible redaction and masking flows
- `SecureKeychain` for secure local key and secret material handling
- `PrivacyEngine` as the higher-level coordination surface

Use tokenization when a later restore path is required. Use anonymization when the original value should not be recoverable inside the workflow.

### Storage

Sensitive material should stay in platform-secure storage and should not be duplicated into:

- logs
- benchmark artifacts
- screenshots
- example fixtures
- test snapshots

### Network

`SwiftIntelligenceNetwork` is infrastructure, not proof that any end-to-end deployment is secure by default.

If you use network transport:

- validate input at the API boundary
- authenticate requests explicitly
- pin or verify trust where your deployment requires it
- avoid sending raw PII if `PrivacyTokenizer` or anonymization can reduce exposure first

### Benchmarks And Examples

Examples and benchmark outputs are part of the repo's public trust surface.

That means:

- no live credentials in example code
- no private payloads in benchmark fixtures
- no performance claims without generated artifact evidence
- no docs examples that rely on inactive APIs

## Integration Checklist

Before adopting a module in production, verify:

- only required products are imported
- external input is validated at the app or service boundary
- privacy-sensitive text, media, or identifiers are minimized before processing
- logs do not contain tokenized source values, secrets, or user payloads
- release builds pass `swift build`, `swift test`, and example validation
- any public performance statement is backed by current benchmark artifacts

## Release And CI Checklist

Use these commands as the minimum maintainer gate:

```bash
swift build
bash Scripts/validate-examples.sh
swift test
bash Scripts/run-benchmarks.sh standard
bash Scripts/prepare-release.sh
```

For pull requests that change dependencies or workflows, also verify the GitHub security workflows remain green:

- `CodeQL`
- `Dependency Review`
- `Scorecard`

## What Not To Assume

Do not assume:

- all processing is always on-device in every integration
- every module is free of future concurrency migration work
- old architectural docs are authoritative if they conflict with `Package.swift`
- historical example code is safe unless it passes the current validation path

When documentation conflicts with code, the active package graph and validation scripts win.

## Reporting A Vulnerability

Do not open public issues for vulnerabilities.

Use the private reporting path described in [SECURITY.md](../SECURITY.md).

Include:

- affected module
- impact
- reproduction steps
- version, branch, or commit if known
- proof of concept or minimal failing case
- suggested mitigation if available

## Related Documents

- [SECURITY.md](../SECURITY.md)
- [Release-Process.md](./Release-Process.md)
- [Benchmark-Baselines.md](./Benchmark-Baselines.md)
- [README.md](../README.md)

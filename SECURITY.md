# Security Policy

SwiftIntelligence is an actively stabilized modular package. Security reporting should focus on issues in the active package graph, not historical umbrella APIs or inactive products.

## Supported Scope

We prioritize security fixes for the current modular products shipped from `Package.swift`:

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

## Report a Vulnerability

- Do not open a public GitHub issue.
- Prefer GitHub Security Advisories:
  [Report a vulnerability](https://github.com/muhittincamdali/SwiftIntelligence/security/advisories)
- If private advisory reporting is unavailable, email:
  `security@swiftintelligence.dev`

## What to Include

- affected module
- impact
- reproduction steps
- proof of concept or code sample
- version / branch / commit if known
- any suggested mitigation

## Current Security Posture

This repository aims for privacy-first, mostly on-device processing, but not every security/privacy claim historically written in the repo should be treated as universally guaranteed across all modules and all example code.

Treat the following as current guidance:

- validate all external input at app boundaries
- do not expose secrets in examples, tests, or benchmark artifacts
- do not assume inactive products are maintained
- review privacy-sensitive flows before enabling network transport
- keep CodeQL, dependency review, and OpenSSF Scorecard definitions maintained and active; use repo-local validation as the maintainer-side floor, not as a substitute for broken public CI
- treat benchmark, example, and release artifacts as part of the trusted supply-chain surface

## Security Operations Matrix

| Surface | Current policy |
| --- | --- |
| Vulnerability intake | Prefer GitHub Security Advisories |
| Public issues | Do not use for vulnerabilities |
| Sensitive examples | Never commit secrets, tokens, or production credentials |
| Privacy-sensitive benchmark output | Treat as trusted release surface, not disposable scratch data |
| GitHub-hosted security workflows | Keep definitions current and active; live GitHub results should stay truthful and green on `main` |
| Local maintainer gate | `bash Scripts/prepare-release.sh` remains the canonical repo-side validation floor |

## Response Expectations

Security reports are reviewed as quickly as possible, but no hard SLA is promised in this file.

## Disclosure

Please allow time for triage, remediation, validation, and release preparation before public disclosure.

## Security-Related Docs

- [Documentation/Security.md](Documentation/Security.md)
- [SUPPORT.md](SUPPORT.md)
- [.github/copilot-instructions.md](.github/copilot-instructions.md)

# Changelog

## Unreleased

- post-1.2.0 changes will be tracked here

## 1.2.0 - 2026-04-08

- stabilized the active modular package graph and kept `swift test` green
- refreshed README and getting-started guides to match the current modular API surface
- aligned Swift Package Index metadata with real package targets
- rewrote legacy examples and added `validate-examples.sh` as a CI gate
- simplified CI to a trustworthy `swift build` plus example validation plus `swift test` gate
- tightened release and documentation workflows around benchmark evidence and scripted release validation
- added benchmark artifact schema/profile validation and linked release gating to `standard` benchmark evidence
- made CI run and publish `smoke` benchmark artifacts, and made tag releases regenerate `standard` artifacts before validation
- added CodeQL, dependency review, and OpenSSF Scorecard workflows to harden code scanning and supply-chain review
- added a positioning/comparison document grounded in current Apple docs and GitHub competitor data
- added module-level comparison pages for NLP, Vision, Speech, and Privacy
- added a showcase page that ties flagship demo flows to current benchmark evidence
- added a generated proof snapshot script and documentation surface derived from benchmark artifacts
- added immutable benchmark evidence archiving and release-proof notes for tagged releases
- added generated benchmark history and latest-vs-release comparison pages
- added generated benchmark methodology and environment matrix pages
- added release-bundle benchmark delta notes against the previous immutable evidence set
- added generated benchmark timeline and release benchmark matrix pages
- added release-notes-proof bundles and generated release proof timeline pages
- added changelog validation and scripted release-note generation from curated release sections
- added version-surface validation for README installation snippets and release tags
- added artifact manifest and checksum generation for benchmark and release evidence bundles
- added benchmark regression threshold policy and release gate validation
- added generated benchmark readiness report for device coverage and publication checklist status
- added generated release-candidate action plan derived from benchmark readiness
- added normalized device metadata, device matrix policy, and a generated device-evidence plan for missing iPhone/iPad capture waves
- added device evidence audit/matrix generation and an external benchmark evidence import script
- added benchmark export packaging plus export/import transfer-chain validation
- added immutable evidence provenance reporting and release provenance validation
- made device-aware benchmark capture able to emit transfer archives directly
- added generated device capture packets plus release-gated packet validation for missing device classes
- added generated device evidence intake surfaces and issue-ready packet payloads
- added a generated release blocker summary wired into roadmap, status, and benchmark docs
- added generated public proof status surfaces for allowed vs blocked release/distribution claims
- wired public proof status into release validation, evidence bundles, and release notes
- added generated device evidence queue surfaces and validation
- added generated device evidence handoff surfaces plus a transport archive for missing-device operator delivery
- wired the device evidence handoff package into immutable release bundles and release assets
- added release-evidence asset validation so missing-device handoff files are enforced inside archived bundles
- added `hydrate-release-evidence-assets.sh` to backfill older immutable bundles to the current release-asset policy
- added a release workflow asset policy plus validation so GitHub uploads cannot drift from the immutable evidence schema
- added device-evidence issue schema validation so packet-local `issue-fields.json` cannot drift from the GitHub form
- centralized packet issue defaults in `device-evidence-form-policy.json`
- added `complete-device-evidence-wave.sh` so the full pending iPhone+iPad import wave can be closed with one command
- fixed release automation to emit a valid Swift Package Manager version snippet
- added `validate-flagship-demo.sh` so the strongest demo path can be smoke-checked independently
- wired flagship demo validation into CI and generated proof surfaces
- added a dedicated IntelligentCamera demo guide with fastest run path and failure signals
- aligned GitHub description and topic metadata with the current Apple on-device AI positioning

## 1.0.0 - 2025-01-15

- initial release
- shipped the first public multi-module SwiftIntelligence package

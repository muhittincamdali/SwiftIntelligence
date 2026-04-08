# Documentation Status

This file tracks which documents match the active package graph and which ones still reflect legacy umbrella-era architecture.

## Verified for Current Modular Graph

- [Getting Started](Getting-Started.md)
- [Benchmark Baselines](Benchmark-Baselines.md)
- [Security Guide](Security.md)
- [Documentation Index](README.md)
- [Positioning](Positioning.md)
- [Module Comparisons](Comparisons/README.md)
- [Showcase](Showcase.md)
- [Generated Proof Snapshot](Generated/Proof-Snapshot.md)
- [Generated Benchmark History](Generated/Benchmark-History.md)
- [Generated Benchmark Comparison](Generated/Benchmark-Comparison.md)
- [Generated Benchmark Methodology](Generated/Benchmark-Methodology.md)
- [Generated Benchmark Timeline](Generated/Benchmark-Timeline.md)
- [Generated Release Benchmark Matrix](Generated/Release-Benchmark-Matrix.md)
- [Generated Release Proof Timeline](Generated/Release-Proof-Timeline.md)
- [Generated Latest Release Proof](Generated/Latest-Release-Proof.md)
- [Generated Benchmark Readiness](Generated/Benchmark-Readiness.md)
- [Generated Release Candidate Plan](Generated/Release-Candidate-Plan.md)
- [Generated Device Evidence Plan](Generated/Device-Evidence-Plan.md)
- [Generated Device Coverage Matrix](Generated/Device-Coverage-Matrix.md)
- [Generated Device Capture Packets](Generated/Device-Capture-Packets.md)
- [Generated Device Evidence Runbook](Generated/Device-Evidence-Runbook.md)
- [Generated Device Evidence Intake](Generated/Device-Evidence-Intake.md)
- [Generated Device Evidence Queue](Generated/Device-Evidence-Queue.md)
- [Generated Device Evidence Handoff](Generated/Device-Evidence-Handoff.md)
- [Generated Release Blockers](Generated/Release-Blockers.md)
- [Generated Public Proof Status](Generated/Public-Proof-Status.md)
- [Generated Evidence Provenance](Generated/Evidence-Provenance.md)
- [GitHub Device Evidence Issue Form](../.github/ISSUE_TEMPLATE/device_evidence.yml)
- [API Overview](API.md)
- [API Reference](API-Reference.md)
- [Architecture](Architecture.md)
- [Performance Guide](Performance.md)
- [visionOS Guide](visionOS-Guide.md)
- [Release Process](Release-Process.md)
- [Release Asset Policy](release-asset-policy.json)
- [Device Evidence Form Policy](device-evidence-form-policy.json)
- diagrams under [Diagrams](Diagrams/README.md)

## Needs Ongoing Review

- top-level repository docs such as `README.md`, `ROADMAP.md`, and `PROJECT_STATUS.md`
- any document that makes benchmark, privacy, or support claims without linking current evidence
- any new example or integration guide that has not yet passed the current validation path

## Rewrite Rules

- remove `IntelligenceEngine` umbrella assumptions unless that product is restored
- remove references to non-active products such as `SwiftIntelligenceImageGeneration`
- prefer examples validated against the current package graph and test suite

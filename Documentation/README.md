# SwiftIntelligence Documentation

This folder is the entry point for implementation notes, usage guides, and proof artifacts.

## Start Here

- [Five-Minute Success Path](Getting-Started.md#five-minute-success-path)
- [README Languages](README-Languages.md)
- [Intelligent Camera demo guide](../Examples/DemoApps/IntelligentCamera/README.md)
- [Getting Started](Getting-Started.md)
- [Documentation Status](DOCUMENTATION_STATUS.md)
- [Architecture](Architecture.md)
- [Positioning](Positioning.md)
- [GitHub Distribution](GitHub-Distribution.md)
- [GitHub Copilot Instructions](../.github/copilot-instructions.md)
- [Code of Conduct](../CODE_OF_CONDUCT.md)
- [Security Policy](../SECURITY.md)
- [Support Guide](../SUPPORT.md)
- [Module Comparisons](Comparisons/README.md)
- [Showcase](Showcase.md)
- [Flagship Media](Assets/Flagship-Demo/README.md)
- [Generated Flagship Media Status](Generated/Flagship-Media-Status.md)
- [Generated Flagship Demo Pack](Generated/Flagship-Demo-Pack.md)
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
- [Proof Surface Validation](../Scripts/validate-proof-surfaces.sh)
- [Device Evidence Wave Import](../Scripts/complete-device-evidence-wave.sh)
- [API Overview](API.md)
- [API Reference](API-Reference.md)
- [Performance Guide](Performance.md)
- [Benchmark Baselines](Benchmark-Baselines.md)
- [Release Process](Release-Process.md)
- [Release Asset Policy](release-asset-policy.json)
- [Device Evidence Form Policy](device-evidence-form-policy.json)
- [Security Guide](Security.md)
- [visionOS Guide](visionOS-Guide.md)

## Maintainer Notes

- [Swift Test Blockers](SWIFT_TEST_BLOCKERS.md)
- [Diagrams](Diagrams/README.md)

## Documentation Standards

- Public examples should reflect the active package graph.
- Performance claims should be backed by reproducible benchmark output.
- High-visibility benchmark language should stay conservative until `Benchmark-Readiness.md` reports `ready`.
- Documentation should prefer modular imports over stale umbrella examples.
- Legacy documents must be clearly marked until they are rewritten.
- Release notes should come from `CHANGELOG.md` plus immutable benchmark evidence, not ad-hoc git log text.
- Public install snippets should match the latest numbered release in `CHANGELOG.md`.

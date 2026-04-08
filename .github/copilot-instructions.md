# SwiftIntelligence Copilot Instructions

SwiftIntelligence is a modular Apple-native AI toolkit, not a generic cross-platform inference layer.

## Product Truth

- Preserve the active modular graph from `Package.swift`.
- Do not revive stale umbrella APIs or historical products unless a maintainer explicitly restores them.
- Do not add hype language that claims category leadership, best-in-class performance, or universal production readiness without evidence.
- Never fake `iPhone`, `iPad`, or any other device evidence. Simulator output and Mac artifacts must not be presented as mobile proof.

## Preferred Technical Direction

- Favor Apple-native framework integration across `Vision`, `NaturalLanguage`, `Speech`, `Core ML`, and privacy-aware workflows.
- Keep code straightforward, strongly typed, and scoped to one clear responsibility.
- Prefer module-local changes over broad abstractions.
- Keep public API and README examples aligned with the maintained modules.

## Validation Expectations

- Run `swift build`, `bash Scripts/validate-flagship-demo.sh`, `bash Scripts/validate-examples.sh`, and `swift test` for product-facing changes.
- Run `bash Scripts/prepare-release.sh` when release surfaces, proof surfaces, benchmark wording, or public claim surfaces change.
- If benchmark or release evidence code changes, keep generated proof pages and release assets in sync.

## Documentation Expectations

- README, showcase, comparison pages, release notes, and proof pages must tell the same story.
- Public claims should point to generated proof surfaces or immutable release bundles.
- If a GitHub-hosted workflow is externally blocked, do not hide the blocker by pretending the workflow passed.

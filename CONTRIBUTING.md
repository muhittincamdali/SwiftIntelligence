# Contributing to SwiftIntelligence

SwiftIntelligence is currently optimized around a modular Swift package graph and Swift 6 migration work. Contributions are welcome, but they need to preserve package stability first.

## Before You Start

- Read [README.md](README.md), [Documentation/README.md](Documentation/README.md), and [Examples/README.md](Examples/README.md).
- Search existing issues and pull requests before opening a new one.
- Keep changes scoped. Large mixed refactors are hard to review and easy to break.

## What We Accept

- Bug fixes in active modules
- Swift 6 concurrency hardening
- Test improvements
- Example and documentation fixes aligned with the active modular graph
- Performance work backed by benchmark output

## What We Usually Reject

- New abstraction layers without a concrete need
- Changes that revive inactive umbrella APIs without an explicit restore plan
- Marketing claims without measurable proof
- Massive multi-area rewrites without a staged rollout

## Local Workflow

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```

If your change affects benchmark-sensitive code, also run:

```bash
bash Scripts/run-benchmarks.sh standard
```

If your change affects public benchmark claims or device evidence, also run:

```bash
bash Scripts/validate-device-evidence.sh
bash Scripts/validate-transfer-chain.sh
bash Scripts/validate-release-provenance.sh
bash Scripts/validate-public-claims.sh
```

If your change adds or updates non-Mac release evidence, also record the exact capture or import command path:

```bash
bash Scripts/run-benchmarks-for-device.sh ...
# or
bash Scripts/import-benchmark-evidence.sh ...
```

## Pull Request Rules

- One pull request should solve one problem.
- Describe the user-visible or maintainer-visible impact.
- Describe the first-user path impact if README, onboarding, examples, or comparisons changed.
- List the modules touched.
- Include validation commands you ran.
- Update docs/examples if the public API changed.
- State whether any public claim, proof wording, or readiness wording changed.
- If benchmark evidence moved, mention which device classes were added, changed, or still missing.
- If you added imported or captured device evidence, include the snapshot name and normalized device metadata in the PR description.

Use the PR template completely. Empty sections for product impact or public-claim impact usually mean the change was not described well enough.

## Device Evidence Intake

Use the `Device Evidence Submission` issue form for:

- missing iPhone/iPad release coverage
- imported external benchmark bundles that need maintainer review
- invalid archived device metadata or broken coverage matrix state

Before opening that issue, check:

- [Documentation/Generated/Device-Evidence-Plan.md](Documentation/Generated/Device-Evidence-Plan.md)
- [Documentation/Generated/Device-Coverage-Matrix.md](Documentation/Generated/Device-Coverage-Matrix.md)
- [Documentation/Generated/Device-Evidence-Runbook.md](Documentation/Generated/Device-Evidence-Runbook.md)

Do not submit simulator output, guessed metadata, or rewritten Mac artifacts as mobile evidence.

## Code Expectations

- Prefer straightforward code over clever code.
- Match the existing module boundaries.
- Keep public APIs documented.
- Treat Swift 6 actor isolation and Sendable correctness as release-quality concerns, not optional cleanup.

## Example Changes

If you touch anything under `Examples/`, the new validation gate must still pass:

```bash
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
```

Do not add examples that depend on inactive products or stale umbrella entry points.

## Security

Do not open public issues for vulnerabilities. Use [SECURITY.md](SECURITY.md).

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).

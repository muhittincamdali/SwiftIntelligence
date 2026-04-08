# Performance Benchmarks

This folder is the canonical home for reproducible SwiftIntelligence performance evidence.

Hand-written benchmark tables go stale fast, so this repository now treats generated artifacts as the source of truth.

## Run The Suite

```bash
swift run -c release Benchmarks --profile standard --output-dir Benchmarks/Results/latest
```

Or use the helper script:

```bash
bash Scripts/run-benchmarks.sh standard
```

To capture a run with explicit normalized device metadata:

```bash
bash Scripts/run-benchmarks-for-device.sh \
  --profile standard \
  --output-dir Benchmarks/Results/iphone-mainstream \
  --device-name "iPhone 16" \
  --device-model "iPhone17,3" \
  --device-class iPhone \
  --platform-family iOS \
  --soc "Apple A18" \
  --export-archive /absolute/path/to/iphone-benchmark-export.tar.gz
```

To archive the validated output as immutable release evidence:

```bash
bash Scripts/run-benchmarks.sh standard Benchmarks/Results/latest v1.2.3
```

To import an artifact set captured on another machine or device:

```bash
bash Scripts/import-benchmark-evidence.sh \
  --device-name "iPhone 16" \
  --device-model "iPhone17,3" \
  --device-class iPhone \
  --platform-family iOS \
  --soc "Apple A18" \
  /absolute/path/to/benchmark-export.tar.gz \
  iphone-baseline-2026-04-02
```

To package a validated artifact set for transfer:

```bash
bash Scripts/export-benchmark-evidence.sh \
  Benchmarks/Results/latest \
  /absolute/path/to/benchmark-export.tar.gz
```

Validate an existing artifact set explicitly:

```bash
bash Scripts/validate-benchmarks.sh standard Benchmarks/Results/latest
```

Check regression thresholds against the latest immutable release baseline:

```bash
bash Scripts/validate-benchmark-thresholds.sh Benchmarks/Results/latest Benchmarks/Results Benchmarks/benchmark-thresholds.json
```

Validate the export/import round-trip on the current artifact set:

```bash
bash Scripts/validate-transfer-chain.sh Benchmarks/Results/latest
```

Validate immutable release provenance metadata:

```bash
bash Scripts/validate-release-provenance.sh Benchmarks/Results
```

Validate immutable release bundle asset completeness:

```bash
bash Scripts/validate-release-evidence-assets.sh Benchmarks/Results
```

Validate that generated packet issue payloads still match the GitHub device evidence form:

```bash
bash Scripts/validate-device-evidence-issue-schema.sh .github/ISSUE_TEMPLATE/device_evidence.yml Documentation/Generated/Device-Capture-Packets Documentation/Generated/Device-Coverage-Matrix.md Documentation/device-evidence-form-policy.json
```

Validate that the GitHub release workflow still uploads the full required asset set:

```bash
bash Scripts/validate-release-workflow-assets.sh .github/workflows/release.yml Documentation/release-asset-policy.json
```

## Profiles

| Profile | Goal | When To Use |
| --- | --- | --- |
| `smoke` | Fast local sanity check | pre-PR, quick regression check |
| `standard` | Default evidence run | documentation updates, release prep |
| `exhaustive` | Long-form deeper signal | milestone validation, release candidates |

## Artifact Contract

Each run writes:

- `benchmark-report.json`
- `benchmark-summary.md`
- `environment.json`
- `device-metadata.json`
- `artifact-manifest.json`
- `checksums.txt`

Default location:

```text
Benchmarks/Results/latest
```

## Publication Rules

- never publish benchmark claims without attaching the generated artifacts
- always include device and OS metadata
- normalize device identity through `device-metadata.json`
- compare competitors only when workload and methodology are equivalent
- keep raw output files versionable outside the main README to avoid stale marketing tables

## Next Step

Use [Benchmark Baselines](../Documentation/Benchmark-Baselines.md) as the publication checklist before turning measurements into public claims.

Release preparation is gated by [Release Process](../Documentation/Release-Process.md).

CI also runs the `smoke` profile and uploads its artifact set so benchmark drift is caught before release tags.
Release validation also enforces the threshold policy defined in `Benchmarks/benchmark-thresholds.json` whenever a previous immutable release bundle exists.
Device coverage expectations are defined in `Benchmarks/device-matrix-policy.json`.
Use `Scripts/run-benchmarks-for-device.sh` when collecting iPhone/iPad/visionOS evidence so generated history surfaces group devices consistently.
It can also emit a portable `.tar.gz` transfer archive directly with `--export-archive`.
Use `Scripts/import-benchmark-evidence.sh` when a validated device run is captured outside this repository checkout and needs to be normalized before archival.
Use `Scripts/export-benchmark-evidence.sh` when the validated artifact set needs to be handed off between machines before import.

Tagged releases archive the validated `standard` artifact set into `Benchmarks/Results/releases/<tag>` and attach that immutable bundle to the GitHub release.
Those bundles now include explicit device metadata, public-proof status snapshots, a file manifest plus SHA-256 checksum list, and a `device-evidence-handoff` package whenever required release device classes are still missing.

For the current repo-level evidence story, see [Showcase](../Documentation/Showcase.md).

For the generated benchmark-backed proof page, see [Proof Snapshot](../Documentation/Generated/Proof-Snapshot.md).

For generated history, methodology, timeline, release matrix, release proof surfaces, and latest-vs-release deltas, see [Benchmark History](../Documentation/Generated/Benchmark-History.md), [Benchmark Methodology](../Documentation/Generated/Benchmark-Methodology.md), [Benchmark Timeline](../Documentation/Generated/Benchmark-Timeline.md), [Release Benchmark Matrix](../Documentation/Generated/Release-Benchmark-Matrix.md), [Release Proof Timeline](../Documentation/Generated/Release-Proof-Timeline.md), [Latest Release Proof](../Documentation/Generated/Latest-Release-Proof.md), and [Benchmark Comparison](../Documentation/Generated/Benchmark-Comparison.md).
For the current publication checklist status, see [Benchmark Readiness](../Documentation/Generated/Benchmark-Readiness.md).
For the next execution waves after that checklist, see [Release Candidate Plan](../Documentation/Generated/Release-Candidate-Plan.md).
For exact missing-device capture commands derived from the current readiness report, see [Device Evidence Plan](../Documentation/Generated/Device-Evidence-Plan.md).
For current device-class coverage across immutable release bundles, see [Device Coverage Matrix](../Documentation/Generated/Device-Coverage-Matrix.md).
For ready-to-send device-specific capture/import bundles, see [Device Capture Packets](../Documentation/Generated/Device-Capture-Packets.md).
For the maintainer step-by-step capture/import checklist, see [Device Evidence Runbook](../Documentation/Generated/Device-Evidence-Runbook.md).
For the maintainer intake summary and issue-ready handoff surface, see [Device Evidence Intake](../Documentation/Generated/Device-Evidence-Intake.md).
For the pending device wave queue, see [Device Evidence Queue](../Documentation/Generated/Device-Evidence-Queue.md).
For the single-archive operator export surface, see [Device Evidence Handoff](../Documentation/Generated/Device-Evidence-Handoff.md) and `Scripts/export-device-evidence-handoff.sh`.
For a one-command import of the full pending device wave once the archives exist, use `Scripts/complete-device-evidence-wave.sh`.
For the current release-proof blocker summary, see [Release Blockers](../Documentation/Generated/Release-Blockers.md).
For the current public claim/distribution envelope, see [Public Proof Status](../Documentation/Generated/Public-Proof-Status.md).
For public intake when a missing-device bundle needs maintainer action, use [Device Evidence Submission](../.github/ISSUE_TEMPLATE/device_evidence.yml).

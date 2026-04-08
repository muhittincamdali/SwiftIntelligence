# Release Process

This repository does not treat a version tag as enough evidence for a trustworthy release.

## Release Gate

Before pushing a release tag, run:

```bash
bash Scripts/prepare-release.sh
```

For a lighter-weight integrity pass that keeps benchmark proof, device-evidence, issue-form, release-asset, and public-claim surfaces aligned without rerunning build/test, use:

```bash
bash Scripts/validate-proof-surfaces.sh
```

This gate currently requires:

- `swift build -c release`
- `bash Scripts/validate-examples.sh`
- `swift test`
- `bash Scripts/validate-changelog.sh`
- `bash Scripts/validate-version-surface.sh`
- fresh benchmark artifacts in `Benchmarks/Results/latest`
- `bash Scripts/validate-benchmarks.sh standard Benchmarks/Results/latest`
- `bash Scripts/validate-transfer-chain.sh Benchmarks/Results/latest`
- `bash Scripts/validate-device-evidence.sh Benchmarks/Results Benchmarks/device-matrix-policy.json`
- `bash Scripts/validate-device-evidence-issue-schema.sh .github/ISSUE_TEMPLATE/device_evidence.yml Documentation/Generated/Device-Capture-Packets Documentation/Generated/Device-Coverage-Matrix.md Documentation/device-evidence-form-policy.json`
- `bash Scripts/validate-release-provenance.sh Benchmarks/Results`
- `bash Scripts/validate-release-evidence-assets.sh Benchmarks/Results`
- `bash Scripts/validate-release-workflow-assets.sh .github/workflows/release.yml Documentation/release-asset-policy.json`
- `bash Scripts/validate-benchmark-thresholds.sh Benchmarks/Results/latest Benchmarks/Results Benchmarks/benchmark-thresholds.json`

The tagged GitHub release workflow now regenerates the `standard` benchmark set before running this gate, so release assets are derived from the tagged commit rather than whatever happened to be in the repository checkout.

Required benchmark artifacts:

- `Benchmarks/Results/latest/benchmark-report.json`
- `Benchmarks/Results/latest/benchmark-summary.md`
- `Benchmarks/Results/latest/environment.json`
- `Benchmarks/Results/latest/device-metadata.json`

## Immutable Evidence Bundle

`latest/` is the working pointer, not the release record.

Before a tag is turned into a GitHub release, automation archives the validated artifact set into:

```text
Benchmarks/Results/releases/<tag-or-timestamp>
```

Each release evidence bundle contains:

- `benchmark-report.json`
- `benchmark-summary.md`
- `environment.json`
- `device-metadata.json`
- `metadata.json`
- `release-proof.md`
- `benchmark-delta.md`
- `release-notes-proof.md`
- `release-blockers.md`
- `public-proof-status.md`
- `public-proof-status.json`
- `flagship-demo-pack.md`
- `flagship-demo-share-pack.tar.gz`
- `intelligent-camera-success.png` when flagship media is published
- `intelligent-camera-run.mp4` when flagship media is published
- `caption.txt` when flagship media is published
- `device-evidence-handoff.md`
- `device-evidence-handoff.json`
- `device-evidence-handoff.tar.gz` when pending device waves still exist
- `release-body.md`
- `artifact-manifest.json`
- `checksums.txt`

Manual archive command:

```bash
bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3
```

If the benchmark run was captured outside this repo checkout, import it through:

```bash
bash Scripts/import-benchmark-evidence.sh /absolute/path/to/benchmark-export.tar.gz iphone-baseline-2026-04-02
```

That archive command now also emits `benchmark-delta.md`, `release-notes-proof.md`, `artifact-manifest.json`, and `checksums.txt` automatically.
It also preserves normalized device metadata so release evidence can be grouped by real device class instead of hostname-only guesses.

Tagged release automation also builds `release-body.md` from the matching `CHANGELOG.md` release section plus immutable proof artifacts.
That release body now starts with a short "Why This Release Matters" summary, a compact proof-link pack, and a flagship demo path block before the deeper evidence sections.
Release hydration also exports `flagship-demo-share-pack.tar.gz`, a small handoff bundle containing the flagship demo guide, source, showcase page, proof posture, and published flagship media when it exists.
When flagship media is published, the immutable release bundle also carries the top-level `intelligent-camera-success.png`, `intelligent-camera-run.mp4`, and `caption.txt` assets directly for GitHub release exposure.
Canonical repo-native media files, when they exist, must live under `Documentation/Assets/Flagship-Demo/` and pass `bash Scripts/validate-flagship-media-assets.sh`.
Release notes now also inherit the generated public-proof envelope so release messaging stays aligned with the current benchmark readiness posture.
If any required release device evidence is still missing, the archived release bundle also carries a transport-ready `device-evidence-handoff.tar.gz` package plus its generated markdown/JSON summary.
If an older immutable bundle predates this asset policy, backfill it with `bash Scripts/hydrate-release-evidence-assets.sh Benchmarks/Results/releases/<snapshot>`.
Workflow asset exposure is locked by `Documentation/release-asset-policy.json` and validated before release so GitHub release uploads cannot silently drift from the immutable bundle schema.

To derive a release-to-release benchmark delta note:

```bash
bash Scripts/generate-release-benchmark-delta.sh Benchmarks/Results/releases/v1.2.3
```

## Benchmark Refresh

If the artifacts are missing or stale:

```bash
bash Scripts/run-benchmarks.sh standard
```

That command now validates the generated artifacts automatically.
For device-class-specific evidence capture, prefer `bash Scripts/run-benchmarks-for-device.sh ...` so `device-metadata.json` stays normalized across iPhone, iPad, Mac, and visionOS runs.

To generate and archive immutable evidence in one pass:

```bash
bash Scripts/run-benchmarks.sh standard Benchmarks/Results/latest v1.2.3
```

Do not cut a release with missing benchmark evidence if the release notes or README make performance claims.
The release gate now also runs `Scripts/validate-public-claims.sh` against high-visibility docs whenever `Benchmark-Readiness.md` is not `ready`.
If a benchmark run is captured off-machine before import, package the validated artifact set with `Scripts/export-benchmark-evidence.sh` so the transfer payload stays deterministic.
For the exact missing-device handoff bundle, generate and use `Documentation/Generated/Device-Capture-Packets.md`.
For maintainer-facing issue intake after import, use `Documentation/Generated/Device-Evidence-Intake.md`.
For the current pending execution list, use `Documentation/Generated/Device-Evidence-Queue.md`.
For a single transport archive containing the whole missing-device operator surface, use `bash Scripts/export-device-evidence-handoff.sh /absolute/path/to/device-evidence-handoff.tar.gz` and the generated `Documentation/Generated/Device-Evidence-Handoff.md`.
When all pending-device archives are ready, use `bash Scripts/complete-device-evidence-wave.sh ...` to import the full queue and immediately rerun release validation.
For the current public claim envelope after each validation run, use `Documentation/Generated/Public-Proof-Status.md`.
Default packet issue payload values are centralized in `Documentation/device-evidence-form-policy.json`.

If an archived release evidence bundle already exists, the release gate also compares the new benchmark set against the latest immutable baseline and fails on threshold-breaking regressions.

## Tagging

Release tags are expected in the format:

```text
v1.2.3
```

Pre-release identifiers such as `alpha`, `beta`, or `rc` remain valid and are treated as prereleases by automation.

## Changelog Discipline

- summarize only real user-visible or maintainer-visible changes
- do not claim support for inactive products
- keep `Unreleased` current before tagging
- add a matching `## x.y.z - YYYY-MM-DD` section before pushing tag `vx.y.z`
- keep `README.md` and `README_TR.md` installation snippets aligned with the latest numbered release section

## Documentation

Documentation publishing uses:

```bash
bash Scripts/build-docs.sh
```

If DocC generation is unavailable in CI, the workflow falls back to a static index that points to the curated repository docs.

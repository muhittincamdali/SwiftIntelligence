# Device Evidence Runbook

Generated maintainer checklist for collecting or importing missing benchmark device evidence.

## Current Gap

- Missing required release device classes: ``
- Source plan: [Device-Evidence-Plan.md](Device-Evidence-Plan.md)
- Source matrix: [Device-Coverage-Matrix.md](Device-Coverage-Matrix.md)
- Public intake form: [../../.github/ISSUE_TEMPLATE/device_evidence.yml](../../.github/ISSUE_TEMPLATE/device_evidence.yml)

## Path A: Capture In This Repo

1. Connect the target Apple device and confirm the benchmark build can run there.
2. Use `Scripts/run-benchmarks-for-device.sh` with the normalized device metadata from the generated plan.
3. Regenerate docs with `bash Scripts/build-docs.sh`.
4. Run `bash Scripts/prepare-release.sh`.
5. Confirm `Device-Coverage-Matrix.md` and `Benchmark-Readiness.md` changed in the expected direction.
6. If the bundle still needs maintainer review, open the `Device Evidence Submission` issue and include the snapshot name plus device metadata.

## Path B: Import External Evidence

1. Export `benchmark-report.json`, `benchmark-summary.md`, and `environment.json` from the source machine, or package a validated artifact set with `Scripts/export-benchmark-evidence.sh`.
2. Import them with `Scripts/import-benchmark-evidence.sh` and normalized device metadata.
3. Regenerate docs with `bash Scripts/build-docs.sh`.
4. Run `bash Scripts/prepare-release.sh`.
5. Confirm the imported bundle appears in `Release-Benchmark-Matrix.md` and `Device-Coverage-Matrix.md`.
6. If review or follow-up hardware work is still needed, open the `Device Evidence Submission` issue and attach the archive path.

## Path C: Close The Full Pending Wave

When all pending archives are available, import them together:

```bash
bash Scripts/complete-device-evidence-wave.sh \
  --skip-prepare-release
```

Remove `--skip-prepare-release` to run the full release validation flow immediately after the final import.

## Capture Commands

No capture commands were found in the current device evidence plan.
## Import Template

Package a validated artifact set for transfer:

```bash
bash Scripts/export-benchmark-evidence.sh \
  Benchmarks/Results/latest \
  /absolute/path/to/benchmark-export.tar.gz
```

Or emit the export archive directly during device capture:

```bash
bash Scripts/run-benchmarks-for-device.sh \
  --profile standard \
  --output-dir Benchmarks/Results/device-run \
  --device-name "<device name>" \
  --device-model "<device model>" \
  --device-class <Mac|iPhone|iPad|visionOS|tvOS|watchOS> \
  --platform-family <macOS|iOS|iPadOS|visionOS|tvOS|watchOS> \
  --soc "<SoC label>" \
  --export-archive /absolute/path/to/benchmark-export.tar.gz
```

Then import the archive directly on the destination repo:

```bash
bash Scripts/import-benchmark-evidence.sh \
  --device-name "<device name>" \
  --device-model "<device model>" \
  --device-class <Mac|iPhone|iPad|visionOS|tvOS|watchOS> \
  --platform-family <macOS|iOS|iPadOS|visionOS|tvOS|watchOS> \
  --soc "<SoC label>" \
  /absolute/path/to/benchmark-export.tar.gz \
  <snapshot-name>
```

## Verification Checklist

- `bash Scripts/validate-benchmarks.sh <profile> <artifact-dir>` passes.
- `bash Scripts/validate-device-evidence.sh` passes.
- `Documentation/Generated/Device-Coverage-Matrix.md` shows the new device class.
- `Documentation/Generated/Benchmark-Readiness.md` moves toward `ready`.
- `bash Scripts/prepare-release.sh` passes without regressions.
- Any remaining maintainer action is tracked through the `Device Evidence Submission` issue form.

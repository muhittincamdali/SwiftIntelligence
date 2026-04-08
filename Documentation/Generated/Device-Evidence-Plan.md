# Device Evidence Plan

Generated from the current benchmark readiness report and device matrix policy.

## Current State

- Publish readiness: `ready`
- Device classes already covered: `Mac, iPhone`
- Minimum device classes required: `2`
- Required device classes: `Mac, iPhone`

## Matrix Rule

- Do not treat hostname-only artifacts as enough evidence.
- Every new device run should go through `Scripts/run-benchmarks-for-device.sh`.
- Archive every validated run into `Benchmarks/Results/releases/<snapshot>` so generated proof pages can count it.

## Status

- Required device classes from `device-matrix-policy.json` are already covered.
- Keep collecting release-grade runs only when hardware, OS, or workload methodology changes.
## Exit Condition

- `Benchmark-Readiness.md` reports `ready`.
- `device-matrix-policy.json` required classes all appear in generated readiness coverage.
- Release evidence is no longer Mac-only.
- `prepare-release.sh` still passes after docs regeneration.

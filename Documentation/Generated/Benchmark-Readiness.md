# Benchmark Readiness

Generated release-readiness and benchmark-publication checklist for the current artifact tree.

## Headline Status

- Publish readiness: `ready`
- Current pointer: `Benchmarks/Results/latest`
- Immutable release bundles: `3`
- Device classes seen: `Mac, iPhone`
- Device matrix policy: `Benchmarks/device-matrix-policy.json`

## Checklist

| Check | Status | Evidence |
| --- | --- | --- |
| Current benchmark artifacts exist | pass | Benchmarks/Results/latest |
| Artifact manifest + checksums exist | pass | manifest, checksums |
| Explicit device metadata exists | pass | device-metadata.json |
| Immutable release baseline exists | pass | Benchmarks/Results/releases/20260402T052611Z-initial-baseline |
| At least 2 device classes covered | pass | Mac, iPhone |
| Standard profile current run | pass | standard |
| Latest run has >= 25 workloads | pass | 25 |

## Current Environment Coverage

| Snapshot | Type | Device Class | Device Name | Device Model | Platform | OS | Profile | Workloads |
| --- | --- | --- | --- | --- | --- | --- | --- | ---: |
| `latest` | latest | Mac | `muhittin-macbook-pro-2.local` | `arm64` | `macOS` | `Version 26.4.1 (Build 25E253)` | `standard` | 25 |
| `20260402T052611Z-initial-baseline` | release | Mac | `Muhittin MacBook Pro (2)` | `arm64` | `macOS` | `Version 26.4 (Build 25E246)` | `standard` | 25 |
| `iphone-baseline-2026-04-07` | release | iPhone | `iPhone 15 Pro Max` | `iPhone16,2` | `iOS` | `Version 26.3.1 (a) (Build 23D771330a)` | `standard` | 25 |
| `v1.2.1` | release | Mac | `muhittin-macbook-pro-2.local` | `arm64` | `macOS` | `Version 26.4.1 (Build 25E253)` | `standard` | 25 |

## Threshold Policy

- Performance score drop limit: `10.0%`
- Average execution time increase limit: `15.0%`
- Total memory increase limit: `20.0%`
- Per-workload execution time increase limit: `25.0%`
- Per-workload peak memory increase limit: `30.0%`
- Max regressed workload count: `5`

## Next Gaps

- Current evidence set satisfies the repository's minimum publish checklist.

## Release Proof

- Release: `iphone-baseline-2026-04-07`
- Evidence bundle: `Benchmarks/Results/releases/iphone-baseline-2026-04-07`
- Git commit: `1b63ab3b42c35b002f8b4d4282a22c748d14008a`
- Benchmark profile: `standard`
- Benchmark run generated at: `2026-04-07T15:01:01Z`
- Evidence archived at: `2026-04-07T15:02:30Z`
- Performance score: `38.59`
- Average execution time: `0.0793s`
- Environment: `Version 26.3.1 (a) (Build 23D771330a)`, `6` processors

## Adoption Snapshot

- strongest first-run flow: `Vision -> NLP -> Privacy`
- flagship demo validation: `bash Scripts/validate-flagship-demo.sh`
- public proof envelope is carried in `public-proof-status.md` when bundled

## Validation Gate

- `swift build -c release`
- `bash Scripts/validate-flagship-demo.sh`
- `bash Scripts/validate-examples.sh`
- `swift test`
- `bash Scripts/run-benchmarks.sh standard Benchmarks/Results/latest`
- immutable benchmark evidence archived under `Benchmarks/Results/releases/iphone-baseline-2026-04-07`

## Attached Artifacts

- [benchmark-summary.md](benchmark-summary.md)
- [benchmark-report.json](benchmark-report.json)
- [environment.json](environment.json)
- [metadata.json](metadata.json)
- [release-proof.md](release-proof.md)
- [benchmark-delta.md](benchmark-delta.md)
- [release-blockers.md](release-blockers.md)
- [public-proof-status.md](public-proof-status.md)
- [device-evidence-handoff.md](device-evidence-handoff.md)

## Benchmark Evidence

- Evidence bundle: `Benchmarks/Results/releases/iphone-baseline-2026-04-07`
- Snapshot name: `iphone-baseline-2026-04-07`
- Git ref: `iphone-baseline-2026-04-07`
- Git commit: `1b63ab3b42c35b002f8b4d4282a22c748d14008a`
- Benchmark profile: `standard`
- Benchmark run generated at: `2026-04-07T15:01:01Z`
- Evidence archived at: `2026-04-07T15:02:30Z`
- Evidence source kind: `physical-device-test`
- Evidence source path: `com.muhittincamdali.swiftintelligence.benchmarkhost.iphone-q66w5bz37f@00008130-001464181110001C`
- Device class: `iPhone`
- Device name: `iPhone 15 Pro Max`
- Device model: `iPhone16,2`
- Platform family: `iOS`
- Total workloads: `25`
- Performance score: `38.59`
- Average execution time: `0.0793s`
- Environment: `Version 26.3.1 (a) (Build 23D771330a)`, `6` processors, `7.5 GB` RAM
- Fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Slowest workload: `ML_Model_Loading` (`0.3032s`)

Attached benchmark assets were copied from this immutable evidence bundle.

## Benchmark Delta

- Current evidence bundle: `Benchmarks/Results/releases/iphone-baseline-2026-04-07`
- Current git ref: `iphone-baseline-2026-04-07`
- Current generated at: `2026-04-07T15:01:01Z`

- Baseline evidence bundle: `Benchmarks/Results/releases/20260402T052611Z-initial-baseline`
- Baseline git ref: `20260402T052611Z-initial-baseline`
- Baseline generated at: `2026-04-02T01:14:14Z`

### Headline Deltas

| Metric | Current | Baseline | Delta |
| --- | ---: | ---: | ---: |
| Performance score | 38.59 | 56.47 | -31.67% |
| Average execution time (s) | 0.0793 | 0.0767 | +3.38% |
| Total memory (MB) | 1037.3 | 246.4 | +321.01% |
| Workloads | 25 | 25 | +0 |

### Top Improvements

- `Privacy_Data_Anonymization`: 0.0168s -> 0.0162s (-3.96%)
- `Privacy_Tokenization`: 0.0220s -> 0.0215s (-2.09%)
- `NLP_Text_Analysis_Small`: 0.0114s -> 0.0112s (-1.66%)
- `NLP_Entity_Recognition`: 0.0219s -> 0.0215s (-1.57%)
- `Network_Local_Request`: 0.0113s -> 0.0112s (-1.44%)

### Top Regressions

- `Cache_Read_Performance`: 0.0888s -> 0.1174s (+32.12%)
- `Cache_Write_Performance`: 0.0976s -> 0.1226s (+25.68%)
- `Privacy_Encryption`: 0.0107s -> 0.0112s (+4.46%)
- `ML_Prediction_Small`: 0.0059s -> 0.0061s (+3.92%)
- `Network_Batch_Processing`: 0.0593s -> 0.0616s (+3.90%)

### Evidence Links

- Current summary: [benchmark-summary.md](benchmark-summary.md)
- Baseline summary: [`Benchmarks/Results/releases/20260402T052611Z-initial-baseline/benchmark-summary.md`](../../Benchmarks/Results/releases/20260402T052611Z-initial-baseline/benchmark-summary.md)
- Baseline metadata: [`Benchmarks/Results/releases/20260402T052611Z-initial-baseline/metadata.json`](../../Benchmarks/Results/releases/20260402T052611Z-initial-baseline/metadata.json)

Interpretation rule: negative execution-time delta is better. Cross-device comparisons are directional only.

# Release Blockers

Generated summary of the blockers that still prevent release-grade public benchmark positioning.

## Headline

- Publish readiness: `ready`
- Immutable release bundles: `2`
- Device classes seen: `Mac, iPhone`
- Missing required release device classes: `none`

## What Is Not Blocking

- The active modular graph is building and testing cleanly.
- Benchmark artifacts, manifests, checksums, provenance, and threshold gates are in place.
- Transfer, import, and packetized handoff flows already exist.

## What Is Blocking

- No required release device classes are currently missing.
- Remaining work is release hygiene, optional extra device breadth, and positioning quality.

## Immediate Execution Surface

- Capture packets: [Device-Capture-Packets.md](Device-Capture-Packets.md)
- Maintainer intake: [Device-Evidence-Intake.md](Device-Evidence-Intake.md)
- Operational runbook: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)

## Exit Condition

- `Benchmark-Readiness.md` reports `ready`.
- `Device-Coverage-Matrix.md` includes all required release device classes from `device-matrix-policy.json`.
- `prepare-release.sh` still passes after the new bundles are archived.

# Public Proof Status

Generated claim envelope for distribution, README language, release messaging, and public positioning.

## Status

- Publish readiness: `ready`
- Distribution posture: `release-grade`
- Immutable release bundles: `2`
- Device classes seen: `Mac, iPhone`
- Missing required device classes: `none`
- Flagship media status: `published`
- Machine-readable payload: [public-proof-status.json](public-proof-status.json)

## Why Adopt Now

- strongest proof path: `Vision -> NLP -> Privacy`
- first demo guide: [../../Examples/DemoApps/IntelligentCamera/README.md](../../Examples/DemoApps/IntelligentCamera/README.md)
- first immutable release proof: [Latest-Release-Proof.md](Latest-Release-Proof.md)
- flagship media truth surface: [Flagship-Media-Status.md](Flagship-Media-Status.md)

## Allowed Public Claims

- The active modular graph builds and tests cleanly.
- The flagship demo path has a dedicated guide and smoke-check.
- Benchmark artifacts, manifests, checksums, provenance, and threshold gates exist.
- A first immutable release baseline exists.
- Device capture, export, import, packet, and intake flows are implemented.

## Blocked Public Claims

- none

# Device Evidence Handoff

Generated export surface for the missing device evidence waves that still block release-grade benchmark positioning.

## Status

- Publish readiness: `ready`
- Distribution posture: `release-grade`
- Pending device classes: `none`
- Queue source: [Device-Evidence-Queue.md](Device-Evidence-Queue.md)
- Intake source: [Device-Evidence-Intake.md](Device-Evidence-Intake.md)
- Runbook source: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)
- Machine-readable payload: [device-evidence-handoff.json](device-evidence-handoff.json)

## Export Command

```bash
bash Scripts/export-device-evidence-handoff.sh /absolute/path/to/device-evidence-handoff.tar.gz
```

## Included Surfaces

- queue summary and JSON payload
- intake summary and maintainer runbook
- packet index and per-device packet folders
- release blockers and public proof envelope
- GitHub `device_evidence` issue form

## State

- No pending device evidence waves remain.


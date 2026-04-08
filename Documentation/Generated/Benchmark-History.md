# Benchmark History

Generated from the current benchmark artifact tree.

## Current Pointer

- Active pointer: `Benchmarks/Results/latest`
- Generated at: `2026-04-02T02:43:10Z`
- Profile: `standard`
- Performance score: `55.28`
- Average execution time: `0.0791s`

## Snapshot Index

| Snapshot | Type | Git Ref | Commit | Generated | Archived | Provenance | Score | Avg (s) | Workloads | Source |
| --- | --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | --- |
| `iphone-baseline-2026-04-07` | release | `iphone-baseline-2026-04-07` | `1b63ab3b42c3` | `2026-04-07T15:01:01Z` | `2026-04-07T15:02:30Z` | `physical-device-test` | 38.59 | 0.0793 | 25 | [summary](../../Benchmarks/Results/releases/iphone-baseline-2026-04-07/benchmark-summary.md) |
| `latest` | latest | `latest` | `n/a` | `2026-04-02T02:43:10Z` | `n/a` | `local-directory` | 55.28 | 0.0791 | 25 | [summary](../../Benchmarks/Results/latest/benchmark-summary.md) |
| `20260402T052611Z-initial-baseline` | release | `20260402T052611Z-initial-baseline` | `1b63ab3b42c3` | `2026-04-02T01:14:14Z` | `2026-04-02T02:30:23Z` | `local-directory` | 56.47 | 0.0767 | 25 | [summary](../../Benchmarks/Results/releases/20260402T052611Z-initial-baseline/benchmark-summary.md) |

## Environment Matrix

| Snapshot | Device Class | Device Name | Device Model | Platform | OS | Provenance | CPU Cores | RAM (GB) | Profile |
| --- | --- | --- | --- | --- | --- | --- | ---: | ---: | --- |
| `iphone-baseline-2026-04-07` | iPhone | `iPhone 15 Pro Max` | `iPhone16,2` | `iOS` | `Version 26.3.1 (a) (Build 23D771330a)` | `physical-device-test` | 6 | 7.5 | `standard` |
| `latest` | Mac | `Muhittin MacBook Pro (2)` | `arm64` | `macOS` | `Version 26.4 (Build 25E246)` | `local-directory` | 18 | 48.0 | `standard` |
| `20260402T052611Z-initial-baseline` | Mac | `Muhittin MacBook Pro (2)` | `arm64` | `macOS` | `Version 26.4 (Build 25E246)` | `local-directory` | 18 | 48.0 | `standard` |

## Evidence Notes

- `latest` is a moving pointer and should not be treated as immutable release evidence.
- `releases/<tag-or-timestamp>` is the immutable evidence path for tagged releases.
- Public benchmark claims should prefer archived release bundles over ad-hoc local runs.

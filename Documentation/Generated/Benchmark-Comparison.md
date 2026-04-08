# Benchmark Comparison

This page compares the current `latest` pointer against the most recent immutable release evidence bundle.

## Compared Snapshots

- Current pointer: `Benchmarks/Results/latest`
- Baseline release evidence: `Benchmarks/Results/releases/iphone-baseline-2026-04-07`
- Baseline git ref: `iphone-baseline-2026-04-07`

## Headline Deltas

| Metric | Latest | Baseline | Delta |
| --- | ---: | ---: | ---: |
| Performance score | 55.28 | 38.59 | +43.27% |
| Average execution time (s) | 0.0791 | 0.0793 | -0.26% |
| Total memory (MB) | 246.0 | 1037.3 | -76.28% |
| Workloads | 25 | 25 | +0 |

## Workload Extremes

- Latest fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Baseline fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Latest slowest workload: `ML_Model_Loading` (`0.3111s`)
- Baseline slowest workload: `ML_Model_Loading` (`0.3032s`)

## Evidence Links

- Latest summary: [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- Baseline summary: [benchmark-summary.md](../../Benchmarks/Results/releases/iphone-baseline-2026-04-07/benchmark-summary.md)
- Baseline metadata: [metadata.json](../../Benchmarks/Results/releases/iphone-baseline-2026-04-07/metadata.json)

Interpretation rule: positive score delta is better, negative average-time delta is better, and any comparison across different hardware should be treated as directional rather than definitive.

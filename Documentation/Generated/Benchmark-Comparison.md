# Benchmark Comparison

This page compares the current `latest` pointer against the most recent immutable release evidence bundle.

## Compared Snapshots

- Current pointer: `Benchmarks/Results/latest`
- Baseline release evidence: `Benchmarks/Results/releases/v1.2.1`
- Baseline git ref: `v1.2.1`

## Headline Deltas

| Metric | Latest | Baseline | Delta |
| --- | ---: | ---: | ---: |
| Performance score | 55.55 | 55.55 | +0.00% |
| Average execution time (s) | 0.0785 | 0.0785 | +0.00% |
| Total memory (MB) | 246.9 | 246.9 | +0.00% |
| Workloads | 25 | 25 | +0 |

## Workload Extremes

- Latest fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Baseline fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Latest slowest workload: `ML_Model_Loading` (`0.3084s`)
- Baseline slowest workload: `ML_Model_Loading` (`0.3084s`)

## Evidence Links

- Latest summary: [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- Baseline summary: [benchmark-summary.md](../../Benchmarks/Results/releases/v1.2.1/benchmark-summary.md)
- Baseline metadata: [metadata.json](../../Benchmarks/Results/releases/v1.2.1/metadata.json)

Interpretation rule: positive score delta is better, negative average-time delta is better, and any comparison across different hardware should be treated as directional rather than definitive.

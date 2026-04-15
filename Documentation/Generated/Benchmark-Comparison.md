# Benchmark Comparison

This page compares the current `latest` pointer against the most recent immutable release evidence bundle.

## Compared Snapshots

- Current pointer: `Benchmarks/Results/latest`
- Baseline release evidence: `Benchmarks/Results/releases/v1.2.2`
- Baseline git ref: `v1.2.2`

## Headline Deltas

| Metric | Latest | Baseline | Delta |
| --- | ---: | ---: | ---: |
| Performance score | 55.51 | 55.51 | +0.00% |
| Average execution time (s) | 0.0786 | 0.0786 | +0.00% |
| Total memory (MB) | 247.8 | 247.8 | +0.00% |
| Workloads | 25 | 25 | +0 |

## Workload Extremes

- Latest fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Baseline fastest workload: `ML_Prediction_Small` (`0.0061s`)
- Latest slowest workload: `ML_Model_Loading` (`0.3076s`)
- Baseline slowest workload: `ML_Model_Loading` (`0.3076s`)

## Evidence Links

- Latest summary: [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- Baseline summary: [benchmark-summary.md](../../Benchmarks/Results/releases/v1.2.2/benchmark-summary.md)
- Baseline metadata: [metadata.json](../../Benchmarks/Results/releases/v1.2.2/metadata.json)

Interpretation rule: positive score delta is better, negative average-time delta is better, and any comparison across different hardware should be treated as directional rather than definitive.

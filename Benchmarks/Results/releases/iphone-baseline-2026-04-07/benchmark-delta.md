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

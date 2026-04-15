## Benchmark Delta

- Current evidence bundle: `Benchmarks/Results/releases/v1.2.1`
- Current git ref: `v1.2.1`
- Current generated at: `2026-04-15T13:00:40Z`

- Baseline evidence bundle: `Benchmarks/Results/releases/iphone-baseline-2026-04-07`
- Baseline git ref: `iphone-baseline-2026-04-07`
- Baseline generated at: `2026-04-07T15:01:01Z`

### Headline Deltas

| Metric | Current | Baseline | Delta |
| --- | ---: | ---: | ---: |
| Performance score | 55.55 | 38.59 | +43.97% |
| Average execution time (s) | 0.0785 | 0.0793 | -0.99% |
| Total memory (MB) | 246.9 | 1037.3 | -76.20% |
| Workloads | 25 | 25 | +0 |

### Top Improvements

- `Cache_Write_Performance`: 0.1226s -> 0.0996s (-18.81%)
- `Cache_Read_Performance`: 0.1174s -> 0.0956s (-18.56%)
- `Vision_Object_Detection`: 0.1581s -> 0.1554s (-1.68%)
- `Integration_Concurrent_Processing`: 0.0637s -> 0.0628s (-1.33%)
- `Integration_Multi_Modal`: 0.2384s -> 0.2355s (-1.18%)

### Top Regressions

- `NLP_Entity_Recognition`: 0.0215s -> 0.0237s (+10.03%)
- `NLP_Text_Analysis_Small`: 0.0112s -> 0.0122s (+8.16%)
- `Network_Local_Request`: 0.0112s -> 0.0120s (+7.76%)
- `Privacy_Tokenization`: 0.0215s -> 0.0231s (+7.52%)
- `Speech_Synthesis_Short`: 0.0269s -> 0.0289s (+7.48%)

### Evidence Links

- Current summary: [benchmark-summary.md](benchmark-summary.md)
- Baseline summary: [`Benchmarks/Results/releases/iphone-baseline-2026-04-07/benchmark-summary.md`](../../Benchmarks/Results/releases/iphone-baseline-2026-04-07/benchmark-summary.md)
- Baseline metadata: [`Benchmarks/Results/releases/iphone-baseline-2026-04-07/metadata.json`](../../Benchmarks/Results/releases/iphone-baseline-2026-04-07/metadata.json)

Interpretation rule: negative execution-time delta is better. Cross-device comparisons are directional only.

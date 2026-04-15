## Benchmark Delta

- Current evidence bundle: `Benchmarks/Results/releases/v1.2.2`
- Current git ref: `v1.2.2`
- Current generated at: `2026-04-15T13:26:36Z`

- Baseline evidence bundle: `Benchmarks/Results/releases/v1.2.1`
- Baseline git ref: `v1.2.1`
- Baseline generated at: `2026-04-15T13:00:40Z`

### Headline Deltas

| Metric | Current | Baseline | Delta |
| --- | ---: | ---: | ---: |
| Performance score | 55.51 | 55.55 | -0.08% |
| Average execution time (s) | 0.0786 | 0.0785 | +0.07% |
| Total memory (MB) | 247.8 | 246.9 | +0.35% |
| Workloads | 25 | 25 | +0 |

### Top Improvements

- `NLP_Sentiment_Analysis`: 0.0315s -> 0.0303s (-4.03%)
- `NLP_Entity_Recognition`: 0.0237s -> 0.0230s (-2.94%)
- `Vision_Face_Detection`: 0.0337s -> 0.0329s (-2.39%)
- `NLP_Text_Analysis_Small`: 0.0122s -> 0.0119s (-2.36%)
- `Vision_Image_Classification`: 0.0536s -> 0.0529s (-1.40%)

### Top Regressions

- `Cache_Read_Performance`: 0.0956s -> 0.1003s (+4.95%)
- `Cache_Write_Performance`: 0.0996s -> 0.1044s (+4.82%)
- `Privacy_Data_Anonymization`: 0.0172s -> 0.0178s (+3.67%)
- `Privacy_Tokenization`: 0.0231s -> 0.0239s (+3.47%)
- `Cache_Eviction_Test`: 0.0333s -> 0.0340s (+1.86%)

### Evidence Links

- Current summary: [benchmark-summary.md](benchmark-summary.md)
- Baseline summary: [`Benchmarks/Results/releases/v1.2.1/benchmark-summary.md`](../../Benchmarks/Results/releases/v1.2.1/benchmark-summary.md)
- Baseline metadata: [`Benchmarks/Results/releases/v1.2.1/metadata.json`](../../Benchmarks/Results/releases/v1.2.1/metadata.json)

Interpretation rule: negative execution-time delta is better. Cross-device comparisons are directional only.

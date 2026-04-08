# SwiftIntelligence Benchmark Summary

- Generated at: 2026-04-02T01:14:14Z
- Profile: `standard`
- Framework version: `1.0.0`
- Total workloads: `25`
- Performance score: `56.47`
- Average execution time: `0.0767s`

## Top Insights

- Slowest operation: ML_Model_Loading (0.3056s)
- Fastest operation: ML_Prediction_Small (0.0059s)
- Most memory intensive: Integration_Concurrent_Processing (10,1 MB)
- Performance distribution: 1 excellent, 17 good, 7 average, 0 slow

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Fastest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Prediction_Small | 0.0059 | 9,9 MB |
| Privacy_Encryption | 0.0107 | 9,9 MB |
| Network_Local_Request | 0.0113 | 10 MB |
| NLP_Text_Analysis_Small | 0.0114 | 9,5 MB |
| Privacy_Data_Anonymization | 0.0168 | 9,9 MB |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3056 | 9,9 MB |
| Integration_Multi_Modal | 0.2317 | 10 MB |
| Speech_Synthesis_Long | 0.2029 | 9,8 MB |
| Vision_Object_Detection | 0.1561 | 9,8 MB |
| NLP_Text_Analysis_Large | 0.1029 | 9,6 MB |

## Artifact Contract

- `benchmark-report.json`: machine-readable benchmark data
- `benchmark-summary.md`: human-readable summary
- `environment.json`: runtime metadata for reproducibility
- `device-metadata.json`: normalized device identity for coverage and release proof

Re-run with:

```bash
swift run -c release Benchmarks --profile standard --output-dir "/Users/muhittincamdali/Desktop/Claude Projects/GitHub/SwiftIntelligence/Benchmarks/Results/latest"
```

# SwiftIntelligence Benchmark Summary

- Generated at: 2026-04-08T18:03:48Z
- Profile: `standard`
- Framework version: `1.2.0`
- Total workloads: `25`
- Performance score: `56.50`
- Average execution time: `0.0766s`

## Top Insights

- Slowest operation: ML_Model_Loading (0.3051s)
- Fastest operation: ML_Prediction_Small (0.0059s)
- Most memory intensive: Integration_Concurrent_Processing (10,1 MB)
- Performance distribution: 1 excellent, 17 good, 7 average, 0 slow

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Fastest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Prediction_Small | 0.0059 | 10 MB |
| Network_Local_Request | 0.0113 | 10,1 MB |
| NLP_Text_Analysis_Small | 0.0114 | 9,6 MB |
| Privacy_Encryption | 0.0119 | 10 MB |
| Privacy_Data_Anonymization | 0.0166 | 10 MB |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3051 | 10 MB |
| Integration_Multi_Modal | 0.2315 | 10,1 MB |
| Speech_Synthesis_Long | 0.2026 | 9,9 MB |
| Vision_Object_Detection | 0.1525 | 9,9 MB |
| ML_Training_Micro | 0.1026 | 10 MB |

## Artifact Contract

- `benchmark-report.json`: machine-readable benchmark data
- `benchmark-summary.md`: human-readable summary
- `environment.json`: runtime metadata for reproducibility
- `device-metadata.json`: normalized device identity for coverage and release proof

# SwiftIntelligence Benchmark Summary

- Generated at: 2026-04-15T13:00:40Z
- Profile: `standard`
- Framework version: `1.2.1`
- Total workloads: `25`
- Performance score: `55.55`
- Average execution time: `0.0785s`

## Top Insights

- Slowest operation: ML_Model_Loading (0.3084s)
- Fastest operation: ML_Prediction_Small (0.0061s)
- Most memory intensive: Integration_Concurrent_Processing (10,1 MB)
- Performance distribution: 1 excellent, 17 good, 7 average, 0 slow

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Fastest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Prediction_Small | 0.0061 | 9,9 MB |
| Privacy_Encryption | 0.0117 | 9,9 MB |
| Network_Local_Request | 0.0120 | 10 MB |
| NLP_Text_Analysis_Small | 0.0122 | 9,5 MB |
| Privacy_Data_Anonymization | 0.0172 | 9,9 MB |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3084 | 9,9 MB |
| Integration_Multi_Modal | 0.2355 | 10 MB |
| Speech_Synthesis_Long | 0.2068 | 9,9 MB |
| Vision_Object_Detection | 0.1554 | 9,8 MB |
| Speech_Recognition_Test | 0.1049 | 9,9 MB |

## Artifact Contract

- `benchmark-report.json`: machine-readable benchmark data
- `benchmark-summary.md`: human-readable summary
- `environment.json`: runtime metadata for reproducibility
- `device-metadata.json`: normalized device identity for coverage and release proof

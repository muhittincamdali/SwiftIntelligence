# SwiftIntelligence Benchmark Summary

- Generated at: 2026-04-07T15:01:01Z
- Profile: `standard`
- Framework version: `1.0.0`
- Total workloads: `25`
- Performance score: `38.59`
- Average execution time: `0.0793s`

## Top Insights

- Slowest operation: ML_Model_Loading (0.3032s)
- Fastest operation: ML_Prediction_Small (0.0061s)
- Most memory intensive: NLP_Text_Analysis_Large (41,7 MB)
- Performance distribution: 1 excellent, 15 good, 9 average, 0 slow

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Fastest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Prediction_Small | 0.0061 | 41,5 MB |
| Network_Local_Request | 0.0112 | 41,5 MB |
| Privacy_Encryption | 0.0112 | 41,5 MB |
| NLP_Text_Analysis_Small | 0.0112 | 41,7 MB |
| Privacy_Data_Anonymization | 0.0162 | 41,5 MB |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3032 | 41,5 MB |
| Integration_Multi_Modal | 0.2384 | 41,5 MB |
| Speech_Synthesis_Long | 0.2024 | 41,4 MB |
| Vision_Object_Detection | 0.1581 | 41,4 MB |
| Cache_Write_Performance | 0.1226 | 41,5 MB |

## Artifact Contract

- `benchmark-report.json`: machine-readable benchmark data
- `benchmark-summary.md`: human-readable summary
- `environment.json`: runtime metadata for reproducibility
- `device-metadata.json`: normalized device identity for coverage and release proof

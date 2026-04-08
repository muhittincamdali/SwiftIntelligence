# Benchmark Methodology

Generated from the current benchmark artifacts and benchmark runner config.

## Current Run

- Generated at: `2026-04-08T18:03:48Z`
- Profile: `standard`
- Framework version: `1.2.0`
- Total workloads: `25`
- Average execution time: `0.0766s`
- Aggregate measured memory: `248.7 MB`

## Environment

- Device class: `Mac`
- Device name: `muhittin-macbook-pro-2.local`
- Device model: `arm64`
- Platform: `macOS`
- Operating system: `Version 26.4 (Build 25E246)`
- Processor count: `18`
- Physical memory: `48.0 GB`

## Config Presets In Use

| Preset | Workloads | Iterations | Warmup | Interval (s) | CPU | Memory | Battery |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| `default` | 21 | 100 | 10 | 0.10 | true | true | true |
| `quick` | 4 | 10 | 2 | 0.05 | false | true | false |

## Workload Coverage

| Workload | Preset | Avg (s) | Peak Memory (MB) |
| --- | --- | ---: | ---: |
| `Cache_Eviction_Test` | `default` | 0.0322 | 10.1 |
| `Cache_Read_Performance` | `default` | 0.0906 | 10.0 |
| `Cache_Write_Performance` | `default` | 0.0944 | 10.0 |
| `Integration_Concurrent_Processing` | `default` | 0.0620 | 10.1 |
| `Integration_Multi_Modal` | `default` | 0.2315 | 10.1 |
| `ML_Model_Loading` | `default` | 0.3051 | 10.0 |
| `ML_Prediction_Large` | `default` | 0.0522 | 10.0 |
| `ML_Prediction_Small` | `default` | 0.0059 | 10.0 |
| `ML_Training_Micro` | `default` | 0.1026 | 10.0 |
| `NLP_Entity_Recognition` | `default` | 0.0218 | 9.8 |
| `NLP_Sentiment_Analysis` | `quick` | 0.0298 | 9.8 |
| `NLP_Text_Analysis_Large` | `default` | 0.1020 | 9.8 |
| `NLP_Text_Analysis_Small` | `default` | 0.0114 | 9.6 |
| `Network_Batch_Processing` | `default` | 0.0590 | 10.1 |
| `Network_Local_Request` | `default` | 0.0113 | 10.1 |
| `Privacy_Data_Anonymization` | `default` | 0.0166 | 10.0 |
| `Privacy_Encryption` | `quick` | 0.0119 | 10.0 |
| `Privacy_Tokenization` | `default` | 0.0221 | 10.0 |
| `Speech_Recognition_Test` | `default` | 0.1019 | 9.9 |
| `Speech_Synthesis_Long` | `default` | 0.2026 | 9.9 |
| `Speech_Synthesis_Short` | `quick` | 0.0267 | 9.9 |
| `Vision_Face_Detection` | `quick` | 0.0331 | 9.9 |
| `Vision_Image_Classification` | `default` | 0.0531 | 9.8 |
| `Vision_Object_Detection` | `default` | 0.1525 | 9.9 |
| `Vision_Text_Recognition` | `default` | 0.0819 | 9.9 |

## Methodology Rules

- `latest` is a moving pointer for the current validated benchmark run.
- immutable release evidence should come from `Benchmarks/Results/releases/<tag-or-timestamp>`.
- competitor comparisons are only valid when workload shape and hardware class are comparable.
- profile changes change methodology; compare like-for-like profiles only.

## Source Artifacts

- [benchmark-report.json](../../Benchmarks/Results/latest/benchmark-report.json)
- [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- [environment.json](../../Benchmarks/Results/latest/environment.json)
- [device-metadata.json](../../Benchmarks/Results/latest/device-metadata.json)
- [Benchmark History](Benchmark-History.md)
- [Benchmark Comparison](Benchmark-Comparison.md)

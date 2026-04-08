# Benchmark Methodology

Generated from the current benchmark artifacts and benchmark runner config.

## Current Run

- Generated at: `2026-04-02T02:43:10Z`
- Profile: `standard`
- Framework version: `1.0.0`
- Total workloads: `25`
- Average execution time: `0.0791s`
- Aggregate measured memory: `246.0 MB`

## Environment

- Device class: `Mac`
- Device name: `Muhittin MacBook Pro (2)`
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
| `Cache_Eviction_Test` | `default` | 0.0334 | 10.0 |
| `Cache_Read_Performance` | `default` | 0.1014 | 9.9 |
| `Cache_Write_Performance` | `default` | 0.1048 | 9.9 |
| `Integration_Concurrent_Processing` | `default` | 0.0632 | 10.1 |
| `Integration_Multi_Modal` | `default` | 0.2365 | 10.0 |
| `ML_Model_Loading` | `default` | 0.3111 | 9.9 |
| `ML_Prediction_Large` | `default` | 0.0531 | 9.9 |
| `ML_Prediction_Small` | `default` | 0.0061 | 9.9 |
| `ML_Training_Micro` | `default` | 0.1045 | 9.9 |
| `NLP_Entity_Recognition` | `default` | 0.0235 | 9.7 |
| `NLP_Sentiment_Analysis` | `quick` | 0.0306 | 9.6 |
| `NLP_Text_Analysis_Large` | `default` | 0.1040 | 9.6 |
| `NLP_Text_Analysis_Small` | `default` | 0.0120 | 9.5 |
| `Network_Batch_Processing` | `default` | 0.0614 | 10.0 |
| `Network_Local_Request` | `default` | 0.0120 | 10.0 |
| `Privacy_Data_Anonymization` | `default` | 0.0177 | 9.9 |
| `Privacy_Encryption` | `quick` | 0.0120 | 9.9 |
| `Privacy_Tokenization` | `default` | 0.0238 | 9.9 |
| `Speech_Recognition_Test` | `default` | 0.1047 | 9.8 |
| `Speech_Synthesis_Long` | `default` | 0.2073 | 9.8 |
| `Speech_Synthesis_Short` | `quick` | 0.0287 | 9.8 |
| `Vision_Face_Detection` | `quick` | 0.0327 | 9.8 |
| `Vision_Image_Classification` | `default` | 0.0533 | 9.7 |
| `Vision_Object_Detection` | `default` | 0.1565 | 9.7 |
| `Vision_Text_Recognition` | `default` | 0.0835 | 9.8 |

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

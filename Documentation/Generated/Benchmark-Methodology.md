# Benchmark Methodology

Generated from the current benchmark artifacts and benchmark runner config.

## Current Run

- Generated at: `2026-04-15T13:00:40Z`
- Profile: `standard`
- Framework version: `1.2.1`
- Total workloads: `25`
- Average execution time: `0.0785s`
- Aggregate measured memory: `246.9 MB`

## Environment

- Device class: `Mac`
- Device name: `muhittin-macbook-pro-2.local`
- Device model: `arm64`
- Platform: `macOS`
- Operating system: `Version 26.4.1 (Build 25E253)`
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
| `Cache_Eviction_Test` | `default` | 0.0333 | 10.0 |
| `Cache_Read_Performance` | `default` | 0.0956 | 10.0 |
| `Cache_Write_Performance` | `default` | 0.0996 | 10.0 |
| `Integration_Concurrent_Processing` | `default` | 0.0628 | 10.1 |
| `Integration_Multi_Modal` | `default` | 0.2355 | 10.0 |
| `ML_Model_Loading` | `default` | 0.3084 | 9.9 |
| `ML_Prediction_Large` | `default` | 0.0537 | 9.9 |
| `ML_Prediction_Small` | `default` | 0.0061 | 9.9 |
| `ML_Training_Micro` | `default` | 0.1040 | 9.9 |
| `NLP_Entity_Recognition` | `default` | 0.0237 | 9.7 |
| `NLP_Sentiment_Analysis` | `quick` | 0.0315 | 9.7 |
| `NLP_Text_Analysis_Large` | `default` | 0.1047 | 9.6 |
| `NLP_Text_Analysis_Small` | `default` | 0.0122 | 9.5 |
| `Network_Batch_Processing` | `default` | 0.0612 | 10.0 |
| `Network_Local_Request` | `default` | 0.0120 | 10.0 |
| `Privacy_Data_Anonymization` | `default` | 0.0172 | 9.9 |
| `Privacy_Encryption` | `quick` | 0.0117 | 9.9 |
| `Privacy_Tokenization` | `default` | 0.0231 | 10.0 |
| `Speech_Recognition_Test` | `default` | 0.1049 | 9.9 |
| `Speech_Synthesis_Long` | `default` | 0.2068 | 9.9 |
| `Speech_Synthesis_Short` | `quick` | 0.0289 | 9.9 |
| `Vision_Face_Detection` | `quick` | 0.0337 | 9.8 |
| `Vision_Image_Classification` | `default` | 0.0536 | 9.7 |
| `Vision_Object_Detection` | `default` | 0.1554 | 9.8 |
| `Vision_Text_Recognition` | `default` | 0.0837 | 9.8 |

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

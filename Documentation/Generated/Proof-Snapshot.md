# Proof Snapshot

Generated from the current benchmark artifacts and maintained showcase flows.

- Generated at: 2026-04-15T13:26:36Z
- Benchmark profile: `standard`
- Framework version: `1.2.2`
- Total workloads: `25`
- Performance score: `55.51`
- Average execution time: `0.0786s`
- Operating system: `Version 26.4.1 (Build 25E253)`
- Processor count: `18`
- Physical memory: `48.0 GB`

## Flagship Flows

- `Intelligent Camera`: `Vision -> NLP -> Privacy` via [`IntelligentCameraApp.swift`](../../Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift) and [demo guide](../../Examples/DemoApps/IntelligentCamera/README.md)
- `Smart Translator`: `NLP -> Privacy -> Speech` via [`SmartTranslatorApp.swift`](../../Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift)
- `Voice Assistant`: `NLP -> Privacy -> Speech` via [`VoiceAssistantApp.swift`](../../Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift)

## Flagship Validation

- `bash Scripts/validate-flagship-demo.sh`
- `bash Scripts/validate-examples.sh`
- [Flagship Demo Pack](Flagship-Demo-Pack.md)

## Fastest Workloads

| Workload | Avg (s) | Peak Memory (MB) |
| --- | ---: | ---: |
| ML_Prediction_Small | 0.0061 | 9.9 |
| Privacy_Encryption | 0.0118 | 10.0 |
| NLP_Text_Analysis_Small | 0.0119 | 9.6 |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory (MB) |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3076 | 9.9 |
| Integration_Multi_Modal | 0.2358 | 10.1 |
| Speech_Synthesis_Long | 0.2047 | 9.9 |

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Source Artifacts

- [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- [benchmark-report.json](../../Benchmarks/Results/latest/benchmark-report.json)
- [environment.json](../../Benchmarks/Results/latest/environment.json)
- [Showcase](../Showcase.md)

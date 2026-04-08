# Proof Snapshot

Generated from the current benchmark artifacts and maintained showcase flows.

- Generated at: 2026-04-08T18:03:48Z
- Benchmark profile: `standard`
- Framework version: `1.2.0`
- Total workloads: `25`
- Performance score: `56.50`
- Average execution time: `0.0766s`
- Operating system: `Version 26.4 (Build 25E246)`
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
| ML_Prediction_Small | 0.0059 | 10.0 |
| Network_Local_Request | 0.0113 | 10.1 |
| NLP_Text_Analysis_Small | 0.0114 | 9.6 |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory (MB) |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3051 | 10.0 |
| Integration_Multi_Modal | 0.2315 | 10.1 |
| Speech_Synthesis_Long | 0.2026 | 9.9 |

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Source Artifacts

- [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- [benchmark-report.json](../../Benchmarks/Results/latest/benchmark-report.json)
- [environment.json](../../Benchmarks/Results/latest/environment.json)
- [Showcase](../Showcase.md)

# Proof Snapshot

Generated from the current benchmark artifacts and maintained showcase flows.

- Generated at: 2026-04-02T02:43:10Z
- Benchmark profile: `standard`
- Framework version: `1.0.0`
- Total workloads: `25`
- Performance score: `55.28`
- Average execution time: `0.0791s`
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
| ML_Prediction_Small | 0.0061 | 9.9 |
| Privacy_Encryption | 0.0120 | 9.9 |
| Network_Local_Request | 0.0120 | 10.0 |

## Slowest Workloads

| Workload | Avg (s) | Peak Memory (MB) |
| --- | ---: | ---: |
| ML_Model_Loading | 0.3111 | 9.9 |
| Integration_Multi_Modal | 0.2365 | 10.0 |
| Speech_Synthesis_Long | 0.2073 | 9.8 |

## Recommendations

- Consider optimizing slow operations: Speech_Synthesis_Long, ML_Model_Loading, Integration_Multi_Modal

## Source Artifacts

- [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)
- [benchmark-report.json](../../Benchmarks/Results/latest/benchmark-report.json)
- [environment.json](../../Benchmarks/Results/latest/environment.json)
- [Showcase](../Showcase.md)

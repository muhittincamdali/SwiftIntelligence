# Examples Status

## Current Examples

- [BasicUsage.swift](BasicUsage.swift)
- [AdvancedFeatures.swift](AdvancedFeatures.swift)
- `DemoApps/VoiceAssistant/VoiceAssistantApp.swift`
- `DemoApps/IntelligentCamera/IntelligentCameraApp.swift`
- `DemoApps/SmartTranslator/SmartTranslatorApp.swift`
- `DemoApps/PersonalAITutor/PersonalAITutorApp.swift`
- `DemoApps/ARCreativeStudio/ARCreativeStudioApp.swift`
- `ServerIntegration/AIServiceClient.swift`

These files are aligned with the active modular package graph.

## Flagship Demo Paths

- `IntelligentCamera`: `Vision -> NLP -> Privacy`
- `SmartTranslator`: `NLP -> Privacy -> Speech`
- `VoiceAssistant`: `NLP -> Privacy -> Speech`

## Recommended First Demo

If you only run one demo first, use:

- [Demo guide](DemoApps/IntelligentCamera/README.md)
- `DemoApps/IntelligentCamera/IntelligentCameraApp.swift`

Reason:

- strongest multi-module maintained flow
- aligned with the current showcase story
- best first proof of package-level composition instead of single-feature wrapping

The current proof narrative for these flows lives in [Documentation/Showcase.md](../Documentation/Showcase.md).
Canonical showcase media rules for the flagship path live in [Documentation/Assets/Flagship-Demo/README.md](../Documentation/Assets/Flagship-Demo/README.md).

## Validation

- `Scripts/validate-flagship-demo.sh`
- `Scripts/validate-examples.sh`

`validate-flagship-demo.sh` smoke-checks the repo's strongest demo path.
`validate-examples.sh` builds a temporary validation package and compile-checks the full example set against the active Swift package products.

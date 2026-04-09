# SwiftIntelligence Examples Hub

This page exists to answer one practical question:

**What should I run first, and which demos are actually mature enough to trust?**

## Best first path

If you only evaluate one example first, use:

- [IntelligentCamera demo guide](DemoApps/IntelligentCamera/README.md)
- validation command: `bash Scripts/validate-flagship-demo.sh`

Why:

- strongest multi-module story
- best current media and proof support
- aligned with the repo's public positioning

## Example maturity map

| Example | Flow | Maturity | Best use |
| --- | --- | --- | --- |
| [IntelligentCamera](DemoApps/IntelligentCamera/README.md) | `Vision -> NLP -> Privacy` | flagship | evaluate the strongest current repo story |
| `DemoApps/SmartTranslator/SmartTranslatorApp.swift` | `NLP -> Privacy -> Speech` | maintained secondary | evaluate text-to-output workflow composition |
| `DemoApps/VoiceAssistant/VoiceAssistantApp.swift` | `NLP -> Privacy -> Speech` | maintained secondary | evaluate assistant-style response flows |
| `DemoApps/PersonalAITutor/PersonalAITutorApp.swift` | tutor-style workflow | source-validated | inspect package coverage, not flagship polish |
| `DemoApps/ARCreativeStudio/ARCreativeStudioApp.swift` | vision-heavy creative workflow | source-validated | inspect breadth, not best-first onboarding |
| [BasicUsage.swift](BasicUsage.swift) | minimal API surface | compile-validated | understand smallest integration path |
| [AdvancedFeatures.swift](AdvancedFeatures.swift) | broader feature sample | compile-validated | inspect more APIs quickly |
| `ServerIntegration/AIServiceClient.swift` | network-adjacent support | compile-validated | inspect integration helper surface |

## Choose by goal

| Your goal | Start here |
| --- | --- |
| see the strongest product-quality path | [IntelligentCamera](DemoApps/IntelligentCamera/README.md) |
| inspect text-heavy workflow composition | `DemoApps/SmartTranslator/SmartTranslatorApp.swift` |
| inspect assistant-style UX | `DemoApps/VoiceAssistant/VoiceAssistantApp.swift` |
| inspect the smallest code sample | [BasicUsage.swift](BasicUsage.swift) |
| review the public narrative behind these demos | [Documentation/Showcase.md](../Documentation/Showcase.md) |

## What is actually validated

- `bash Scripts/validate-flagship-demo.sh`
  - smoke-checks the strongest maintained path
- `bash Scripts/validate-examples.sh`
  - compile-checks the full example set against the active package graph

Validation truth:

- `IntelligentCamera` is the only example with full flagship media, proof narrative, and strongest onboarding
- the other demos are real and compile-validated, but they are not yet presented with the same product polish

## Media and proof

- [Showcase](../Documentation/Showcase.md)
- [Flagship media policy](../Documentation/Assets/Flagship-Demo/README.md)
- [Flagship media status](../Documentation/Generated/Flagship-Media-Status.md)
- [Flagship demo pack](../Documentation/Generated/Flagship-Demo-Pack.md)

## Maintainer rule

Do not market a demo as flagship-quality unless it has:

- a dedicated guide
- a repeatable run path
- current media
- validation coverage
- a clear role in the repo's public positioning

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
| [SmartTranslator](DemoApps/SmartTranslator/README.md) | `NLP -> Privacy -> Speech` | maintained secondary | evaluate text-to-output workflow composition |
| [VoiceAssistant](DemoApps/VoiceAssistant/README.md) | `NLP -> Privacy -> Speech` | maintained secondary | evaluate assistant-style response flows |
| `DemoApps/PersonalAITutor/PersonalAITutorApp.swift` | tutor-style workflow | source-validated | inspect package coverage, not flagship polish |
| `DemoApps/ARCreativeStudio/ARCreativeStudioApp.swift` | vision-heavy creative workflow | source-validated | inspect breadth, not best-first onboarding |
| [BasicUsage.swift](BasicUsage.swift) | minimal API surface | compile-validated | understand smallest integration path |
| [AdvancedFeatures.swift](AdvancedFeatures.swift) | broader feature sample | compile-validated | inspect more APIs quickly |
| `ServerIntegration/AIServiceClient.swift` | network-adjacent support | compile-validated | inspect integration helper surface |

This page is the canonical demo decision surface. README and Showcase should point back here instead of duplicating large decision tables.
Start with `IntelligentCamera` unless you are specifically evaluating a text-first flow, assistant-style UX, or the smallest compile-only sample.

## What is actually validated

- `bash Scripts/validate-flagship-demo.sh`
  - smoke-checks the strongest maintained path
- `bash Scripts/validate-examples.sh`
  - compile-checks the full example set against the active package graph

Validation truth:

- `IntelligentCamera` is the only example with full flagship media, proof narrative, and strongest onboarding
- `SmartTranslator` and `VoiceAssistant` now also have real screenshots, recordings, and media policies
- the secondary demos are still below flagship polish, but they are no longer source-only surfaces

## Secondary Demo Previews

<table>
  <tr>
    <td width="50%" valign="top">
      <a href="DemoApps/SmartTranslator/README.md">
        <img src="../Documentation/Assets/SmartTranslator-Demo/smarttranslator-success.png" alt="SmartTranslator preview" />
      </a>
      <p><strong>SmartTranslator</strong><br />Language analysis, redacted preview, translated output, spoken result.</p>
    </td>
    <td width="50%" valign="top">
      <a href="DemoApps/VoiceAssistant/README.md">
        <img src="../Documentation/Assets/VoiceAssistant-Demo/voiceassistant-success.png" alt="VoiceAssistant preview" />
      </a>
      <p><strong>VoiceAssistant</strong><br />Intent-style command analysis, response generation, redacted preview, spoken output.</p>
    </td>
  </tr>
</table>

## Demo decision matrix

| Demo | Best for | Not for | Compare first |
| --- | --- | --- | --- |
| [IntelligentCamera](DemoApps/IntelligentCamera/README.md) | strongest evaluator path and repo-wide story | smallest example path or text-only evaluation | [Vision vs Apple Vision](../Documentation/Comparisons/Vision-vs-AppleVision.md) |
| [SmartTranslator](DemoApps/SmartTranslator/README.md) | text-heavy user-visible flows | flagship proof or runtime-level evaluation | [NLP vs Apple NaturalLanguage](../Documentation/Comparisons/NLP-vs-NaturalLanguage.md) |
| [VoiceAssistant](DemoApps/VoiceAssistant/README.md) | assistant-style response UI | speech-recognition leadership or agent claims | [Speech vs Apple Speech](../Documentation/Comparisons/Speech-vs-AppleSpeech.md) |

## Media and proof

- [Showcase](../Documentation/Showcase.md)
- [Flagship media status](../Documentation/Generated/Flagship-Media-Status.md)
- [Flagship demo pack](../Documentation/Generated/Flagship-Demo-Pack.md)

## Maintainer rule

Do not market a demo as flagship-quality unless it has:

- a dedicated guide
- a repeatable run path
- current media
- validation coverage
- a clear role in the repo's public positioning

For secondary demos, always answer three questions clearly:

- best for what?
- not for what?
- compare against which raw Apple or rival surface first?

# Comparisons Hub

This folder exists to close decisions, not to dump loose feature lists.

## Fastest decision path

| If you need to decide... | Start here | Why |
| --- | --- | --- |
| repo vs real rivals | [Competitive Matrix](Competitive-Matrix.md) | closes the top-level adoption decision first |
| whether to stay on raw Apple NLP | [NLP vs Apple NaturalLanguage](NLP-vs-NaturalLanguage.md) | text pipeline fit, not generic model hype |
| whether to stay on raw Apple Vision | [Vision vs Apple Vision](Vision-vs-AppleVision.md) | strongest visual product-lane comparison |
| whether SwiftIntelligence adds value beyond speech primitives | [Speech vs Apple Speech](Speech-vs-AppleSpeech.md) | assistant-style flow vs framework assembly |
| whether the privacy lane is real or decorative | [Privacy vs CryptoKit + Security](Privacy-vs-CryptoKit-Security.md) | boundary controls, tokenization, handling discipline |

## Use this hub correctly

<table>
  <tr>
    <td width="50%" valign="top">
      <strong>Use comparisons to answer</strong><br /><br />
      should I adopt this repo?<br />
      should I stay on raw Apple APIs?<br />
      which demo helps answer my question fastest?
    </td>
    <td width="50%" valign="top">
      <strong>Do not use comparisons to claim</strong><br /><br />
      benchmark dominance outside the proof envelope<br />
      runtime superiority over specialist low-level stacks<br />
      category leadership that the repo has not earned yet
    </td>
  </tr>
</table>

## Decision order

1. Read the [Competitive Matrix](Competitive-Matrix.md) if you are choosing between SwiftIntelligence and other real repositories.
2. Read the module-level pages if you are deciding whether to adopt one product lane or stay on raw Apple APIs.
3. Read the proof pages only after the product and comparison story is already clear.

## Start with the repo-level comparison

- [SwiftIntelligence vs top rivals](Competitive-Matrix.md)

That page covers:

- `coremltools`
- `MLX`
- `WhisperKit`
- `swift-transformers`
- `AnyLanguageModel`

## Module-level comparisons

- [NLP overview](NLP.md)
- [SwiftIntelligenceNLP vs Apple NaturalLanguage](NLP-vs-NaturalLanguage.md)
- [Vision overview](Vision.md)
- [SwiftIntelligenceVision vs Apple Vision](Vision-vs-AppleVision.md)
- [Speech overview](Speech.md)
- [SwiftIntelligenceSpeech vs Apple Speech](Speech-vs-AppleSpeech.md)
- [Privacy overview](Privacy.md)
- [SwiftIntelligencePrivacy vs CryptoKit + Security](Privacy-vs-CryptoKit-Security.md)

## Current proof envelope

- publish readiness: `ready`
- distribution posture: `release-grade`
- required release device classes covered: `Mac, iPhone`
- canonical trust page: [../Generated/Public-Proof-Status.md](../Generated/Public-Proof-Status.md)
- latest immutable release proof: [../Generated/Latest-Release-Proof.md](../Generated/Latest-Release-Proof.md)

## Best demo to pair with each comparison

| Comparison question | Best demo to open next |
| --- | --- |
| repo-level value vs real rivals | [IntelligentCamera](../../Examples/DemoApps/IntelligentCamera/README.md) |
| text-heavy user-visible workflow value | [SmartTranslator](../../Examples/DemoApps/SmartTranslator/README.md) |
| assistant-style response UX value | [VoiceAssistant](../../Examples/DemoApps/VoiceAssistant/README.md) |

## Comparison rules

- compare against primary sources first
- compare against real alternatives people actually choose
- separate raw framework capability from developer workflow value
- state where SwiftIntelligence loses as clearly as where it wins
- do not claim superiority without current proof or product evidence

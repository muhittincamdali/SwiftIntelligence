# GitHub Distribution

Last updated: 2026-04-15

This page defines the public GitHub-facing metadata for SwiftIntelligence.

## Current About Box

Source of truth checked against the GitHub repository API on 2026-04-13.

- description: `Apple-native on-device AI workflow stack for Vision, NaturalLanguage, Speech, privacy, benchmarks, and release proof.`
- homepage: `none`
- primary repo URL: `https://github.com/muhittincamdali/SwiftIntelligence`

## Current Topics

- `apple`
- `benchmarking`
- `coreml`
- `ios`
- `macos`
- `natural-language`
- `on-device-ai`
- `privacy`
- `privacy-first`
- `speech`
- `swift`
- `swift-ai`
- `swift-package-manager`
- `tvos`
- `visionos`
- `vision-framework`
- `watchos`
- `apple-developer-tools`

## Distribution Rules

- GitHub description must stay category-specific, not generic AI hype
- topics must reflect actual maintained modules and supported Apple surfaces
- homepage should stay empty until there is a real external docs or product URL
- README, About box, and positioning docs must tell the same category story
- public proof links must point to generated status and immutable release proof, not ad-hoc claims
- issue forms and PR template must ask for public-claim impact and evidence truthfulness when relevant
- GitHub-hosted workflows should stay enabled and truthful; do not present repo health as green if hosted checks are actually failing or externally blocked

## Current Operational Note

As of 2026-04-15, GitHub-hosted workflows are active and split into:

- fast push-facing integrity checks on `main`
- full Swift CodeQL analysis on `schedule` and `workflow_dispatch`

Operational policy now:

- keep workflow definitions versioned and active
- do not fake green CI state
- treat GitHub-hosted results as the public live signal
- keep `bash Scripts/prepare-release.sh` as the canonical repo-side validation floor
- do not let a stuck hosted Swift CodeQL build hold the whole push surface open when the same full scan can run on schedule/manual truthfully
- only disable hosted workflows if there is a real external blocker and that blocker is documented truthfully

## First Links For New Visitors

- [README](../README.md)
- [Getting Started](Getting-Started.md#five-minute-success-path)
- [IntelligentCamera demo guide](../Examples/DemoApps/IntelligentCamera/README.md)
- [Showcase](Showcase.md)
- [Trust Start](Trust-Start.md)
- [Public Proof Status](Generated/Public-Proof-Status.md)
- [Latest Release Proof](Generated/Latest-Release-Proof.md)
- [Positioning](Positioning.md)
- [GitHub Sponsors](https://github.com/sponsors/muhittincamdali)

## Drift Checklist

Check these when category, module scope, or proof posture changes:

- GitHub description
- GitHub topics
- README opening story
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/documentation.yml`
- `.github/ISSUE_TEMPLATE/performance_issue.yml`
- `.github/ISSUE_TEMPLATE/device_evidence.yml`
- [Positioning](Positioning.md)
- [Showcase](Showcase.md)
- [GitHub Presentation Backlog](GitHub-Presentation-Backlog.md)
- [Public Proof Status](Generated/Public-Proof-Status.md)

## Presentation Rule

The GitHub surface should be treated as a maintained product surface, not a decorative README project.

That means:

- hero, docs routing, examples routing, trust routing, and About box must stay aligned
- visual redesign work must close evaluator decisions faster, not just add style
- remaining visual-system work is tracked in [GitHub Presentation Backlog](GitHub-Presentation-Backlog.md)

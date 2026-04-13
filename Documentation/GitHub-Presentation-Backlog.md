# GitHub Presentation Backlog

Last updated: 2026-04-13

This page defines the remaining GitHub-facing presentation backlog for `SwiftIntelligence`.

It exists so visual redesign work stays tied to category-leadership outcomes, not random cosmetic churn.

## Source-backed benchmark set

The current benchmark set for GitHub presentation quality is:

- [GitHub Docs: About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)
- [GitHub Docs: Classifying your repository with topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)
- [Supabase README](https://github.com/supabase/supabase)
- [shadcn/ui README](https://github.com/shadcn-ui/ui)
- [Expo README](https://github.com/expo/expo)
- [Tauri README](https://github.com/tauri-apps/tauri)

These are not category-identical repos. They are the current benchmark set for:

- first-screen clarity
- visual hierarchy
- docs routing
- trust signals
- community and distribution posture

This is a source-backed inference from their live repository surfaces and the official GitHub repository guidance above.

## What benchmark repos do better

The benchmark set consistently does these things well:

1. The first screen closes the core product story fast.
2. Primary navigation is short and obvious.
3. README visuals support the story instead of repeating text.
4. Docs and community links are routed by intent, not dumped as a wall of links.
5. Social proof, support, and contribution signals are visible without overwhelming the page.
6. About box, topics, README opening, and docs story all say the same thing.

## Current SwiftIntelligence gaps

`SwiftIntelligence` is stronger than before, but these gaps remain:

1. The hero is cleaner, but it is still more maintainer-grade than category-dominant.
2. README visual boards are stable, but not yet distinctive enough to feel world-class.
3. The first screen still carries more navigation and explanation than the best benchmark repos.
4. Community and distribution signals exist, but they are not yet integrated into a single premium public story.
5. README, Showcase, Comparisons, and Docs now share a visual language, but the system is not yet visually unforgettable.
6. The repo still proves technical rigor better than it proves product pull.

## Hard requirements for the next visual system

Any redesign must keep these rules:

1. Text inside visuals must stay deterministic and layout-safe.
2. README hero must answer `what`, `why`, and `where to start` in one screen.
3. Visual assets must survive GitHub light/dark rendering and width changes.
4. Visuals must reduce text debt, not create more.
5. Proof posture must stay truthful and generated pages must remain the canonical claim boundary.
6. Badges must stay low-noise; signal belongs in product-grade surfaces, not shield clutter.

## Presentation sprint backlog

### Sprint A: Hero dominance

Goal: make the first screen look like a product landing page instead of a polished package index.

Tasks:

- redesign the hero around one dominant message and one dominant action
- reduce the current top meta surface to the minimum signal set
- turn the current support boards into a more cohesive visual family
- keep `Start Here`, `Release Proof`, and `Examples Hub` as the only top-level action cluster unless a stronger replacement exists

Definition of done:

- the first viewport explains category, fit, and start path without scrolling
- the hero does not depend on badge clutter
- no duplicated top-level narrative between hero and first two sections

### Sprint B: Product-lane storytelling

Goal: make the repo feel like a maintained product stack, not a collection of module surfaces.

Tasks:

- strengthen the `Vision`, `NaturalLanguage`, `Speech`, and `Privacy` lane framing
- make the flagship and secondary demo story more obviously connected to those lanes
- reduce any remaining repetition between README, Showcase, and Examples Hub

Definition of done:

- a visitor can tell which demo answers which product question in under 30 seconds
- module-lane value is visible before deep docs reading

### Sprint C: Trust and community integration

Goal: make trust signals and contribution signals feel product-grade instead of footer-grade.

Tasks:

- tighten how README, `Trust Start`, `Public Proof Status`, release proof, and community-health files connect
- surface contribution, security, and support as quality signals without bloating the hero
- review About box, topics, release notes, and pinned links as one system

Definition of done:

- a new visitor sees trust and maintenance quality without hunting
- community health looks intentional, not merely complete

### Sprint D: Visual anti-regression

Goal: prevent future drift after redesign.

Tasks:

- keep SVG structural validators
- add browser screenshot regression for the hero and support boards
- add documented review criteria for visual-copy density and GitHub rendering safety

Definition of done:

- visual breakage is caught before merge
- new board edits cannot silently reintroduce overflow or layout drift

## Priority order

1. Hero dominance
2. Product-lane storytelling
3. Trust and community integration
4. Visual anti-regression

## What not to do

- do not turn the README into a badge wall
- do not replace deterministic text with AI-generated text baked into raster art
- do not create visuals that only look good in one viewport
- do not let style outrun proof, release, or trust reality

## Exit bar

This backlog is only closed when:

- the first screen is category-clear and low-noise
- the visual system feels intentional across README, Showcase, Comparisons, and Docs
- trust signals feel integrated, not bolted on
- demo routing is obvious
- visual regression guardrails exist for the new system

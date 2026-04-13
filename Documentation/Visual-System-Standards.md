# Visual System Standards

Last updated: 2026-04-13

This page defines the public visual safety bar for `SwiftIntelligence`.

It exists so the README, Showcase, Comparisons, and Documentation boards do not drift back into text-heavy, layout-fragile surfaces.

## What this standard protects

The visual system must stay:

1. deterministic
2. GitHub-safe
3. low-noise
4. truth-aligned

These boards are support surfaces, not posters that can say anything.

## Hard rules

1. Text inside SVGs must stay deterministic and source-controlled.
2. The hero must close `what`, `why`, and `where to start` in one screen.
3. Support boards must summarize decisions, not duplicate full doc sections.
4. Public claim language inside visuals must stay inside the generated proof envelope.
5. Visuals must survive GitHub width changes without badge clutter or text overflow.

## Copy-density contract

The repo now enforces a visual copy budget in:

- [Documentation/visual-copy-policy.json](visual-copy-policy.json)

Each public SVG surface has three limits:

1. `max_text_nodes`
2. `max_chars_per_node`
3. `max_total_chars`

These are not design perfection metrics. They are anti-regression limits.

They exist to stop:

- too many text rows
- overly long single lines
- gradual narrative bloat inside visual boards

## Validation chain

The visual system is protected by two validator layers:

1. structural and raster validation
   - SVG contract
   - baseline snapshots
   - renderer-aware checksum checks
2. copy-density validation
   - text node count
   - longest line budget
   - total character budget

Maintainer commands:

```bash
bash Scripts/validate-readme-visual-assets.sh
bash Scripts/validate-showcase-visual-assets.sh
bash Scripts/validate-comparison-visual-assets.sh
bash Scripts/validate-docs-visual-assets.sh
bash Scripts/validate-visual-copy-density.sh
```

## Review rule

If a redesign needs more copy than the current budget allows, change both:

1. the visual itself
2. the policy file

That forces visual debt to be explicit and reviewable instead of silently growing.

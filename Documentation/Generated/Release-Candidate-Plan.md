# Release Candidate Plan

Generated from the current benchmark readiness report.

## Current State

- Publish readiness: `ready`
- Device classes seen: `Mac, iPhone`
- Immutable release bundles: `4`
- Immutable release baseline: `present`
- Coverage rule: `At least 2 device classes covered`

## Wave 1: Release Candidate Execution

- Goal: The benchmark surface is ready for a release candidate push.
- Steps:
  - Run `bash Scripts/prepare-release.sh` on the final candidate commit.
  - Archive the final immutable evidence bundle with the candidate tag.
  - Push the matching tag only after changelog and proof surfaces are fully aligned.

## Exit Condition

- `Benchmark-Readiness.md` reports `ready`.
- At least one immutable release evidence bundle exists.
- Device coverage is broad enough that public performance claims are not Mac-only.
- `prepare-release.sh` completes without threshold failures or missing artifact gates.

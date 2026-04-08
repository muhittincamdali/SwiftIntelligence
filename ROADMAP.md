# SwiftIntelligence Roadmap

Last updated: 2026-04-02

## North Star

Make `SwiftIntelligence` the most trustworthy modular AI package for Apple-platform developers who want native-framework-first building blocks, honest docs, and reproducible proof.

## Current Baseline

- active modular package graph is the source of truth
- `swift test` is green on the maintained branch
- examples are compile-validated
- release preparation is script-gated
- benchmark claims are expected to come from generated artifacts
- benchmark publication readiness is now tracked through generated readiness and release-candidate plan surfaces
- missing-device capture work is now tracked through a generated device-evidence plan
- security and supply-chain workflows are in place, but repo polish is still in progress

## Current Benchmark Evidence Reality

As of the latest generated readiness surface:

- publish readiness is still `not ready`
- the current benchmark pointer is valid and the first immutable archived release baseline now exists
- device coverage is still Mac-only

The operational source of truth for closing that gap is now:

- [Documentation/Generated/Benchmark-Readiness.md](Documentation/Generated/Benchmark-Readiness.md)
- [Documentation/Generated/Release-Candidate-Plan.md](Documentation/Generated/Release-Candidate-Plan.md)
- [Documentation/Generated/Device-Evidence-Plan.md](Documentation/Generated/Device-Evidence-Plan.md)
- [Documentation/Generated/Device-Capture-Packets.md](Documentation/Generated/Device-Capture-Packets.md)
- [Documentation/Generated/Device-Evidence-Intake.md](Documentation/Generated/Device-Evidence-Intake.md)
- [Documentation/Generated/Device-Evidence-Queue.md](Documentation/Generated/Device-Evidence-Queue.md)
- [Documentation/Generated/Release-Blockers.md](Documentation/Generated/Release-Blockers.md)
- [Documentation/Generated/Public-Proof-Status.md](Documentation/Generated/Public-Proof-Status.md)

## Wave 0: Trust Surface

Status: in progress

- keep docs aligned with the active package graph
- remove stale umbrella and inactive-product claims
- keep CI, release, benchmark, and security workflows trustworthy
- tighten repo health files, issue forms, and maintainer guidance

## Wave 1: Adoption Surface

Status: next

- improve README onboarding for first successful integration in under 5 minutes
- add clearer per-module usage paths and comparison tables
- make benchmark summaries easier to consume without marketing inflation
- strengthen example discoverability and validated demo coverage
- complete Wave 1 benchmark evidence tasks:
  - keep the archived baseline trustworthy and reproducible
  - execute the generated iPhone and iPad capture waves
  - use the generated packet + intake surfaces instead of ad-hoc maintainer notes
  - move from Mac-only proof to at least 3 device classes
  - make `Benchmark-Readiness.md` report `ready`

## Wave 2: Engineering Hardening

Status: planned

- continue Swift 6 concurrency cleanup in active modules
- reduce warning backlog in Vision, NLP, Privacy, and infrastructure layers
- document module-level guarantees and non-goals more explicitly
- improve benchmark methodology notes and device matrix guidance
- keep threshold policy, artifact manifest, checksum, and release-proof automation trustworthy under real release use

## Wave 3: Category Leadership

Status: planned

- publish stronger comparative positioning against top Apple-native and OSS alternatives
- add showcase-quality demos that prove real developer value
- turn benchmarks, examples, and docs into obvious public proof rather than internal notes
- restore only the modules/products that can meet current quality and maintenance standards

## Explicit Non-Goals

- preserving stale umbrella APIs for nostalgia
- pretending inactive products are production-ready
- publishing unverified performance or privacy claims
- treating internal aspiration docs as evidence

## Exit Criteria

`SwiftIntelligence` is not "done" until these are true:

- active docs, examples, and workflows agree with `Package.swift`
- the maintained modules stay green under build, test, example, benchmark, and security gates
- adoption path is obvious for new users
- public claims are backed by reproducible artifacts
- benchmark readiness is `ready`, not `not ready`
- at least one immutable release evidence bundle exists
- public performance claims are not based on Mac-only evidence
- restored modules meet the same bar as the active graph

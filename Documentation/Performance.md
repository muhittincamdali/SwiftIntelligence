# Performance Guide

This document covers the current performance model of the active modular graph.

## Performance Philosophy

The current repository optimizes in this order:

1. correct behavior
2. deterministic tests
3. concurrency safety
4. measurable performance

That means some earlier highly parallel code paths were intentionally simplified during stabilization. Performance claims should come from benchmark output, not optimistic architecture diagrams.

## Core Levers

### Configuration

`IntelligenceConfiguration` contains the main runtime knobs:

- `memoryLimit`
- `cacheDuration`
- `maxConcurrentOperations`
- `enableOnDeviceProcessing`
- `enableCloudFallback`
- `enableNeuralEngine`
- `batchSize`
- `performanceProfile`
- `cachePolicy`

Presets:

- `.development`
- `.production`
- `.testing`

### Module-Level Caches

Current caches live inside the modules that own the work:

- `NLPEngine` caches NLP results
- `VisionEngine` caches images and vision results
- `SpeechEngine` caches recognition and synthesis artifacts
- `SwiftIntelligenceML` caches inference outputs

### Memory Hygiene

Use these controls when long-lived sessions accumulate state:

- `VisionEngine.optimizeMemory()`
- `VisionEngine.shutdown()`
- `SwiftIntelligenceML.clearCache()`
- `SwiftIntelligenceCore.shared.cleanup()`

## Practical Recommendations

### NLP

- reuse `NLPEngine.shared`
- avoid recreating analysis state for every short text
- request only the signals you need in `NLPOptions`

### Vision

- initialize `VisionEngine` once per session
- shut it down when camera or document workflows end
- use realtime APIs only when you actually have a streaming source
- prefer narrow option presets such as `.default` or `.realtime` before custom tuning

### Speech

- reuse the shared engine
- prefer `SpeechEngine.availableVoices(for:)` when you only need metadata
- avoid repeated init/teardown around single utterances

### ML

- register and reuse models instead of rebuilding them repeatedly
- clear caches only when memory pressure or correctness requires it
- benchmark training and inference separately

## Benchmark Workflow

Public claims should be backed by generated artifacts.

Run:

```bash
bash Scripts/run-benchmarks.sh standard
```

Outputs are expected under:

- `Benchmarks/Results/latest`

Supporting documents:

- [Benchmark-Baselines.md](Benchmark-Baselines.md)
- [Benchmarks/README.md](../Benchmarks/README.md)

## What To Avoid

- treating stale marketing claims as performance facts
- assuming task groups are always faster than sequential execution
- comparing modules without a reproducible benchmark harness
- publishing latency or throughput claims without artifacts

## Current Truth

At the current stage of the repo, build stability and `swift test` health are the primary performance gate. Any optimization that reintroduces concurrency instability is a regression, even if it looks faster in isolation.

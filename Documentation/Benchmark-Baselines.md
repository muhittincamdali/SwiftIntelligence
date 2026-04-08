# Benchmark Baselines

This document exists to turn SwiftIntelligence performance claims into reproducible proof.

## Current Repository Standard

All benchmark claims should now come from the executable benchmark runner:

```bash
swift run -c release Benchmarks --profile standard --output-dir Benchmarks/Results/latest
```

Helper script:

```bash
bash Scripts/run-benchmarks.sh standard
```

Device-aware helper:

```bash
bash Scripts/run-benchmarks-for-device.sh \
  --profile standard \
  --output-dir Benchmarks/Results/iphone-baseline \
  --snapshot-name iphone-baseline-2026-04-07 \
  --device-class iPhone \
  --export-archive /absolute/path/to/iphone-benchmark-export.tar.gz
```

External import helper:

```bash
bash Scripts/import-benchmark-evidence.sh \
  --device-name "iPhone 16" \
  --device-model "iPhone17,3" \
  --device-class iPhone \
  --platform-family iOS \
  /absolute/path/to/benchmark-export.tar.gz \
  iphone-baseline-2026-04-02
```

External export helper:

```bash
bash Scripts/export-benchmark-evidence.sh \
  Benchmarks/Results/latest \
  /absolute/path/to/benchmark-export.tar.gz
```

Artifact validator:

```bash
bash Scripts/validate-benchmarks.sh standard Benchmarks/Results/latest
```

Regression threshold gate:

```bash
bash Scripts/validate-benchmark-thresholds.sh Benchmarks/Results/latest Benchmarks/Results Benchmarks/benchmark-thresholds.json
```

Transfer round-trip gate:

```bash
bash Scripts/validate-transfer-chain.sh Benchmarks/Results/latest
```

Release provenance gate:

```bash
bash Scripts/validate-release-provenance.sh Benchmarks/Results
```

Expected artifacts:

- `Benchmarks/Results/latest/benchmark-report.json`
- `Benchmarks/Results/latest/benchmark-summary.md`
- `Benchmarks/Results/latest/environment.json`
- `Benchmarks/Results/latest/device-metadata.json`
- `Benchmarks/Results/latest/artifact-manifest.json`
- `Benchmarks/Results/latest/checksums.txt`
- generated public history in `Documentation/Generated/Benchmark-History.md`
- generated methodology in `Documentation/Generated/Benchmark-Methodology.md`
- generated timeline in `Documentation/Generated/Benchmark-Timeline.md`
- generated release matrix in `Documentation/Generated/Release-Benchmark-Matrix.md`
- generated release proof timeline in `Documentation/Generated/Release-Proof-Timeline.md`
- generated latest release proof in `Documentation/Generated/Latest-Release-Proof.md`
- generated publish-readiness report in `Documentation/Generated/Benchmark-Readiness.md`
- generated release-candidate action plan in `Documentation/Generated/Release-Candidate-Plan.md`
- generated device-evidence action plan in `Documentation/Generated/Device-Evidence-Plan.md`
- generated device coverage matrix in `Documentation/Generated/Device-Coverage-Matrix.md`
- `Scripts/validate-public-claims.sh` to keep public benchmark language honest while readiness is not `ready`
- generated latest-vs-release comparison in `Documentation/Generated/Benchmark-Comparison.md`

## What To Publish

- latency by feature
- memory footprint by feature
- energy profile by feature
- model size and accuracy tradeoffs where applicable
- device-to-device variance

## Recommended Device Matrix

| Device Class | Example Device | Notes |
| --- | --- | --- |
| High-end iPhone | latest Pro class | best-case Neural Engine path |
| Mainstream iPhone | non-Pro recent device | realistic production baseline |
| iPad | recent iPad Pro or Air | larger-screen compute profile |
| Mac | Apple Silicon laptop | desktop and dev workflow profile |
| visionOS | Apple Vision Pro | spatial UI and thermal context |

## Suggested Benchmark Groups

| Area | Sample Operation | Target Metric |
| --- | --- | --- |
| Vision | image classification | median latency, p95 latency |
| Vision | OCR | latency and memory |
| NLP | sentiment and entity extraction | latency and throughput |
| Speech | transcription | real-time factor and memory |
| Forecasting | time-series prediction | latency and accuracy |
| Recommendations | top-N recommendation | latency and cache effect |

## Publish Format

For each feature publish:

- device name
- OS version
- model configuration
- input size
- cold run
- warm run median
- p95
- memory peak
- notes

## Repository Gate Before README Claims

- `swift build` passes
- `bash Scripts/validate-examples.sh` passes
- `swift test` passes
- benchmark artifacts are freshly regenerated
- benchmark artifact schema/profile validation passes
- explicit device metadata exists and matches the benchmark payload
- benchmark regression threshold gate passes against the latest immutable release baseline when one exists
- markdown summary and raw JSON both exist
- environment metadata is attached
- artifact manifest and checksum files match the generated payload
- competitor comparisons use equivalent workloads
- date of measurement is explicit

## CLI Or Script Hooks

- keep executable runner exposed as `swift run -c release Benchmarks`
- keep helper automation in `Scripts/run-benchmarks.sh`
- keep normalized device capture in `Scripts/run-benchmarks-for-device.sh`
- keep validated artifact packaging in `Scripts/export-benchmark-evidence.sh`
- keep external evidence ingestion in `Scripts/import-benchmark-evidence.sh`
- keep artifact validation in `Scripts/validate-benchmarks.sh`
- keep release validation in `Scripts/prepare-release.sh`
- keep export/import round-trip validation in `Scripts/validate-transfer-chain.sh`
- keep release provenance validation in `Scripts/validate-release-provenance.sh`
- keep threshold policy in `Benchmarks/benchmark-thresholds.json`
- keep CI exercising at least the `smoke` profile and preserving its artifacts
- keep release regression threshold gates tied to `standard` release-grade evidence, not hosted `smoke` CI artifacts
- version the benchmark inputs and methodology notes
- keep one markdown summary and one machine-readable JSON artifact
- keep environment metadata alongside results
- keep normalized device metadata alongside results

## Minimum Bar Before New Performance Claims

- all required release device classes in `Benchmarks/device-matrix-policy.json` tested
- at least 30 runs per benchmark scenario
- cold and warm numbers separated
- known limitations documented

## Review Rule

If the artifacts are missing, stale, or not reproducible, treat every performance claim as unproven.

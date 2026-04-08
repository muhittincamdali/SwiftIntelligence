# Benchmark Results

Generated benchmark artifacts belong in this directory.

Recommended layout:

- `latest/` for the most recent local run
- `releases/<tag-or-timestamp>/` for immutable release evidence bundles
- each release bundle may also contain `benchmark-delta.md` comparing against the previous immutable release bundle
- each release bundle also contains `release-notes-proof.md` for public release-note reuse
- latest and release bundles also contain `artifact-manifest.json` and `checksums.txt`

Do not edit generated files by hand.

Current human-readable benchmark evidence starts at:

- [`latest/benchmark-summary.md`](latest/benchmark-summary.md)
- [`latest/environment.json`](latest/environment.json)
- generated history: [`../../Documentation/Generated/Benchmark-History.md`](../../Documentation/Generated/Benchmark-History.md)
- generated methodology: [`../../Documentation/Generated/Benchmark-Methodology.md`](../../Documentation/Generated/Benchmark-Methodology.md)
- generated comparison: [`../../Documentation/Generated/Benchmark-Comparison.md`](../../Documentation/Generated/Benchmark-Comparison.md)
- generated device plan: [`../../Documentation/Generated/Device-Evidence-Plan.md`](../../Documentation/Generated/Device-Evidence-Plan.md)
- generated device coverage matrix: [`../../Documentation/Generated/Device-Coverage-Matrix.md`](../../Documentation/Generated/Device-Coverage-Matrix.md)
- generated device runbook: [`../../Documentation/Generated/Device-Evidence-Runbook.md`](../../Documentation/Generated/Device-Evidence-Runbook.md)

Archive the current validated set with:

```bash
bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3
```

Import a validated benchmark set captured elsewhere with:

```bash
bash Scripts/import-benchmark-evidence.sh /absolute/path/to/benchmark-export.tar.gz iphone-baseline-2026-04-02
```

Package a validated artifact set for transfer with:

```bash
bash Scripts/export-benchmark-evidence.sh Benchmarks/Results/latest /absolute/path/to/benchmark-export.tar.gz
```

That archive command also writes `benchmark-delta.md`, `release-notes-proof.md`, `artifact-manifest.json`, and `checksums.txt` into the release bundle.

Generate release delta notes with:

```bash
bash Scripts/generate-release-benchmark-delta.sh Benchmarks/Results/releases/v1.2.3
```

Repo-level interpretation of those artifacts lives in [Documentation/Showcase.md](../../Documentation/Showcase.md).

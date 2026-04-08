#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/docs}"
REPO_BLOB_BASE="https://github.com/muhittincamdali/SwiftIntelligence/blob/main"

if [[ "$OUTPUT_DIR" != /* ]]; then
  OUTPUT_DIR="$ROOT_DIR/$OUTPUT_DIR"
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

cd "$ROOT_DIR"

bash "$ROOT_DIR/Scripts/generate-proof-snapshot.sh" "$ROOT_DIR/Benchmarks/Results/latest" "$ROOT_DIR/Documentation/Generated/Proof-Snapshot.md"
bash "$ROOT_DIR/Scripts/generate-benchmark-history.sh" "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Documentation/Generated/Benchmark-History.md" "$ROOT_DIR/Documentation/Generated/Benchmark-Comparison.md" "$ROOT_DIR/Documentation/Generated/Benchmark-Methodology.md" "$ROOT_DIR/Documentation/Generated/Benchmark-Timeline.md" "$ROOT_DIR/Documentation/Generated/Release-Benchmark-Matrix.md" "$ROOT_DIR/Documentation/Generated/Release-Proof-Timeline.md" "$ROOT_DIR/Documentation/Generated/Latest-Release-Proof.md"
bash "$ROOT_DIR/Scripts/generate-benchmark-readiness-report.sh" "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Benchmarks/benchmark-thresholds.json"
bash "$ROOT_DIR/Scripts/generate-release-candidate-plan.sh" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Release-Candidate-Plan.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-plan.sh" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Benchmarks/device-matrix-policy.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md"
bash "$ROOT_DIR/Scripts/generate-device-coverage-matrix.sh" "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Benchmarks/device-matrix-policy.json" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md"
bash "$ROOT_DIR/Scripts/generate-device-capture-packets.sh" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-runbook.sh" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-intake.sh" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-queue.sh" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md" "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json"
bash "$ROOT_DIR/Scripts/generate-release-blockers.sh" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$ROOT_DIR/Documentation/Generated/Release-Blockers.md"
bash "$ROOT_DIR/Scripts/generate-public-proof-status.sh" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Release-Blockers.md" "$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md" "$ROOT_DIR/Documentation/Generated/public-proof-status.json"
bash "$ROOT_DIR/Scripts/generate-device-evidence-handoff.sh" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md" "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md" "$ROOT_DIR/Documentation/Generated/public-proof-status.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md" "$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json"
bash "$ROOT_DIR/Scripts/generate-evidence-provenance-report.sh" "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Documentation/Generated/Evidence-Provenance.md"

if swift package --allow-writing-to-directory "$OUTPUT_DIR" generate-documentation --disable-indexing --transform-for-static-hosting --output-path "$OUTPUT_DIR"; then
  echo "DocC documentation generated."
  exit 0
fi

echo "DocC generation unavailable. Building fallback documentation index."

cat > "$OUTPUT_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SwiftIntelligence Documentation</title>
    <style>
      :root {
        color-scheme: light;
        --bg: #f4f7fb;
        --panel: #ffffff;
        --ink: #102033;
        --muted: #5f6f82;
        --line: #d7e0ea;
        --accent: #0b63ce;
      }
      body {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        background: linear-gradient(180deg, #eef4fb 0%, #f8fbff 100%);
        color: var(--ink);
      }
      main {
        max-width: 920px;
        margin: 0 auto;
        padding: 48px 24px 72px;
      }
      .panel {
        background: var(--panel);
        border: 1px solid var(--line);
        border-radius: 18px;
        padding: 24px;
        box-shadow: 0 12px 32px rgba(16, 32, 51, 0.06);
      }
      h1, h2 { margin-top: 0; }
      p { color: var(--muted); line-height: 1.6; }
      ul { padding-left: 18px; }
      li { margin: 10px 0; }
      a { color: var(--accent); text-decoration: none; }
      a:hover { text-decoration: underline; }
      .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 16px;
        margin-top: 20px;
      }
      .card {
        background: #fbfdff;
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 18px;
      }
    </style>
  </head>
  <body>
    <main>
      <section class="panel">
        <h1>SwiftIntelligence Documentation</h1>
        <p>DocC output is not available in this environment. Use the curated repository documentation below.</p>
        <div class="grid">
          <div class="card">
            <h2>Start</h2>
            <ul>
              <li><a href="$REPO_BLOB_BASE/README.md">README</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/README.md">Documentation Index</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Getting-Started.md">Getting Started</a></li>
            </ul>
          </div>
          <div class="card">
            <h2>Architecture</h2>
            <ul>
              <li><a href="$REPO_BLOB_BASE/Documentation/Architecture.md">Architecture</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Showcase.md">Showcase</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Proof-Snapshot.md">Proof Snapshot</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Benchmark-History.md">Benchmark History</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Benchmark-Comparison.md">Benchmark Comparison</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Benchmark-Methodology.md">Benchmark Methodology</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Benchmark-Timeline.md">Benchmark Timeline</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Release-Benchmark-Matrix.md">Release Benchmark Matrix</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Release-Proof-Timeline.md">Release Proof Timeline</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Latest-Release-Proof.md">Latest Release Proof</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Benchmark-Readiness.md">Benchmark Readiness</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Release-Candidate-Plan.md">Release Candidate Plan</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Evidence-Plan.md">Device Evidence Plan</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Coverage-Matrix.md">Device Coverage Matrix</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Capture-Packets.md">Device Capture Packets</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Evidence-Runbook.md">Device Evidence Runbook</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Evidence-Intake.md">Device Evidence Intake</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Evidence-Queue.md">Device Evidence Queue</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Device-Evidence-Handoff.md">Device Evidence Handoff</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Release-Blockers.md">Release Blockers</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Public-Proof-Status.md">Public Proof Status</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Generated/Evidence-Provenance.md">Evidence Provenance</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/API.md">API Overview</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/API-Reference.md">API Reference</a></li>
            </ul>
          </div>
          <div class="card">
            <h2>Quality Gates</h2>
            <ul>
              <li><a href="$REPO_BLOB_BASE/Documentation/Benchmark-Baselines.md">Benchmark Baselines</a></li>
              <li><a href="$REPO_BLOB_BASE/Documentation/Release-Process.md">Release Process</a></li>
              <li><a href="$REPO_BLOB_BASE/SECURITY.md">Security Policy</a></li>
            </ul>
          </div>
        </div>
      </section>
    </main>
  </body>
</html>
EOF

echo "Fallback documentation index generated at $OUTPUT_DIR/index.html"

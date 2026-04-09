#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "Preparing release validation for SwiftIntelligence..."

swift build -c release
bash Scripts/validate-examples.sh
swift test
bash Scripts/validate-changelog.sh
bash Scripts/validate-version-surface.sh
bash Scripts/validate-readme-localizations.sh
bash Scripts/validate-flagship-media-assets.sh
bash Scripts/validate-flagship-media-assets.sh "$ROOT_DIR/Documentation/smarttranslator-media-policy.json" "$ROOT_DIR/Documentation/Assets/SmartTranslator-Demo/README.md"
bash Scripts/validate-flagship-media-assets.sh "$ROOT_DIR/Documentation/voiceassistant-media-policy.json" "$ROOT_DIR/Documentation/Assets/VoiceAssistant-Demo/README.md"
bash Scripts/generate-flagship-media-status.sh "$ROOT_DIR/Documentation/flagship-media-policy.json" "$ROOT_DIR/Documentation/Assets/Flagship-Demo/README.md" "$ROOT_DIR/Documentation/Generated/Flagship-Media-Status.md" "$ROOT_DIR/Documentation/Generated/flagship-media-status.json"
bash Scripts/generate-proof-snapshot.sh "$ROOT_DIR/Benchmarks/Results/latest" "$ROOT_DIR/Documentation/Generated/Proof-Snapshot.md"
bash Scripts/generate-benchmark-history.sh "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Documentation/Generated/Benchmark-History.md" "$ROOT_DIR/Documentation/Generated/Benchmark-Comparison.md" "$ROOT_DIR/Documentation/Generated/Benchmark-Methodology.md" "$ROOT_DIR/Documentation/Generated/Benchmark-Timeline.md" "$ROOT_DIR/Documentation/Generated/Release-Benchmark-Matrix.md" "$ROOT_DIR/Documentation/Generated/Release-Proof-Timeline.md" "$ROOT_DIR/Documentation/Generated/Latest-Release-Proof.md"
bash Scripts/generate-benchmark-readiness-report.sh "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Benchmarks/benchmark-thresholds.json"
bash Scripts/validate-public-claims.sh "$ROOT_DIR/Documentation/public-claims-policy.json"
bash Scripts/generate-release-candidate-plan.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Release-Candidate-Plan.md"
bash Scripts/generate-device-evidence-plan.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Benchmarks/device-matrix-policy.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md"
bash Scripts/generate-device-coverage-matrix.sh "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Benchmarks/device-matrix-policy.json" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md"
bash Scripts/generate-device-capture-packets.sh "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md"
bash Scripts/generate-device-evidence-runbook.sh "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md"
bash Scripts/generate-device-evidence-intake.sh "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md"
bash Scripts/generate-device-evidence-queue.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md" "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json"
bash Scripts/generate-release-blockers.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$ROOT_DIR/Documentation/Generated/Release-Blockers.md"
bash Scripts/generate-public-proof-status.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Release-Blockers.md" "$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md" "$ROOT_DIR/Documentation/Generated/public-proof-status.json"
bash Scripts/generate-flagship-demo-pack.sh "$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md" "$ROOT_DIR/Documentation/Generated/Latest-Release-Proof.md" "$ROOT_DIR/Documentation/Generated/Flagship-Demo-Pack.md"
bash Scripts/generate-device-evidence-handoff.sh "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md" "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md" "$ROOT_DIR/Documentation/Generated/public-proof-status.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md" "$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json"
bash Scripts/generate-evidence-provenance-report.sh "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Documentation/Generated/Evidence-Provenance.md"

required_artifacts=(
  "Benchmarks/Results/latest/benchmark-report.json"
  "Benchmarks/Results/latest/benchmark-summary.md"
  "Benchmarks/Results/latest/environment.json"
)

for artifact in "${required_artifacts[@]}"; do
  if [[ ! -f "$artifact" ]]; then
    echo "Missing required release artifact: $artifact" >&2
    echo "Run 'bash Scripts/run-benchmarks.sh standard' before cutting a release." >&2
    exit 1
  fi
done

bash Scripts/validate-benchmarks.sh standard "$ROOT_DIR/Benchmarks/Results/latest"
bash Scripts/validate-transfer-chain.sh "$ROOT_DIR/Benchmarks/Results/latest"
bash Scripts/validate-device-evidence.sh "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Benchmarks/device-matrix-policy.json"
bash Scripts/validate-device-capture-packets.sh "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md"
bash Scripts/validate-device-evidence-issue-schema.sh "$ROOT_DIR/.github/ISSUE_TEMPLATE/device_evidence.yml" "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets" "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/device-evidence-form-policy.json"
bash Scripts/validate-device-evidence-queue.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md" "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json"
bash Scripts/validate-public-proof-status.sh "$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md" "$ROOT_DIR/Documentation/Generated/Release-Blockers.md" "$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md" "$ROOT_DIR/Documentation/Generated/public-proof-status.json"
bash Scripts/validate-device-evidence-handoff.sh "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json" "$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md" "$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json"
bash Scripts/validate-release-workflow-assets.sh "$ROOT_DIR/.github/workflows/release.yml" "$ROOT_DIR/Documentation/release-asset-policy.json"
bash Scripts/validate-release-provenance.sh "$ROOT_DIR/Benchmarks/Results"
bash Scripts/validate-release-evidence-assets.sh "$ROOT_DIR/Benchmarks/Results"
bash Scripts/validate-benchmark-thresholds.sh "$ROOT_DIR/Benchmarks/Results/latest" "$ROOT_DIR/Benchmarks/Results" "$ROOT_DIR/Benchmarks/benchmark-thresholds.json"

echo "Release validation succeeded."

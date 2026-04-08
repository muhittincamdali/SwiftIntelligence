#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
GENERATED_DIR="${2:-$ROOT_DIR/Documentation/Generated}"
WORKFLOW_PATH="${3:-$ROOT_DIR/.github/workflows/release.yml}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$GENERATED_DIR" != /* ]]; then
  GENERATED_DIR="$ROOT_DIR/$GENERATED_DIR"
fi

if [[ "$WORKFLOW_PATH" != /* ]]; then
  WORKFLOW_PATH="$ROOT_DIR/$WORKFLOW_PATH"
fi

ACTIVE_RESULTS_DIR="$RESULTS_ROOT/latest"
ACTIVE_PROFILE="standard"

if [[ ! -f "$ACTIVE_RESULTS_DIR/benchmark-report.json" && -f "$RESULTS_ROOT/ci-smoke/benchmark-report.json" ]]; then
  ACTIVE_RESULTS_DIR="$RESULTS_ROOT/ci-smoke"
  ACTIVE_PROFILE="smoke"
fi

bash "$ROOT_DIR/Scripts/generate-proof-snapshot.sh" "$ACTIVE_RESULTS_DIR" "$GENERATED_DIR/Proof-Snapshot.md"
bash "$ROOT_DIR/Scripts/generate-benchmark-history.sh" "$RESULTS_ROOT" "$GENERATED_DIR/Benchmark-History.md" "$GENERATED_DIR/Benchmark-Comparison.md" "$GENERATED_DIR/Benchmark-Methodology.md" "$GENERATED_DIR/Benchmark-Timeline.md" "$GENERATED_DIR/Release-Benchmark-Matrix.md" "$GENERATED_DIR/Release-Proof-Timeline.md" "$GENERATED_DIR/Latest-Release-Proof.md"
bash "$ROOT_DIR/Scripts/generate-benchmark-readiness-report.sh" "$RESULTS_ROOT" "$GENERATED_DIR/Benchmark-Readiness.md" "$ROOT_DIR/Benchmarks/benchmark-thresholds.json" "$ROOT_DIR/Benchmarks/device-matrix-policy.json"
bash "$ROOT_DIR/Scripts/generate-release-candidate-plan.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$GENERATED_DIR/Release-Candidate-Plan.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-plan.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$ROOT_DIR/Benchmarks/device-matrix-policy.json" "$GENERATED_DIR/Device-Evidence-Plan.md"
bash "$ROOT_DIR/Scripts/generate-device-coverage-matrix.sh" "$RESULTS_ROOT" "$ROOT_DIR/Benchmarks/device-matrix-policy.json" "$GENERATED_DIR/Device-Coverage-Matrix.md"
bash "$ROOT_DIR/Scripts/generate-device-capture-packets.sh" "$GENERATED_DIR/Device-Evidence-Plan.md" "$GENERATED_DIR/Device-Coverage-Matrix.md" "$GENERATED_DIR/Device-Capture-Packets" "$GENERATED_DIR/Device-Capture-Packets.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-runbook.sh" "$GENERATED_DIR/Device-Evidence-Plan.md" "$GENERATED_DIR/Device-Coverage-Matrix.md" "$GENERATED_DIR/Device-Evidence-Runbook.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-intake.sh" "$GENERATED_DIR/Device-Capture-Packets.md" "$GENERATED_DIR/Device-Evidence-Runbook.md" "$GENERATED_DIR/Device-Evidence-Intake.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-queue.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$GENERATED_DIR/Device-Evidence-Intake.md" "$GENERATED_DIR/Device-Evidence-Queue.md" "$GENERATED_DIR/device-evidence-queue.json"
bash "$ROOT_DIR/Scripts/generate-release-blockers.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$GENERATED_DIR/Device-Capture-Packets.md" "$GENERATED_DIR/Device-Evidence-Intake.md" "$GENERATED_DIR/Release-Blockers.md"
bash "$ROOT_DIR/Scripts/validate-flagship-media-assets.sh" "$ROOT_DIR/Documentation/flagship-media-policy.json" "$ROOT_DIR/Documentation/Assets/Flagship-Demo/README.md"
bash "$ROOT_DIR/Scripts/generate-flagship-media-status.sh" "$ROOT_DIR/Documentation/flagship-media-policy.json" "$ROOT_DIR/Documentation/Assets/Flagship-Demo/README.md" "$GENERATED_DIR/Flagship-Media-Status.md" "$GENERATED_DIR/flagship-media-status.json"
bash "$ROOT_DIR/Scripts/generate-public-proof-status.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$GENERATED_DIR/Release-Blockers.md" "$GENERATED_DIR/Public-Proof-Status.md" "$GENERATED_DIR/public-proof-status.json"
bash "$ROOT_DIR/Scripts/generate-flagship-demo-pack.sh" "$GENERATED_DIR/Public-Proof-Status.md" "$GENERATED_DIR/Latest-Release-Proof.md" "$GENERATED_DIR/Flagship-Demo-Pack.md"
bash "$ROOT_DIR/Scripts/generate-device-evidence-handoff.sh" "$GENERATED_DIR/Device-Evidence-Queue.md" "$GENERATED_DIR/device-evidence-queue.json" "$GENERATED_DIR/Device-Evidence-Intake.md" "$GENERATED_DIR/Device-Evidence-Runbook.md" "$GENERATED_DIR/public-proof-status.json" "$GENERATED_DIR/Device-Evidence-Handoff.md" "$GENERATED_DIR/device-evidence-handoff.json"
bash "$ROOT_DIR/Scripts/generate-evidence-provenance-report.sh" "$RESULTS_ROOT" "$GENERATED_DIR/Evidence-Provenance.md"
bash "$ROOT_DIR/Scripts/validate-benchmarks.sh" "$ACTIVE_PROFILE" "$ACTIVE_RESULTS_DIR"
bash "$ROOT_DIR/Scripts/validate-transfer-chain.sh" "$ACTIVE_RESULTS_DIR"
bash "$ROOT_DIR/Scripts/validate-device-evidence.sh" "$RESULTS_ROOT" "$ROOT_DIR/Benchmarks/device-matrix-policy.json"
bash "$ROOT_DIR/Scripts/validate-device-capture-packets.sh" "$GENERATED_DIR/Device-Coverage-Matrix.md" "$GENERATED_DIR/Device-Capture-Packets" "$GENERATED_DIR/Device-Capture-Packets.md"
bash "$ROOT_DIR/Scripts/validate-device-evidence-issue-schema.sh" "$ROOT_DIR/.github/ISSUE_TEMPLATE/device_evidence.yml" "$GENERATED_DIR/Device-Capture-Packets" "$GENERATED_DIR/Device-Coverage-Matrix.md" "$ROOT_DIR/Documentation/device-evidence-form-policy.json"
bash "$ROOT_DIR/Scripts/validate-device-evidence-queue.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$GENERATED_DIR/Device-Evidence-Queue.md" "$GENERATED_DIR/device-evidence-queue.json"
bash "$ROOT_DIR/Scripts/validate-public-proof-status.sh" "$GENERATED_DIR/Benchmark-Readiness.md" "$GENERATED_DIR/Release-Blockers.md" "$GENERATED_DIR/Public-Proof-Status.md" "$GENERATED_DIR/public-proof-status.json"
bash "$ROOT_DIR/Scripts/validate-public-claims.sh" "$ROOT_DIR/Documentation/public-claims-policy.json"
bash "$ROOT_DIR/Scripts/validate-device-evidence-handoff.sh" "$GENERATED_DIR/device-evidence-queue.json" "$GENERATED_DIR/Device-Evidence-Handoff.md" "$GENERATED_DIR/device-evidence-handoff.json"
bash "$ROOT_DIR/Scripts/validate-release-workflow-assets.sh" "$WORKFLOW_PATH" "$ROOT_DIR/Documentation/release-asset-policy.json"
bash "$ROOT_DIR/Scripts/validate-release-provenance.sh" "$RESULTS_ROOT"
bash "$ROOT_DIR/Scripts/validate-release-evidence-assets.sh" "$RESULTS_ROOT"

if [[ "$ACTIVE_PROFILE" == "standard" ]]; then
  bash "$ROOT_DIR/Scripts/validate-benchmark-thresholds.sh" "$ACTIVE_RESULTS_DIR" "$RESULTS_ROOT" "$ROOT_DIR/Benchmarks/benchmark-thresholds.json"
else
  echo "Benchmark regression threshold gate skipped for '$ACTIVE_PROFILE' profile."
fi

echo "Proof surfaces validated."

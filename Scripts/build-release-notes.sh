#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_TAG="${1:-}"
EVIDENCE_DIR="${2:-}"
OUTPUT_PATH="${3:-}"
REPOSITORY_NAME="${4:-SwiftIntelligence}"

if [[ -z "$RELEASE_TAG" || -z "$EVIDENCE_DIR" ]]; then
  echo "Usage: bash Scripts/build-release-notes.sh <release-tag> <evidence-dir> [output-path] [repository-name]" >&2
  exit 1
fi

if [[ "$EVIDENCE_DIR" != /* ]]; then
  EVIDENCE_DIR="$ROOT_DIR/$EVIDENCE_DIR"
fi

if [[ -z "$OUTPUT_PATH" ]]; then
  OUTPUT_PATH="$EVIDENCE_DIR/release-body.md"
elif [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

CHANGELOG_PATH="$ROOT_DIR/CHANGELOG.md"
RELEASE_NOTES_PROOF_PATH="$EVIDENCE_DIR/release-notes-proof.md"
PUBLIC_PROOF_STATUS_PATH="$EVIDENCE_DIR/public-proof-status.md"
RELEASE_BLOCKERS_PATH="$EVIDENCE_DIR/release-blockers.md"
HANDOFF_MD_PATH="$EVIDENCE_DIR/device-evidence-handoff.md"
HANDOFF_ARCHIVE_PATH="$EVIDENCE_DIR/device-evidence-handoff.tar.gz"
RELEASE_VERSION="${RELEASE_TAG#v}"

if [[ ! -f "$CHANGELOG_PATH" ]]; then
  echo "Missing CHANGELOG: $CHANGELOG_PATH" >&2
  exit 1
fi

if [[ ! -f "$RELEASE_NOTES_PROOF_PATH" ]]; then
  echo "Missing release notes proof: $RELEASE_NOTES_PROOF_PATH" >&2
  exit 1
fi

CHANGELOG_SECTION="$(
  awk -v version="$RELEASE_VERSION" '
    BEGIN {
      in_section = 0
    }
    $0 ~ "^## " version " - " {
      in_section = 1
      next
    }
    /^## / && in_section {
      exit
    }
    in_section {
      print
    }
  ' "$CHANGELOG_PATH"
)"

has_changelog_section="true"
if [[ -z "${CHANGELOG_SECTION//$'\n'/}" ]]; then
  has_changelog_section="false"
  CHANGELOG_SECTION=$'- immutable benchmark evidence snapshot for `'"$RELEASE_TAG"$'`\n- generated without a matching numbered CHANGELOG release section'
fi

is_numbered_release="false"
if [[ "$RELEASE_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9]+)*$ ]]; then
  is_numbered_release="true"
fi

publish_readiness="unknown"
distribution_posture="unknown"
flagship_media_status="unknown"
if [[ -f "$PUBLIC_PROOF_STATUS_PATH" ]]; then
  publish_readiness="$(ruby -e 'text = File.read(ARGV[0]); puts(text[/Publish readiness: `([^`]+)`/, 1] || "unknown")' "$PUBLIC_PROOF_STATUS_PATH")"
  distribution_posture="$(ruby -e 'text = File.read(ARGV[0]); puts(text[/Distribution posture: `([^`]+)`/, 1] || "unknown")' "$PUBLIC_PROOF_STATUS_PATH")"
  flagship_media_status="$(ruby -e 'text = File.read(ARGV[0]); puts(text[/Flagship media status: `([^`]+)`/, 1] || "unknown")' "$PUBLIC_PROOF_STATUS_PATH")"
fi

{
  printf '## Why This Release Matters\n\n'
  printf -- '- SwiftIntelligence currently ships a validated flagship workflow: `Vision -> NLP -> Privacy`\n'
  printf -- '- Release posture: `%s / %s`\n' "$publish_readiness" "$distribution_posture"
  printf -- '- Fastest first proof path: `bash Scripts/validate-flagship-demo.sh`\n'
  printf '\n'
  printf '## Proof Pack\n\n'
  printf -- '- [release-notes-proof.md](release-notes-proof.md)\n'
  printf -- '- [release-proof.md](release-proof.md)\n'
  printf -- '- [public-proof-status.md](public-proof-status.md)\n'
  printf -- '- [benchmark-summary.md](benchmark-summary.md)\n'
  printf -- '- [flagship-demo-pack.md](flagship-demo-pack.md)\n'
  printf -- '- `flagship-demo-share-pack.tar.gz`\n'
  printf '\n'
  printf '## Flagship Demo Path\n\n'
  printf -- '- Demo: `Intelligent Camera`\n'
  printf -- '- Flow: `Vision -> NLP -> Privacy`\n'
  printf -- '- Fastest app run: `macOS 14+` or `iOS 17+`, then tap `Analyze Frame`\n'
  printf -- '- First proof command: `bash Scripts/validate-flagship-demo.sh`\n'
  printf -- '- Success signals: populated `Top labels`, populated `OCR`, generated `Summary`, tokenized `Privacy preview`\n'
  if [[ "$flagship_media_status" == "published" ]]; then
    printf -- '- Published media ships inside `flagship-demo-share-pack.tar.gz` (`intelligent-camera-success.png`, `intelligent-camera-run.mp4`, `caption.txt`)\n'
  fi
  printf '\n'
  printf '## What'\''s Changed\n\n'
  printf '%s\n\n' "$CHANGELOG_SECTION"
  if [[ "$has_changelog_section" != "true" ]]; then
    printf '_No numbered CHANGELOG section matched this bundle, so this section documents the immutable evidence snapshot rather than a tagged GitHub release._\n\n'
  fi
  cat "$RELEASE_NOTES_PROOF_PATH"
  printf '\n\n'
  if [[ "$is_numbered_release" == "true" ]]; then
    printf '## Installation\n\n'
    printf '### Swift Package Manager\n'
    printf '```swift\n'
    printf 'dependencies: [\n'
    printf '    .package(url: "https://github.com/muhittincamdali/%s.git", from: "%s")\n' "$REPOSITORY_NAME" "$RELEASE_VERSION"
    printf ']\n'
    printf '```\n'
  else
    printf '## Installation\n\n'
    printf 'Installation snippet omitted because `%s` is an immutable evidence snapshot, not a numbered package release tag.\n' "$RELEASE_TAG"
  fi
} > "$OUTPUT_PATH"

echo "Release notes written to $OUTPUT_PATH"

bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$EVIDENCE_DIR" "$EVIDENCE_DIR/artifact-manifest.json" "$EVIDENCE_DIR/checksums.txt" >/dev/null

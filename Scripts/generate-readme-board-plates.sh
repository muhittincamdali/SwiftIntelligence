#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_FILE="$ROOT_DIR/Documentation/Assets/Readme/readme-board-imagegen-prompts.jsonl"
OUTPUT_DIR="$ROOT_DIR/Documentation/Assets/Readme/Generated-Plates"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
IMAGE_GEN="${IMAGE_GEN:-$CODEX_HOME/skills/imagegen/scripts/image_gen.py}"

if [[ ! -f "$PROMPTS_FILE" ]]; then
  echo "Missing prompts file: $PROMPTS_FILE" >&2
  exit 1
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "OPENAI_API_KEY is not set." >&2
  exit 1
fi

if [[ ! -f "$IMAGE_GEN" ]]; then
  echo "Missing image generation CLI: $IMAGE_GEN" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

python3 "$IMAGE_GEN" generate-batch \
  --input "$PROMPTS_FILE" \
  --out-dir "$OUTPUT_DIR" \
  --model gpt-image-1.5 \
  --quality high \
  --output-format png \
  --force

echo "Generated README board plates in: $OUTPUT_DIR"

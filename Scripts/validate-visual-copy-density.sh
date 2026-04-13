#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_PATH="$ROOT_DIR/Documentation/visual-copy-policy.json"

python3 - "$ROOT_DIR" "$POLICY_PATH" <<'PY'
import json
import pathlib
import re
import sys

root_dir = pathlib.Path(sys.argv[1])
policy_path = pathlib.Path(sys.argv[2])
policy = json.loads(policy_path.read_text())

def visible_text_stats(svg_text: str) -> tuple[int, int, int]:
    matches = re.findall(r"<text[^>]*>(.*?)</text>", svg_text, re.S)
    values = [re.sub(r"\s+", " ", match.strip()) for match in matches]
    values = [value for value in values if value]
    text_nodes = len(values)
    max_chars = max((len(value) for value in values), default=0)
    total_chars = sum(len(value) for value in values)
    return text_nodes, max_chars, total_chars

for surface in policy["surfaces"]:
    asset_path = root_dir / surface["asset"]
    label = surface["label"]

    if not asset_path.exists():
      raise SystemExit(f"Missing visual asset for copy-density validation: {asset_path}")

    svg_text = asset_path.read_text()
    text_nodes, max_chars, total_chars = visible_text_stats(svg_text)

    if text_nodes > surface["max_text_nodes"]:
        raise SystemExit(
            f"{label} exceeds max_text_nodes: {text_nodes} > {surface['max_text_nodes']}"
        )

    if max_chars > surface["max_chars_per_node"]:
        raise SystemExit(
            f"{label} exceeds max_chars_per_node: {max_chars} > {surface['max_chars_per_node']}"
        )

    if total_chars > surface["max_total_chars"]:
        raise SystemExit(
            f"{label} exceeds max_total_chars: {total_chars} > {surface['max_total_chars']}"
        )

print(f"Visual copy density validated for {len(policy['surfaces'])} surfaces.")
PY

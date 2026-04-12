#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

expected_files=(
  "README.md"
  "README_AR.md"
  "README_DE.md"
  "README_ES.md"
  "README_FR.md"
  "README_HI.md"
  "README_ID.md"
  "README_IT.md"
  "README_JA.md"
  "README_KO.md"
  "README_NL.md"
  "README_PL.md"
  "README_PT-BR.md"
  "README_RU.md"
  "README_TR.md"
  "README_UK.md"
  "README_VI.md"
  "README_ZH-CN.md"
)

language_hub="$ROOT_DIR/Documentation/README-Languages.md"
summary_line_limit=100

[[ -f "$language_hub" ]] || {
  echo "Missing README language hub: $language_hub" >&2
  exit 1
}

for file in "${expected_files[@]}"; do
  path="$ROOT_DIR/$file"
  [[ -f "$path" ]] || {
    echo "Missing localized README: $file" >&2
    exit 1
  }

  grep -q "Documentation/README-Languages.md" "$path" || {
    echo "Missing language hub link in $file" >&2
    exit 1
  }

  grep -q "README.md" "$path" || {
    echo "Missing English README link in $file" >&2
    exit 1
  }

  if [[ "$file" != "README.md" ]]; then
    grep -q "canonical and most complete" "$path" || {
      echo "Missing canonical-English note in $file" >&2
      exit 1
    }

    line_count="$(wc -l < "$path" | tr -d ' ')"
    [[ "$line_count" -le "$summary_line_limit" ]] || {
      echo "$file exceeds localized summary budget of $summary_line_limit lines ($line_count)." >&2
      exit 1
    }
  fi
done

actual_count="$(printf '%s\n' "${expected_files[@]}" | wc -l | tr -d ' ')"

grep -q "README Languages" "$ROOT_DIR/README.md" || {
  echo "README.md must expose README language surfaces." >&2
  exit 1
}

grep -q "README Languages" "$ROOT_DIR/README_TR.md" || {
  echo "README_TR.md must expose README language surfaces." >&2
  exit 1
}

grep -q "canonical and most complete" "$language_hub" || {
  echo "README language hub must document English as the canonical README surface." >&2
  exit 1
}

echo "README localization surfaces validated for $actual_count languages."

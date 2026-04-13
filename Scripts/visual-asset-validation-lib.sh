#!/usr/bin/env bash
set -euo pipefail

host_renderer_major() {
  sw_vers -productVersion | cut -d. -f1
}

render_svg_snapshot() {
  local source_asset="$1"
  local raster_width="$2"
  local output_asset="$3"
  local temp_dir="$4"
  local temp_snapshot

  rm -f "$output_asset"
  qlmanage -t -s "$raster_width" -o "$temp_dir" "$source_asset" >/dev/null
  temp_snapshot="$temp_dir/$(basename "$source_asset").png"

  [[ -f "$temp_snapshot" ]] || {
    echo "Quick Look rasterization failed for $source_asset" >&2
    exit 1
  }

  mv "$temp_snapshot" "$output_asset"
}

require_svg_contract() {
  local asset="$1"
  local label="$2"

  [[ -f "$asset" ]] || {
    echo "Missing $label visual asset: $asset" >&2
    exit 1
  }

  xmllint --noout "$asset"

  grep -q 'viewBox="' "$asset" || {
    echo "Missing viewBox in $label visual asset." >&2
    exit 1
  }

  grep -q 'preserveAspectRatio="xMidYMid meet"' "$asset" || {
    echo "Missing preserveAspectRatio contract in $label visual asset." >&2
    exit 1
  }

  grep -q 'font-family=' "$asset" || {
    echo "Missing font-family declaration in $label visual asset." >&2
    exit 1
  }
}

require_visual_baseline() {
  local baseline_asset="$1"
  local manifest_asset="$2"
  local label="$3"

  [[ -f "$baseline_asset" ]] || {
    echo "Missing $label visual baseline: $baseline_asset" >&2
    exit 1
  }

  [[ -f "$manifest_asset" ]] || {
    echo "Missing $label visual manifest: $manifest_asset" >&2
    exit 1
  }
}

manifest_renderer_major() {
  local manifest_asset="$1"
  awk -F= '/^renderer_major=/{print $2}' "$manifest_asset"
}

manifest_svg_checksum() {
  local manifest_asset="$1"
  local filename="$2"
  awk -v filename="$filename" '$1 == filename {print $2}' "$manifest_asset"
}

validate_svg_source_checksum() {
  local asset="$1"
  local manifest_asset="$2"
  local label="$3"
  local filename
  local expected_checksum
  local actual_checksum

  filename="$(basename "$asset")"
  expected_checksum="$(manifest_svg_checksum "$manifest_asset" "$filename")"

  [[ -n "$expected_checksum" ]] || {
    echo "Missing source checksum entry for $filename in $manifest_asset" >&2
    exit 1
  }

  actual_checksum="$(shasum -a 256 "$asset" | awk '{print $1}')"

  [[ "$actual_checksum" == "$expected_checksum" ]] || {
    echo "$label source drift detected for $filename." >&2
    echo "Expected source checksum: $expected_checksum" >&2
    echo "Actual source checksum:   $actual_checksum" >&2
    echo "Refresh visual baselines only if the redesign is intentional." >&2
    exit 1
  }
}

validate_snapshot_dimensions() {
  local rasterized_asset="$1"
  local baseline_asset="$2"
  local label="$3"
  local actual_width
  local actual_height
  local baseline_width
  local baseline_height

  actual_width="$(sips -g pixelWidth "$rasterized_asset" | awk '/pixelWidth/ {print $2}')"
  actual_height="$(sips -g pixelHeight "$rasterized_asset" | awk '/pixelHeight/ {print $2}')"
  baseline_width="$(sips -g pixelWidth "$baseline_asset" | awk '/pixelWidth/ {print $2}')"
  baseline_height="$(sips -g pixelHeight "$baseline_asset" | awk '/pixelHeight/ {print $2}')"

  [[ "$actual_width" == "$baseline_width" ]] || {
    echo "Unexpected $label snapshot width: $actual_width (expected baseline $baseline_width)" >&2
    exit 1
  }

  [[ "$actual_height" == "$baseline_height" ]] || {
    echo "Unexpected $label snapshot height: $actual_height (expected baseline $baseline_height)" >&2
    exit 1
  }
}

validate_snapshot_checksum_if_renderer_matches() {
  local rasterized_asset="$1"
  local baseline_asset="$2"
  local manifest_asset="$3"
  local label="$4"
  local filename="$5"
  local host_major
  local baseline_major
  local current_checksum
  local baseline_checksum

  host_major="$(host_renderer_major)"
  baseline_major="$(manifest_renderer_major "$manifest_asset")"

  [[ -n "$baseline_major" ]] || {
    echo "Missing renderer_major in $manifest_asset" >&2
    exit 1
  }

  if [[ "$host_major" != "$baseline_major" ]]; then
    echo "Skipping raster checksum for $filename on macOS $host_major; baseline renderer is macOS $baseline_major."
    return 0
  fi

  current_checksum="$(shasum -a 256 "$rasterized_asset" | awk '{print $1}')"
  baseline_checksum="$(shasum -a 256 "$baseline_asset" | awk '{print $1}')"

  [[ "$current_checksum" == "$baseline_checksum" ]] || {
    echo "$label visual regression detected for $filename." >&2
    echo "Baseline renderer major: $baseline_major" >&2
    echo "Actual raster checksum:   $current_checksum" >&2
    echo "Expected raster checksum: $baseline_checksum" >&2
    echo "Refresh baseline only if the visual redesign is intentional." >&2
    exit 1
  }
}

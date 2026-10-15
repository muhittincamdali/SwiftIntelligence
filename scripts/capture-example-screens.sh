#!/usr/bin/env bash
# Captures the README screenshots of the KnowledgeDemo example app on an iPhone simulator.
#
# The script builds and installs the app, opens each screen with `-screen <name>`, and takes a
# simulator screenshot in light and dark appearance with a fixed status bar. The screens show
# the package's real output for the demo articles; nothing is drawn by hand. The Ask screen
# needs Apple Intelligence on the Mac that runs the simulator, and its wording changes from run
# to run because it is the on-device model's answer.
#
# Usage: scripts/capture-example-screens.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ -z "$device" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

bundle_id="io.github.muhittincamdali.KnowledgeDemo"
screens=(search ask redact)
output_dir="$repo_root/docs/images"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
mkdir -p "$output_dir"

echo "Building KnowledgeDemo for '$device'"
destination="platform=iOS Simulator,name=$device"
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  destination="platform=iOS Simulator,id=$device"
fi
xcodebuild build \
  -project "$repo_root/Examples/KnowledgeDemo/KnowledgeDemo.xcodeproj" \
  -scheme KnowledgeDemo \
  -destination "$destination" \
  -derivedDataPath "$build_dir" \
  -quiet
app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'KnowledgeDemo.app' -path '*iphonesimulator*' | head -1)"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""
xcrun simctl install "$device" "$app"

for appearance in light dark; do
  xcrun simctl ui "$device" appearance "$appearance"
  for screen in "${screens[@]}"; do
    xcrun simctl launch --terminate-running-process "$device" "$bundle_id" -screen "$screen" \
      -AppleLanguages "(en)" -AppleLocale en_US >/dev/null
    # Let the articles load and the first search finish; the on-device model needs longer.
    if [[ "$screen" == ask ]]; then sleep 20; else sleep 5; fi
    file="$output_dir/example-$screen-$appearance.png"
    xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
    # Half the width of an iPhone screenshot keeps the README light.
    width="$(sips -g pixelWidth "$file" | awk '/pixelWidth/ {print $2}')"
    sips --resampleWidth $((width / 2)) "$file" >/dev/null
    echo "$file"
  done
done

xcrun simctl status_bar "$device" clear
xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true

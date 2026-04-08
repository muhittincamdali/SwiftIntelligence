#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Example validation currently requires macOS because the examples depend on SwiftUI/AppKit/UIKit." >&2
  exit 1
fi

ONLY_TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      if [[ $# -lt 2 ]]; then
        echo "--only requires a target name." >&2
        exit 1
      fi
      ONLY_TARGET="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/swiftintelligence-examples.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

escape_swift_string() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

ROOT_DIR_SWIFT="$(escape_swift_string "$ROOT_DIR")"

AVAILABLE_TARGETS=(
  "BasicUsageValidation"
  "AdvancedFeaturesValidation"
  "AIServiceClientValidation"
  "VoiceAssistantValidation"
  "SmartTranslatorValidation"
  "IntelligentCameraValidation"
  "PersonalAITutorValidation"
  "ARCreativeStudioValidation"
)

if [[ -n "$ONLY_TARGET" ]]; then
  TARGET_FOUND=0
  for target in "${AVAILABLE_TARGETS[@]}"; do
    if [[ "$target" == "$ONLY_TARGET" ]]; then
      TARGET_FOUND=1
      break
    fi
  done

  if [[ "$TARGET_FOUND" -ne 1 ]]; then
    printf 'Unknown validation target: %s\nAvailable targets:\n' "$ONLY_TARGET" >&2
    printf '  - %s\n' "${AVAILABLE_TARGETS[@]}" >&2
    exit 1
  fi
fi

should_include_target() {
  local target_name="$1"
  [[ -z "$ONLY_TARGET" || "$ONLY_TARGET" == "$target_name" ]]
}

cat > "$TEMP_DIR/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceExampleValidation",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "$ROOT_DIR_SWIFT")
    ],
    targets: [
EOF

append_target_definition() {
  cat <<EOF >> "$TEMP_DIR/Package.swift"
        .executableTarget(
            name: "$1",
            dependencies: [
$2
            ]
        ),
EOF
}

if should_include_target "BasicUsageValidation"; then
  append_target_definition "BasicUsageValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceML", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "AdvancedFeaturesValidation"; then
  append_target_definition "AdvancedFeaturesValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceML", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "AIServiceClientValidation"; then
  append_target_definition "AIServiceClientValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "VoiceAssistantValidation"; then
  append_target_definition "VoiceAssistantValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "SmartTranslatorValidation"; then
  append_target_definition "SmartTranslatorValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "IntelligentCameraValidation"; then
  append_target_definition "IntelligentCameraValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "PersonalAITutorValidation"; then
  append_target_definition "PersonalAITutorValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceML", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")'
fi

if should_include_target "ARCreativeStudioValidation"; then
  append_target_definition "ARCreativeStudioValidation" '                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence")'
fi

cat >> "$TEMP_DIR/Package.swift" <<'EOF'
    ]
)
EOF

mkdir -p "$TEMP_DIR/Sources"

copy_main_target() {
  local target_name="$1"
  local source_file="$2"
  mkdir -p "$TEMP_DIR/Sources/$target_name"
  cp "$source_file" "$TEMP_DIR/Sources/$target_name/main.swift"
}

copy_support_target() {
  local target_name="$1"
  shift
  mkdir -p "$TEMP_DIR/Sources/$target_name"
  for source_file in "$@"; do
    cp "$source_file" "$TEMP_DIR/Sources/$target_name/$(basename "$source_file")"
  done
}

if should_include_target "BasicUsageValidation"; then
  copy_main_target "BasicUsageValidation" "$ROOT_DIR/Examples/BasicUsage.swift"
fi

if should_include_target "VoiceAssistantValidation"; then
  copy_main_target "VoiceAssistantValidation" "$ROOT_DIR/Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift"
fi

if should_include_target "SmartTranslatorValidation"; then
  copy_main_target "SmartTranslatorValidation" "$ROOT_DIR/Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift"
fi

if should_include_target "IntelligentCameraValidation"; then
  copy_main_target "IntelligentCameraValidation" "$ROOT_DIR/Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift"
fi

if should_include_target "PersonalAITutorValidation"; then
  copy_main_target "PersonalAITutorValidation" "$ROOT_DIR/Examples/DemoApps/PersonalAITutor/PersonalAITutorApp.swift"
fi

if should_include_target "ARCreativeStudioValidation"; then
  copy_main_target "ARCreativeStudioValidation" "$ROOT_DIR/Examples/DemoApps/ARCreativeStudio/ARCreativeStudioApp.swift"
fi

if should_include_target "AdvancedFeaturesValidation"; then
  copy_support_target \
    "AdvancedFeaturesValidation" \
    "$ROOT_DIR/Examples/AdvancedFeatures.swift"

  cat > "$TEMP_DIR/Sources/AdvancedFeaturesValidation/main.swift" <<'EOF'
import Foundation

_ = AdvancedFeaturesDemo.self
print("AdvancedFeatures.swift typechecked successfully")
EOF
fi

if should_include_target "AIServiceClientValidation"; then
  copy_support_target \
    "AIServiceClientValidation" \
    "$ROOT_DIR/Examples/ServerIntegration/AIServiceClient.swift" \
    "$ROOT_DIR/Examples/ServerIntegration/RateLimiter.swift"

  cat > "$TEMP_DIR/Sources/AIServiceClientValidation/main.swift" <<'EOF'
import Foundation

_ = AIServiceClient.self
print("AIServiceClient.swift typechecked successfully")
EOF
fi

if [[ -n "$ONLY_TARGET" ]]; then
  echo "Validating SwiftIntelligence example target: $ONLY_TARGET"
  swift build --package-path "$TEMP_DIR" --target "$ONLY_TARGET"
else
  echo "Validating SwiftIntelligence examples via temporary package..."
  swift build --package-path "$TEMP_DIR"
fi

echo "Example validation succeeded."

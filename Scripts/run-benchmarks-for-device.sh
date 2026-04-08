#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="standard"
OUTPUT_DIR="$ROOT_DIR/Benchmarks/Results/latest"
SNAPSHOT_NAME=""
DEVICE_NAME=""
DEVICE_MODEL=""
DEVICE_CLASS=""
PLATFORM_FAMILY=""
SYSTEM_ON_CHIP=""
NOTES=""
EXPORT_ARCHIVE=""
DESTINATION_ID=""

usage() {
  cat <<'EOF'
Usage: bash Scripts/run-benchmarks-for-device.sh [options]

Options:
  --profile VALUE           Benchmark profile. Default: standard
  --output-dir PATH         Artifact output directory. Default: Benchmarks/Results/latest
  --snapshot-name VALUE     Optional immutable archive snapshot name
  --device-name VALUE       Friendly device name override
  --device-model VALUE      Device model identifier override
  --device-class VALUE      Required normalized device class (Mac, iPhone, iPad, visionOS, tvOS, watchOS)
  --platform-family VALUE   Platform family override (macOS, iOS, iPadOS, visionOS, tvOS, watchOS)
  --soc VALUE               Optional system-on-chip label
  --notes VALUE             Optional metadata notes
  --export-archive PATH     Optional `.tar.gz` export path for transfer after validation
  --destination-id VALUE    Optional connected device UDID to target
  --help                    Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --snapshot-name)
      SNAPSHOT_NAME="$2"
      shift 2
      ;;
    --device-name)
      DEVICE_NAME="$2"
      shift 2
      ;;
    --device-model)
      DEVICE_MODEL="$2"
      shift 2
      ;;
    --device-class)
      DEVICE_CLASS="$2"
      shift 2
      ;;
    --platform-family)
      PLATFORM_FAMILY="$2"
      shift 2
      ;;
    --soc)
      SYSTEM_ON_CHIP="$2"
      shift 2
      ;;
    --notes)
      NOTES="$2"
      shift 2
      ;;
    --export-archive)
      EXPORT_ARCHIVE="$2"
      shift 2
      ;;
    --destination-id)
      DESTINATION_ID="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$DEVICE_CLASS" ]]; then
  echo "Missing required --device-class argument." >&2
  usage >&2
  exit 1
fi

if [[ "$OUTPUT_DIR" != /* ]]; then
  OUTPUT_DIR="$ROOT_DIR/$OUTPUT_DIR"
fi

if [[ -n "$EXPORT_ARCHIVE" && "$EXPORT_ARCHIVE" != /* ]]; then
  EXPORT_ARCHIVE="$ROOT_DIR/$EXPORT_ARCHIVE"
fi

normalize_platform_family() {
  case "$1" in
    Mac) echo "macOS" ;;
    iPhone) echo "iOS" ;;
    iPad) echo "iPadOS" ;;
    visionOS) echo "visionOS" ;;
    tvOS) echo "tvOS" ;;
    watchOS) echo "watchOS" ;;
    *) echo "Unknown" ;;
  esac
}

select_development_team() {
  if [[ -n "${SI_IOS_DEVELOPMENT_TEAM:-}" ]]; then
    echo "$SI_IOS_DEVELOPMENT_TEAM"
    return 0
  fi

  ruby <<'RUBY'
defaults_output = `defaults read com.apple.dt.Xcode 2>/dev/null`
abort("Unable to read Xcode provisioning teams.") if defaults_output.nil? || defaults_output.empty?

teams = defaults_output.scan(/isFreeProvisioningTeam = (\d+);\s+teamID = ([A-Z0-9]+);\s+teamName = "([^"]+)";/m)
free_teams = teams.select { |is_free, _, _| is_free == "1" }
abort("No free provisioning team found in Xcode defaults.") if free_teams.empty?

preferred = free_teams.find { |(_, _, name)| name.include?("Muhittin") } || free_teams.first
puts preferred[1]
RUBY
}

report_xcodebuild_failure() {
  local build_log="$1"

  if [[ ! -f "$build_log" ]]; then
    echo "xcodebuild failed and no build log was captured." >&2
    return 1
  fi

  if rg -q "device is locked|Unlock .* to Continue" "$build_log"; then
    echo "Physical device benchmark capture failed because the device is locked. Unlock the device and keep it awake during capture." >&2
    return 1
  fi

  if rg -q "not been explicitly trusted by the user|invalid code signature, inadequate entitlements" "$build_log"; then
    echo "Physical device benchmark capture failed because the developer app/profile is not yet trusted on the device. Trust the developer profile on the device, then retry." >&2
    return 1
  fi

  if rg -q "No profiles for|Failed Registering Bundle Identifier|team has no devices from which to generate a provisioning profile" "$build_log"; then
    echo "Physical device benchmark capture failed during provisioning. Ensure the selected Xcode team can register the device and create a development profile." >&2
    return 1
  fi

  echo "Physical device benchmark capture failed. Inspect build log: $build_log" >&2
  tail -n 80 "$build_log" >&2
  return 1
}

extract_required_attachment() {
  local attachments_dir="$1"
  local artifact_name="$2"
  local destination_path="$3"
  local source_path manifest_path exported_filename

  source_path="$(find "$attachments_dir" -type f -name "$artifact_name" | head -n1)"

  if [[ -z "$source_path" ]]; then
    manifest_path="$attachments_dir/manifest.json"

    if [[ -f "$manifest_path" ]]; then
      exported_filename="$(ruby -rjson -e '
        manifest = JSON.parse(File.read(ARGV[0]))
        requested = ARGV[1]

        attachment = manifest
          .flat_map { |entry| Array(entry["attachments"]) }
          .find do |candidate|
            suggested = candidate["suggestedHumanReadableName"].to_s
            basename = suggested.sub(/_[^_]+\.[^.]+\z/, ".#{suggested.split(".").last}")
            suggested.start_with?(requested.sub(/\.[^.]+\z/, "")) || basename == requested
          end

        abort("") unless attachment
        puts attachment.fetch("exportedFileName")
      ' "$manifest_path" "$artifact_name" 2>/dev/null || true)"

      if [[ -n "$exported_filename" && -f "$attachments_dir/$exported_filename" ]]; then
        source_path="$attachments_dir/$exported_filename"
      fi
    fi
  fi

  if [[ -z "$source_path" ]]; then
    echo "Missing exported attachment: $artifact_name" >&2
    exit 1
  fi

  cp "$source_path" "$destination_path"
}

run_host_benchmarks() {
  if [[ -z "$DEVICE_NAME" || -z "$DEVICE_MODEL" ]]; then
    echo "Host benchmark capture requires --device-name and --device-model." >&2
    exit 1
  fi

  if [[ -z "$PLATFORM_FAMILY" ]]; then
    PLATFORM_FAMILY="$(normalize_platform_family "$DEVICE_CLASS")"
  fi

  export SI_BENCHMARK_DEVICE_NAME="$DEVICE_NAME"
  export SI_BENCHMARK_DEVICE_MODEL="$DEVICE_MODEL"
  export SI_BENCHMARK_DEVICE_CLASS="$DEVICE_CLASS"
  export SI_BENCHMARK_PLATFORM_FAMILY="$PLATFORM_FAMILY"

  if [[ -n "$SYSTEM_ON_CHIP" ]]; then
    export SI_BENCHMARK_SOC="$SYSTEM_ON_CHIP"
  fi

  if [[ -n "$NOTES" ]]; then
    export SI_BENCHMARK_NOTES="$NOTES"
  fi

  if [[ -n "$SNAPSHOT_NAME" ]]; then
    bash "$ROOT_DIR/Scripts/run-benchmarks.sh" "$PROFILE" "$OUTPUT_DIR" "$SNAPSHOT_NAME"
  else
    bash "$ROOT_DIR/Scripts/run-benchmarks.sh" "$PROFILE" "$OUTPUT_DIR"
  fi
}

run_physical_device_benchmarks() {
  local devices_json selected_device_json actual_udid actual_name actual_model actual_platform actual_nickname
  devices_json="$(mktemp "$ROOT_DIR/Benchmarks/Results/device-list.XXXXXX")"

  xcrun devicectl list devices --json-output "$devices_json" >/dev/null

  selected_device_json="$(ruby -rjson -e '
    payload = JSON.parse(File.read(ARGV[0]))
    expected_class = ARGV[1]
    requested_udid = ARGV[2]
    devices = Array(payload.dig("result", "devices"))

    matches = devices.select do |device|
      hardware = device["hardwareProperties"] || {}
      device_type = hardware["deviceType"]
      reality = hardware["reality"]
      pairing_state = device.dig("connectionProperties", "pairingState")
      udid = hardware["udid"]

      next false unless reality == "physical"
      next false unless pairing_state == "paired"
      next false unless requested_udid.empty? || udid == requested_udid
      next false unless device_type == expected_class

      true
    end

    abort("No connected physical #{expected_class} device matched.") if matches.empty?
    puts JSON.generate(matches.first)
  ' "$devices_json" "$DEVICE_CLASS" "$DESTINATION_ID")"

  actual_udid="$(ruby -rjson -e 'device = JSON.parse(ARGV[0]); puts device.dig("hardwareProperties", "udid")' "$selected_device_json")"
  actual_name="$(ruby -rjson -e 'device = JSON.parse(ARGV[0]); puts device.dig("hardwareProperties", "marketingName")' "$selected_device_json")"
  actual_model="$(ruby -rjson -e 'device = JSON.parse(ARGV[0]); puts device.dig("hardwareProperties", "productType")' "$selected_device_json")"
  actual_platform="$(ruby -rjson -e 'device = JSON.parse(ARGV[0]); puts device.dig("hardwareProperties", "platform")' "$selected_device_json")"
  actual_nickname="$(ruby -rjson -e 'device = JSON.parse(ARGV[0]); puts device.dig("deviceProperties", "name")' "$selected_device_json")"

  DEVICE_NAME="$actual_name"
  DEVICE_MODEL="$actual_model"
  PLATFORM_FAMILY="$actual_platform"
  DESTINATION_ID="$actual_udid"

  local notes_prefix
  notes_prefix="Captured on physical device via installed iOS benchmark host app; device alias: ${actual_nickname}; udid: ${actual_udid}"
  if [[ -n "$NOTES" ]]; then
    NOTES="${NOTES}; ${notes_prefix}"
  else
    NOTES="$notes_prefix"
  fi

  mkdir -p "$OUTPUT_DIR"

  local host_package_dir host_project_spec host_project_path derived_data build_log app_path bundle_identifier development_team bundle_suffix result_bundle attachments_dir test_identifier
  host_package_dir="$ROOT_DIR/DemoApps/iOS/SwiftIntelligenceBenchmarkHost"
  host_project_spec="$host_package_dir/project.yml"
  host_project_path="$host_package_dir/SwiftIntelligenceBenchmarkHost.xcodeproj"
  derived_data="$(mktemp -d "$ROOT_DIR/Benchmarks/Results/device-derived-data.XXXXXX")"
  build_log="$(mktemp "$ROOT_DIR/Benchmarks/Results/device-build-log.XXXXXX")"
  result_bundle="$(mktemp -d "$ROOT_DIR/Benchmarks/Results/device-xcresult.XXXXXX").xcresult"
  attachments_dir="$(mktemp -d "$ROOT_DIR/Benchmarks/Results/device-attachments.XXXXXX")"

  if [[ ! -d "$host_package_dir" ]]; then
    echo "Missing iOS benchmark host package: $host_package_dir" >&2
    exit 1
  fi

  if ! command -v xcodegen >/dev/null 2>&1; then
    echo "xcodegen is required to build the iOS benchmark host app." >&2
    exit 1
  fi

  if [[ ! -f "$host_project_spec" ]]; then
    echo "Missing benchmark host project spec: $host_project_spec" >&2
    exit 1
  fi

  (
    cd "$host_package_dir"
    xcodegen generate >/dev/null
  )

  if [[ ! -d "$host_project_path" ]]; then
    echo "Failed to generate benchmark host Xcode project." >&2
    exit 1
  fi

  development_team="$(select_development_team)"
  bundle_suffix="$(echo "${DEVICE_CLASS}-${development_team}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
  bundle_identifier="com.muhittincamdali.swiftintelligence.benchmarkhost.${bundle_suffix}"

  case "$PROFILE" in
    smoke)
      test_identifier="SwiftIntelligenceBenchmarkHostTests/DeviceBenchmarkCaptureTests/testSmokeProfileCapture"
      ;;
    standard)
      test_identifier="SwiftIntelligenceBenchmarkHostTests/DeviceBenchmarkCaptureTests/testStandardProfileCapture"
      ;;
    exhaustive)
      test_identifier="SwiftIntelligenceBenchmarkHostTests/DeviceBenchmarkCaptureTests/testExhaustiveProfileCapture"
      ;;
    *)
      echo "Unsupported profile for device capture: $PROFILE" >&2
      exit 1
      ;;
  esac

  rm -rf "$result_bundle"

  (
    cd "$host_package_dir"
    xcodebuild \
      -project "$host_project_path" \
      -scheme SwiftIntelligenceBenchmarkHost \
      -destination "platform=iOS,id=$DESTINATION_ID" \
      -derivedDataPath "$derived_data" \
      -resultBundlePath "$result_bundle" \
      -only-testing:"$test_identifier" \
      -allowProvisioningUpdates \
      -allowProvisioningDeviceRegistration \
      DEVELOPMENT_TEAM="$development_team" \
      APP_BUNDLE_IDENTIFIER="$bundle_identifier" \
      CODE_SIGN_STYLE=Automatic \
      test \
      >"$build_log"
  ) || report_xcodebuild_failure "$build_log"

  xcrun xcresulttool export attachments --path "$result_bundle" --output-path "$attachments_dir" >/dev/null

  rm -rf "$OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"

  extract_required_attachment "$attachments_dir" "benchmark-report.json" "$OUTPUT_DIR/benchmark-report.json"
  extract_required_attachment "$attachments_dir" "benchmark-summary.md" "$OUTPUT_DIR/benchmark-summary.md"
  extract_required_attachment "$attachments_dir" "environment.json" "$OUTPUT_DIR/environment.json"

  for required_artifact in benchmark-report.json benchmark-summary.md environment.json; do
    if [[ ! -f "$OUTPUT_DIR/$required_artifact" ]]; then
      echo "Missing expected device artifact: $required_artifact" >&2
      exit 1
    fi
  done

  export SI_BENCHMARK_DEVICE_NAME="$DEVICE_NAME"
  export SI_BENCHMARK_DEVICE_MODEL="$DEVICE_MODEL"
  export SI_BENCHMARK_DEVICE_CLASS="$DEVICE_CLASS"
  export SI_BENCHMARK_PLATFORM_FAMILY="$PLATFORM_FAMILY"

  if [[ -n "$SYSTEM_ON_CHIP" ]]; then
    export SI_BENCHMARK_SOC="$SYSTEM_ON_CHIP"
  fi

  if [[ -n "$NOTES" ]]; then
    export SI_BENCHMARK_NOTES="$NOTES"
  fi

  export SI_BENCHMARK_EVIDENCE_SOURCE_KIND="physical-device-test"
  export SI_BENCHMARK_EVIDENCE_SOURCE_PATH="$bundle_identifier@$DESTINATION_ID"

  bash "$ROOT_DIR/Scripts/generate-device-metadata.sh" "$OUTPUT_DIR" >/dev/null
  bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$OUTPUT_DIR" >/dev/null
  bash "$ROOT_DIR/Scripts/validate-benchmarks.sh" "$PROFILE" "$OUTPUT_DIR"

  if [[ -n "$SNAPSHOT_NAME" ]]; then
    SNAPSHOT_DIR="$(bash "$ROOT_DIR/Scripts/archive-benchmark-evidence.sh" "$OUTPUT_DIR" "$SNAPSHOT_NAME")"
    echo "Immutable evidence archived at: $SNAPSHOT_DIR"
  fi
}

if [[ "$DEVICE_CLASS" == "Mac" || "$PLATFORM_FAMILY" == "macOS" ]]; then
  run_host_benchmarks
else
  run_physical_device_benchmarks
fi

if [[ -n "$EXPORT_ARCHIVE" ]]; then
  bash "$ROOT_DIR/Scripts/export-benchmark-evidence.sh" "$OUTPUT_DIR" "$EXPORT_ARCHIVE"
fi

echo "Artifacts available at: $OUTPUT_DIR"

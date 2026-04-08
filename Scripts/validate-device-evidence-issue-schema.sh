#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISSUE_TEMPLATE_PATH="${1:-$ROOT_DIR/.github/ISSUE_TEMPLATE/device_evidence.yml}"
PACKETS_DIR="${2:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets}"
MATRIX_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md}"
POLICY_PATH="${4:-$ROOT_DIR/Documentation/device-evidence-form-policy.json}"

if [[ "$ISSUE_TEMPLATE_PATH" != /* ]]; then
  ISSUE_TEMPLATE_PATH="$ROOT_DIR/$ISSUE_TEMPLATE_PATH"
fi

if [[ "$PACKETS_DIR" != /* ]]; then
  PACKETS_DIR="$ROOT_DIR/$PACKETS_DIR"
fi

if [[ "$MATRIX_PATH" != /* ]]; then
  MATRIX_PATH="$ROOT_DIR/$MATRIX_PATH"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

ruby - "$ISSUE_TEMPLATE_PATH" "$PACKETS_DIR" "$MATRIX_PATH" "$POLICY_PATH" <<'RUBY'
require "json"
require "yaml"

issue_template_path, packets_dir, matrix_path, policy_path = ARGV

abort("Missing device evidence issue template: #{issue_template_path}") unless File.exist?(issue_template_path)
abort("Missing device coverage matrix: #{matrix_path}") unless File.exist?(matrix_path)
abort("Missing device capture packets directory: #{packets_dir}") unless Dir.exist?(packets_dir)
abort("Missing device evidence form policy: #{policy_path}") unless File.exist?(policy_path)

template = YAML.load_file(issue_template_path)
policy = JSON.parse(File.read(policy_path))
body = Array(template["body"])

field_specs = body.map do |item|
  next unless item.is_a?(Hash)
  next unless item["id"]
  next unless %w[dropdown input textarea].include?(item["type"])

  {
    "id" => item["id"],
    "type" => item["type"],
    "required" => item.dig("validations", "required") == true,
    "options" => Array(item.dig("attributes", "options"))
  }
end.compact

field_ids = field_specs.map { |spec| spec.fetch("id") }
spec_by_id = field_specs.each_with_object({}) { |spec, hash| hash[spec.fetch("id")] = spec }
matrix = File.read(matrix_path)
missing_classes = begin
  explicit = matrix[/Missing required release device classes: `([^`]+)`/, 1]
  explicit ? explicit.split(",").map(&:strip).reject(&:empty?) : []
end

errors = []

request_type_spec = spec_by_id["request_type"]
benchmark_profile_spec = spec_by_id["benchmark_profile"]
errors << "request_type field is missing from #{issue_template_path}" unless request_type_spec
errors << "benchmark_profile field is missing from #{issue_template_path}" unless benchmark_profile_spec

if request_type_spec && !request_type_spec.fetch("options").include?(policy.fetch("defaultRequestType"))
  errors << "defaultRequestType is not a valid issue template option"
end

if benchmark_profile_spec && !benchmark_profile_spec.fetch("options").include?(policy.fetch("defaultBenchmarkProfile"))
  errors << "defaultBenchmarkProfile is not a valid issue template option"
end

missing_classes.each do |device_class|
  slug = device_class.downcase
  issue_fields_path = File.join(packets_dir, slug, "issue-fields.json")
  issue_submission_path = File.join(packets_dir, slug, "issue-submission.md")

  unless File.exist?(issue_fields_path)
    errors << "Missing issue-fields.json for #{device_class}: #{issue_fields_path}"
    next
  end

  issue_fields = JSON.parse(File.read(issue_fields_path))
  required_ids = field_specs.select { |spec| spec.fetch("required") }.map { |spec| spec.fetch("id") }

  required_ids.each do |field_id|
    value = issue_fields[field_id]
    missing =
      if value.nil?
        true
      elsif value.is_a?(String)
        value.strip.empty?
      elsif value.is_a?(Array)
        value.empty?
      else
        false
      end

    errors << "Missing required field #{field_id} in #{issue_fields_path}" if missing
  end

  unknown_keys = issue_fields.keys - field_ids
  unknown_keys.each do |key|
    errors << "Unknown issue field #{key} in #{issue_fields_path}"
  end

  field_specs.each do |spec|
    field_id = spec.fetch("id")
    next unless issue_fields.key?(field_id)

    value = issue_fields[field_id]

    case spec.fetch("type")
    when "dropdown"
      options = spec.fetch("options")
      errors << "Invalid dropdown value for #{field_id} in #{issue_fields_path}" unless options.include?(value)
    when "input"
      errors << "Expected string for #{field_id} in #{issue_fields_path}" unless value.is_a?(String)
    when "textarea"
      valid = value.is_a?(String) || value.is_a?(Array)
      errors << "Expected string or array for #{field_id} in #{issue_fields_path}" unless valid
    end
  end

  errors << "device_class mismatch in #{issue_fields_path}" unless issue_fields["device_class"] == device_class
  errors << "request_type policy mismatch in #{issue_fields_path}" unless issue_fields["request_type"] == policy.fetch("defaultRequestType")
  errors << "benchmark_profile policy mismatch in #{issue_fields_path}" unless issue_fields["benchmark_profile"] == policy.fetch("defaultBenchmarkProfile")
  errors << "validation_commands policy mismatch in #{issue_fields_path}" unless issue_fields["validation_commands"] == Array(policy.fetch("validationCommands"))
  unless Array(issue_fields["artifact_paths"]).include?(policy.fetch("coverageArtifactPath"))
    errors << "artifact_paths policy mismatch in #{issue_fields_path}"
  end

  unless File.exist?(issue_submission_path)
    errors << "Missing issue-submission.md for #{device_class}: #{issue_submission_path}"
    next
  end

  submission = File.read(issue_submission_path)
  errors << "Issue submission missing device class heading in #{issue_submission_path}" unless submission.include?("# #{device_class} Device Evidence Submission")
  errors << "Issue submission missing template reference in #{issue_submission_path}" unless submission.include?(".github/ISSUE_TEMPLATE/device_evidence.yml")
  errors << "Issue submission intro mismatch in #{issue_submission_path}" unless submission.include?(policy.fetch("issueSubmissionIntro"))
end

if errors.empty?
  puts "Device evidence issue schema validated for #{missing_classes.length} pending class(es)."
  exit 0
end

warn "Device evidence issue schema validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
RUBY

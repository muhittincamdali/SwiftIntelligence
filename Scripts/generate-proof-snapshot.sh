#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="${1:-$ROOT_DIR/Benchmarks/Results/latest}"
OUTPUT_PATH="${2:-$ROOT_DIR/Documentation/Generated/Proof-Snapshot.md}"

if [[ "$RESULTS_DIR" != /* ]]; then
  RESULTS_DIR="$ROOT_DIR/$RESULTS_DIR"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

REPORT_PATH="$RESULTS_DIR/benchmark-report.json"
SUMMARY_PATH="$RESULTS_DIR/benchmark-summary.md"
ENVIRONMENT_PATH="$RESULTS_DIR/environment.json"

mkdir -p "$(dirname "$OUTPUT_PATH")"

if [[ ! -f "$REPORT_PATH" || ! -f "$SUMMARY_PATH" || ! -f "$ENVIRONMENT_PATH" ]]; then
  cat > "$OUTPUT_PATH" <<EOF
# Proof Snapshot

Last updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

Current benchmark artifacts are missing from \`$(realpath --relative-to="$ROOT_DIR" "$RESULTS_DIR" 2>/dev/null || echo "Benchmarks/Results/latest")\`.

Until fresh artifacts are generated and validated, public performance claims should be treated as unproven.

Expected files:

- \`benchmark-report.json\`
- \`benchmark-summary.md\`
- \`environment.json\`

Regenerate with:

\`\`\`bash
bash Scripts/run-benchmarks.sh standard
\`\`\`
EOF
  echo "Proof snapshot generated without benchmark artifacts."
  exit 0
fi

ruby - "$REPORT_PATH" "$SUMMARY_PATH" "$ENVIRONMENT_PATH" "$OUTPUT_PATH" <<'RUBY'
require "json"
require "time"

report_path, summary_path, environment_path, output_path = ARGV

report = JSON.parse(File.read(report_path))
environment = JSON.parse(File.read(environment_path))
summary_lines = File.readlines(summary_path, chomp: true)

results = report.fetch("results")
sorted_by_time = results.sort_by { |result| result["averageExecutionTime"].to_f }
fastest = sorted_by_time.first(3)
slowest = sorted_by_time.last(3).reverse
analysis = report.fetch("analysis")

module_examples = [
  ["Intelligent Camera", "Vision -> NLP -> Privacy", "Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift", "Examples/DemoApps/IntelligentCamera/README.md"],
  ["Smart Translator", "NLP -> Privacy -> Speech", "Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift"],
  ["Voice Assistant", "NLP -> Privacy -> Speech", "Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift"]
]

File.open(output_path, "w") do |file|
  bytes_to_mb = ->(value) { value.to_f / (1024 * 1024) }
  bytes_to_gb = ->(value) { value.to_f / (1024 * 1024 * 1024) }

  file.puts "# Proof Snapshot"
  file.puts
  file.puts "Generated from the current benchmark artifacts and maintained showcase flows."
  file.puts
  file.puts "- Generated at: #{report['generatedAt']}"
  file.puts "- Benchmark profile: `#{report['profile']}`"
  file.puts "- Framework version: `#{report['frameworkVersion']}`"
  file.puts "- Total workloads: `#{analysis['totalBenchmarks']}`"
  file.puts format("- Performance score: `%.2f`", analysis["performanceScore"].to_f)
  file.puts format("- Average execution time: `%.4fs`", analysis["averageExecutionTime"].to_f)
  file.puts "- Operating system: `#{environment['operatingSystemVersion']}`"
  file.puts "- Processor count: `#{environment['processorCount']}`"
  file.puts format("- Physical memory: `%.1f GB`", bytes_to_gb.call(environment["physicalMemory"]))
  file.puts
  file.puts "## Flagship Flows"
  file.puts

  module_examples.each do |name, flow, path, guide_path|
    line = "- `#{name}`: `#{flow}` via [`#{File.basename(path)}`](../../#{path})"
    if guide_path
      line += " and [demo guide](../../#{guide_path})"
    end
    file.puts line
  end

  file.puts
  file.puts "## Flagship Validation"
  file.puts
  file.puts "- `bash Scripts/validate-flagship-demo.sh`"
  file.puts "- `bash Scripts/validate-examples.sh`"
  file.puts "- [Flagship Demo Pack](Flagship-Demo-Pack.md)"

  file.puts
  file.puts "## Fastest Workloads"
  file.puts
  file.puts "| Workload | Avg (s) | Peak Memory (MB) |"
  file.puts "| --- | ---: | ---: |"
  fastest.each do |result|
    file.puts format("| %s | %.4f | %.1f |", result["name"], result["averageExecutionTime"].to_f, bytes_to_mb.call(result["peakMemoryUsage"]))
  end

  file.puts
  file.puts "## Slowest Workloads"
  file.puts
  file.puts "| Workload | Avg (s) | Peak Memory (MB) |"
  file.puts "| --- | ---: | ---: |"
  slowest.each do |result|
    file.puts format("| %s | %.4f | %.1f |", result["name"], result["averageExecutionTime"].to_f, bytes_to_mb.call(result["peakMemoryUsage"]))
  end

  file.puts
  file.puts "## Recommendations"
  file.puts

  recommendations = analysis["recommendations"] || []
  if recommendations.empty?
    file.puts "- No benchmark recommendations were emitted."
  else
    recommendations.each do |recommendation|
      file.puts "- #{recommendation}"
    end
  end

  file.puts
  file.puts "## Source Artifacts"
  file.puts
  file.puts "- [benchmark-summary.md](../../Benchmarks/Results/latest/benchmark-summary.md)"
  file.puts "- [benchmark-report.json](../../Benchmarks/Results/latest/benchmark-report.json)"
  file.puts "- [environment.json](../../Benchmarks/Results/latest/environment.json)"
  file.puts "- [Showcase](../Showcase.md)"
end
RUBY

echo "Proof snapshot generated at $OUTPUT_PATH"

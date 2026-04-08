import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct BenchmarkArtifactFile: Sendable {
    public let filename: String
    public let data: Data

    public init(filename: String, data: Data) {
        self.filename = filename
        self.data = data
    }
}

public struct BenchmarkRuntimeEnvironment: Codable, Sendable {
    public let profile: String
    public let hostname: String
    public let operatingSystemVersion: String
    public let processorCount: Int
    public let physicalMemory: UInt64

    public init(profile: String) {
        let processInfo = ProcessInfo.processInfo
        self.profile = profile
        self.hostname = processInfo.hostName
        self.operatingSystemVersion = processInfo.operatingSystemVersionString
        self.processorCount = processInfo.processorCount
        self.physicalMemory = processInfo.physicalMemory
    }
}

public enum BenchmarkArtifacts {
    public static func write(
        report: BenchmarkReport,
        profile: String,
        outputDirectory: URL
    ) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        for artifact in try makeArtifactFiles(report: report, profile: profile) {
            let destination = outputDirectory.appendingPathComponent(artifact.filename)
            try artifact.data.write(to: destination)
        }
    }

    public static func makeArtifactFiles(
        report: BenchmarkReport,
        profile: String
    ) throws -> [BenchmarkArtifactFile] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let environment = BenchmarkRuntimeEnvironment(profile: profile)
        let markdown = renderMarkdown(report: report, profile: profile)

        return [
            BenchmarkArtifactFile(
                filename: "benchmark-report.json",
                data: try encoder.encode(report)
            ),
            BenchmarkArtifactFile(
                filename: "environment.json",
                data: try encoder.encode(environment)
            ),
            BenchmarkArtifactFile(
                filename: "benchmark-summary.md",
                data: Data(markdown.utf8)
            )
        ]
    }

    private static func renderMarkdown(report: BenchmarkReport, profile: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let sortedResults = report.results.sorted { $0.averageExecutionTime < $1.averageExecutionTime }
        let slowest = sortedResults.suffix(5).reversed()
        let fastest = sortedResults.prefix(5)

        var markdown: [String] = []
        markdown.append("# SwiftIntelligence Benchmark Summary")
        markdown.append("")
        markdown.append("- Generated at: \(isoFormatter.string(from: report.generatedAt))")
        markdown.append("- Profile: `\(profile)`")
        markdown.append("- Framework version: `\(report.frameworkVersion)`")
        markdown.append("- Total workloads: `\(report.analysis.totalBenchmarks)`")
        markdown.append("- Performance score: `\(String(format: "%.2f", report.analysis.performanceScore))`")
        markdown.append("- Average execution time: `\(String(format: "%.4f", report.analysis.averageExecutionTime))s`")
        markdown.append("")
        markdown.append("## Top Insights")
        markdown.append("")
        markdown.append(contentsOf: report.analysis.insights.map { "- \($0)" })
        markdown.append("")
        markdown.append("## Recommendations")
        markdown.append("")
        markdown.append(contentsOf: report.analysis.recommendations.map { "- \($0)" })
        markdown.append("")
        markdown.append("## Fastest Workloads")
        markdown.append("")
        markdown.append("| Workload | Avg (s) | Peak Memory |")
        markdown.append("| --- | ---: | ---: |")
        for result in fastest {
            markdown.append("| \(result.name) | \(String(format: "%.4f", result.averageExecutionTime)) | \(ByteCountFormatter.string(fromByteCount: result.peakMemoryUsage, countStyle: .memory)) |")
        }
        markdown.append("")
        markdown.append("## Slowest Workloads")
        markdown.append("")
        markdown.append("| Workload | Avg (s) | Peak Memory |")
        markdown.append("| --- | ---: | ---: |")
        for result in slowest {
            markdown.append("| \(result.name) | \(String(format: "%.4f", result.averageExecutionTime)) | \(ByteCountFormatter.string(fromByteCount: result.peakMemoryUsage, countStyle: .memory)) |")
        }
        markdown.append("")
        markdown.append("## Artifact Contract")
        markdown.append("")
        markdown.append("- `benchmark-report.json`: machine-readable benchmark data")
        markdown.append("- `benchmark-summary.md`: human-readable summary")
        markdown.append("- `environment.json`: runtime metadata for reproducibility")
        markdown.append("- `device-metadata.json`: normalized device identity for coverage and release proof")
        markdown.append("")

        return markdown.joined(separator: "\n")
    }
}

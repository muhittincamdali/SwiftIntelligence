import Foundation
import SwiftIntelligenceBenchmarks

#if os(macOS)
@main
struct BenchmarksCLI {
    static func main() async {
        do {
            let options = try CLIOptions(arguments: Array(CommandLine.arguments.dropFirst()))
            let runner = AIBenchmarks()

            print("Running SwiftIntelligence benchmarks with profile '\(options.profile.rawValue)'...")
            let results = await runner.runBenchmarks(profile: options.profile)
            let rawReport = try runner.exportBenchmarkReport(results, profile: options.profile)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let report: BenchmarkReport
            if let decoded = try? decoder.decode(BenchmarkReport.self, from: rawReport) {
                report = decoded
            } else {
                report = try JSONDecoder().decode(BenchmarkReport.self, from: rawReport)
            }

            try writeArtifacts(report: report, options: options)

            print("Completed \(report.results.count) benchmark workloads.")
            print("Artifacts written to \(options.outputDirectory.path)")
            print("Performance score: \(String(format: "%.2f", report.analysis.performanceScore))")
        } catch {
            fputs("Benchmarks failed: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func writeArtifacts(report: BenchmarkReport, options: CLIOptions) throws {
        try BenchmarkArtifacts.write(
            report: report,
            profile: options.profile.rawValue,
            outputDirectory: options.outputDirectory
        )
    }
}

private struct CLIOptions {
    let profile: AIBenchmarks.Profile
    let outputDirectory: URL

    init(arguments: [String]) throws {
        var profile: AIBenchmarks.Profile = .standard
        var outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Benchmarks/Results/latest", isDirectory: true)

        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--profile":
                index += 1
                guard index < arguments.count, let parsed = AIBenchmarks.Profile(rawValue: arguments[index]) else {
                    throw CLIError.invalidProfile
                }
                profile = parsed
            case "--output-dir":
                index += 1
                guard index < arguments.count else {
                    throw CLIError.missingOutputDirectory
                }
                outputDirectory = URL(fileURLWithPath: arguments[index], isDirectory: true)
            case "--help", "-h":
                print(Self.help)
                exit(0)
            default:
                throw CLIError.unknownArgument(argument)
            }
            index += 1
        }

        self.profile = profile
        self.outputDirectory = outputDirectory
    }

    private static let help = """
    Usage: swift run -c release Benchmarks [--profile smoke|standard|exhaustive] [--output-dir PATH]

    Options:
      --profile      Benchmark intensity profile. Default: standard
      --output-dir   Directory for benchmark artifacts. Default: Benchmarks/Results/latest
    """
}

private enum CLIError: Error, CustomStringConvertible {
    case invalidProfile
    case missingOutputDirectory
    case unknownArgument(String)

    var description: String {
        switch self {
        case .invalidProfile:
            return "Invalid profile. Use one of: smoke, standard, exhaustive."
        case .missingOutputDirectory:
            return "Missing path after --output-dir."
        case .unknownArgument(let argument):
            return "Unknown argument: \(argument)"
        }
    }
}
#else
public enum BenchmarksDeviceBuildStub {
    public static func deviceBuildMarker() {}
}
#endif

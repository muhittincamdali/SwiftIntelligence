import Darwin
import Foundation
import SwiftIntelligenceBenchmarks
import SwiftUI

@main
struct SwiftIntelligenceBenchmarkHostApp: App {
    @StateObject private var runner = BenchmarkCaptureRunner()

    var body: some Scene {
        WindowGroup {
            BenchmarkCaptureView(state: runner.state)
                .task {
                    await runner.startIfRequested()
                }
        }
    }
}

private struct BenchmarkCaptureView: View {
    let state: BenchmarkCaptureRunner.State

    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftIntelligence Benchmark Host")
                .font(.title2)
                .fontWeight(.semibold)

            Text(statusText)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }

    private var statusText: String {
        switch state {
        case .idle:
            return "Waiting for benchmark capture request."
        case .running(let profile):
            return "Running \(profile) benchmark capture on this device."
        case .succeeded(let location):
            return "Capture completed. Artifacts written to \(location.path)."
        case .failed(let message):
            return "Capture failed: \(message)"
        }
    }
}

@MainActor
private final class BenchmarkCaptureRunner: ObservableObject {
    enum State {
        case idle
        case running(String)
        case succeeded(URL)
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    func startIfRequested() async {
        guard case .idle = state else { return }
        guard let request = CaptureRequest.fromEnvironment() else { return }

        state = .running(request.profile.rawValue)

        do {
            let outputDirectory = try request.prepareOutputDirectory()
            try Self.writeStatus(
                CaptureStatus(
                    state: "running",
                    profile: request.profile.rawValue,
                    outputDirectory: outputDirectory.path,
                    message: "Benchmark capture started.",
                    completedWorkloads: nil
                ),
                to: outputDirectory
            )

            let benchmarks = AIBenchmarks()
            let results = await benchmarks.runBenchmarks(profile: request.profile)
            let reportData = try benchmarks.exportBenchmarkReport(results, profile: request.profile)
            let report = try Self.decodeReport(from: reportData)

            try BenchmarkArtifacts.write(
                report: report,
                profile: request.profile.rawValue,
                outputDirectory: outputDirectory
            )

            try Self.writeStatus(
                CaptureStatus(
                    state: "completed",
                    profile: request.profile.rawValue,
                    outputDirectory: outputDirectory.path,
                    message: "Benchmark capture completed.",
                    completedWorkloads: report.results.count
                ),
                to: outputDirectory
            )

            state = .succeeded(outputDirectory)
            print("Benchmark capture completed at \(outputDirectory.path)")
            fflush(stdout)
            exit(EXIT_SUCCESS)
        } catch {
            let message = String(describing: error)
            state = .failed(message)

            if let fallbackDirectory = try? request.fallbackOutputDirectory() {
                try? Self.writeStatus(
                    CaptureStatus(
                        state: "failed",
                        profile: request.profile.rawValue,
                        outputDirectory: fallbackDirectory.path,
                        message: message,
                        completedWorkloads: nil
                    ),
                    to: fallbackDirectory
                )
            }

            fputs("Benchmark capture failed: \(message)\n", stderr)
            fflush(stderr)
            exit(EXIT_FAILURE)
        }
    }

    private static func decodeReport(from data: Data) throws -> BenchmarkReport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let report = try? decoder.decode(BenchmarkReport.self, from: data) {
            return report
        }

        return try JSONDecoder().decode(BenchmarkReport.self, from: data)
    }

    private static func writeStatus(_ status: CaptureStatus, to outputDirectory: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        let destination = outputDirectory.appendingPathComponent("capture-status.json")
        try encoder.encode(status).write(to: destination)
    }
}

private struct CaptureRequest {
    let profile: AIBenchmarks.Profile
    let sessionIdentifier: String

    static func fromEnvironment() -> CaptureRequest? {
        let environment = ProcessInfo.processInfo.environment
        let arguments = ProcessInfo.processInfo.arguments

        let requested = environment["SI_BENCHMARK_CAPTURE_MODE"] == "1" ||
            arguments.contains("--capture-benchmarks")

        guard requested else { return nil }

        let profileValue = environment["SI_BENCHMARK_PROFILE"] ?? "standard"
        let sessionIdentifier = environment["SI_BENCHMARK_SESSION_ID"] ?? "default"

        guard let profile = AIBenchmarks.Profile(rawValue: profileValue) else {
            return CaptureRequest(profile: .standard, sessionIdentifier: sessionIdentifier)
        }

        return CaptureRequest(profile: profile, sessionIdentifier: sessionIdentifier)
    }

    func prepareOutputDirectory() throws -> URL {
        let outputDirectory = try fallbackOutputDirectory()
        if FileManager.default.fileExists(atPath: outputDirectory.path) {
            try FileManager.default.removeItem(at: outputDirectory)
        }

        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        return outputDirectory
    }

    func fallbackOutputDirectory() throws -> URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        return documentsDirectory
            .appendingPathComponent("SwiftIntelligenceBenchmarkEvidence", isDirectory: true)
            .appendingPathComponent(sessionIdentifier, isDirectory: true)
    }
}

private struct CaptureStatus: Codable {
    let state: String
    let profile: String
    let outputDirectory: String
    let message: String
    let completedWorkloads: Int?
    let updatedAt: Date

    init(
        state: String,
        profile: String,
        outputDirectory: String,
        message: String,
        completedWorkloads: Int?
    ) {
        self.state = state
        self.profile = profile
        self.outputDirectory = outputDirectory
        self.message = message
        self.completedWorkloads = completedWorkloads
        self.updatedAt = Date()
    }
}

@preconcurrency import XCTest
@testable import SwiftIntelligenceBenchmarks

@MainActor
final class DeviceBenchmarkCaptureTests: XCTestCase {
    private struct CaptureManifest: Codable {
        let profile: String
        let artifacts: [String]
    }

    func testSmokeProfileCapture() async throws {
        try await capture(profile: .smoke)
    }

    func testStandardProfileCapture() async throws {
        try await capture(profile: .standard)
    }

    func testExhaustiveProfileCapture() async throws {
        try await capture(profile: .exhaustive)
    }

    private func capture(profile: AIBenchmarks.Profile) async throws {
        #if os(iOS)
        let runner = AIBenchmarks()
        let results = await runner.runBenchmarks(profile: profile)
        XCTAssertFalse(results.isEmpty, "Expected benchmark workloads to produce results.")

        let rawReport = try runner.exportBenchmarkReport(results, profile: profile)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let report = try decoder.decode(BenchmarkReport.self, from: rawReport)
        let artifacts = try BenchmarkArtifacts.makeArtifactFiles(report: report, profile: profile.rawValue)

        for artifact in artifacts {
            let attachment = XCTAttachment(
                data: artifact.data,
                uniformTypeIdentifier: artifact.filename.hasSuffix(".json") ? "public.json" : "public.plain-text"
            )
            attachment.name = artifact.filename
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        let manifestEncoder = JSONEncoder()
        manifestEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let manifest = try manifestEncoder.encode(
            CaptureManifest(
                profile: profile.rawValue,
                artifacts: artifacts.map(\.filename)
            )
        )

        let manifestAttachment = XCTAttachment(data: manifest, uniformTypeIdentifier: "public.json")
        manifestAttachment.name = "capture-manifest.json"
        manifestAttachment.lifetime = .keepAlways
        add(manifestAttachment)
        #else
        throw XCTSkip("Device capture tests are intended for physical iOS hardware.")
        #endif
    }
}

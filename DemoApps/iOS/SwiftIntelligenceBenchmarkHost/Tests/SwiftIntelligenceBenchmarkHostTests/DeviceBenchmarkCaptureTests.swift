import Foundation
import SwiftIntelligenceBenchmarks
import XCTest

@MainActor
final class DeviceBenchmarkCaptureTests: XCTestCase {
    func testSmokeProfileCapture() async throws {
        try await captureArtifacts(for: .smoke)
    }

    func testStandardProfileCapture() async throws {
        try await captureArtifacts(for: .standard)
    }

    func testExhaustiveProfileCapture() async throws {
        try await captureArtifacts(for: .exhaustive)
    }

    private func captureArtifacts(for profile: AIBenchmarks.Profile) async throws {
        let runner = AIBenchmarks()
        let results = await runner.runBenchmarks(profile: profile)
        let report = try decodeReport(
            from: runner.exportBenchmarkReport(results, profile: profile)
        )

        for artifact in try BenchmarkArtifacts.makeArtifactFiles(
            report: report,
            profile: profile.rawValue
        ) {
            let destination = try writeAttachment(named: artifact.filename, data: artifact.data)
            let attachment = try XCTAttachment(contentsOfFile: destination)
            attachment.name = artifact.filename
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    private func decodeReport(from data: Data) throws -> BenchmarkReport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let report = try? decoder.decode(BenchmarkReport.self, from: data) {
            return report
        }

        return try JSONDecoder().decode(BenchmarkReport.self, from: data)
    }

    private func writeAttachment(named filename: String, data: Data) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let destination = directory.appendingPathComponent(filename)
        try data.write(to: destination)
        return destination
    }
}

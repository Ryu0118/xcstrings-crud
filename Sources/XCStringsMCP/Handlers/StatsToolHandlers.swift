import Foundation
import MCP
import XCStringsKit

// MARK: - Stats Coverage Handler

struct StatsCoverageHandler: ToolHandler {
    static let toolName = "xcstrings_stats_coverage"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let compact = context.arguments.bool("compact", default: true)

        let parser = XCStringsParser(path: file)

        if compact {
            let stats = try await parser.getCompactStats()
            return try JSONEncoderHelper.encode(stats)
        } else {
            let stats = try await parser.getStats()
            return try JSONEncoderHelper.encode(stats)
        }
    }
}

// MARK: - Stats Progress Handler

struct StatsProgressHandler: ToolHandler {
    static let toolName = "xcstrings_stats_progress"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let language = try context.arguments.requireString("language")

        let parser = XCStringsParser(path: file)
        let progress = try await parser.getProgress(for: language)
        return try JSONEncoderHelper.encode(progress)
    }
}

// MARK: - Batch Stats Coverage Handler

struct BatchStatsCoverageHandler: ToolHandler {
    static let toolName = "xcstrings_batch_stats_coverage"

    func execute(with context: ToolContext) async throws -> String {
        let files = try context.arguments.requireStringArray("files")
        let compact = context.arguments.bool("compact", default: true)

        if compact {
            let batchCoverage = try XCStringsParser.getCompactBatchCoverage(paths: files)
            return try JSONEncoderHelper.encode(batchCoverage)
        } else {
            let batchCoverage = try XCStringsParser.getBatchCoverage(paths: files)
            return try JSONEncoderHelper.encode(batchCoverage)
        }
    }
}

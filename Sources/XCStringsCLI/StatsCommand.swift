import ArgumentParser
import Foundation
import XCStringsKit

struct StatsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stats",
        abstract: "Get statistics about translations",
        subcommands: [Coverage.self, Progress.self, BatchCoverage.self]
    )
}

extension StatsCommand {
    struct Coverage: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "coverage",
            abstract: "Get overall translation coverage statistics"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        @Flag(name: .long, help: "Compact output: only show languages under 100%")
        var compact = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            if compact {
                let stats = try await parser.getCompactStats()
                try CLIOutput.printJSON(stats, pretty: pretty)
            } else {
                let stats = try await parser.getStats()
                try CLIOutput.printJSON(stats, pretty: pretty)
            }
        }
    }

    struct Progress: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "progress",
            abstract: "Get translation progress for a specific language"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Language code to check progress for")
        var lang: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let progress = try await parser.getProgress(for: lang)
            try CLIOutput.printJSON(progress, pretty: pretty)
        }
    }

    struct BatchCoverage: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "batch-coverage",
            abstract: "Get token-efficient coverage statistics for multiple xcstrings files"
        )

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Paths to xcstrings files")
        var files: [String]

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        @Flag(name: .long, help: "Compact output: only show languages under 100%")
        var compact = false

        func validate() throws {
            if files.isEmpty {
                throw ValidationError("At least one file path must be specified")
            }
        }

        func run() async throws {
            if compact {
                let batchCoverage = try XCStringsParser.getCompactBatchCoverage(paths: files)
                try CLIOutput.printJSON(batchCoverage, pretty: pretty)
            } else {
                let batchCoverage = try XCStringsParser.getBatchCoverage(paths: files)
                try CLIOutput.printJSON(batchCoverage, pretty: pretty)
            }
        }
    }
}

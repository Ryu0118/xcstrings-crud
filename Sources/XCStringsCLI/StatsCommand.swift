import ArgumentParser
import Foundation
import XCStringsKit

struct StatsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stats",
        abstract: "Get statistics about translations",
        subcommands: [Coverage.self, Progress.self]
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

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let stats = try await parser.getStats()
            try CLIOutput.printJSON(stats, pretty: pretty)
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
}

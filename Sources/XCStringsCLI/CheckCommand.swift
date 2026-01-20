import ArgumentParser
import Foundation
import XCStringsKit

struct CheckCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Check key existence or coverage",
        subcommands: [Key.self, Coverage.self]
    )
}

extension CheckCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Check if a key exists"
        )

        @Argument(help: "The key to check")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Specific language to check (optional)")
        var lang: String?

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let exists = try await parser.checkKey(key, language: lang)
            print(exists)
        }
    }

    struct Coverage: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "coverage",
            abstract: "Check translation coverage for a specific key"
        )

        @Argument(help: "The key to check coverage for")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let coverage = try await parser.checkCoverage(key)
            try output(coverage, pretty: pretty)
        }
    }
}

// MARK: - Output Helper

private func output<T: Encodable>(_ value: T, pretty: Bool) throws {
    let encoder = JSONEncoder()
    if pretty {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    let data = try encoder.encode(value)
    if let json = String(data: data, encoding: .utf8) {
        print(json)
    }
}

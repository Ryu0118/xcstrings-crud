import ArgumentParser
import Foundation
import XCStringsKit

struct UpsertCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "upsert",
        abstract: "Add or update translations (upsert)",
        subcommands: [Key.self]
    )
}

extension UpsertCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Add or update a translation for a key"
        )

        @Argument(help: "The key to add or update translation for")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Language code for the translation")
        var lang: String

        @Option(name: .shortAndLong, help: "Translation value")
        var value: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            try await parser.upsertTranslation(key: key, language: lang, value: value)

            let result = CLIResult.success(message: "Translation upserted successfully")
            try output(result, pretty: pretty)
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

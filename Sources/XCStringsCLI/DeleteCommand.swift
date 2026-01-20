import ArgumentParser
import Foundation
import XCStringsKit

struct DeleteCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete keys or translations",
        subcommands: [Key.self]
    )
}

extension DeleteCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Delete a key or specific translation(s)"
        )

        @Argument(help: "The key to delete")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Language(s) to delete (e.g., -l ja en fr). If not specified, deletes entire key")
        var lang: [String] = []

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)

            if lang.isEmpty {
                try await parser.deleteKey(key)
                let result = CLIResult.success(message: "Key deleted successfully")
                try output(result, pretty: pretty)
            } else if lang.count == 1 {
                try await parser.deleteTranslation(key: key, language: lang[0])
                let result = CLIResult.success(message: "Translation for '\(lang[0])' deleted successfully")
                try output(result, pretty: pretty)
            } else {
                try await parser.deleteTranslations(key: key, languages: lang)
                let result = CLIResult.success(message: "Translations deleted successfully for \(lang.count) languages")
                try output(result, pretty: pretty)
            }
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

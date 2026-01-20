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
            abstract: "Delete a key or a specific translation"
        )

        @Argument(help: "The key to delete")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Specific language to delete (optional, deletes entire key if not specified)")
        var lang: String?

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)

            if let lang = lang {
                try await parser.deleteTranslation(key: key, language: lang)
            } else {
                try await parser.deleteKey(key)
            }

            let message = lang != nil
                ? "Translation for '\(lang!)' deleted successfully"
                : "Key deleted successfully"
            let result = CLIResult.success(message: message)
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

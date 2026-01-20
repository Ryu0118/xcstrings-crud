import ArgumentParser
import Foundation
import XCStringsKit

struct AddCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add new translations",
        subcommands: [Key.self]
    )
}

extension AddCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Add a translation for a key"
        )

        @Argument(help: "The key to add translation for")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Language code for the translation")
        var lang: String?

        @Option(name: .shortAndLong, help: "Translation value")
        var value: String?

        @Option(name: .long, help: "JSON object with multiple translations (e.g., '{\"ja\":\"こんにちは\",\"en\":\"Hello\"}')")
        var translations: String?

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)

            if let translationsJSON = translations {
                // 複数言語一括追加
                guard let data = translationsJSON.data(using: .utf8),
                      let translationDict = try? JSONDecoder().decode([String: String].self, from: data)
                else {
                    throw XCStringsError.invalidJSON(reason: "Invalid translations JSON format")
                }
                try await parser.addTranslations(key: key, translations: translationDict)
            } else if let lang = lang, let value = value {
                // 単一言語追加
                try await parser.addTranslation(key: key, language: lang, value: value)
            } else {
                throw ValidationError("Either --lang and --value, or --translations must be provided")
            }

            let result = CLIResult.success(message: "Translation added successfully")
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

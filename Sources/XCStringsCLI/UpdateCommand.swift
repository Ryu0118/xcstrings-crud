import ArgumentParser
import Foundation
import XCStringsKit

struct UpdateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update existing translations",
        subcommands: [Key.self]
    )
}

extension UpdateCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Update a translation for a key"
        )

        @Argument(help: "The key to update translation for")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Language code for the translation (use with -v)")
        var lang: String?

        @Option(name: .shortAndLong, help: "New translation value (use with -l)")
        var value: String?

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Translations in lang:value format (e.g., -t ja:こんにちは en:Hello)")
        var translations: [String] = []

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func validate() throws {
            let hasSingleLang = lang != nil && value != nil
            let hasMultiple = !translations.isEmpty

            if hasSingleLang && hasMultiple {
                throw ValidationError("Cannot use both -l/-v and -t options together")
            }

            if !hasSingleLang && !hasMultiple {
                throw ValidationError("Either -l and -v, or -t must be specified")
            }

            if (lang != nil) != (value != nil) {
                throw ValidationError("Both -l and -v must be specified together")
            }
        }

        func run() async throws {
            let parser = XCStringsParser(path: file)

            if !translations.isEmpty {
                let translationsDict = try TranslationParser.parse(translations)
                try await parser.updateTranslations(key: key, translations: translationsDict)
                let result = CLIResult.success(message: "Translations updated successfully for \(translationsDict.count) languages")
                try output(result, pretty: pretty)
            } else if let lang = lang, let value = value {
                try await parser.updateTranslation(key: key, language: lang, value: value)
                let result = CLIResult.success(message: "Translation updated successfully")
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

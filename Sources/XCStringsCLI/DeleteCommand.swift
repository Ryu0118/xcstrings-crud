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
            let result: CLIResult

            switch lang.count {
            case 0:
                try await parser.deleteKey(key)
                result = .success(message: "Key deleted successfully")
            case 1:
                try await parser.deleteTranslation(key: key, language: lang[0])
                result = .success(message: "Translation for '\(lang[0])' deleted successfully")
            default:
                try await parser.deleteTranslations(key: key, languages: lang)
                result = .success(message: "Translations deleted successfully for \(lang.count) languages")
            }

            try CLIOutput.printJSON(result, pretty: pretty)
        }
    }
}

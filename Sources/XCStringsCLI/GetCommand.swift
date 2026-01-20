import ArgumentParser
import Foundation
import XCStringsKit

struct GetCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get information about keys or translations",
        subcommands: [Key.self, SourceLanguage.self]
    )
}

extension GetCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Get translations for a specific key"
        )

        @Argument(help: "The key to get translations for")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Specific language to get (optional)")
        var lang: String?

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let translations = try await parser.getTranslation(key: key, language: lang)
            try CLIOutput.printJSON(translations, pretty: pretty)
        }
    }

    struct SourceLanguage: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "source-language",
            abstract: "Get the source language of the xcstrings file"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let sourceLanguage = try await parser.getSourceLanguage()
            print(sourceLanguage)
        }
    }
}

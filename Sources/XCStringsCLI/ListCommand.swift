import ArgumentParser
import Foundation
import XCStringsKit

struct ListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List keys, languages, or untranslated items",
        subcommands: [Keys.self, Languages.self, Untranslated.self]
    )
}

extension ListCommand {
    struct Keys: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "keys",
            abstract: "List all keys in the xcstrings file"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let keys = try await parser.listKeys()
            try CLIOutput.printJSON(keys, pretty: pretty)
        }
    }

    struct Languages: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "languages",
            abstract: "List all languages in the xcstrings file"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let languages = try await parser.listLanguages()
            try CLIOutput.printJSON(languages, pretty: pretty)
        }
    }

    struct Untranslated: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "untranslated",
            abstract: "List untranslated keys for a specific language"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Language code to check")
        var lang: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let untranslated = try await parser.listUntranslated(for: lang)
            try CLIOutput.printJSON(untranslated, pretty: pretty)
        }
    }
}

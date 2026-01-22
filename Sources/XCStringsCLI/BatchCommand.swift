import ArgumentParser
import Foundation
import XCStringsKit

struct BatchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "batch",
        abstract: "Batch operations for multiple keys",
        subcommands: [Check.self, Add.self, Update.self]
    )
}

extension BatchCommand {
    struct Check: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "check",
            abstract: "Check if multiple keys exist"
        )

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Keys to check")
        var keys: [String]

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Specific language to check (optional)")
        var lang: String?

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func validate() throws {
            if keys.isEmpty {
                throw ValidationError("At least one key must be specified")
            }
        }

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let result = try await parser.checkKeys(keys, language: lang)
            try CLIOutput.printJSON(result, pretty: pretty)
        }
    }

    struct Add: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "add",
            abstract: "Add translations for multiple keys at once"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Entries in key=lang:value,lang:value format (e.g., -e Hello=ja:こんにちは,en:Hello -e Goodbye=ja:さようなら)")
        var entries: [String]

        @Flag(name: .long, help: "Allow overwriting existing translations")
        var overwrite = false

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func validate() throws {
            if entries.isEmpty {
                throw ValidationError("At least one entry must be specified")
            }
        }

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let batchEntries = try entries.map { try BatchEntryParser.parse($0) }
            let result = try await parser.addTranslationsBatch(entries: batchEntries, allowOverwrite: overwrite)
            try CLIOutput.printJSON(result, pretty: pretty)
        }
    }

    struct Update: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "update",
            abstract: "Update translations for multiple keys at once"
        )

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Entries in key=lang:value,lang:value format (e.g., -e Hello=ja:こんにちは,en:Hello -e Goodbye=ja:さようなら)")
        var entries: [String]

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func validate() throws {
            if entries.isEmpty {
                throw ValidationError("At least one entry must be specified")
            }
        }

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let batchEntries = try entries.map { try BatchEntryParser.parse($0) }
            let result = try await parser.updateTranslationsBatch(entries: batchEntries)
            try CLIOutput.printJSON(result, pretty: pretty)
        }
    }
}

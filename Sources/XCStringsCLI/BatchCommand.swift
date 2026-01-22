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
            let batchEntries = try parseEntries(entries)
            let result = try await parser.addTranslationsBatch(entries: batchEntries, allowOverwrite: overwrite)
            try CLIOutput.printJSON(result, pretty: pretty)
        }

        private func parseEntries(_ inputs: [String]) throws -> [BatchTranslationEntry] {
            try inputs.map { input in
                try BatchEntryParser.parse(input)
            }
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
            let batchEntries = try parseEntries(entries)
            let result = try await parser.updateTranslationsBatch(entries: batchEntries)
            try CLIOutput.printJSON(result, pretty: pretty)
        }

        private func parseEntries(_ inputs: [String]) throws -> [BatchTranslationEntry] {
            try inputs.map { input in
                try BatchEntryParser.parse(input)
            }
        }
    }
}

/// Parser for batch entry format
enum BatchEntryParser {
    /// Parse "key=lang:value,lang:value" format
    /// Example: "Hello=ja:こんにちは,en:Hello"
    static func parse(_ input: String) throws -> BatchTranslationEntry {
        guard let equalsIndex = input.firstIndex(of: "=") else {
            throw BatchEntryParseError.invalidFormat(input)
        }

        let key = String(input[..<equalsIndex])
        let translationsStr = String(input[input.index(after: equalsIndex)...])

        guard !key.isEmpty else {
            throw BatchEntryParseError.emptyKey(input)
        }

        // Parse translations (comma-separated lang:value pairs)
        let pairs = translationsStr.split(separator: ",", omittingEmptySubsequences: false)
        var translations: [String: String] = [:]

        for pair in pairs {
            let pairStr = String(pair)
            guard let colonIndex = pairStr.firstIndex(of: ":") else {
                throw BatchEntryParseError.invalidTranslationFormat(pairStr)
            }

            let lang = String(pairStr[..<colonIndex])
            let value = String(pairStr[pairStr.index(after: colonIndex)...])

            guard !lang.isEmpty else {
                throw BatchEntryParseError.emptyLanguage(pairStr)
            }

            translations[lang] = value
        }

        if translations.isEmpty {
            throw BatchEntryParseError.noTranslations(input)
        }

        return BatchTranslationEntry(key: key, translations: translations)
    }
}

/// Errors for batch entry parsing
enum BatchEntryParseError: Error, LocalizedError {
    case invalidFormat(String)
    case emptyKey(String)
    case invalidTranslationFormat(String)
    case emptyLanguage(String)
    case noTranslations(String)

    var errorDescription: String? {
        switch self {
        case .invalidFormat(let input):
            return "Invalid batch entry format: '\(input)'. Expected 'key=lang:value,lang:value'"
        case .emptyKey(let input):
            return "Empty key in: '\(input)'"
        case .invalidTranslationFormat(let input):
            return "Invalid translation format: '\(input)'. Expected 'lang:value'"
        case .emptyLanguage(let input):
            return "Empty language code in: '\(input)'"
        case .noTranslations(let input):
            return "No translations specified for: '\(input)'"
        }
    }
}

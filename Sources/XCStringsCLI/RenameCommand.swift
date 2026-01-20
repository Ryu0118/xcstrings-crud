import ArgumentParser
import Foundation
import XCStringsKit

struct RenameCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rename",
        abstract: "Rename keys",
        subcommands: [Key.self]
    )
}

extension RenameCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Rename a key"
        )

        @Argument(help: "The key to rename")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .long, help: "New name for the key")
        var to: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            try await parser.renameKey(from: key, to: to)

            let result = CLIResult.success(message: "Key renamed from '\(key)' to '\(to)' successfully")
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

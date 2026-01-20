import ArgumentParser
import Foundation
import XCStringsKit

struct CreateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new xcstrings file"
    )

    @Argument(help: "Path for the new xcstrings file")
    var file: String

    @Option(name: .shortAndLong, help: "Source language code (default: en)")
    var sourceLanguage: String = "en"

    @Flag(name: .long, help: "Overwrite existing file if it exists")
    var overwrite = false

    @Flag(name: .long, help: "Output in pretty-printed JSON format")
    var pretty = false

    func run() async throws {
        try XCStringsParser.createFile(at: file, sourceLanguage: sourceLanguage, overwrite: overwrite)
        let result = CLIResult.success(message: "Created xcstrings file at '\(file)' with source language '\(sourceLanguage)'")
        try CLIOutput.printJSON(result, pretty: pretty)
    }
}

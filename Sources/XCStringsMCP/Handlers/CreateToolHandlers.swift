import Foundation
import MCP
import XCStringsKit

// MARK: - Create File Handler

struct CreateFileHandler: ToolHandler {
    static let toolName = "xcstrings_create_file"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let sourceLanguage = context.arguments.optionalString("sourceLanguage") ?? "en"
        let overwrite = context.arguments.bool("overwrite", default: false)

        try XCStringsParser.createFile(at: file, sourceLanguage: sourceLanguage, overwrite: overwrite)
        return "Created xcstrings file at '\(file)' with source language '\(sourceLanguage)'"
    }
}

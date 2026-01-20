import Foundation
import Testing
@testable import XCStringsKit

@Suite("File I/O operations for xcstrings files")
struct XCStringsFileHandlerTests {
    @Test("load returns XCStringsFile for valid file")
    func loadValidFile() throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = XCStringsFileHandler(path: path)
        let file = try handler.load()

        #expect(file.sourceLanguage == "en")
        #expect(file.strings.count == 1)
    }

    @Test("load throws fileNotFound for non-existent path")
    func loadNonExistentFile() {
        let handler = XCStringsFileHandler(path: "/nonexistent/path/file.xcstrings")

        #expect(throws: XCStringsError.self) {
            _ = try handler.load()
        }
    }

    @Test("load throws invalidFileFormat for invalid JSON")
    func loadInvalidJSON() throws {
        let path = try TestHelper.createTempFile(content: "{ invalid json }")
        defer { TestHelper.removeTempFile(at: path) }

        let handler = XCStringsFileHandler(path: path)

        #expect(throws: XCStringsError.self) {
            _ = try handler.load()
        }
    }

    @Test("save writes file to disk")
    func saveFile() throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.empty)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = XCStringsFileHandler(path: path)
        var file = try handler.load()

        file.strings["NewKey"] = StringEntry(localizations: [
            "en": Localization(stringUnit: StringUnit(state: "translated", value: "New Value")),
        ])

        try handler.save(file)

        // Verify by loading again
        let reloaded = try handler.load()
        #expect(reloaded.strings["NewKey"] != nil)
        #expect(reloaded.strings["NewKey"]?.localizations?["en"]?.stringUnit?.value == "New Value")
    }

    @Test("save preserves file structure")
    func savePreservesStructure() throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeyMultipleLangs)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = XCStringsFileHandler(path: path)
        let original = try handler.load()

        try handler.save(original)

        let reloaded = try handler.load()
        #expect(reloaded.sourceLanguage == original.sourceLanguage)
        #expect(reloaded.version == original.version)
        #expect(reloaded.strings.count == original.strings.count)
    }
}

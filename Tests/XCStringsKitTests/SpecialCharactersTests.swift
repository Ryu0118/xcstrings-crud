import Foundation
import Testing
@testable import XCStringsKit

@Suite("Special Characters Handling")
struct SpecialCharactersTests {
    @Test("Handles keys with format specifiers", arguments: [
        ("Hello, %@!", "ja", "こんにちは、%@！"),
        ("Items: %lld", "en", "Items: %lld"),
    ])
    func formatSpecifiers(key: String, language: String, expectedValue: String) async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.specialCharacters)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let translations = try await parser.getTranslation(key: key, language: language)

        #expect(translations[language]?.value == expectedValue)
    }

    @Test("Handles keys with escape sequences")
    func escapeSequences() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.specialCharacters)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        // JSON "Line1\\nLine2" becomes "Line1\nLine2" (backslash + n) after parsing
        let exists = try await parser.checkKey("Line1\\nLine2", language: nil)

        #expect(exists == true)
    }

    @Test("Add and retrieve translation with special characters")
    func addSpecialCharacters() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.empty)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let key = "Special: %@ with \"quotes\" and 'apostrophes'"
        let value = "Special: %@ with quotes"

        try await parser.addTranslation(key: key, language: "en", value: value)

        let translations = try await parser.getTranslation(key: key, language: "en")
        #expect(translations["en"]?.value == value)
    }
}

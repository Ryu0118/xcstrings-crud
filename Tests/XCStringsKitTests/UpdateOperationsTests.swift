import Foundation
import Testing
@testable import XCStringsKit

@Suite("Update Operations")
struct UpdateOperationsTests {
    @Test("updateTranslation updates existing translation", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "en", "Hi there"),
        (FixtureType.singleKeyMultipleLangs, "Hello", "ja", "やあ"),
        (FixtureType.multipleKeysPartialTranslations, "Welcome", "de", "Willkommen!"),
    ])
    func updateTranslation(fixture: FixtureType, key: String, language: String, newValue: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Get original value
        let originalTranslations = try await parser.getTranslation(key: key, language: language)
        let originalValue = originalTranslations[language]?.value
        #expect(originalValue != newValue)

        // Update translation
        try await parser.updateTranslation(key: key, language: language, value: newValue)

        // Verify update
        let updatedTranslations = try await parser.getTranslation(key: key, language: language)
        #expect(updatedTranslations[language]?.value == newValue)
    }

    @Test("updateTranslation throws for non-existent key", arguments: FixtureType.allCases)
    func updateTranslationNonExistentKey(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.updateTranslation(key: "NonExistentKey", language: "en", value: "Value")
        }
    }

    @Test("updateTranslation throws for non-existent language", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "fr"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "ja"),
    ])
    func updateTranslationNonExistentLanguage(fixture: FixtureType, key: String, language: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.updateTranslation(key: key, language: language, value: "Value")
        }
    }
}

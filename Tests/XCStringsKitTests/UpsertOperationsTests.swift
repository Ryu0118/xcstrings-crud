import Foundation
import Testing
@testable import XCStringsKit

@Suite("Upsert Operations")
struct UpsertOperationsTests {
    @Test("upsertTranslation creates new key", arguments: [
        FixtureType.empty,
        FixtureType.singleKeySingleLang,
    ])
    func upsertCreatesNewKey(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let newKey = "UpsertedKey"

        try await parser.upsertTranslation(key: newKey, language: "en", value: "Upserted Value")

        let exists = try await parser.checkKey(newKey, language: "en")
        #expect(exists == true)
    }

    @Test("upsertTranslation adds translation to existing key", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "ja", "こんにちは"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "de", "Auf Wiedersehen"),
    ])
    func upsertAddsTranslation(fixture: FixtureType, key: String, language: String, value: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Verify doesn't exist
        let beforeExists = try await parser.checkKey(key, language: language)
        #expect(beforeExists == false)

        try await parser.upsertTranslation(key: key, language: language, value: value)

        let afterExists = try await parser.checkKey(key, language: language)
        #expect(afterExists == true)
    }

    @Test("upsertTranslation updates existing translation", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "en", "Updated Hello"),
        (FixtureType.singleKeyMultipleLangs, "Hello", "ja", "更新されたこんにちは"),
    ])
    func upsertUpdatesTranslation(fixture: FixtureType, key: String, language: String, newValue: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Verify exists
        let beforeExists = try await parser.checkKey(key, language: language)
        #expect(beforeExists == true)

        try await parser.upsertTranslation(key: key, language: language, value: newValue)

        let translations = try await parser.getTranslation(key: key, language: language)
        #expect(translations[language]?.value == newValue)
    }
}

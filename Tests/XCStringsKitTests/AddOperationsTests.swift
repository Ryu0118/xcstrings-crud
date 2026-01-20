import Foundation
import Testing
@testable import XCStringsKit

@Suite("Add Operations")
struct AddOperationsTests {
    @Test("addTranslation adds new translation to existing key", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "ja", "こんにちは"),
        (FixtureType.singleKeySingleLang, "Hello", "de", "Hallo"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "ja", "さようなら"),
    ])
    func addTranslationToExistingKey(fixture: FixtureType, key: String, language: String, value: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Verify translation doesn't exist
        let beforeExists = try await parser.checkKey(key, language: language)
        #expect(beforeExists == false)

        // Add translation
        try await parser.addTranslation(key: key, language: language, value: value)

        // Verify translation was added
        let afterExists = try await parser.checkKey(key, language: language)
        #expect(afterExists == true)

        let translations = try await parser.getTranslation(key: key, language: language)
        #expect(translations[language]?.value == value)
    }

    @Test("addTranslation creates new key", arguments: [
        FixtureType.empty,
        FixtureType.singleKeySingleLang,
        FixtureType.multipleKeysPartialTranslations,
    ])
    func addTranslationNewKey(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let newKey = "BrandNewKey"
        let language = "en"
        let value = "Brand New Value"

        // Verify key doesn't exist
        let beforeExists = try await parser.checkKey(newKey, language: nil)
        #expect(beforeExists == false)

        // Add translation
        try await parser.addTranslation(key: newKey, language: language, value: value)

        // Verify key was created
        let afterExists = try await parser.checkKey(newKey, language: language)
        #expect(afterExists == true)

        let keys = try await parser.listKeys()
        #expect(keys.contains(newKey))
    }

    @Test("addTranslation throws when translation already exists", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "en"),
        (FixtureType.singleKeyMultipleLangs, "Hello", "ja"),
        (FixtureType.multipleKeysPartialTranslations, "Welcome", "de"),
    ])
    func addTranslationAlreadyExists(fixture: FixtureType, key: String, language: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.addTranslation(key: key, language: language, value: "New Value")
        }
    }
}

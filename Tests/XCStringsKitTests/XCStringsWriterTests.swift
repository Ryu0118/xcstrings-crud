import Foundation
import Testing
@testable import XCStringsKit

@Suite("Write and delete operations for xcstrings files")
struct XCStringsWriterTests {
    // MARK: - addTranslation

    @Test("addTranslation adds new key and translation")
    func addTranslationNewKey() throws {
        var file = try loadFixture(TestFixtures.empty)

        file = try XCStringsWriter.addTranslation(to: file, key: "NewKey", language: "en", value: "New Value")

        #expect(file.strings["NewKey"] != nil)
        #expect(file.strings["NewKey"]?.localizations?["en"]?.stringUnit?.value == "New Value")
    }

    @Test("addTranslation adds translation to existing key")
    func addTranslationExistingKey() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.addTranslation(to: file, key: "Hello", language: "ja", value: "こんにちは")

        #expect(file.strings["Hello"]?.localizations?["ja"]?.stringUnit?.value == "こんにちは")
        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Hello")
    }

    @Test("addTranslation throws when translation exists and allowOverwrite is false")
    func addTranslationThrowsWhenExists() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.addTranslation(to: file, key: "Hello", language: "en", value: "New Value")
        }
    }

    @Test("addTranslation overwrites when allowOverwrite is true")
    func addTranslationOverwrite() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.addTranslation(to: file, key: "Hello", language: "en", value: "Updated", allowOverwrite: true)

        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Updated")
    }

    // MARK: - addTranslations

    @Test("addTranslations adds multiple languages")
    func addTranslationsMultiple() throws {
        var file = try loadFixture(TestFixtures.empty)

        file = try XCStringsWriter.addTranslations(to: file, key: "Greeting", translations: [
            "en": "Hello",
            "ja": "こんにちは",
            "de": "Hallo",
        ])

        #expect(file.strings["Greeting"]?.localizations?["en"]?.stringUnit?.value == "Hello")
        #expect(file.strings["Greeting"]?.localizations?["ja"]?.stringUnit?.value == "こんにちは")
        #expect(file.strings["Greeting"]?.localizations?["de"]?.stringUnit?.value == "Hallo")
    }

    // MARK: - updateTranslation

    @Test("updateTranslation updates existing translation")
    func updateTranslation() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.updateTranslation(in: file, key: "Hello", language: "en", value: "Hi there")

        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Hi there")
    }

    @Test("updateTranslation throws for non-existent key")
    func updateTranslationKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.updateTranslation(in: file, key: "NonExistent", language: "en", value: "Value")
        }
    }

    @Test("updateTranslation throws for non-existent language")
    func updateTranslationLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.updateTranslation(in: file, key: "Hello", language: "ja", value: "Value")
        }
    }

    // MARK: - renameKey

    @Test("renameKey renames key")
    func renameKey() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.renameKey(in: file, from: "Hello", to: "Greeting")

        #expect(file.strings["Hello"] == nil)
        #expect(file.strings["Greeting"] != nil)
        #expect(file.strings["Greeting"]?.localizations?["en"]?.stringUnit?.value == "Hello")
    }

    @Test("renameKey throws for non-existent key")
    func renameKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.renameKey(in: file, from: "NonExistent", to: "NewName")
        }
    }

    @Test("renameKey throws when target key exists")
    func renameKeyTargetExists() throws {
        let file = try loadFixture(TestFixtures.multipleKeysPartialTranslations)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.renameKey(in: file, from: "Hello", to: "Goodbye")
        }
    }

    // MARK: - deleteKey

    @Test("deleteKey removes key")
    func deleteKey() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.deleteKey(from: file, key: "Hello")

        #expect(file.strings["Hello"] == nil)
    }

    @Test("deleteKey throws for non-existent key")
    func deleteKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteKey(from: file, key: "NonExistent")
        }
    }

    // MARK: - deleteTranslation

    @Test("deleteTranslation removes specific language")
    func deleteTranslation() throws {
        var file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        file = try XCStringsWriter.deleteTranslation(from: file, key: "Hello", language: "ja")

        #expect(file.strings["Hello"]?.localizations?["ja"] == nil)
        #expect(file.strings["Hello"]?.localizations?["en"] != nil)
    }

    @Test("deleteTranslation throws for non-existent key")
    func deleteTranslationKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteTranslation(from: file, key: "NonExistent", language: "en")
        }
    }

    @Test("deleteTranslation throws for non-existent language")
    func deleteTranslationLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteTranslation(from: file, key: "Hello", language: "fr")
        }
    }

    // MARK: - Helper

    private func loadFixture(_ content: String) throws -> XCStringsFile {
        let data = content.data(using: .utf8)!
        return try JSONDecoder().decode(XCStringsFile.self, from: data)
    }
}

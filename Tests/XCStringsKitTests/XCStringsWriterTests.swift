import Foundation
import Testing
@testable import XCStringsKit

@Suite("Write and delete operations for xcstrings files")
struct XCStringsWriterTests {
    // MARK: - addTranslation

    @Test
    func addTranslationNewKey() throws {
        var file = try loadFixture(TestFixtures.empty)

        file = try XCStringsWriter.addTranslation(to: file, key: "NewKey", language: "en", value: "New Value")

        #expect(file.strings["NewKey"] != nil)
        #expect(file.strings["NewKey"]?.localizations?["en"]?.stringUnit?.value == "New Value")
    }

    @Test
    func addTranslationExistingKey() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.addTranslation(to: file, key: "Hello", language: "ja", value: "こんにちは")

        #expect(file.strings["Hello"]?.localizations?["ja"]?.stringUnit?.value == "こんにちは")
        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Hello")
    }

    @Test
    func addTranslationThrowsWhenExists() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.addTranslation(to: file, key: "Hello", language: "en", value: "New Value")
        }
    }

    @Test
    func addTranslationOverwrite() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.addTranslation(to: file, key: "Hello", language: "en", value: "Updated", allowOverwrite: true)

        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Updated")
    }

    // MARK: - addTranslations

    @Test
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

    @Test
    func updateTranslation() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.updateTranslation(in: file, key: "Hello", language: "en", value: "Hi there")

        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Hi there")
    }

    @Test
    func updateTranslationKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.updateTranslation(in: file, key: "NonExistent", language: "en", value: "Value")
        }
    }

    @Test
    func updateTranslationLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.updateTranslation(in: file, key: "Hello", language: "ja", value: "Value")
        }
    }

    // MARK: - updateTranslations

    @Test
    func updateTranslationsMultiple() throws {
        var file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        file = try XCStringsWriter.updateTranslations(in: file, key: "Hello", translations: [
            "en": "Hi",
            "ja": "やあ",
            "de": "Hi",
        ])

        #expect(file.strings["Hello"]?.localizations?["en"]?.stringUnit?.value == "Hi")
        #expect(file.strings["Hello"]?.localizations?["ja"]?.stringUnit?.value == "やあ")
        #expect(file.strings["Hello"]?.localizations?["de"]?.stringUnit?.value == "Hi")
    }

    @Test
    func updateTranslationsKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.updateTranslations(in: file, key: "NonExistent", translations: ["en": "Value"])
        }
    }

    @Test
    func updateTranslationsLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.updateTranslations(in: file, key: "Hello", translations: ["fr": "Bonjour"])
        }
    }

    // MARK: - renameKey

    @Test
    func renameKey() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.renameKey(in: file, from: "Hello", to: "Greeting")

        #expect(file.strings["Hello"] == nil)
        #expect(file.strings["Greeting"] != nil)
        #expect(file.strings["Greeting"]?.localizations?["en"]?.stringUnit?.value == "Hello")
    }

    @Test
    func renameKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.renameKey(in: file, from: "NonExistent", to: "NewName")
        }
    }

    @Test
    func renameKeyTargetExists() throws {
        let file = try loadFixture(TestFixtures.multipleKeysPartialTranslations)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.renameKey(in: file, from: "Hello", to: "Goodbye")
        }
    }

    // MARK: - deleteKey

    @Test
    func deleteKey() throws {
        var file = try loadFixture(TestFixtures.singleKeySingleLang)

        file = try XCStringsWriter.deleteKey(from: file, key: "Hello")

        #expect(file.strings["Hello"] == nil)
    }

    @Test
    func deleteKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteKey(from: file, key: "NonExistent")
        }
    }

    // MARK: - deleteTranslation

    @Test
    func deleteTranslation() throws {
        var file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        file = try XCStringsWriter.deleteTranslation(from: file, key: "Hello", language: "ja")

        #expect(file.strings["Hello"]?.localizations?["ja"] == nil)
        #expect(file.strings["Hello"]?.localizations?["en"] != nil)
    }

    @Test
    func deleteTranslationKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteTranslation(from: file, key: "NonExistent", language: "en")
        }
    }

    @Test
    func deleteTranslationLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteTranslation(from: file, key: "Hello", language: "fr")
        }
    }

    // MARK: - deleteTranslations

    @Test
    func deleteTranslationsMultiple() throws {
        var file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        file = try XCStringsWriter.deleteTranslations(from: file, key: "Hello", languages: ["ja", "de"])

        #expect(file.strings["Hello"]?.localizations?["ja"] == nil)
        #expect(file.strings["Hello"]?.localizations?["de"] == nil)
        #expect(file.strings["Hello"]?.localizations?["en"] != nil)
    }

    @Test
    func deleteTranslationsKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteTranslations(from: file, key: "NonExistent", languages: ["en"])
        }
    }

    @Test
    func deleteTranslationsLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)

        #expect(throws: XCStringsError.self) {
            _ = try XCStringsWriter.deleteTranslations(from: file, key: "Hello", languages: ["fr"])
        }
    }

    // MARK: - Helper

    private func loadFixture(_ content: String) throws -> XCStringsFile {
        let data = content.data(using: .utf8)!
        return try JSONDecoder().decode(XCStringsFile.self, from: data)
    }
}

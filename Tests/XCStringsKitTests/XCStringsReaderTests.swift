import Foundation
import Testing
@testable import XCStringsKit

@Suite("Read operations for xcstrings files")
struct XCStringsReaderTests {
    // MARK: - listKeys

    @Test
    func listKeysSorted() throws {
        let file = try loadFixture(TestFixtures.manyKeys)
        let reader = XCStringsReader(file: file)

        let keys = reader.listKeys()

        #expect(keys == keys.sorted())
    }

    @Test
    func listKeysEmpty() throws {
        let file = try loadFixture(TestFixtures.empty)
        let reader = XCStringsReader(file: file)

        let keys = reader.listKeys()

        #expect(keys.isEmpty)
    }

    // MARK: - listLanguages

    @Test
    func listLanguagesIncludesSource() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)
        let reader = XCStringsReader(file: file)

        let languages = reader.listLanguages()

        #expect(languages.contains("en"))
    }

    @Test
    func listLanguagesAll() throws {
        let file = try loadFixture(TestFixtures.manyLanguages)
        let reader = XCStringsReader(file: file)

        let languages = reader.listLanguages()

        #expect(languages.contains("en"))
        #expect(languages.contains("ja"))
        #expect(languages.contains("de"))
        #expect(languages.contains("fr"))
        #expect(languages.contains("es"))
    }

    // MARK: - listUntranslated

    @Test
    func listUntranslatedKeys() throws {
        let file = try loadFixture(TestFixtures.multipleKeysPartialTranslations)
        let reader = XCStringsReader(file: file)

        let untranslated = reader.listUntranslated(for: "de")

        #expect(untranslated.contains("Hello"))
        #expect(untranslated.contains("Goodbye"))
    }

    // MARK: - getSourceLanguage

    @Test
    func getSourceLanguage() throws {
        let file = try loadFixture(TestFixtures.japaneseSource)
        let reader = XCStringsReader(file: file)

        let source = reader.getSourceLanguage()

        #expect(source == "ja")
    }

    // MARK: - getKey

    @Test
    func getKeyInfo() throws {
        let file = try loadFixture(TestFixtures.withComments)
        let reader = XCStringsReader(file: file)

        let info = try reader.getKey("Hello")

        #expect(info.key == "Hello")
        #expect(info.comment == "Greeting message shown on home screen")
    }

    @Test
    func getKeyNotFound() throws {
        let file = try loadFixture(TestFixtures.empty)
        let reader = XCStringsReader(file: file)

        #expect(throws: XCStringsError.self) {
            _ = try reader.getKey("NonExistent")
        }
    }

    // MARK: - getTranslation

    @Test
    func getTranslationAll() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let reader = XCStringsReader(file: file)

        let translations = try reader.getTranslation(key: "Hello", language: nil)

        #expect(translations.count == 3)
        #expect(translations["en"]?.value == "Hello")
        #expect(translations["ja"]?.value == "こんにちは")
    }

    @Test
    func getTranslationSpecific() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let reader = XCStringsReader(file: file)

        let translations = try reader.getTranslation(key: "Hello", language: "ja")

        #expect(translations.count == 1)
        #expect(translations["ja"]?.value == "こんにちは")
    }

    // MARK: - checkKey

    @Test
    func checkKeyExists() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)
        let reader = XCStringsReader(file: file)

        let exists = reader.checkKey("Hello", language: nil)

        #expect(exists == true)
    }

    @Test
    func checkKeyNotExists() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)
        let reader = XCStringsReader(file: file)

        let exists = reader.checkKey("NonExistent", language: nil)

        #expect(exists == false)
    }

    @Test
    func checkKeyWithLanguage() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let reader = XCStringsReader(file: file)

        #expect(reader.checkKey("Hello", language: "ja") == true)
        #expect(reader.checkKey("Hello", language: "fr") == false)
    }

    // MARK: - checkCoverage

    @Test
    func checkCoverage() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let reader = XCStringsReader(file: file)

        let coverage = try reader.checkCoverage("Hello")

        #expect(coverage.key == "Hello")
        #expect(coverage.translatedLanguages.count == 3)
        #expect(coverage.coveragePercent == 100.0)
    }

    // MARK: - Helper

    private func loadFixture(_ content: String) throws -> XCStringsFile {
        let data = content.data(using: .utf8)!
        return try JSONDecoder().decode(XCStringsFile.self, from: data)
    }
}

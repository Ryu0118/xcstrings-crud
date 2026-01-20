import Foundation
import Testing
@testable import XCStringsKit

@Suite("Get Operations")
struct GetOperationsTests {
    @Test("getSourceLanguage returns correct language", arguments: FixtureType.allCases)
    func getSourceLanguage(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let sourceLanguage = try await parser.getSourceLanguage()

        #expect(sourceLanguage == fixture.expectedSourceLanguage)
    }

    @Test("getTranslation returns all translations for key", arguments: [
        (FixtureType.singleKeyMultipleLangs, "Hello", 3),
        (FixtureType.manyLanguages, "Hello", 7),
        (FixtureType.multipleKeysPartialTranslations, "Hello", 2),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", 1),
    ])
    func getTranslationAllLanguages(fixture: FixtureType, key: String, expectedCount: Int) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let translations = try await parser.getTranslation(key: key, language: nil)

        #expect(translations.count == expectedCount)
    }

    @Test("getTranslation returns specific language", arguments: [
        (FixtureType.singleKeyMultipleLangs, "Hello", "ja", "こんにちは"),
        (FixtureType.singleKeyMultipleLangs, "Hello", "de", "Hallo"),
        (FixtureType.manyLanguages, "Hello", "fr", "Bonjour"),
        (FixtureType.manyLanguages, "Hello", "zh-Hans", "你好"),
    ])
    func getTranslationSpecificLanguage(fixture: FixtureType, key: String, language: String, expectedValue: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let translations = try await parser.getTranslation(key: key, language: language)

        #expect(translations.count == 1)
        #expect(translations[language]?.value == expectedValue)
    }

    @Test("getTranslation throws for non-existent key", arguments: FixtureType.allCases.filter { $0 != .empty })
    func getTranslationNonExistentKey(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            _ = try await parser.getTranslation(key: "NonExistentKey", language: nil)
        }
    }
}

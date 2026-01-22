import Foundation
import Testing
@testable import XCStringsKit

@Suite("Checking key existence and translation coverage")
struct CheckOperationsTests {
    @Test("checkKey returns true for existing key", arguments: [
        (FixtureType.singleKeySingleLang, "Hello"),
        (FixtureType.multipleKeysPartialTranslations, "Hello"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye"),
        (FixtureType.multipleKeysPartialTranslations, "Welcome"),
        (FixtureType.specialCharacters, "Hello, %@!"),
    ])
    func checkKeyExists(fixture: FixtureType, key: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let exists = try await parser.checkKey(key, language: nil)

        #expect(exists == true)
    }

    @Test("checkKey returns false for non-existent key", arguments: FixtureType.allCases)
    func checkKeyNotExists(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let exists = try await parser.checkKey("NonExistentKey", language: nil)

        #expect(exists == false)
    }

    @Test("checkKey with language returns correct result", arguments: [
        (FixtureType.singleKeyMultipleLangs, "Hello", "ja", true),
        (FixtureType.singleKeyMultipleLangs, "Hello", "fr", false),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "en", true),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "ja", false),
    ])
    func checkKeyWithLanguage(fixture: FixtureType, key: String, language: String, expected: Bool) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let exists = try await parser.checkKey(key, language: language)

        #expect(exists == expected)
    }

    @Test("checkCoverage returns correct coverage", arguments: [
        (FixtureType.singleKeyMultipleLangs, "Hello", 3, 0),
        (FixtureType.multipleKeysPartialTranslations, "Hello", 2, 1),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", 1, 2),
        (FixtureType.multipleKeysPartialTranslations, "Welcome", 3, 0),
    ])
    func checkCoverage(fixture: FixtureType, key: String, translatedCount: Int, missingCount: Int) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let coverage = try await parser.checkCoverage(key)

        #expect(coverage.translatedLanguages.count == translatedCount)
        #expect(coverage.missingLanguages.count == missingCount)
    }
}

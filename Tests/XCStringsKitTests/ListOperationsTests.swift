import Foundation
import Testing
@testable import XCStringsKit

@Suite("List Operations")
struct ListOperationsTests {
    @Test("listKeys returns correct count", arguments: FixtureType.allCases)
    func listKeysCount(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let keys = try await parser.listKeys()

        #expect(keys.count == fixture.expectedKeyCount)
    }

    @Test("listKeys returns sorted keys", arguments: [
        FixtureType.multipleKeysPartialTranslations,
        FixtureType.manyKeys,
    ])
    func listKeysSorted(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let keys = try await parser.listKeys()
        let sortedKeys = keys.sorted()

        #expect(keys == sortedKeys)
    }

    @Test("listLanguages returns all languages", arguments: [
        (FixtureType.singleKeySingleLang, 1),
        (FixtureType.singleKeyMultipleLangs, 3),
        (FixtureType.manyLanguages, 7),
    ])
    func listLanguagesCount(fixture: FixtureType, expectedCount: Int) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let languages = try await parser.listLanguages()

        #expect(languages.count == expectedCount)
    }

    @Test("listUntranslated returns correct keys", arguments: [
        (FixtureType.multipleKeysPartialTranslations, "ja", ["Goodbye"]),
        (FixtureType.multipleKeysPartialTranslations, "de", ["Goodbye", "Hello"]),
        (FixtureType.manyKeys, "ja", ["Key1", "Key10", "Key2", "Key3", "Key4", "Key5", "Key9"]),
    ])
    func listUntranslated(fixture: FixtureType, language: String, expectedKeys: [String]) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let untranslated = try await parser.listUntranslated(for: language)

        #expect(untranslated == expectedKeys)
    }
}

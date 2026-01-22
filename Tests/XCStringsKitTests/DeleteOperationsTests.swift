import Foundation
import Testing
@testable import XCStringsKit

@Suite("Deleting keys and translations from xcstrings files")
struct DeleteOperationsTests {
    @Test("deleteKey removes key entirely", arguments: [
        (FixtureType.singleKeySingleLang, "Hello"),
        (FixtureType.multipleKeysPartialTranslations, "Hello"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye"),
    ])
    func deleteKey(fixture: FixtureType, key: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Verify exists
        let beforeExists = try await parser.checkKey(key, language: nil)
        #expect(beforeExists == true)

        let beforeCount = try await parser.listKeys().count

        // Delete
        try await parser.deleteKey(key)

        // Verify deleted
        let afterExists = try await parser.checkKey(key, language: nil)
        #expect(afterExists == false)

        let afterCount = try await parser.listKeys().count
        #expect(afterCount == beforeCount - 1)
    }

    @Test("deleteKey throws for non-existent key", arguments: FixtureType.allCases)
    func deleteKeyNonExistent(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.deleteKey("NonExistentKey")
        }
    }

    @Test("deleteTranslation removes specific language", arguments: [
        (FixtureType.singleKeyMultipleLangs, "Hello", "ja"),
        (FixtureType.singleKeyMultipleLangs, "Hello", "de"),
        (FixtureType.multipleKeysPartialTranslations, "Welcome", "de"),
    ])
    func deleteTranslation(fixture: FixtureType, key: String, language: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Verify exists
        let beforeExists = try await parser.checkKey(key, language: language)
        #expect(beforeExists == true)

        // Delete translation
        try await parser.deleteTranslation(key: key, language: language)

        // Verify translation deleted but key still exists
        let afterTranslationExists = try await parser.checkKey(key, language: language)
        #expect(afterTranslationExists == false)

        let keyStillExists = try await parser.checkKey(key, language: nil)
        #expect(keyStillExists == true)
    }

    @Test("deleteTranslation throws for non-existent translation", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "fr"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "ja"),
    ])
    func deleteTranslationNonExistent(fixture: FixtureType, key: String, language: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.deleteTranslation(key: key, language: language)
        }
    }
}

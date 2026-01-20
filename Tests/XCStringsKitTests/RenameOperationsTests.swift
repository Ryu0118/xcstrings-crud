import Foundation
import Testing
@testable import XCStringsKit

@Suite("Rename Operations")
struct RenameOperationsTests {
    @Test("renameKey renames key preserving translations", arguments: [
        (FixtureType.singleKeySingleLang, "Hello", "Greeting"),
        (FixtureType.singleKeyMultipleLangs, "Hello", "Salutation"),
        (FixtureType.multipleKeysPartialTranslations, "Hello", "Hi"),
    ])
    func renameKey(fixture: FixtureType, oldKey: String, newKey: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Get original translations
        let originalTranslations = try await parser.getTranslation(key: oldKey, language: nil)

        // Rename
        try await parser.renameKey(from: oldKey, to: newKey)

        // Verify old key doesn't exist
        let oldExists = try await parser.checkKey(oldKey, language: nil)
        #expect(oldExists == false)

        // Verify new key exists with same translations
        let newExists = try await parser.checkKey(newKey, language: nil)
        #expect(newExists == true)

        let newTranslations = try await parser.getTranslation(key: newKey, language: nil)
        #expect(newTranslations.count == originalTranslations.count)
    }

    @Test("renameKey throws for non-existent key", arguments: FixtureType.allCases)
    func renameKeyNonExistent(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.renameKey(from: "NonExistentKey", to: "NewKey")
        }
    }

    @Test("renameKey throws when target key already exists", arguments: [
        (FixtureType.multipleKeysPartialTranslations, "Hello", "Goodbye"),
        (FixtureType.multipleKeysPartialTranslations, "Goodbye", "Welcome"),
    ])
    func renameKeyTargetExists(fixture: FixtureType, oldKey: String, newKey: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: XCStringsError.self) {
            try await parser.renameKey(from: oldKey, to: newKey)
        }
    }
}

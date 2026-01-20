import Foundation
import Testing
@testable import XCStringsKit

@Suite("Persistence")
struct PersistenceTests {
    @Test("Changes are persisted to file", arguments: [
        FixtureType.empty,
        FixtureType.singleKeySingleLang,
    ])
    func changesPersisted(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        // Make changes with first parser
        let parser1 = XCStringsParser(path: path)
        try await parser1.addTranslation(key: "PersistenceTest", language: "en", value: "Persisted Value")

        // Verify with new parser instance
        let parser2 = XCStringsParser(path: path)
        let exists = try await parser2.checkKey("PersistenceTest", language: "en")
        #expect(exists == true)

        let translations = try await parser2.getTranslation(key: "PersistenceTest", language: "en")
        #expect(translations["en"]?.value == "Persisted Value")
    }

    @Test("Multiple operations persist correctly")
    func multipleOperationsPersist() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.empty)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Perform multiple operations
        try await parser.addTranslation(key: "Key1", language: "en", value: "Value1")
        try await parser.addTranslation(key: "Key1", language: "ja", value: "Value1 JA")
        try await parser.addTranslation(key: "Key2", language: "en", value: "Value2")
        try await parser.updateTranslation(key: "Key1", language: "en", value: "UpdatedValue1")
        try await parser.renameKey(from: "Key2", to: "RenamedKey2")

        // Verify with new parser
        let verifyParser = XCStringsParser(path: path)
        let keys = try await verifyParser.listKeys()

        #expect(keys.contains("Key1"))
        #expect(keys.contains("RenamedKey2"))
        #expect(!keys.contains("Key2"))

        let key1Translations = try await verifyParser.getTranslation(key: "Key1", language: nil)
        #expect(key1Translations["en"]?.value == "UpdatedValue1")
        #expect(key1Translations["ja"]?.value == "Value1 JA")
    }
}

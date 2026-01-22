import Foundation
import MCP
import Testing

@testable import XCStringsMCP

@Suite("ToolArguments parsing tests")
struct ToolArgumentsTests {

    // MARK: - String Tests

    @Test("requireString returns value for existing key")
    func requireStringExisting() throws {
        let args = ToolArguments(raw: ["file": .string("/path/to/file.xcstrings")])
        let value = try args.requireString("file")
        #expect(value == "/path/to/file.xcstrings")
    }

    @Test("requireString throws for missing key")
    func requireStringMissing() throws {
        let args = ToolArguments(raw: [:])
        #expect(throws: Error.self) {
            _ = try args.requireString("file")
        }
    }

    @Test("optionalString returns value for existing key")
    func optionalStringExisting() {
        let args = ToolArguments(raw: ["language": .string("ja")])
        let value = args.optionalString("language")
        #expect(value == "ja")
    }

    @Test("optionalString returns nil for missing key")
    func optionalStringMissing() {
        let args = ToolArguments(raw: [:])
        let value = args.optionalString("language")
        #expect(value == nil)
    }

    // MARK: - Bool Tests

    @Test("bool returns value for existing key")
    func boolExisting() {
        let args = ToolArguments(raw: ["compact": .bool(false)])
        let value = args.bool("compact", default: true)
        #expect(value == false)
    }

    @Test("bool returns default for missing key")
    func boolMissing() {
        let args = ToolArguments(raw: [:])
        let value = args.bool("compact", default: true)
        #expect(value == true)
    }

    // MARK: - Array Tests

    @Test("requireStringArray returns values for existing key")
    func requireStringArrayExisting() throws {
        let args = ToolArguments(raw: [
            "keys": .array([.string("Hello"), .string("Goodbye"), .string("Welcome")])
        ])
        let values = try args.requireStringArray("keys")
        #expect(values == ["Hello", "Goodbye", "Welcome"])
    }

    @Test("requireStringArray throws for missing key")
    func requireStringArrayMissing() throws {
        let args = ToolArguments(raw: [:])
        #expect(throws: Error.self) {
            _ = try args.requireStringArray("keys")
        }
    }

    @Test("optionalStringArray returns values for existing key")
    func optionalStringArrayExisting() {
        let args = ToolArguments(raw: [
            "languages": .array([.string("ja"), .string("en")])
        ])
        let values = args.optionalStringArray("languages")
        #expect(values == ["ja", "en"])
    }

    @Test("optionalStringArray returns nil for missing key")
    func optionalStringArrayMissing() {
        let args = ToolArguments(raw: [:])
        let values = args.optionalStringArray("languages")
        #expect(values == nil)
    }

    // MARK: - Translations Tests

    @Test("requireTranslations parses object correctly")
    func requireTranslationsParsing() throws {
        let args = ToolArguments(raw: [
            "translations": .object([
                "ja": .string("こんにちは"),
                "en": .string("Hello"),
                "de": .string("Hallo")
            ])
        ])
        let translations = try args.requireTranslations("translations")
        #expect(translations.count == 3)
        #expect(translations["ja"] == "こんにちは")
        #expect(translations["en"] == "Hello")
        #expect(translations["de"] == "Hallo")
    }

    @Test("requireTranslations throws for missing key")
    func requireTranslationsMissing() throws {
        let args = ToolArguments(raw: [:])
        #expect(throws: Error.self) {
            _ = try args.requireTranslations("translations")
        }
    }

    // MARK: - Batch Entries Tests

    @Test("requireBatchEntries parses array of entries correctly")
    func requireBatchEntriesParsing() throws {
        let args = ToolArguments(raw: [
            "entries": .array([
                .object([
                    "key": .string("Hello"),
                    "translations": .object([
                        "ja": .string("こんにちは"),
                        "en": .string("Hello")
                    ])
                ]),
                .object([
                    "key": .string("Goodbye"),
                    "translations": .object([
                        "ja": .string("さようなら")
                    ])
                ])
            ])
        ])

        let entries = try args.requireBatchEntries("entries")

        #expect(entries.count == 2)
        #expect(entries[0].key == "Hello")
        #expect(entries[0].translations["ja"] == "こんにちは")
        #expect(entries[0].translations["en"] == "Hello")
        #expect(entries[1].key == "Goodbye")
        #expect(entries[1].translations["ja"] == "さようなら")
    }

    @Test("requireBatchEntries throws for missing key")
    func requireBatchEntriesMissing() throws {
        let args = ToolArguments(raw: [:])
        #expect(throws: Error.self) {
            _ = try args.requireBatchEntries("entries")
        }
    }

    @Test("requireBatchEntries throws for invalid entry format")
    func requireBatchEntriesInvalidFormat() throws {
        let args = ToolArguments(raw: [
            "entries": .array([
                .object([
                    "key": .string("Hello")
                    // missing translations
                ])
            ])
        ])
        #expect(throws: Error.self) {
            _ = try args.requireBatchEntries("entries")
        }
    }
}

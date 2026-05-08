import Foundation
import Testing
@testable import XCStringsKit

/// Fixture containing a key with a curly apostrophe (U+2019).
/// Defined locally to avoid inflating TestFixtures enum body length.
private let curlyApostropheFixture = #"""
{
  "sourceLanguage" : "en",
  "strings" : {
    "Record today’s progress" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Record today’s progress"
          }
        },
        "ja" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "今日の継続を記録しよう"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""#

@Suite("Special Characters Handling")
struct SpecialCharactersTests {
    @Test("Handles keys with format specifiers", arguments: [
        ("Hello, %@!", "ja", "こんにちは、%@！"),
        ("Items: %lld", "en", "Items: %lld"),
    ])
    func formatSpecifiers(key: String, language: String, expectedValue: String) async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.specialCharacters)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let translations = try await parser.getTranslation(key: key, language: language)

        #expect(translations[language]?.value == expectedValue)
    }

    @Test("Handles keys with escape sequences")
    func escapeSequences() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.specialCharacters)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        // JSON "Line1\\nLine2" becomes "Line1\nLine2" (backslash + n) after parsing
        let exists = try await parser.checkKey("Line1\\nLine2", language: nil)

        #expect(exists == true)
    }

    @Test("checkKey returns true for key containing curly apostrophe (U+2019)")
    func checkKeyWithCurlyApostrophe() async throws {
        let path = try TestHelper.createTempFile(content: curlyApostropheFixture)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let key = "Record today\u{2019}s progress"
        let exists = try await parser.checkKey(key, language: nil)

        #expect(exists == true)
    }

    @Test("getTranslation returns correct value for key containing curly apostrophe (U+2019)")
    func getTranslationWithCurlyApostrophe() async throws {
        let path = try TestHelper.createTempFile(content: curlyApostropheFixture)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let key = "Record today\u{2019}s progress"
        let translations = try await parser.getTranslation(key: key, language: "ja")

        #expect(translations["ja"]?.value == "今日の継続を記録しよう")
    }

    @Test("listKeys includes key containing curly apostrophe (U+2019)")
    func listKeysWithCurlyApostrophe() async throws {
        let path = try TestHelper.createTempFile(content: curlyApostropheFixture)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let keys = try await parser.listKeys()

        #expect(keys.contains("Record today\u{2019}s progress"))
    }

    @Test("Add and retrieve translation with special characters")
    func addSpecialCharacters() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.empty)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let key = "Special: %@ with \"quotes\" and 'apostrophes'"
        let value = "Special: %@ with quotes"

        try await parser.addTranslation(key: key, language: "en", value: value)

        let translations = try await parser.getTranslation(key: key, language: "en")
        #expect(translations["en"]?.value == value)
    }
}

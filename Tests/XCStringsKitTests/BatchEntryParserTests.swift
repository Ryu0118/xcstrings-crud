import Foundation
import Testing
@testable import XCStringsKit

@Suite("Parsing batch entry format strings into BatchTranslationEntry")
struct BatchEntryParserTests {
    @Test("parse converts key=lang:value format correctly")
    func parseSingleTranslation() throws {
        let result = try BatchEntryParser.parse("Hello=en:Hello World")

        #expect(result.key == "Hello")
        #expect(result.translations == ["en": "Hello World"])
    }

    @Test("parse converts multiple lang:value pairs")
    func parseMultipleTranslations() throws {
        let result = try BatchEntryParser.parse("Hello=ja:こんにちは,en:Hello")

        #expect(result.key == "Hello")
        #expect(result.translations["ja"] == "こんにちは")
        #expect(result.translations["en"] == "Hello")
    }

    @Test("parse handles value containing colons")
    func parseValueWithColons() throws {
        let result = try BatchEntryParser.parse("Time=en:12:30:45")

        #expect(result.key == "Time")
        #expect(result.translations["en"] == "12:30:45")
    }

    @Test("parse handles value containing equals sign")
    func parseValueWithEquals() throws {
        let result = try BatchEntryParser.parse("Math=en:1+1=2")

        #expect(result.key == "Math")
        #expect(result.translations["en"] == "1+1=2")
    }

    @Test("parse handles empty value")
    func parseEmptyValue() throws {
        let result = try BatchEntryParser.parse("Empty=en:")

        #expect(result.key == "Empty")
        #expect(result.translations["en"] == "")
    }

    @Test("parse throws invalidFormat for missing equals")
    func parseMissingEquals() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("HelloWorld")
        }
    }

    @Test("parse throws emptyKey for empty key")
    func parseEmptyKey() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("=en:Hello")
        }
    }

    @Test("parse throws invalidTranslationFormat for missing colon")
    func parseMissingColon() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("Hello=enHello")
        }
    }

    @Test("parse throws emptyLanguage for empty language code")
    func parseEmptyLanguage() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("Hello=:Hello")
        }
    }

    @Test("parse throws noTranslations for empty translations")
    func parseNoTranslations() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("Hello=")
        }
    }
}

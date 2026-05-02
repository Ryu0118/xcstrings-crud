import Foundation
import Testing
@testable import XCStringsKit

@Suite("Parsing batch entry format strings into BatchTranslationEntry")
struct BatchEntryParserTests {
    @Test
    func parseSingleTranslation() throws {
        let result = try BatchEntryParser.parse("Hello=en:Hello World")

        #expect(result.key == "Hello")
        #expect(result.translations == ["en": "Hello World"])
    }

    @Test
    func parseMultipleTranslations() throws {
        let result = try BatchEntryParser.parse("Hello=ja:こんにちは,en:Hello")

        #expect(result.key == "Hello")
        #expect(result.translations["ja"] == "こんにちは")
        #expect(result.translations["en"] == "Hello")
    }

    @Test
    func parseValueWithColons() throws {
        let result = try BatchEntryParser.parse("Time=en:12:30:45")

        #expect(result.key == "Time")
        #expect(result.translations["en"] == "12:30:45")
    }

    @Test
    func parseValueWithEquals() throws {
        let result = try BatchEntryParser.parse("Math=en:1+1=2")

        #expect(result.key == "Math")
        #expect(result.translations["en"] == "1+1=2")
    }

    @Test
    func parseEmptyValue() throws {
        let result = try BatchEntryParser.parse("Empty=en:")

        #expect(result.key == "Empty")
        #expect(result.translations["en"] == "")
    }

    @Test
    func parseMissingEquals() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("HelloWorld")
        }
    }

    @Test
    func parseEmptyKey() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("=en:Hello")
        }
    }

    @Test
    func parseMissingColon() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("Hello=enHello")
        }
    }

    @Test
    func parseEmptyLanguage() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("Hello=:Hello")
        }
    }

    @Test
    func parseNoTranslations() throws {
        #expect(throws: BatchEntryParseError.self) {
            try BatchEntryParser.parse("Hello=")
        }
    }
}

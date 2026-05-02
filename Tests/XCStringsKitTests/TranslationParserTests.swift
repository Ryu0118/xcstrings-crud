import Foundation
import Testing
@testable import XCStringsKit

@Suite("Parsing lang:value format strings into translation dictionaries")
struct TranslationParserTests {
    // MARK: - parse

    @Test
    func parseMultiple() throws {
        let inputs = ["ja:こんにちは", "en:Hello", "de:Hallo"]

        let result = try TranslationParser.parse(inputs)

        #expect(result == ["ja": "こんにちは", "en": "Hello", "de": "Hallo"])
    }

    @Test
    func parseEmpty() throws {
        let result = try TranslationParser.parse([])

        #expect(result.isEmpty)
    }

    @Test
    func parseValueWithColons() throws {
        let inputs = ["en:Time: 10:30"]

        let result = try TranslationParser.parse(inputs)

        #expect(result == ["en": "Time: 10:30"])
    }

    @Test
    func parseEmptyValue() throws {
        let inputs = ["en:"]

        let result = try TranslationParser.parse(inputs)

        #expect(result == ["en": ""])
    }

    @Test
    func parseMissingColon() {
        let inputs = ["ja-invalid"]

        #expect(throws: TranslationParseError.self) {
            _ = try TranslationParser.parse(inputs)
        }
    }

    @Test
    func parseEmptyLanguage() {
        let inputs = [":value"]

        #expect(throws: TranslationParseError.self) {
            _ = try TranslationParser.parse(inputs)
        }
    }

    // MARK: - parseSingle

    @Test
    func parseSingle() throws {
        let (language, value) = try TranslationParser.parseSingle("ja:こんにちは")

        #expect(language == "ja")
        #expect(value == "こんにちは")
    }

    @Test
    func parseSingleHyphenatedLang() throws {
        let (language, value) = try TranslationParser.parseSingle("zh-Hans:你好")

        #expect(language == "zh-Hans")
        #expect(value == "你好")
    }

    // MARK: - TranslationParseError

    @Test
    func errorInvalidFormat() {
        let error = TranslationParseError.invalidFormat("bad-input")

        #expect(error.errorDescription?.contains("bad-input") == true)
        #expect(error.errorDescription?.contains("lang:value") == true)
    }

    @Test
    func errorEmptyLanguage() {
        let error = TranslationParseError.emptyLanguage(":value")

        #expect(error.errorDescription?.contains(":value") == true)
        #expect(error.errorDescription?.contains("Empty language") == true)
    }
}

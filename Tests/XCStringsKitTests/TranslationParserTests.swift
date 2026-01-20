import Foundation
import Testing
@testable import XCStringsKit

@Suite("TranslationParser")
struct TranslationParserTests {
    // MARK: - parse

    @Test("parse converts array of lang:value strings to dictionary")
    func parseMultiple() throws {
        let inputs = ["ja:こんにちは", "en:Hello", "de:Hallo"]

        let result = try TranslationParser.parse(inputs)

        #expect(result == ["ja": "こんにちは", "en": "Hello", "de": "Hallo"])
    }

    @Test("parse returns empty dictionary for empty input")
    func parseEmpty() throws {
        let result = try TranslationParser.parse([])

        #expect(result.isEmpty)
    }

    @Test("parse handles value containing colons")
    func parseValueWithColons() throws {
        let inputs = ["en:Time: 10:30"]

        let result = try TranslationParser.parse(inputs)

        #expect(result == ["en": "Time: 10:30"])
    }

    @Test("parse handles empty value")
    func parseEmptyValue() throws {
        let inputs = ["en:"]

        let result = try TranslationParser.parse(inputs)

        #expect(result == ["en": ""])
    }

    @Test("parse throws for missing colon")
    func parseMissingColon() {
        let inputs = ["ja-invalid"]

        #expect(throws: TranslationParseError.self) {
            _ = try TranslationParser.parse(inputs)
        }
    }

    @Test("parse throws for empty language")
    func parseEmptyLanguage() {
        let inputs = [":value"]

        #expect(throws: TranslationParseError.self) {
            _ = try TranslationParser.parse(inputs)
        }
    }

    // MARK: - parseSingle

    @Test("parseSingle extracts language and value")
    func parseSingle() throws {
        let (language, value) = try TranslationParser.parseSingle("ja:こんにちは")

        #expect(language == "ja")
        #expect(value == "こんにちは")
    }

    @Test("parseSingle handles hyphenated language codes")
    func parseSingleHyphenatedLang() throws {
        let (language, value) = try TranslationParser.parseSingle("zh-Hans:你好")

        #expect(language == "zh-Hans")
        #expect(value == "你好")
    }

    // MARK: - TranslationParseError

    @Test("TranslationParseError.invalidFormat has descriptive message")
    func errorInvalidFormat() {
        let error = TranslationParseError.invalidFormat("bad-input")

        #expect(error.errorDescription?.contains("bad-input") == true)
        #expect(error.errorDescription?.contains("lang:value") == true)
    }

    @Test("TranslationParseError.emptyLanguage has descriptive message")
    func errorEmptyLanguage() {
        let error = TranslationParseError.emptyLanguage(":value")

        #expect(error.errorDescription?.contains(":value") == true)
        #expect(error.errorDescription?.contains("Empty language") == true)
    }
}

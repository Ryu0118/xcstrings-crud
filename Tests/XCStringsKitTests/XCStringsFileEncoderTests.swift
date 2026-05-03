import Foundation
import Testing
@testable import XCStringsKit

@Suite("Encoding xcstrings files")
struct XCStringsFileEncoderTests {
    @Test("Encoded files are valid JSON and decode back to the model", arguments: [
        FixtureType.empty,
        .singleKeySingleLang,
        .singleKeyMultipleLangs,
        .multipleKeysPartialTranslations,
        .specialCharacters,
        .pluralVariations,
        .deviceVariations,
    ])
    func encodedFilesRoundTrip(fixture: FixtureType) throws {
        let original = try decodeFixture(fixture.content)

        let encoded = try XCStringsFileEncoder.encode(original)
        let decoded = try JSONDecoder().decode(XCStringsFile.self, from: encoded)

        #expect(decoded.sourceLanguage == original.sourceLanguage)
        #expect(decoded.version == original.version)
        #expect(Set(decoded.strings.keys) == Set(original.strings.keys))
    }

    @Test("Encoded strings use Xcode-like numeric key order", arguments: [
        [
            "product.type.12_1",
            "product.type.1_1",
            "product.type.11_1",
            "product.type.3_1",
            "product.type.2_1",
        ],
        [
            "Key10",
            "Key2",
            "Key1",
            "Key9",
        ],
    ])
    func encodedStringsUseNaturalKeyOrder(inputKeys: [String]) throws {
        let file = makeFile(keys: inputKeys)

        let encoded = try XCStringsFileEncoder.encode(file)
        let encodedString = String(decoding: encoded, as: UTF8.self)
        let keyOrder = try topLevelStringKeyOrder(in: encodedString)

        #expect(keyOrder == XCStringsKeySorter.sort(inputKeys))
    }

    @Test("Encoded string order is deterministic across repeated runs")
    func encodedStringOrderIsDeterministic() throws {
        let file = makeFile(keys: [
            "product.type.12_1",
            "product.type.1_1",
            "product.type.11_1",
            "product.type.3_1",
            "product.type.2_1",
        ])

        let outputs = try Set((0 ..< 20).map { _ in
            try String(decoding: XCStringsFileEncoder.encode(file), as: UTF8.self)
        })

        #expect(outputs.count == 1)
    }

    @Test("Encoded files preserve escaped keys and values")
    func preservesEscapedKeysAndValues() throws {
        let key = "quote\"backslash\\newline\n"
        let value = "value with \"quotes\", slash \\, and newline\nend"
        let file = XCStringsFile(sourceLanguage: "en", strings: [
            key: StringEntry(localizations: [
                "en": Localization(stringUnit: StringUnit(state: "translated", value: value)),
            ]),
        ], version: "1.1")

        let encoded = try XCStringsFileEncoder.encode(file)
        let decoded = try JSONDecoder().decode(XCStringsFile.self, from: encoded)
        let entry = try #require(decoded.strings[key])
        let localization = try #require(entry.localizations?["en"])

        #expect(localization.stringUnit?.value == value)
    }

    @Test("Encoded files preserve variation structures", arguments: [
        FixtureType.pluralVariations,
        .deviceVariations,
    ])
    func preservesVariationStructures(fixture: FixtureType) throws {
        let original = try decodeFixture(fixture.content)

        let encoded = try XCStringsFileEncoder.encode(original)
        let decoded = try JSONDecoder().decode(XCStringsFile.self, from: encoded)

        #expect(decoded.strings.keys.contains { key in
            decoded.strings[key]?.localizations?.values.contains { localization in
                localization.variations != nil
            } == true
        })
    }

    private func makeFile(keys: [String]) -> XCStringsFile {
        XCStringsFile(sourceLanguage: "en", strings: Dictionary(uniqueKeysWithValues: keys.map { key in
            (key, StringEntry(localizations: [
                "en": Localization(stringUnit: StringUnit(state: "translated", value: "Value for \(key)")),
            ]))
        }), version: "1.1")
    }

    private func decodeFixture(_ content: String) throws -> XCStringsFile {
        let data = try #require(content.data(using: .utf8))
        return try JSONDecoder().decode(XCStringsFile.self, from: data)
    }

    private func topLevelStringKeyOrder(in encodedFile: String) throws -> [String] {
        let lines = encodedFile.split(separator: "\n", omittingEmptySubsequences: false)
        let keyLines = lines.filter { line in
            line.hasPrefix("    \"") && line.contains("\" : {")
        }

        return try keyLines.map { line in
            let lineString = String(line)
            let keyStart = try #require(lineString.firstIndex(of: "\""))
            let searchStart = lineString.index(after: keyStart)
            let keyEnd = try #require(lineString[searchStart...].firstIndex(of: "\""))
            return String(lineString[searchStart ..< keyEnd])
        }
    }
}

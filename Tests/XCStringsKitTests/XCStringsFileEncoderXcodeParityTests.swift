import Foundation
import Testing
@testable import XCStringsKit

/// Verifies that `XCStringsFileEncoder` produces byte-for-byte identical output to Xcode's
/// `xcstringstool sync`. Skipped when `xcstringstool` isn't available on this machine.
@Suite("Encoded xcstrings files match xcstringstool byte-for-byte", .enabled(if: XcodeParityFixtures.xcstringstoolIsAvailable))
struct XCStringsFileEncoderXcodeParityTests {
    @Test("Encoder output matches xcstringstool's rewrite of the same catalog", arguments: XcodeParityFixtures.catalogs)
    func matchesXcstringstoolByteForByte(catalog: XcodeParityFixtures.Catalog) throws {
        let fileManager = FileManager.default
        let workDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: workDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: workDir) }

        let tableName = catalog.tableName
        let xcstringsURL = workDir.appendingPathComponent("\(tableName).xcstrings")
        let stringsdataURL = workDir.appendingPathComponent("Sentinel.stringsdata")

        // Xcode's `sync` only rewrites the file when the stringsdata introduces a change,
        // so add a new sentinel key that isn't in the catalog yet.
        var sentinelFile = catalog.file
        sentinelFile.strings["zz sentinel"] = StringEntry()

        let inputData = try XCStringsFileEncoder.encode(catalog.file)
        try inputData.write(to: xcstringsURL)

        let stringsdata = """
        {"source":"/tmp/\(tableName).swift","tables":{"\(tableName)":[{"comment":"","key":"zz sentinel","location":{"startingColumn":1,"startingLine":1}}]},"version":1}
        """
        try stringsdata.write(to: stringsdataURL, atomically: true, encoding: .utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "xcstringstool", "sync",
            xcstringsURL.path,
            "--stringsdata", stringsdataURL.path,
            "--skip-marking-strings-stale",
        ]
        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        try process.run()
        process.waitUntilExit()

        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrOutput = String(data: stderrData, encoding: .utf8) ?? ""
        #expect(process.terminationStatus == 0, "xcstringstool sync failed: \(stderrOutput)")

        let xcodeOutput = try Data(contentsOf: xcstringsURL)
        let encoderOutput = try XCStringsFileEncoder.encode(sentinelFile)

        if xcodeOutput != encoderOutput {
            Issue.record(Comment(rawValue: diffDescription(expected: xcodeOutput, actual: encoderOutput)))
        }
    }

    /// Describes the first differing byte between xcstringstool's output (expected) and the
    /// encoder's output (actual), with ~40 bytes of surrounding context from each side.
    private func diffDescription(expected: Data, actual: Data) -> String {
        let expectedBytes = [UInt8](expected)
        let actualBytes = [UInt8](actual)
        let commonLength = min(expectedBytes.count, actualBytes.count)

        var firstMismatch = commonLength
        for index in 0 ..< commonLength where expectedBytes[index] != actualBytes[index] {
            firstMismatch = index
            break
        }

        func context(_ bytes: [UInt8], around index: Int) -> String {
            let start = max(0, index - 40)
            let end = min(bytes.count, index + 40)
            let slice = Data(bytes[start ..< end])
            return String(bytes: slice, encoding: .utf8) ?? "<non-UTF-8 bytes: \(Array(slice))>"
        }

        return """
        Output diverges from xcstringstool at byte offset \(firstMismatch) \
        (expected length: \(expectedBytes.count), actual length: \(actualBytes.count)).
        xcstringstool: \(context(expectedBytes, around: firstMismatch))
        encoder:       \(context(actualBytes, around: firstMismatch))
        """
    }
}

/// Fixtures for the Xcode parity test: a set of catalogs covering ASCII/non-ASCII keys,
/// mixed case, numeric suffixes, empty objects, `shouldTranslate: false`, `/` in values,
/// and plural variations.
enum XcodeParityFixtures {
    struct Catalog: CustomTestStringConvertible {
        let tableName: String
        let file: XCStringsFile

        var testDescription: String {
            tableName
        }
    }

    static var xcstringstoolIsAvailable: Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["--find", "xcstringstool"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    static let catalogs: [Catalog] = [
        Catalog(tableName: "MixedKeys", file: mixedKeysCatalog),
        Catalog(tableName: "PluralCatalog", file: pluralCatalog),
    ]

    private static func unit(_ value: String, state: String = "translated") -> Localization {
        Localization(stringUnit: StringUnit(state: state, value: value))
    }

    private static var mixedKeysCatalog: XCStringsFile {
        var strings: [String: StringEntry] = [:]

        let asciiAndNonASCIIKeys = [
            "-x", "_x", "~x", "f", "B upper", "b lower", "Key10", "Key2", "Z", "a",
            "product.type.11_1", "product.type.12_1", "product.type.1_1", "product.type.2_1",
            "e\u{301}b", "é", "éa", "ω", "日本", "ａ", "～", "😀", "😀x",
        ]
        for key in asciiAndNonASCIIKeys {
            strings[key] = StringEntry(localizations: ["en": unit("Value for \(key)")])
        }

        // Value containing a forward slash, a quote, and a newline, to check escaping parity.
        strings["Domestic / Foreign"] = StringEntry(localizations: [
            "en": unit("Value with \"quotes\"\nand a newline"),
        ])

        // Non-translatable key.
        strings["BrandName"] = StringEntry(comment: "Product name", shouldTranslate: false)

        // Key with an empty entry (no localizations key at all).
        strings["EmptyEntry"] = StringEntry()

        // Key with an empty `localizations` dictionary (e.g. after deleting the last
        // language via `XCStringsWriter`, which leaves `localizations: [:]` rather than nil).
        strings["EmptyLocalizations"] = StringEntry(localizations: [:])

        return XCStringsFile(sourceLanguage: "en", strings: strings, version: "1.0")
    }

    private static var pluralCatalog: XCStringsFile {
        let variations = Variations(
            plural: PluralVariation(
                one: VariationValue(stringUnit: StringUnit(state: "translated", value: "%lld item")),
                other: VariationValue(stringUnit: StringUnit(state: "translated", value: "%lld items"))
            )
        )
        let strings: [String: StringEntry] = [
            "%lld items": StringEntry(localizations: [
                "en": Localization(variations: variations),
            ]),
        ]

        return XCStringsFile(sourceLanguage: "en", strings: strings, version: "1.0")
    }
}

import Foundation
import Testing
@testable import XCStringsKit

@Suite("xcstringstool-compatible string key sorting")
struct XCStringsKeySorterTests {
    struct SortCase: CustomTestStringConvertible {
        let name: String
        let input: [String]
        let expected: [String]

        var testDescription: String {
            name
        }
    }

    @Test("Sorts keys using UTF-8 byte order, matching xcstringstool", arguments: [
        SortCase(
            name: "numeric suffix",
            input: ["Key10", "Key2", "Key1", "Key9"],
            expected: ["Key1", "Key10", "Key2", "Key9"]
        ),
        SortCase(
            name: "Xcode issue example",
            input: [
                "product.type.12_1",
                "product.type.1_1",
                "product.type.11_1",
                "product.type.3_1",
                "product.type.2_1",
            ],
            expected: [
                "product.type.11_1",
                "product.type.12_1",
                "product.type.1_1",
                "product.type.2_1",
                "product.type.3_1",
            ]
        ),
        SortCase(
            name: "mixed numeric components",
            input: ["section.2.item.10", "section.2.item.2", "section.10.item.1", "section.1.item.20"],
            expected: ["section.1.item.20", "section.10.item.1", "section.2.item.10", "section.2.item.2"]
        ),
        SortCase(
            name: "uppercase sorts before lowercase in ASCII byte order",
            input: ["b lower", "B upper"],
            expected: ["B upper", "b lower"]
        ),
        SortCase(
            name: "byte order matches xcstringstool for a broad mix of scripts and symbols",
            input: [
                "f", "~x", "-x", "_x", "Z", "a", "product.type.2_1", "é", "éa",
                "ω", "日本", "ａ", "～", "😀", "😀x", "product.type.1_1",
            ],
            expected: [
                "-x", "Z", "_x", "a", "f", "product.type.1_1", "product.type.2_1",
                "~x", "é", "éa", "ω", "日本", "ａ", "～", "😀", "😀x",
            ]
        ),
    ])
    func byteOrderSort(testCase: SortCase) {
        #expect(XCStringsKeySorter.sort(testCase.input) == testCase.expected)
    }

    @Test("Sort result does not depend on input order", arguments: [
        ["Key1", "Key10", "Key2", "Key9"],
        ["Key10", "Key9", "Key2", "Key1"],
        ["Key9", "Key1", "Key10", "Key2"],
    ])
    func inputOrderIndependent(keys: [String]) {
        #expect(XCStringsKeySorter.sort(keys) == ["Key1", "Key10", "Key2", "Key9"])
    }

    @Test("Combining-mark and precomposed forms are compared as distinct UTF-8 byte sequences, not normalized")
    func normalizationIsNotApplied() {
        // "e" + COMBINING ACUTE ACCENT (U+0065 U+0301) vs "é" (precomposed, U+00E9): these are
        // canonically equivalent, but must not be treated as equal or reordered by normalization.
        // Byte order sorts the combining form first, since its leading byte "e" (0x65) is less
        // than the precomposed form's leading byte 0xC3.
        let combining = "e\u{301}b"
        let precomposed = "éa"
        #expect(XCStringsKeySorter.sort([precomposed, combining]) == [combining, precomposed])
    }
}

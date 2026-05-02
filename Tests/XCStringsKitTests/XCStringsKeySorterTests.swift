import Foundation
import Testing
@testable import XCStringsKit

@Suite("Xcode-like string key sorting")
struct XCStringsKeySorterTests {
    struct SortCase: CustomTestStringConvertible {
        let name: String
        let input: [String]
        let expected: [String]

        var testDescription: String {
            name
        }
    }

    @Test("Sorts keys using natural numeric order", arguments: [
        SortCase(
            name: "numeric suffix",
            input: ["Key10", "Key2", "Key1", "Key9"],
            expected: ["Key1", "Key2", "Key9", "Key10"]
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
                "product.type.1_1",
                "product.type.2_1",
                "product.type.3_1",
                "product.type.11_1",
                "product.type.12_1",
            ]
        ),
        SortCase(
            name: "mixed numeric components",
            input: ["section.2.item.10", "section.2.item.2", "section.10.item.1", "section.1.item.20"],
            expected: ["section.1.item.20", "section.2.item.2", "section.2.item.10", "section.10.item.1"]
        ),
    ])
    func naturalNumericOrder(testCase: SortCase) {
        #expect(XCStringsKeySorter.sort(testCase.input) == testCase.expected)
    }

    @Test("Sort result does not depend on input order", arguments: [
        ["Key1", "Key2", "Key9", "Key10"],
        ["Key10", "Key9", "Key2", "Key1"],
        ["Key9", "Key1", "Key10", "Key2"],
    ])
    func inputOrderIndependent(keys: [String]) {
        #expect(XCStringsKeySorter.sort(keys) == ["Key1", "Key2", "Key9", "Key10"])
    }
}

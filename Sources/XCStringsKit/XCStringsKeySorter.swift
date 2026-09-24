import Foundation

/// Sorts xcstrings keys the same way Xcode's `xcstringstool` does: by UTF-8 byte order
/// (equivalent to Unicode scalar order), not natural/localized order.
enum XCStringsKeySorter {
    /// Byte-order comparison matching `xcstringstool`'s key ordering.
    static func areInIncreasingOrder(_ lhs: String, _ rhs: String) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }

    static func sort(_ keys: some Sequence<String>) -> [String] {
        keys.sorted(by: areInIncreasingOrder)
    }
}

extension Sequence<String> {
    func withXcodeSort() -> [String] {
        XCStringsKeySorter.sort(self)
    }
}

import Foundation

enum XCStringsKeySorter {
    static func sort(_ keys: some Sequence<String>) -> [String] {
        keys.sorted { lhs, rhs in
            let comparison = lhs.localizedStandardCompare(rhs)
            if comparison == .orderedSame {
                return lhs < rhs
            }
            return comparison == .orderedAscending
        }
    }
}

extension Sequence<String> {
    func withXcodeSort() -> [String] {
        XCStringsKeySorter.sort(self)
    }
}

import Foundation
import Testing
@testable import XCStringsKit

@Suite("Thread safety for concurrent read operations")
struct ConcurrentAccessTests {
    @Test("Concurrent reads are safe")
    func concurrentReads() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.manyKeys)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // Perform concurrent reads
        await withTaskGroup(of: [String].self) { group in
            for _ in 0 ..< 10 {
                group.addTask {
                    (try? await parser.listKeys()) ?? []
                }
            }

            var results: [[String]] = []
            for await result in group {
                results.append(result)
            }

            // All results should be identical
            let first = results.first ?? []
            for result in results {
                #expect(result == first)
            }
        }
    }
}

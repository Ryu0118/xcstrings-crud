import Foundation
import Testing
@testable import XCStringsKit

@Suite("Error Handling")
struct ErrorHandlingTests {
    @Test("Parser throws for non-existent file")
    func fileNotFound() async throws {
        let parser = XCStringsParser(path: "/nonexistent/path/file.xcstrings")

        await #expect(throws: XCStringsError.self) {
            _ = try await parser.listKeys()
        }
    }

    @Test("Parser throws for invalid JSON")
    func invalidJSON() async throws {
        let invalidContent = "{ invalid json content }"
        let path = try TestHelper.createTempFile(content: invalidContent)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        await #expect(throws: (any Error).self) {
            _ = try await parser.listKeys()
        }
    }

    @Test("Parser throws for malformed xcstrings structure")
    func malformedStructure() async throws {
        let malformedContent = """
        {
          "sourceLanguage": "en",
          "version": "1.0"
        }
        """
        let path = try TestHelper.createTempFile(content: malformedContent)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        // This should throw because "strings" key is missing
        await #expect(throws: (any Error).self) {
            _ = try await parser.listKeys()
        }
    }
}

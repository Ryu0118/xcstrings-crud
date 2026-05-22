import Foundation

/// Handles file I/O operations for xcstrings files.
///
/// Reads and writes are routed through ``XCStringsStore`` so a long-lived
/// process (the MCP server) can cache the decoded catalog and coalesce writes.
/// The raw, cache-bypassing disk access lives in the static helpers below, which
/// the store uses to perform the actual reads and writes.
struct XCStringsFileHandler {
    private let path: String

    init(path: String) {
        self.path = path
    }

    /// Load xcstrings file (served from the cache when valid)
    func load() throws -> XCStringsFile {
        try XCStringsStore.shared.load(path: path)
    }

    /// Save xcstrings file (may be coalesced when running under the MCP server)
    func save(_ file: XCStringsFile) throws {
        try XCStringsStore.shared.save(path: path, file: file)
    }

    /// Create a new xcstrings file
    func create(sourceLanguage: String, overwrite: Bool = false) throws {
        if !overwrite, FileManager.default.fileExists(atPath: path) {
            throw XCStringsError.fileAlreadyExists(path: path)
        }

        let file = XCStringsFile(sourceLanguage: sourceLanguage)
        try Self.writeToDisk(path: path, file: file)
        XCStringsStore.shared.invalidate(path: path)
    }

    // MARK: - Raw Disk I/O

    /// Read and decode an xcstrings file directly from disk, bypassing the cache.
    static func readFromDisk(path: String) throws -> XCStringsFile {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: path) else {
            throw XCStringsError.fileNotFound(path: path)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw XCStringsError.invalidFileFormat(path: path, reason: error.localizedDescription)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(XCStringsFile.self, from: data)
        } catch {
            throw XCStringsError.invalidFileFormat(path: path, reason: error.localizedDescription)
        }
    }

    /// Encode and atomically write an xcstrings file directly to disk, bypassing the cache.
    static func writeToDisk(path: String, file: XCStringsFile) throws {
        let url = URL(fileURLWithPath: path)

        let data: Data
        do {
            data = try XCStringsFileEncoder.encode(file)
        } catch {
            throw XCStringsError.writeError(path: path, reason: error.localizedDescription)
        }

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw XCStringsError.writeError(path: path, reason: error.localizedDescription)
        }
    }
}

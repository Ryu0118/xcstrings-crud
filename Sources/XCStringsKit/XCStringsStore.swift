import Foundation

/// Process-wide cache for xcstrings files with optional coalesced writes.
///
/// The MCP server is a long-lived process, so re-reading and re-encoding a
/// multi-megabyte catalog on every single call dominates latency. This store
/// keeps the decoded `XCStringsFile` in memory — validated against the file's
/// on-disk signature so external edits (e.g. Xcode re-extracting keys) are
/// detected — and, when coalescing is enabled, defers disk writes. A burst of
/// mutations then collapses into a single encode + atomic write.
///
/// Coalescing is opt-in via ``enableCoalescing(delayMilliseconds:)`` and is only
/// turned on by the MCP server, which guarantees a final ``flushAll()`` on
/// shutdown. The CLI keeps the default write-through behaviour so one-shot
/// commands stay durable.
///
/// Set `XCSTRINGS_FLUSH_MS=0` to force write-through even under the MCP server.
package final class XCStringsStore: @unchecked Sendable {
    package static let shared = XCStringsStore()

    private struct Signature: Equatable {
        let modificationDate: Date?
        let size: Int?
    }

    private struct Entry {
        var file: XCStringsFile
        var diskSignature: Signature
        var dirty: Bool
    }

    private let lock = NSLock()
    private var entries: [String: Entry] = [:]
    private var pendingFlushes: [String: DispatchWorkItem] = [:]

    private var coalescingEnabled = false
    private var flushDelay: DispatchTimeInterval = .milliseconds(250)
    private let flushQueue = DispatchQueue(label: "com.xcstrings-crud.store.flush", qos: .utility)

    private init() {}

    // MARK: - Configuration

    /// Enable coalesced (debounced) writes. Intended to be called once at MCP server startup.
    package func enableCoalescing(delayMilliseconds: Int) {
        lock.lock()
        coalescingEnabled = true
        flushDelay = .milliseconds(max(0, delayMilliseconds))
        lock.unlock()
    }

    // MARK: - Read

    /// Return the cached file when it is still valid, otherwise read it from disk.
    package func load(path: String) throws -> XCStringsFile {
        lock.lock()
        if let entry = entries[path], entry.dirty || entry.diskSignature == signature(of: path) {
            let file = entry.file
            lock.unlock()
            return file
        }
        lock.unlock()
        return try readThrough(path: path)
    }

    // MARK: - Write

    /// Store the updated file. Flushes immediately unless coalescing is enabled.
    package func save(path: String, file: XCStringsFile) throws {
        lock.lock()
        let signature = entries[path]?.diskSignature ?? Signature(modificationDate: nil, size: nil)
        entries[path] = Entry(file: file, diskSignature: signature, dirty: true)
        let coalesce = coalescingEnabled && flushDelay != .milliseconds(0)
        lock.unlock()

        if coalesce {
            scheduleFlush(path: path)
        } else {
            try flush(path: path)
        }
    }

    /// Drop any cached state for a path (e.g. after the file is recreated on disk).
    package func invalidate(path: String) {
        lock.lock()
        pendingFlushes[path]?.cancel()
        pendingFlushes[path] = nil
        entries[path] = nil
        lock.unlock()
    }

    /// Write pending changes for a single path to disk.
    package func flush(path: String) throws {
        lock.lock()
        defer { lock.unlock() }
        pendingFlushes[path]?.cancel()
        pendingFlushes[path] = nil
        guard var entry = entries[path], entry.dirty else { return }
        try XCStringsFileHandler.writeToDisk(path: path, file: entry.file)
        entry.diskSignature = signature(of: path)
        entry.dirty = false
        entries[path] = entry
    }

    /// Flush every path with pending changes. Used on server shutdown.
    package func flushAll() {
        lock.lock()
        let paths = entries.compactMap { $0.value.dirty ? $0.key : nil }
        lock.unlock()
        for path in paths {
            try? flush(path: path)
        }
    }

    // MARK: - Helpers

    private func readThrough(path: String) throws -> XCStringsFile {
        let file = try XCStringsFileHandler.readFromDisk(path: path)
        lock.lock()
        entries[path] = Entry(file: file, diskSignature: signature(of: path), dirty: false)
        lock.unlock()
        return file
    }

    private func scheduleFlush(path: String) {
        let work = DispatchWorkItem { [weak self] in
            try? self?.flush(path: path)
        }
        lock.lock()
        pendingFlushes[path]?.cancel()
        pendingFlushes[path] = work
        let delay = flushDelay
        lock.unlock()
        flushQueue.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func signature(of path: String) -> Signature {
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        return Signature(
            modificationDate: attributes?[.modificationDate] as? Date,
            size: attributes?[.size] as? Int
        )
    }
}

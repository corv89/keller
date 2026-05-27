import Foundation

struct CacheManager: Sendable {
    var ttl: TimeInterval = 3600
    let directory: URL

    init(directory: URL? = nil) {
        self.directory = directory ?? Self.defaultCacheDirectory
    }

    private static var defaultCacheDirectory: URL {
        let cacheHome = ProcessInfo.processInfo.environment["XDG_CACHE_HOME"]
            ?? NSString(string: "~").expandingTildeInPath.appending("/.cache")
        return URL(fileURLWithPath: cacheHome).appendingPathComponent("keller")
    }

    private var snapshotURL: URL {
        directory.appendingPathComponent("brew-snapshot.json")
    }

    private struct Snapshot: Codable {
        let fetchedAt: TimeInterval
        let formulae: [Formula]
    }

    func loadIfFresh() -> [Formula]? {
        guard FileManager.default.fileExists(atPath: snapshotURL.path) else { return nil }

        guard let data = try? Data(contentsOf: snapshotURL),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data)
        else { return nil }

        let age = Date().timeIntervalSince1970 - snapshot.fetchedAt
        guard age <= ttl else { return nil }

        return snapshot.formulae
    }

    func write(_ formulae: [Formula]) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directory.path)

        let snapshot = Snapshot(fetchedAt: Date().timeIntervalSince1970, formulae: formulae)
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: snapshotURL, options: .atomic)
    }

    func invalidate() throws {
        if FileManager.default.fileExists(atPath: snapshotURL.path) {
            try FileManager.default.removeItem(at: snapshotURL)
        }
    }
}

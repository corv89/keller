import Foundation

actor AnnotationStore {
    let url: URL
    private var cache: [String: Annotation]?

    static var defaultURL: URL {
        let configHome = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"]
            ?? NSString(string: "~").expandingTildeInPath.appending("/.config")
        let dir = URL(fileURLWithPath: configHome).appendingPathComponent("cellar")
        return dir.appendingPathComponent("annotations.json")
    }

    init(url: URL = AnnotationStore.defaultURL) {
        self.url = url
    }

    static func loadSync(url: URL = defaultURL) -> [String: Annotation] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [:] }
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: Annotation].self, from: data)
        else { return [:] }
        return decoded.filter { !$0.value.isEmpty }
    }

    private func ensureDirectory() throws {
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path)
    }

    func load() throws -> [String: Annotation] {
        if let cache { return cache }

        guard FileManager.default.fileExists(atPath: url.path) else {
            cache = [:]
            return [:]
        }

        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([String: Annotation].self, from: data)
        let pruned = decoded.filter { !$0.value.isEmpty }
        cache = pruned
        return pruned
    }

    func annotation(for name: String) throws -> Annotation {
        let all = try load()
        return all[name] ?? Annotation()
    }

    func save(_ annotation: Annotation, for name: String) throws {
        try ensureDirectory()
        var all = try load()

        if annotation.isEmpty {
            all.removeValue(forKey: name)
        } else {
            all[name] = annotation
        }

        let data = try JSONEncoder().encode(all)
        let tmp = url.deletingLastPathComponent()
            .appendingPathComponent(".annotations.tmp.\(UUID().uuidString)")

        try data.write(to: tmp, options: .atomic)
        _ = try FileManager.default.replaceItemAt(url, withItemAt: tmp)
        cache = all
    }

    func remove(for name: String) throws {
        var all = try load()
        all.removeValue(forKey: name)

        try ensureDirectory()
        let data = try JSONEncoder().encode(all)
        let tmp = url.deletingLastPathComponent()
            .appendingPathComponent(".annotations.tmp.\(UUID().uuidString)")

        try data.write(to: tmp, options: .atomic)
        _ = try FileManager.default.replaceItemAt(url, withItemAt: tmp)
        cache = all
    }
}

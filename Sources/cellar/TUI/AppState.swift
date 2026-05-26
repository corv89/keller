import Combine
import Foundation

class AppState: ObservableObject {
    @Published var entries: [ToolEntry] = []
    @Published var selectedIndex: Int = 0
    @Published var filterText: String = ""
    @Published var showDependencies: Bool = false

    var visibleEntries: [ToolEntry] {
        entries
            .filter { showDependencies || $0.formula.installedOnRequest }
            .filter { filterText.isEmpty || matchesFilter($0) }
    }

    var selectedEntry: ToolEntry? {
        let visible = visibleEntries
        guard selectedIndex >= 0, selectedIndex < visible.count else { return nil }
        return visible[selectedIndex]
    }

    var entryCounts: (request: Int, total: Int) {
        let req = entries.filter { $0.formula.installedOnRequest }.count
        return (req, entries.count)
    }

    func clampSelection() {
        let count = visibleEntries.count
        if count == 0 {
            selectedIndex = 0
        } else if selectedIndex >= count {
            selectedIndex = count - 1
        }
    }

    func refresh() {
        let cacheManager = CacheManager()
        try? cacheManager.invalidate()

        do {
            let brewService = BrewService()
            let brewPath = try brewService.brewPath()

            let process = Foundation.Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: brewPath)
            process.arguments = ["info", "--json=v2", "--installed"]
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice

            try process.run()
            let data = try pipe.fileHandleForReading.readToEnd()
            process.waitUntilExit()

            guard process.terminationStatus == 0, let data else { return }

            let response = try JSONDecoder().decode(BrewInfoResponse.self, from: data)
            let formulae = response.formulae.map { $0.toFormula() }
            try? cacheManager.write(formulae)

            let annotations = AnnotationStore.loadSync()

            self.entries = formulae.map { f in
                ToolEntry(formula: f, annotation: annotations[f.name] ?? Annotation())
            }
            self.clampSelection()
        } catch {
            // Keep existing data on refresh failure
        }
    }

    func editSelected() {
        guard let entry = selectedEntry else { return }
        do {
            let edited = try EditorLauncher.edit(entry.annotation, name: entry.formula.name)

            let url = AnnotationStore.defaultURL
            var all = AnnotationStore.loadSync()
            if edited.isEmpty {
                all.removeValue(forKey: entry.formula.name)
            } else {
                all[entry.formula.name] = edited
            }

            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(all)
            let tmp = dir.appendingPathComponent(".annotations.tmp.\(UUID().uuidString)")
            try data.write(to: tmp, options: .atomic)
            _ = try FileManager.default.replaceItemAt(url, withItemAt: tmp)

            if let idx = entries.firstIndex(where: { $0.formula.name == entry.formula.name }) {
                entries[idx].annotation = edited
            }
        } catch {
            // Silently ignore edit failures
        }
    }

    private func matchesFilter(_ entry: ToolEntry) -> Bool {
        let query = filterText.lowercased()
        return entry.formula.name.lowercased().contains(query)
            || (entry.formula.desc?.lowercased().contains(query) ?? false)
            || entry.annotation.tags.contains { $0.lowercased().contains(query) }
            || entry.annotation.notes.lowercased().contains(query)
    }

    static func sampleData() -> [ToolEntry] {
        [
            ToolEntry(formula: Formula(
                name: "git", desc: "Distributed version control system",
                homepage: "https://git-scm.com", installedVersion: "2.45.0",
                installedOnRequest: true, dependencies: ["pcre2"],
                caveats: nil, deprecated: false, disabled: false, outdated: false
            ), annotation: Annotation(notes: "Main VCS", tags: ["vcs", "cli"], examples: ["git log --oneline"])),
            ToolEntry(formula: Formula(
                name: "ripgrep", desc: "Search tool like grep and ag",
                homepage: "https://github.com/BurntSushi/ripgrep",
                installedVersion: "14.1.0", installedOnRequest: true,
                dependencies: [], caveats: nil, deprecated: false,
                disabled: false, outdated: true
            ), annotation: Annotation(tags: ["search"])),
            ToolEntry(formula: Formula(
                name: "fd", desc: "Simple, fast alternative to find",
                homepage: "https://github.com/sharkdp/fd",
                installedVersion: "10.1.0", installedOnRequest: true,
                dependencies: [], caveats: nil, deprecated: false,
                disabled: false, outdated: false
            ), annotation: Annotation()),
            ToolEntry(formula: Formula(
                name: "jq", desc: "Lightweight command-line JSON processor",
                homepage: "https://jqlang.github.io/jq/",
                installedVersion: "1.7.1", installedOnRequest: true,
                dependencies: ["oniguruma"], caveats: nil,
                deprecated: false, disabled: false, outdated: false
            ), annotation: Annotation(notes: "Essential for API work", examples: ["cat file.json | jq '.name'"])),
            ToolEntry(formula: Formula(
                name: "pcre2", desc: "Perl Compatible Regular Expressions",
                homepage: "https://www.pcre.org/", installedVersion: "10.44",
                installedOnRequest: false, dependencies: [],
                caveats: nil, deprecated: false, disabled: false, outdated: false
            ), annotation: Annotation()),
            ToolEntry(formula: Formula(
                name: "oniguruma", desc: "Regular expressions library",
                homepage: "https://github.com/kkos/oniguruma",
                installedVersion: "6.9.9", installedOnRequest: false,
                dependencies: [], caveats: nil, deprecated: true,
                disabled: false, outdated: false
            ), annotation: Annotation()),
        ]
    }
}

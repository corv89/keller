import Combine

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

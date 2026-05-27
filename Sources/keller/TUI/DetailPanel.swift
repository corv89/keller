import SwiftTUI

struct DetailPanel: View {
    @ObservedObject var state: AppState

    private var width: Int { TerminalSize.detailWidth }

    var body: some View {
        VStack(alignment: .leading) {
            if let entry = state.selectedEntry {
                header(entry)
                Divider()
                description(entry)
                if !entry.annotation.notes.isEmpty {
                    Divider()
                    notes(entry)
                }
                if !entry.annotation.tags.isEmpty {
                    tags(entry)
                }
                if !entry.annotation.examples.isEmpty {
                    examples(entry)
                }
                if !entry.formula.dependencies.isEmpty {
                    Divider()
                    dependencies(entry)
                }
                if let caveats = entry.formula.caveats {
                    Divider()
                    caveatsSection(caveats)
                }
                if let homepage = entry.formula.homepage {
                    Spacer()
                    homepageSection(homepage)
                }
            } else {
                Text("No formula selected")
            }
            Spacer()
        }
    }

    private func header(_ entry: ToolEntry) -> some View {
        HStack {
            Text(entry.formula.name).bold()
            if let v = entry.formula.installedVersion {
                Text("(\(v))").foregroundColor(.gray)
            }
            if entry.formula.outdated {
                Text("[outdated]").foregroundColor(.blue)
            }
            if entry.formula.deprecated {
                Text("[deprecated]").foregroundColor(.yellow)
            }
            if entry.formula.disabled {
                Text("[disabled]").foregroundColor(.red)
            }
            if !entry.formula.installedOnRequest {
                Text("[dep]").foregroundColor(.gray)
            }
        }
    }

    private func description(_ entry: ToolEntry) -> some View {
        let text = entry.formula.desc ?? "No description available"
        return wrappedText(text)
    }

    private func notes(_ entry: ToolEntry) -> some View {
        VStack(alignment: .leading) {
            Text("Notes:").bold()
            wrappedText(entry.annotation.notes)
        }
    }

    private func tags(_ entry: ToolEntry) -> some View {
        let joined = entry.annotation.tags.joined(separator: ", ")
        return VStack(alignment: .leading) {
            HStack {
                Text("Tags:").bold()
                if let first = wrapLines(joined, width: width - 6).first {
                    Text(first).foregroundColor(.cyan)
                }
            }
            ForEach(Array(wrapLines(joined, width: width - 6).dropFirst()), id: \.self) { line in
                Text("      " + line).foregroundColor(.cyan)
            }
        }
    }

    private func examples(_ entry: ToolEntry) -> some View {
        VStack(alignment: .leading) {
            Text("Examples:").bold()
            ForEach(entry.annotation.examples, id: \.self) { ex in
                let lines = wrapLines("  " + ex, width: width)
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line).foregroundColor(.green)
                }
            }
        }
    }

    private func dependencies(_ entry: ToolEntry) -> some View {
        let joined = entry.formula.dependencies.joined(separator: ", ")
        return VStack(alignment: .leading) {
            HStack {
                Text("Deps:").bold()
                if let first = wrapLines(joined, width: width - 6).first {
                    Text(first).foregroundColor(.gray)
                }
            }
            ForEach(Array(wrapLines(joined, width: width - 6).dropFirst()), id: \.self) { line in
                Text("      " + line).foregroundColor(.gray)
            }
        }
    }

    private func caveatsSection(_ caveats: String) -> some View {
        VStack(alignment: .leading) {
            Text("Caveats:").bold().foregroundColor(.yellow)
            wrappedText(caveats)
        }
    }

    private func homepageSection(_ url: String) -> some View {
        Text(truncateTo(url, width: width)).foregroundColor(.blue).underline()
    }

    private func wrappedText(_ text: String) -> some View {
        let lines = wrapLines(text, width: width)
        return VStack(alignment: .leading) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
            }
        }
    }
}

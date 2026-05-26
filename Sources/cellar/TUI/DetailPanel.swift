import SwiftTUI

struct DetailPanel: View {
    @ObservedObject var state: AppState

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
        Text(entry.formula.desc ?? "No description available")
    }

    private func notes(_ entry: ToolEntry) -> some View {
        VStack(alignment: .leading) {
            Text("Notes:").bold()
            Text(entry.annotation.notes)
        }
    }

    private func tags(_ entry: ToolEntry) -> some View {
        HStack {
            Text("Tags:").bold()
            Text(entry.annotation.tags.joined(separator: ", "))
                .foregroundColor(.cyan)
        }
    }

    private func examples(_ entry: ToolEntry) -> some View {
        VStack(alignment: .leading) {
            Text("Examples:").bold()
            ForEach(entry.annotation.examples, id: \.self) { ex in
                Text("  \(ex)").foregroundColor(.green)
            }
        }
    }

    private func dependencies(_ entry: ToolEntry) -> some View {
        HStack {
            Text("Deps:").bold()
            Text(entry.formula.dependencies.joined(separator: ", "))
                .foregroundColor(.gray)
        }
    }

    private func caveatsSection(_ caveats: String) -> some View {
        VStack(alignment: .leading) {
            Text("Caveats:").bold().foregroundColor(.yellow)
            Text(caveats)
        }
    }

    private func homepageSection(_ url: String) -> some View {
        Text(url).foregroundColor(.blue).underline()
    }
}

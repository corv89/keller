import SwiftTUI

struct DetailPanel: View {
    @ObservedObject var state: AppState

    private var width: Int { TerminalSize.detailWidth }
    private var labelCol: Extended { 12 }

    var body: some View {
        VStack(alignment: .leading) {
            if let entry = state.selectedEntry {
                header(entry)
                Divider()
                description(entry)
                VStack(alignment: .leading, spacing: 1) {
                    if !entry.annotation.notes.isEmpty {
                        labeledBlock("Notes:", content: entry.annotation.notes)
                    }
                    if !entry.annotation.tags.isEmpty {
                        tags(entry)
                    }
                    if !entry.annotation.examples.isEmpty {
                        examples(entry)
                    }
                    if !entry.formula.dependencies.isEmpty {
                        labeledBlock(
                            "Deps:",
                            content: entry.formula.dependencies.joined(separator: ", ")
                        )
                    }
                    if let caveats = entry.formula.caveats {
                        labeledBlock("Caveats:", labelColor: .yellow, content: caveats)
                    }
                    if let homepage = entry.formula.homepage {
                        homepageSection(homepage)
                    }
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
        wrappedText(entry.formula.desc ?? "No description available")
    }

    private func tags(_ entry: ToolEntry) -> some View {
        let joined = entry.annotation.tags.joined(separator: ", ")
        return labeledBlock("Tags:", content: joined)
    }

    private func examples(_ entry: ToolEntry) -> some View {
        let contentWidth = width - 12
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("Examples:").foregroundColor(.gray)
                    .frame(width: labelCol, alignment: .leading)
                Text("")
            }
            ForEach(Array(entry.annotation.examples.enumerated()), id: \.offset) { _, ex in
                let lines = wrapLines(ex, width: contentWidth)
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    HStack(spacing: 0) {
                        Text("").frame(width: labelCol)
                        Text(line)
                    }
                }
            }
        }
    }

    private func homepageSection(_ url: String) -> some View {
        HStack(spacing: 0) {
            Text("Homepage:").foregroundColor(.gray)
                .frame(width: labelCol, alignment: .leading)
            Text(truncateTo(url, width: width - 12)).foregroundColor(.blue).underline()
        }
    }

    private func labeledBlock(
        _ label: String,
        labelColor: Color = .gray,
        content: String
    ) -> some View {
        let contentWidth = width - 12
        let lines = wrapLines(content, width: contentWidth)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(label).foregroundColor(labelColor)
                    .frame(width: labelCol, alignment: .leading)
                Text(lines.first ?? "")
            }
            ForEach(Array(lines.dropFirst()), id: \.self) { line in
                HStack(spacing: 0) {
                    Text("").frame(width: labelCol)
                    Text(line)
                }
            }
        }
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

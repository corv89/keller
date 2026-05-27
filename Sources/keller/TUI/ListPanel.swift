import SwiftTUI

struct ListPanel: View {
    @ObservedObject var state: AppState

    private var height: Int { TerminalSize.rows - 2 }

    var body: some View {
        let entries = state.visibleEntries
        let start = state.scrollOffset
        let end = min(start + height, entries.count)
        return VStack {
            ForEach(start..<end, id: \.self) { i in
                let entry = entries[i]
                Text(entry.formula.name)
                    .foregroundColor(i == state.selectedIndex ? .black : colorForEntry(entry))
                    .background(i == state.selectedIndex ? .white : .default)
                    .frame(width: 28)
            }
        }
    }

    private func colorForEntry(_ entry: ToolEntry) -> Color {
        if !entry.formula.installedOnRequest {
            return .gray
        }
        if entry.formula.deprecated {
            return .yellow
        }
        if entry.formula.disabled {
            return .red
        }
        return .default
    }
}

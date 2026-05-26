import SwiftTUI

struct ListPanel: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack {
            ForEach(Array(state.visibleEntries.enumerated()), id: \.element.id) { index, entry in
                Button(entry.formula.name, hover: {
                    state.selectedIndex = index
                }) {
                    state.selectedIndex = index
                }
                .foregroundColor(colorForEntry(entry))
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

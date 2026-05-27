import SwiftTUI

struct ListPanel: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack {
            ForEach(Array(state.visibleEntries.enumerated()), id: \.element.id) { index, entry in
                Text(entry.formula.name)
                    .foregroundColor(index == state.selectedIndex ? .black : colorForEntry(entry))
                    .background(index == state.selectedIndex ? .white : .default)
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

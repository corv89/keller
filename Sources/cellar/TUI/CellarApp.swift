import SwiftTUI

struct CellarApp: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            filterBar

            HStack(spacing: 1) {
                ScrollView {
                    ListPanel(state: state)
                }
                .frame(width: 28)

                DetailPanel(state: state)
            }

            ActionBar(
                state: state,
                onRefresh: { state.refresh() },
                onToggleDeps: { state.showDependencies.toggle() },
                onEdit: { state.editSelected() }
            )
        }
    }

    private var headerBar: some View {
        HStack {
            Text("cellar").bold()
            Text(countLabel).foregroundColor(.gray)
            Spacer()
        }
    }

    private var filterBar: some View {
        HStack {
            Text("Filter:").foregroundColor(.gray)
            TextField(placeholder: state.filterText.isEmpty ? "type to filter, Enter to apply" : state.filterText) { text in
                state.filterText = text
                state.clampSelection()
            }
            Spacer()
        }
    }

    private var countLabel: String {
        let counts = state.entryCounts
        let visible = state.visibleEntries.count
        let filter = state.filterText.isEmpty ? "" : " filter:\(state.filterText)"
        if state.showDependencies {
            return "(\(visible)/\(counts.total))\(filter)"
        }
        return "(\(visible)/\(counts.request) explicit)\(filter)"
    }
}

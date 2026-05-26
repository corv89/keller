import SwiftTUI

struct CellarApp: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            headerBar

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
                onToggleDeps: { state.showDependencies.toggle() }
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

    private var countLabel: String {
        let counts = state.entryCounts
        let visible = state.visibleEntries.count
        if state.showDependencies {
            return "(\(visible)/\(counts.total) formulae)"
        }
        return "(\(visible)/\(counts.request) explicit)"
    }
}

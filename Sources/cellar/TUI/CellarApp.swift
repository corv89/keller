import Foundation
import SwiftTUI

struct CellarApp: View {
    @ObservedObject var state: AppState
    @State var showHelp = false

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            filterBar

            HStack(spacing: 1) {
                ScrollView {
                    ListPanel(state: state)
                }
                .frame(width: 28)

                ZStack {
                    DetailPanel(state: state)
                    HelpOverlay(visible: showHelp)
                }
            }

            statusBar
        }
    }

    private var headerBar: some View {
        HStack {
            Text("cellar").bold()
            Text(countLabel).foregroundColor(.gray)
            Spacer()
            Button("Toggle Deps", action: { state.showDependencies.toggle() })
            Button("Edit", action: { state.editSelected() })
            Button("Refresh", action: { state.refresh() })
            Button("Clear Filter", action: { state.filterText = ""; state.clampSelection() })
            Button("Help", action: { showHelp.toggle() })
            Button("Quit") { exit(0) }
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

    private var statusBar: some View {
        HStack {
            Text(depsLabel).foregroundColor(.gray)
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

    private var depsLabel: String {
        state.showDependencies ? "Showing all formulae" : "Showing explicit only"
    }
}

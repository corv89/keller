import Foundation
import SwiftTUI

struct ActionBar: View {
    @ObservedObject var state: AppState
    let onRefresh: () -> Void
    let onToggleDeps: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Button("Toggle Deps", action: onToggleDeps)
            Button("Edit", action: onEdit)
            Button("Refresh", action: onRefresh)
            Button("Clear Filter", action: { state.filterText = ""; state.clampSelection() })
            Button("Quit") { exit(0) }
            Spacer()
            Text(depsLabel).foregroundColor(.gray)
        }
    }

    private var depsLabel: String {
        state.showDependencies ? "Showing all formulae" : "Showing explicit only"
    }
}

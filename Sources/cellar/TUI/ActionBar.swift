import Foundation
import SwiftTUI

struct ActionBar: View {
    @ObservedObject var state: AppState
    let onRefresh: () -> Void
    let onToggleDeps: () -> Void

    var body: some View {
        HStack {
            Button("Toggle Deps", action: onToggleDeps)
            Button("Refresh", action: onRefresh)
            Button("Quit") { exit(0) }
            Spacer()
            Text(depsLabel).foregroundColor(.gray)
        }
    }

    private var depsLabel: String {
        state.showDependencies ? "Showing all formulae" : "Showing explicit only"
    }
}

import SwiftTUI

struct CellarApp: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 1) {
                ScrollView {
                    ListPanel(state: state)
                }
                .frame(width: 28)

                DetailPanel(state: state)
            }

            ActionBar(
                state: state,
                onRefresh: {},
                onToggleDeps: { state.showDependencies.toggle() }
            )
        }
    }
}

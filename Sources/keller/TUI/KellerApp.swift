import Foundation
import SwiftTUI

struct KellerApp: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            HStack(spacing: 1) {
                ListPanel(state: state)
                    .frame(width: 28)

                ZStack {
                    DetailPanel(state: state)
                    HelpOverlay(visible: state.showHelp)
                }
            }

            bottomBar
        }
    }

    private var headerBar: some View {
        HStack {
            Text("keller").bold()
            Text(state.countLabel).foregroundColor(.gray)
            Spacer()
            Text("Deps").foregroundColor(state.showDependencies ? .green : .gray)
            Text(" ^R Refresh ↵ Edit ^H Help ^Q Quit").foregroundColor(.gray)
        }
    }

    private var bottomBar: some View {
        HStack {
            if state.filterText.isEmpty {
                Text("filter…").foregroundColor(.gray)
            } else {
                Text(state.filterText)
            }
            Spacer()
        }
    }
}

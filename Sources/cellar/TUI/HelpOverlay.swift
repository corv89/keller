import SwiftTUI

struct HelpOverlay: View {
    let visible: Bool

    var body: some View {
        if visible {
            VStack(alignment: .leading) {
                Text("cellar — Keybindings").bold()
                Divider()
                VStack(alignment: .leading) {
                    helpRow("Arrow Up/Down", "Navigate formula list")
                    helpRow("Arrow Left/Right", "Move between panels")
                    helpRow("Enter", "Activate focused control")
                    helpRow("Toggle Deps", "Show/hide transitive deps")
                }
                Divider()
                VStack(alignment: .leading) {
                    helpRow("Edit", "Open $EDITOR for annotation")
                    helpRow("Refresh", "Re-fetch brew metadata")
                    helpRow("Clear Filter", "Remove active filter")
                    helpRow("Help", "Toggle this overlay")
                    helpRow("Quit / Ctrl-C", "Exit cellar")
                }
                Spacer()
                Text("Navigate to Help to close").foregroundColor(.gray)
            }
            .padding()
            .border()
        }
    }

    private func helpRow(_ key: String, _ desc: String) -> some View {
        HStack {
            Text(key).foregroundColor(.cyan).frame(width: 22)
            Text(desc)
        }
    }
}

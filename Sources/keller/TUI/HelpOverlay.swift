import SwiftTUI

struct HelpOverlay: View {
    let visible: Bool

    var body: some View {
        if visible {
            VStack(alignment: .leading) {
                Text("keller — Keybindings").bold()
                Divider()
                VStack(alignment: .leading) {
                    helpRow("↑/↓", "Navigate list")
                    helpRow("type", "Filter formulae (live)")
                    helpRow("⌫", "Delete filter character")
                    helpRow("^U", "Clear filter")
                    helpRow("↵", "Edit annotation in $EDITOR")
                }
                Divider()
                VStack(alignment: .leading) {
                    helpRow("^T", "Toggle deps")
                    helpRow("^R", "Refresh brew data")
                    helpRow("^H", "Toggle this help")
                    helpRow("^Q / ^C", "Quit")
                }
                Spacer()
                Text("Press ^H to close").foregroundColor(.gray)
            }
            .padding()
            .border()
        }
    }

    private func helpRow(_ key: String, _ desc: String) -> some View {
        HStack {
            Text(key).foregroundColor(.cyan).frame(width: 12)
            Text(desc)
        }
    }
}

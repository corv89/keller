import Foundation

enum TerminalSize {
    static var columns: Int {
        var w = winsize()
        guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w) == 0, w.ws_col > 0 else { return 80 }
        return Int(w.ws_col)
    }

    static var detailWidth: Int {
        max(columns - 29, 20)
    }
}

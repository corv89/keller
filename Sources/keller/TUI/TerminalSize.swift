import Foundation

enum TerminalSize {
    static var columns: Int {
        var w = winsize()
        guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w) == 0, w.ws_col > 0 else { return 80 }
        return Int(w.ws_col)
    }

    static var rows: Int {
        var w = winsize()
        guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w) == 0, w.ws_row > 0 else { return 24 }
        return Int(w.ws_row)
    }

    static var detailWidth: Int {
        max(columns - 29, 20)
    }
}

enum TerminalTeardown {
    static func restore() {
        var tattr = termios()
        tcgetattr(STDIN_FILENO, &tattr)
        tattr.c_lflag |= tcflag_t(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
        FileHandle.standardOutput.write(Data("\u{1B}[?1049l\u{1B}[?25h".utf8))
    }
}

enum TerminalSuspend {
    static func forEditor() {
        var tattr = termios()
        tcgetattr(STDIN_FILENO, &tattr)
        tattr.c_lflag |= tcflag_t(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
        FileHandle.standardOutput.write(Data("\u{1B}[?1049l\u{1B}[?25h".utf8))
    }

    static func resume() {
        FileHandle.standardOutput.write(Data("\u{1B}[?1049h\u{1B}[?25l".utf8))
        var tattr = termios()
        tcgetattr(STDIN_FILENO, &tattr)
        tattr.c_lflag &= ~tcflag_t(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
    }
}

import Foundation
#if os(macOS)
import AppKit
#endif

open class Application {
    private let node: Node
    private let window: Window
    private let control: Control
    private let renderer: Renderer

    private let runLoopType: RunLoopType

    private var arrowKeyParser = ArrowKeyParser()

    public var onKey: ((Key) -> Bool)?

    private var invalidatedNodes: [Node] = []
    private var updateScheduled = false

    public init<I: View>(rootView: I, runLoopType: RunLoopType = .dispatch) {
        self.runLoopType = runLoopType

        node = Node(view: VStack(content: rootView).view)
        node.build()

        control = node.control!

        window = Window()
        window.addControl(control)

        window.firstResponder = control.firstSelectableElement
        window.firstResponder?.becomeFirstResponder()

        renderer = Renderer(layer: window.layer)
        window.layer.renderer = renderer

        node.application = self
        renderer.application = self
    }

    var stdInSource: DispatchSourceRead?

    public enum RunLoopType {
        /// The default option, using Dispatch for the main run loop.
        case dispatch

        #if os(macOS)
        /// This creates and runs an NSApplication with an associated run loop. This allows you
        /// e.g. to open NSWindows running simultaneously to the terminal app. This requires macOS
        /// and AppKit.
        case cocoa
        #endif
    }

    public func start() {
        setInputMode()
        updateWindowSize()
        control.layout(size: window.layer.frame.size)
        renderer.draw()

        let stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
        stdInSource.setEventHandler(qos: .default, flags: [], handler: self.handleInput)
        stdInSource.resume()
        self.stdInSource = stdInSource

        let sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
        sigWinChSource.setEventHandler(qos: .default, flags: [], handler: self.handleWindowSizeChange)
        sigWinChSource.resume()

        signal(SIGINT, SIG_IGN)
        let sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        sigIntSource.setEventHandler(qos: .default, flags: [], handler: self.stop)
        sigIntSource.resume()

        switch runLoopType {
        case .dispatch:
            dispatchMain()
        #if os(macOS)
        case .cocoa:
            NSApplication.shared.setActivationPolicy(.accessory)
            NSApplication.shared.run()
        #endif
        }
    }

    private func setInputMode() {
        var tattr = termios()
        tcgetattr(STDIN_FILENO, &tattr)
        tattr.c_lflag &= ~tcflag_t(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr);
    }

    private func handleInput() {
        let data = FileHandle.standardInput.availableData

        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        for char in string {
            if arrowKeyParser.parse(character: char) {
                guard let arrowKey = arrowKeyParser.arrowKey else { continue }
                arrowKeyParser.arrowKey = nil
                if onKey?(.arrow(arrowKey.direction)) == true { continue }
                handleArrowKey(arrowKey)
            } else if char == ASCII.EOT {
                stop()
                return
            } else {
                let key = keyFrom(char: char)
                if onKey?(key) == true { continue }
                window.firstResponder?.handleEvent(char)
            }
        }
    }

    private func handleArrowKey(_ key: ArrowKeyParser.ArrowKey) {
        switch key {
        case .down:
            if let next = window.firstResponder?.selectableElement(below: 0) {
                window.firstResponder?.resignFirstResponder()
                window.firstResponder = next
                window.firstResponder?.becomeFirstResponder()
            }
        case .up:
            if let next = window.firstResponder?.selectableElement(above: 0) {
                window.firstResponder?.resignFirstResponder()
                window.firstResponder = next
                window.firstResponder?.becomeFirstResponder()
            }
        case .right:
            if let next = window.firstResponder?.selectableElement(rightOf: 0) {
                window.firstResponder?.resignFirstResponder()
                window.firstResponder = next
                window.firstResponder?.becomeFirstResponder()
            }
        case .left:
            if let next = window.firstResponder?.selectableElement(leftOf: 0) {
                window.firstResponder?.resignFirstResponder()
                window.firstResponder = next
                window.firstResponder?.becomeFirstResponder()
            }
        }
    }

    private func keyFrom(char: Character) -> Key {
        let v = char.asciiValue ?? 0
        if v == 0x0A {
            return .enter
        }
        if v == 0x7F {
            return .backspace
        }
        if v >= 0x01 && v <= 0x1A {
            return .ctrl(Character(UnicodeScalar(Int(v) + 0x60)!))
        }
        return .char(char)
    }

    func invalidateNode(_ node: Node) {
        invalidatedNodes.append(node)
        scheduleUpdate()
    }

    func scheduleUpdate() {
        if !updateScheduled {
            DispatchQueue.main.async { self.update() }
            updateScheduled = true
        }
    }

    private func update() {
        updateScheduled = false

        for node in invalidatedNodes {
            node.update(using: node.view)
        }
        invalidatedNodes = []

        control.layout(size: window.layer.frame.size)
        renderer.update()
    }

    private func handleWindowSizeChange() {
        updateWindowSize()
        control.layer.invalidate()
        update()
    }

    private func updateWindowSize() {
        var size = winsize()
        guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0,
              size.ws_col > 0, size.ws_row > 0 else {
            assertionFailure("Could not get window size")
            return
        }
        window.layer.frame.size = Size(width: Extended(Int(size.ws_col)), height: Extended(Int(size.ws_row)))
        renderer.setCache()
    }

    private func stop() {
        renderer.stop()
        resetInputMode() // Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
        exit(0)
    }

    public func suspendInput() {
        stdInSource?.suspend()
    }

    public func resumeInput() {
        stdInSource?.resume()
    }

    public func forceRedraw() {
        renderer.setCache()
        renderer.draw()
    }

    /// Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
    private func resetInputMode() {
        // Reset ECHO and ICANON values:
        var tattr = termios()
        tcgetattr(STDIN_FILENO, &tattr)
        tattr.c_lflag |= tcflag_t(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr);
    }

}

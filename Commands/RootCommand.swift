import ArgumentParser

struct RootCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cellar",
        abstract: "Launch the cellar TUI (default)."
    )

    func run() throws {
        print("cellar: TUI not yet implemented")
    }
}

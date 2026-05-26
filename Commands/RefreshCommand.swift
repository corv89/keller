import ArgumentParser

struct RefreshCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "refresh",
        abstract: "Force rebuild the brew metadata cache."
    )

    func run() throws {
        print("cellar refresh: not yet implemented")
    }
}

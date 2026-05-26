import ArgumentParser

struct EditCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Open $EDITOR on one formula's annotation."
    )

    @Argument(help: "Name of the Homebrew formula to annotate.")
    var name: String

    func run() throws {
        print("cellar edit \(name): not yet implemented")
    }
}

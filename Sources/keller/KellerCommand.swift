import ArgumentParser
import Foundation
import SwiftTUI

@main
struct Keller: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "keller",
        abstract: "A browsable, annotatable overview of your Homebrew CLI tools.",
        subcommands: [EditCommand.self, RefreshCommand.self]
    )

    func run() throws {
        let state = AppState.loadFromCacheOrFetch()
        let app = Application(rootView: KellerApp(state: state))
        app.onKey = { key in state.handleKey(key) }
        app.start()
    }
}

extension AppState {
    static func loadFromCacheOrFetch() -> AppState {
        let cacheManager = CacheManager()

        let formulae: [Formula]
        if let cached = cacheManager.loadIfFresh() {
            formulae = cached
        } else {
            do {
                formulae = try BrewService().fetchInstalledFormulaeSync()
                try? cacheManager.write(formulae)
            } catch {
                let state = AppState()
                state.entries = sampleData()
                return state
            }
        }

        let annotations = AnnotationStore.loadSync()

        let state = AppState()
        state.entries = formulae.map { f in
            ToolEntry(formula: f, annotation: annotations[f.name] ?? Annotation())
        }
        return state
    }
}

import ArgumentParser
import SwiftTUI

@main
struct Cellar: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cellar",
        abstract: "A browsable, annotatable overview of your Homebrew CLI tools.",
        subcommands: [EditCommand.self, RefreshCommand.self]
    )

    func run() async throws {
        let state = await AppState.loadFromCacheOrFetch()
        Application(rootView: CellarApp(state: state)).start()
    }
}

extension AppState {
    static func loadFromCacheOrFetch() async -> AppState {
        let cacheManager = CacheManager()

        let formulae: [Formula]
        if let cached = cacheManager.loadIfFresh() {
            formulae = cached
        } else {
            do {
                formulae = try await BrewService().fetchInstalledFormulae()
                try? cacheManager.write(formulae)
            } catch {
                formulae = sampleData().map { $0.formula }
            }
        }

        let annotations = (try? await AnnotationStore().load()) ?? [:]
        let entries = formulae.map { f in
            ToolEntry(formula: f, annotation: annotations[f.name] ?? Annotation())
        }

        let state = AppState()
        state.entries = entries
        return state
    }
}

import ArgumentParser
import Foundation
import SwiftTUI

@main
struct Cellar: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cellar",
        abstract: "A browsable, annotatable overview of your Homebrew CLI tools.",
        subcommands: [EditCommand.self, RefreshCommand.self]
    )

    func run() async throws {
        let state = AppState.loadFromCacheOrFetch()
        Application(rootView: CellarApp(state: state)).start()
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
                let process = Foundation.Process()
                let pipe = Pipe()
                let brewPath = try BrewService().brewPath()
                process.executableURL = URL(fileURLWithPath: brewPath)
                process.arguments = ["info", "--json=v2", "--installed"]
                process.standardOutput = pipe
                process.standardError = FileHandle.nullDevice
                try process.run()
                let data = try pipe.fileHandleForReading.readToEnd()
                process.waitUntilExit()

                guard process.terminationStatus == 0, let data else {
                    formulae = sampleData().map { $0.formula }
                    let state = AppState()
                    state.entries = sampleData()
                    return state
                }

                let response = try JSONDecoder().decode(BrewInfoResponse.self, from: data)
                formulae = response.formulae.map { $0.toFormula() }
                try? cacheManager.write(formulae)
            } catch {
                formulae = sampleData().map { $0.formula }
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

import ArgumentParser
import Foundation

struct RefreshCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "refresh",
        abstract: "Force rebuild the brew metadata cache."
    )

    func run() throws {
        let cacheManager = CacheManager()
        try cacheManager.invalidate()

        let formulae = try BrewService().fetchInstalledFormulaeSync()
        try cacheManager.write(formulae)

        let onRequest = formulae.filter { $0.installedOnRequest }.count
        print("Refreshed: \(formulae.count) formulae (\(onRequest) explicitly installed).")
    }
}

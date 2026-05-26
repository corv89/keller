import ArgumentParser

struct RefreshCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "refresh",
        abstract: "Force rebuild the brew metadata cache."
    )

    func run() async throws {
        let brewService = BrewService()
        let cacheManager = CacheManager()

        try cacheManager.invalidate()

        let formulae = try await brewService.fetchInstalledFormulae()
        try cacheManager.write(formulae)

        let onRequest = formulae.filter { $0.installedOnRequest }.count
        print("Refreshed: \(formulae.count) formulae (\(onRequest) explicitly installed).")
    }
}

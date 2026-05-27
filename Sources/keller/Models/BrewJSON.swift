import Foundation

struct BrewInfoResponse: Decodable, Sendable {
    let formulae: [BrewFormula]
}

struct BrewFormula: Decodable, Sendable {
    let name: String
    let desc: String?
    let homepage: String?
    let dependencies: [String]
    let caveats: String?
    let deprecated: Bool
    let disabled: Bool
    let outdated: Bool
    let installed: [BrewInstalled]

    struct BrewInstalled: Decodable, Sendable {
        let version: String
        let installedOnRequest: Bool

        enum CodingKeys: String, CodingKey {
            case version
            case installedOnRequest = "installed_on_request"
        }
    }
}

extension BrewFormula {
    func toFormula() -> Formula {
        Formula(
            name: name,
            desc: desc,
            homepage: homepage,
            installedVersion: installed.last?.version,
            installedOnRequest: installed.last?.installedOnRequest ?? false,
            dependencies: dependencies,
            caveats: caveats,
            deprecated: deprecated,
            disabled: disabled,
            outdated: outdated
        )
    }
}

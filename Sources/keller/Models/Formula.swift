import Foundation

struct Formula: Codable, Equatable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let desc: String?
    let homepage: String?
    let installedVersion: String?
    let installedOnRequest: Bool
    let dependencies: [String]
    let caveats: String?
    let deprecated: Bool
    let disabled: Bool
    let outdated: Bool
}

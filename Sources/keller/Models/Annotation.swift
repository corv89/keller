import Foundation

struct Annotation: Codable, Equatable, Sendable {
    var notes: String = ""
    var tags: [String] = []
    var examples: [String] = []

    var isEmpty: Bool {
        notes.isEmpty && tags.isEmpty && examples.isEmpty
    }
}

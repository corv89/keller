import Foundation

struct ToolEntry: Identifiable {
    var id: String { formula.name }
    let formula: Formula
    var annotation: Annotation
}

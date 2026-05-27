import Foundation

func wrapLines(_ text: String, width: Int) -> [String] {
    guard width > 0 else { return [text] }
    let inputLines = text.components(separatedBy: "\n")
    var result: [String] = []
    for inputLine in inputLines {
        guard !inputLine.isEmpty else {
            result.append("")
            continue
        }
        var current = ""
        let words = inputLine.split(separator: " ", omittingEmptySubsequences: false)
        for word in words {
            if current.isEmpty {
                current = String(word)
            } else if current.count + 1 + word.count <= width {
                current += " " + word
            } else {
                result.append(current)
                current = String(word)
            }
            while current.count > width {
                result.append(String(current.prefix(width)))
                current = String(current.dropFirst(width))
            }
        }
        if !current.isEmpty {
            result.append(current)
        }
    }
    return result.isEmpty ? [""] : result
}

func truncateTo(_ text: String, width: Int) -> String {
    guard text.count > width, width > 1 else { return text }
    return String(text.prefix(width - 1)) + "\u{2026}"
}

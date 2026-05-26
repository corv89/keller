import Foundation

struct EditorLauncher {
    static func edit(_ annotation: Annotation, name: String) throws -> Annotation {
        let editor = ProcessInfo.processInfo.environment["EDITOR"]
            ?? ProcessInfo.processInfo.environment["VISUAL"]
            ?? "vi"

        let template = buildTemplate(name: name, annotation: annotation)

        let tmpDir = FileManager.default.temporaryDirectory
        let tmpFile = tmpDir.appendingPathComponent("cellar-\(name)-annotation.md")
        try template.write(to: tmpFile, atomically: true, encoding: .utf8)

        let process = Foundation.Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [editor, tmpFile.path]
        process.standardInput = FileHandle.standardInput
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw EditorError.editorFailed(exitCode: process.terminationStatus)
        }

        let edited = try String(contentsOf: tmpFile, encoding: .utf8)
        try? FileManager.default.removeItem(at: tmpFile)

        return parseTemplate(edited, fallback: annotation)
    }

    static func buildTemplate(name: String, annotation: Annotation) -> String {
        var lines: [String] = []
        lines.append("---")
        lines.append("tags: [\(annotation.tags.joined(separator: ", "))]")
        lines.append("examples:")
        for ex in annotation.examples {
            lines.append("  - \"\(ex)\"")
        }
        if annotation.examples.isEmpty {
            lines.append("  # - \"example command here\"")
        }
        lines.append("---")
        lines.append("")
        lines.append("<!-- cellar: annotation for \(name) -->")
        lines.append("<!-- Edit freely below. YAML front-matter for tags/examples. -->")
        lines.append(annotation.notes.isEmpty ? "" : annotation.notes)
        return lines.joined(separator: "\n")
    }

    static func parseTemplate(_ content: String, fallback: Annotation) -> Annotation {
        var annotation = Annotation()

        let parts = content.components(separatedBy: "---")
        guard parts.count >= 3 else {
            annotation.notes = content.trimmingCharacters(in: .whitespacesAndNewlines)
            return annotation
        }

        let yaml = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let body = parts[2...].joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)

        let lines = yaml.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("tags:") {
                let tagsStr = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
                let inner = tagsStr.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                annotation.tags = inner
                    .components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            } else if trimmed.hasPrefix("- \"") || trimmed.hasPrefix("- '") {
                let afterPrefix = String(trimmed.dropFirst(2))
                let quoteChar = afterPrefix.first!
                let inner = String(afterPrefix.dropFirst())
                if let closingRange = inner.range(of: String(quoteChar)) {
                    let value = String(inner[inner.startIndex..<closingRange.lowerBound])
                    annotation.examples.append(value)
                }
            }
        }

        let cleanBody = body
            .components(separatedBy: "\n")
            .filter { !$0.hasPrefix("<!--") }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        annotation.notes = cleanBody

        return annotation
    }
}

enum EditorError: Error, LocalizedError {
    case editorFailed(exitCode: Int32)

    var errorDescription: String? {
        switch self {
        case .editorFailed(let code):
            "Editor exited with code \(code)"
        }
    }
}
